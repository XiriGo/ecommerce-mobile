package com.molt.marketplace.core.network

import com.google.common.truth.Truth.assertThat
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Before
import org.junit.Test

/**
 * Additional edge-case tests for [AuthInterceptor] covering all public endpoint paths
 * and boundary conditions not covered by the primary test class.
 */
class AuthInterceptorEdgeCasesTest {

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
            .build()

    // -------------------------------------------------------------------------
    // Public endpoint path coverage
    // -------------------------------------------------------------------------

    @Test
    fun `skips token for login endpoint even when token is available`() {
        tokenProvider.accessToken = "valid-token"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        client.newCall(
            Request.Builder()
                .url(server.url("/auth/customer/emailpass"))
                .build(),
        ).execute()

        val recorded = server.takeRequest()
        assertThat(recorded.getHeader("Authorization")).isNull()
    }

    @Test
    fun `skips token for register endpoint even when token is available`() {
        tokenProvider.accessToken = "valid-token"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        client.newCall(
            Request.Builder()
                .url(server.url("/auth/customer/emailpass/register"))
                .build(),
        ).execute()

        val recorded = server.takeRequest()
        assertThat(recorded.getHeader("Authorization")).isNull()
    }

    @Test
    fun `injects token for non-public endpoint with sub-path`() {
        tokenProvider.accessToken = "sub-path-token"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        client.newCall(
            Request.Builder()
                .url(server.url("/store/products/prod_123"))
                .build(),
        ).execute()

        val recorded = server.takeRequest()
        assertThat(recorded.getHeader("Authorization")).isEqualTo("Bearer sub-path-token")
    }

    @Test
    fun `injects token for cart endpoint`() {
        tokenProvider.accessToken = "cart-token"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        client.newCall(
            Request.Builder()
                .url(server.url("/store/carts"))
                .build(),
        ).execute()

        val recorded = server.takeRequest()
        assertThat(recorded.getHeader("Authorization")).isEqualTo("Bearer cart-token")
    }

    @Test
    fun `injects token for orders endpoint`() {
        tokenProvider.accessToken = "orders-token"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        client.newCall(
            Request.Builder()
                .url(server.url("/store/orders"))
                .build(),
        ).execute()

        val recorded = server.takeRequest()
        assertThat(recorded.getHeader("Authorization")).isEqualTo("Bearer orders-token")
    }

    @Test
    fun `does not inject token for endpoint with no token available`() {
        tokenProvider.accessToken = null
        server.enqueue(MockResponse().setResponseCode(401))

        val client = createClient()
        client.newCall(
            Request.Builder()
                .url(server.url("/store/orders"))
                .build(),
        ).execute()

        val recorded = server.takeRequest()
        assertThat(recorded.getHeader("Authorization")).isNull()
    }

    @Test
    fun `accept header is always application json on public endpoint`() {
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        client.newCall(
            Request.Builder()
                .url(server.url("/auth/customer/emailpass"))
                .build(),
        ).execute()

        val recorded = server.takeRequest()
        assertThat(recorded.getHeader("Accept")).isEqualTo("application/json")
    }

    @Test
    fun `does not overwrite pre-set authorization on non-public endpoint`() {
        tokenProvider.accessToken = "provider-token"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        client.newCall(
            Request.Builder()
                .url(server.url("/store/products"))
                .header("Authorization", "Bearer caller-token")
                .build(),
        ).execute()

        val recorded = server.takeRequest()
        assertThat(recorded.getHeader("Authorization")).isEqualTo("Bearer caller-token")
    }

    @Test
    fun `path containing emailpass substring but not ending with it gets token injected`() {
        // e.g., /auth/customer/emailpass/reset is NOT in public list, so token should be injected
        tokenProvider.accessToken = "reset-token"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        client.newCall(
            Request.Builder()
                .url(server.url("/auth/customer/emailpass/reset"))
                .build(),
        ).execute()

        val recorded = server.takeRequest()
        // /auth/customer/emailpass/reset does NOT end with /emailpass or /emailpass/register
        // so it is NOT public and the token SHOULD be injected
        assertThat(recorded.getHeader("Authorization")).isEqualTo("Bearer reset-token")
    }
}
