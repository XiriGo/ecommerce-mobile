package com.xirigo.ecommerce.core.network

import com.google.common.truth.Truth.assertThat
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Before
import org.junit.Test

class AuthInterceptorTest {

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
            .build()
    }

    @Test
    fun `injects bearer token when token is available`() {
        tokenProvider.accessToken = "test-token-123"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        val request = Request.Builder()
            .url(server.url("/store/products"))
            .build()

        client.newCall(request).execute()
        val recorded = server.takeRequest()

        assertThat(recorded.getHeader("Authorization")).isEqualTo("Bearer test-token-123")
    }

    @Test
    fun `does not inject token when token is null`() {
        tokenProvider.accessToken = null
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        val request = Request.Builder()
            .url(server.url("/store/products"))
            .build()

        client.newCall(request).execute()
        val recorded = server.takeRequest()

        assertThat(recorded.getHeader("Authorization")).isNull()
    }

    @Test
    fun `skips token for login endpoint`() {
        tokenProvider.accessToken = "test-token"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        val request = Request.Builder()
            .url(server.url("/auth/customer/emailpass"))
            .build()

        client.newCall(request).execute()
        val recorded = server.takeRequest()

        assertThat(recorded.getHeader("Authorization")).isNull()
    }

    @Test
    fun `skips token for register endpoint`() {
        tokenProvider.accessToken = "test-token"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        val request = Request.Builder()
            .url(server.url("/auth/customer/emailpass/register"))
            .build()

        client.newCall(request).execute()
        val recorded = server.takeRequest()

        assertThat(recorded.getHeader("Authorization")).isNull()
    }

    @Test
    fun `does not overwrite existing authorization header`() {
        tokenProvider.accessToken = "provider-token"
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        val request = Request.Builder()
            .url(server.url("/store/products"))
            .header("Authorization", "Bearer custom-token")
            .build()

        client.newCall(request).execute()
        val recorded = server.takeRequest()

        assertThat(recorded.getHeader("Authorization")).isEqualTo("Bearer custom-token")
    }

    @Test
    fun `always adds accept json header`() {
        server.enqueue(MockResponse().setResponseCode(200))

        val client = createClient()
        val request = Request.Builder()
            .url(server.url("/store/products"))
            .build()

        client.newCall(request).execute()
        val recorded = server.takeRequest()

        assertThat(recorded.getHeader("Accept")).isEqualTo("application/json")
    }
}

class FakeTokenProvider : TokenProvider {
    var accessToken: String? = null
    var refreshedToken: String? = null
    var tokensCleared = false

    override suspend fun getAccessToken(): String? = accessToken

    override suspend fun refreshToken(): String? {
        val token = refreshedToken
        if (token != null) {
            accessToken = token
        }
        return token
    }

    override suspend fun clearTokens() {
        accessToken = null
        refreshedToken = null
        tokensCleared = true
    }
}
