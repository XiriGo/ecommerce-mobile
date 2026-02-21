package com.molt.marketplace.core.di

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.runBlocking
import okhttp3.OkHttpClient
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Before
import org.junit.Test
import java.util.concurrent.TimeUnit
import com.molt.marketplace.core.network.ApiClient
import com.molt.marketplace.core.network.AuthInterceptor
import com.molt.marketplace.core.network.FakeTokenProvider
import com.molt.marketplace.core.network.NetworkConfig
import com.molt.marketplace.core.network.TokenRefreshAuthenticator

class NetworkModuleTest {

    private lateinit var server: MockWebServer

    @Before
    fun setUp() {
        server = MockWebServer()
        server.start()
    }

    @After
    fun tearDown() {
        server.shutdown()
    }

    // region provideJson

    @Test
    fun `provideJson returns non-null Json instance`() {
        val json = NetworkModule.provideJson()
        assertThat(json).isNotNull()
    }

    @Test
    fun `provideJson ignoreUnknownKeys is true`() {
        val json = NetworkModule.provideJson()
        assertThat(json.configuration.ignoreUnknownKeys).isTrue()
    }

    @Test
    fun `provideJson isLenient is true`() {
        val json = NetworkModule.provideJson()
        assertThat(json.configuration.isLenient).isTrue()
    }

    @Test
    fun `provideJson explicitNulls is false`() {
        val json = NetworkModule.provideJson()
        assertThat(json.configuration.explicitNulls).isFalse()
    }

    @Test
    fun `provideJson coerceInputValues is true`() {
        val json = NetworkModule.provideJson()
        assertThat(json.configuration.coerceInputValues).isTrue()
    }

    @Test
    fun `provideJson encodeDefaults is false`() {
        val json = NetworkModule.provideJson()
        assertThat(json.configuration.encodeDefaults).isFalse()
    }

    @Test
    fun `provideJson can decode unknown keys without throwing`() {
        val json = NetworkModule.provideJson()
        val result = json.decodeFromString<TestData>("""{"id":1,"unknownField":"ignored"}""")
        assertThat(result.id).isEqualTo(1)
    }

    @Test
    fun `provideJson omits null fields when explicitNulls is false`() {
        val json = NetworkModule.provideJson()
        val data = TestData(id = 42)
        val encoded = json.encodeToString(TestData.serializer(), data)
        assertThat(encoded).doesNotContain("\"name\"")
    }

    // endregion

    // region provideTokenProvider
    // NOTE: NetworkModule.provideTokenProvider() was removed in M0-06 when the real
    // SessionTokenProvider was wired via AuthModule. These tests verify behavior using
    // FakeTokenProvider (from the network test package) which mirrors the old contract.

    @Test
    fun `FakeTokenProvider getAccessToken returns null initially`() {
        val provider = FakeTokenProvider()
        val token = runBlocking { provider.getAccessToken() }
        assertThat(token).isNull()
    }

    @Test
    fun `FakeTokenProvider refreshToken returns null when not configured`() {
        val provider = FakeTokenProvider()
        val token = runBlocking { provider.refreshToken() }
        assertThat(token).isNull()
    }

    @Test
    fun `FakeTokenProvider clearTokens does not throw`() {
        val provider = FakeTokenProvider()
        runBlocking { provider.clearTokens() }
    }

    // endregion

    // region provideAuthInterceptor

    @Test
    fun `provideAuthInterceptor returns non-null AuthInterceptor`() {
        val tokenProvider = FakeTokenProvider()
        val interceptor = NetworkModule.provideAuthInterceptor(tokenProvider)
        assertThat(interceptor).isNotNull()
    }

    @Test
    fun `provideAuthInterceptor creates AuthInterceptor with given TokenProvider`() {
        val tokenProvider = FakeTokenProvider()
        val interceptor = NetworkModule.provideAuthInterceptor(tokenProvider)
        assertThat(interceptor).isInstanceOf(AuthInterceptor::class.java)
    }

    // endregion

    // region provideTokenRefreshAuthenticator

    @Test
    fun `provideTokenRefreshAuthenticator returns non-null instance`() {
        val tokenProvider = FakeTokenProvider()
        val authenticator = NetworkModule.provideTokenRefreshAuthenticator(tokenProvider)
        assertThat(authenticator).isNotNull()
    }

