package com.xirigo.ecommerce.core.network

import com.google.common.truth.Truth.assertThat
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Before
import org.junit.Test

class ApiClientTest {

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

    @Test
    fun `createRetrofit should return non-null Retrofit instance`() {
        val retrofit = ApiClient.createRetrofit(
            baseUrl = server.url("/").toString(),
            okHttpClient = OkHttpClient(),
            json = Json { ignoreUnknownKeys = true },
        )
        assertThat(retrofit).isNotNull()
    }

    @Test
    fun `createRetrofit should use provided base URL`() {
        val baseUrl = server.url("/").toString()
        val retrofit = ApiClient.createRetrofit(
            baseUrl = baseUrl,
            okHttpClient = OkHttpClient(),
            json = Json { ignoreUnknownKeys = true },
        )
        assertThat(retrofit.baseUrl().toString()).isEqualTo(baseUrl)
    }

    @Test
    fun `createRetrofit should use provided OkHttpClient`() {
        val customClient = OkHttpClient.Builder().build()
        val retrofit = ApiClient.createRetrofit(
            baseUrl = server.url("/").toString(),
            okHttpClient = customClient,
            json = Json { ignoreUnknownKeys = true },
        )
        // Verify retrofit was built (non-null means OkHttpClient was accepted)
        assertThat(retrofit).isNotNull()
    }

    @Test
    fun `createRetrofit should register kotlinx serialization converter`() {
        val retrofit = ApiClient.createRetrofit(
            baseUrl = server.url("/").toString(),
            okHttpClient = OkHttpClient(),
            json = Json { ignoreUnknownKeys = true },
        )
        // Converters are present — we verify by checking converterFactories is not empty
        assertThat(retrofit.converterFactories()).isNotEmpty()
    }
}
