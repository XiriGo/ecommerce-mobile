package com.molt.marketplace.core.network

import com.google.common.truth.Truth.assertThat
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Before
import org.junit.Test

class TokenRefreshAuthenticatorTest {

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

    private fun createClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(AuthInterceptor(tokenProvider))
            .authenticator(TokenRefreshAuthenticator(tokenProvider))
            .build()
    }

    @Test
    fun `refreshes token and retries on 401`() {
        tokenProvider.accessToken = "expired-token"
        tokenProvider.refreshedToken = "new-token"

        server.enqueue(MockResponse().setResponseCode(401))
        server.enqueue(MockResponse().setResponseCode(200).setBody("""{"ok":true}"""))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/store/products")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(200)
        assertThat(server.requestCount).isEqualTo(2)

        server.takeRequest() // first (401)
        val secondRequest = server.takeRequest() // retry (200)
        assertThat(secondRequest.getHeader("Authorization")).isEqualTo("Bearer new-token")
    }

    @Test
    fun `clears tokens when refresh fails`() {
        tokenProvider.accessToken = "expired-token"
        tokenProvider.refreshedToken = null

        server.enqueue(MockResponse().setResponseCode(401))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/store/products")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(401)
        assertThat(tokenProvider.tokensCleared).isTrue()
    }

    @Test
    fun `uses already refreshed token without refreshing again`() {
        tokenProvider.accessToken = "new-token-from-another-request"
        tokenProvider.refreshedToken = "should-not-be-used"

        server.enqueue(MockResponse().setResponseCode(401))
        server.enqueue(MockResponse().setResponseCode(200).setBody("""{"ok":true}"""))

        val client = createClient()
        val request = Request.Builder()
            .url(server.url("/store/products"))
            .header("Authorization", "Bearer old-token")
            .build()

        val response = client.newCall(request).execute()

        assertThat(response.code).isEqualTo(200)
        server.takeRequest()
        val secondRequest = server.takeRequest()
        assertThat(secondRequest.getHeader("Authorization"))
            .isEqualTo("Bearer new-token-from-another-request")
    }
}
