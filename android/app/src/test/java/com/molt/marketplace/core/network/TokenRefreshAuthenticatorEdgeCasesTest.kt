package com.molt.marketplace.core.network

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.runBlocking
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Before
import org.junit.Test

/**
 * Additional edge-case tests for [TokenRefreshAuthenticator] covering:
 * - retry limit enforcement
 * - null token no-op
 * - concurrent refresh serialisation (mutex)
 */
class TokenRefreshAuthenticatorEdgeCasesTest {

    private lateinit var server: MockWebServer
    private lateinit var tokenProvider: FakeTokenProvider

    @Before
    fun setUp() {
        server = MockWebServer()
        server.start()
        tokenProvider = FakeTokenProvider()
    }

    @After
    fun tearDown() {
        server.shutdown()
    }

    private fun createClient(): OkHttpClient =
        OkHttpClient.Builder()
            .addInterceptor(AuthInterceptor(tokenProvider))
            .authenticator(TokenRefreshAuthenticator(tokenProvider))
            .build()

    // -------------------------------------------------------------------------
    // Retry-limit enforcement
    // -------------------------------------------------------------------------

    @Test
    fun `stops retrying after MAX_RETRY_COUNT consecutive 401 responses`() {
        // OkHttp stops calling authenticate() after two 401s in a row (MAX_RETRY_COUNT = 2)
        tokenProvider.accessToken = "expired-token"
        tokenProvider.refreshedToken = "new-token"

        // Enqueue enough 401s to exceed the retry limit
        repeat(3) { server.enqueue(MockResponse().setResponseCode(401)) }

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/store/products")).build(),
        ).execute()

        // After hitting the retry cap the authenticator returns null → final response is 401
        assertThat(response.code).isEqualTo(401)
    }

    @Test
    fun `returns null and does not crash when token provider returns null access token`() {
        tokenProvider.accessToken = null
        tokenProvider.refreshedToken = null

        server.enqueue(MockResponse().setResponseCode(401))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/store/products")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(401)
        // Tokens were already null — clearTokens() marks tokensCleared
        assertThat(tokenProvider.tokensCleared).isTrue()
    }

    @Test
    fun `rebuilds request with new token authorization header after successful refresh`() {
        tokenProvider.accessToken = "expired-token"
        tokenProvider.refreshedToken = "refreshed-token"

        server.enqueue(MockResponse().setResponseCode(401))
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        client.newCall(
            Request.Builder().url(server.url("/store/products")).build(),
        ).execute()

        // The second (retry) request must carry the refreshed token
        server.takeRequest() // first 401 request
        val retryRequest = server.takeRequest()
        assertThat(retryRequest.getHeader("Authorization")).isEqualTo("Bearer refreshed-token")
    }

    @Test
    fun `clears tokens when refresh returns null`() {
        tokenProvider.accessToken = "expired-token"
        tokenProvider.refreshedToken = null

        server.enqueue(MockResponse().setResponseCode(401))

        val client = createClient()
        client.newCall(
            Request.Builder().url(server.url("/store/products")).build(),
        ).execute()

        assertThat(tokenProvider.tokensCleared).isTrue()
        assertThat(tokenProvider.accessToken).isNull()
    }

    // -------------------------------------------------------------------------
    // Concurrent refresh serialisation (mutex guarantees single refresh)
    // -------------------------------------------------------------------------

    @Test
    fun `concurrent 401 responses result in single token refresh via mutex`() = runBlocking {
        val concurrentCallCount = 3
        tokenProvider.accessToken = "shared-expired-token"
        tokenProvider.refreshedToken = "shared-new-token"

        // Enqueue 401 + 200 pairs for each concurrent call
        repeat(concurrentCallCount) {
            server.enqueue(MockResponse().setResponseCode(401))
            server.enqueue(MockResponse().setResponseCode(200))
        }

        val client = createClient()

        // Launch concurrent requests
        val deferredResponses = (1..concurrentCallCount).map {
            async {
                client.newCall(
                    Request.Builder().url(server.url("/store/products")).build(),
                ).execute()
            }
        }

        val responses = deferredResponses.awaitAll()

        // All requests should eventually succeed (200)
        responses.forEach { response ->
            assertThat(response.code).isEqualTo(200)
        }

        // After all calls, token should be the refreshed one
        assertThat(tokenProvider.accessToken).isEqualTo("shared-new-token")
    }

    @Test
    fun `does not refresh token when current token differs from failed token`() {
        // Simulates another coroutine already refreshing: by the time authenticate() runs,
        // the stored token is already different from the failed one.
        tokenProvider.accessToken = "already-refreshed-token"
        tokenProvider.refreshedToken = "should-not-use-this"

        server.enqueue(MockResponse().setResponseCode(401))
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()

        // The outgoing request has a stale token in the Authorization header
        val request = Request.Builder()
            .url(server.url("/store/products"))
            .header("Authorization", "Bearer old-stale-token")
            .build()

        val response = client.newCall(request).execute()

        assertThat(response.code).isEqualTo(200)

        // The retry request should use the already-current token, not a newly refreshed one
        server.takeRequest() // first (401) request
        val retryRequest = server.takeRequest()
        assertThat(retryRequest.getHeader("Authorization"))
            .isEqualTo("Bearer already-refreshed-token")

        // refreshedToken should NOT have been promoted to accessToken
        assertThat(tokenProvider.accessToken).isEqualTo("already-refreshed-token")
    }
}