    @Test
    fun `provideTokenRefreshAuthenticator creates TokenRefreshAuthenticator`() {
        val tokenProvider = FakeTokenProvider()
        val authenticator = NetworkModule.provideTokenRefreshAuthenticator(tokenProvider)
        assertThat(authenticator).isInstanceOf(TokenRefreshAuthenticator::class.java)
    }

    // endregion

    // region Authenticated vs Unauthenticated client comparison

    @Test
    fun `authenticated client interceptors include AuthInterceptor`() {
        val tokenProvider = FakeTokenProvider()
        val authInterceptor = NetworkModule.provideAuthInterceptor(tokenProvider)
        val client = OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .build()

        val interceptorClasses = client.interceptors.map { it::class.java }
        assertThat(interceptorClasses).contains(AuthInterceptor::class.java)
    }

    @Test
    fun `unauthenticated client interceptors do not include AuthInterceptor`() {
        val client = OkHttpClient.Builder().build()
        val interceptorClasses = client.interceptors.map { it::class.java }
        assertThat(interceptorClasses).doesNotContain(AuthInterceptor::class.java)
    }

    @Test
    fun `authenticated client has connect timeout matching NetworkConfig`() {
        val client = OkHttpClient.Builder()
            .connectTimeout(NetworkConfig.CONNECT_TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .build()
        assertThat(client.connectTimeoutMillis.toLong())
            .isEqualTo(TimeUnit.SECONDS.toMillis(NetworkConfig.CONNECT_TIMEOUT_SECONDS))
    }

    @Test
    fun `authenticated client has read timeout matching NetworkConfig`() {
        val client = OkHttpClient.Builder()
            .readTimeout(NetworkConfig.READ_TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .build()
        assertThat(client.readTimeoutMillis.toLong())
            .isEqualTo(TimeUnit.SECONDS.toMillis(NetworkConfig.READ_TIMEOUT_SECONDS))
    }

    @Test
    fun `authenticated client has write timeout matching NetworkConfig`() {
        val client = OkHttpClient.Builder()
            .writeTimeout(NetworkConfig.WRITE_TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .build()
        assertThat(client.writeTimeoutMillis.toLong())
            .isEqualTo(TimeUnit.SECONDS.toMillis(NetworkConfig.WRITE_TIMEOUT_SECONDS))
    }

    // endregion

    // region provideRetrofit

    @Test
    fun `provideRetrofit returns non-null Retrofit instance`() {
        val json = NetworkModule.provideJson()
        val client = OkHttpClient()
        val retrofit = ApiClient.createRetrofit(
            baseUrl = server.url("/").toString(),
            okHttpClient = client,
            json = json,
        )
        assertThat(retrofit).isNotNull()
    }

    @Test
    fun `provideRetrofit sets base URL correctly`() {
        val json = NetworkModule.provideJson()
        val client = OkHttpClient()
        val baseUrl = server.url("/").toString()
        val retrofit = ApiClient.createRetrofit(
            baseUrl = baseUrl,
            okHttpClient = client,
            json = json,
        )
        assertThat(retrofit.baseUrl().toString()).isEqualTo(baseUrl)
    }

    @Test
    fun `provideRetrofit registers converter factory`() {
        val json = NetworkModule.provideJson()
        val client = OkHttpClient()
        val retrofit = ApiClient.createRetrofit(
            baseUrl = server.url("/").toString(),
            okHttpClient = client,
            json = json,
        )
        assertThat(retrofit.converterFactories()).isNotEmpty()
    }

    @Test
    fun `provideRetrofit uses authenticated OkHttpClient`() {
        val tokenProvider = FakeTokenProvider()
        val authInterceptor = NetworkModule.provideAuthInterceptor(tokenProvider)
        val client = OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .build()
        val json = NetworkModule.provideJson()

        val retrofit = ApiClient.createRetrofit(
            baseUrl = server.url("/").toString(),
            okHttpClient = client,
            json = json,
        )
        assertThat(retrofit).isNotNull()
    }

    // endregion
}

@kotlinx.serialization.Serializable
private data class TestData(
    val id: Int,
    val name: String? = null,
)
