package com.molt.marketplace.core.network

import com.google.common.truth.Truth.assertThat
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Before
import org.junit.Test

class RetryInterceptorTest {

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

    private fun createClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(RetryInterceptor())
            .build()
    }

    @Test
    fun `retries on 500 and succeeds`() {
        server.enqueue(MockResponse().setResponseCode(500))
        server.enqueue(MockResponse().setResponseCode(200).setBody("""{"ok":true}"""))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(200)
        assertThat(server.requestCount).isEqualTo(2)
    }

    @Test
    fun `retries on 502 and succeeds`() {
        server.enqueue(MockResponse().setResponseCode(502))
        server.enqueue(MockResponse().setResponseCode(200).setBody("""{"ok":true}"""))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(200)
        assertThat(server.requestCount).isEqualTo(2)
    }

    @Test
    fun `retries on 503 and succeeds`() {
        server.enqueue(MockResponse().setResponseCode(503))
        server.enqueue(MockResponse().setResponseCode(200).setBody("""{"ok":true}"""))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(200)
        assertThat(server.requestCount).isEqualTo(2)
    }

    @Test
    fun `retries on 504 and succeeds`() {
        server.enqueue(MockResponse().setResponseCode(504))
        server.enqueue(MockResponse().setResponseCode(200).setBody("""{"ok":true}"""))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(200)
        assertThat(server.requestCount).isEqualTo(2)
    }

    @Test
    fun `returns last error after max retries exhausted`() {
        repeat(4) {
            server.enqueue(MockResponse().setResponseCode(500))
        }

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(500)
        assertThat(server.requestCount).isEqualTo(4) // 1 original + 3 retries
    }

    @Test
    fun `does not retry on 400`() {
        server.enqueue(MockResponse().setResponseCode(400))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(400)
        assertThat(server.requestCount).isEqualTo(1)
    }

    @Test
    fun `does not retry on 401`() {
        server.enqueue(MockResponse().setResponseCode(401))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(401)
        assertThat(server.requestCount).isEqualTo(1)
    }

    @Test
    fun `does not retry on 404`() {
        server.enqueue(MockResponse().setResponseCode(404))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(404)
        assertThat(server.requestCount).isEqualTo(1)
    }

    @Test
    fun `does not retry on 200`() {
        server.enqueue(MockResponse().setResponseCode(200).setBody("""{"ok":true}"""))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(200)
        assertThat(server.requestCount).isEqualTo(1)
    }

    @Test
    fun `calculateDelay returns value within expected range for attempt 1`() {
        val interceptor = RetryInterceptor()
        val delay = interceptor.calculateDelay(1)

        // Attempt 1: baseDelay = 1000ms, jitter = +/- 20% => [800, 1200]
        assertThat(delay).isAtLeast(800L)
        assertThat(delay).isAtMost(1200L)
    }

    @Test
    fun `calculateDelay returns value within expected range for attempt 2`() {
        val interceptor = RetryInterceptor()
        val delay = interceptor.calculateDelay(2)

        // Attempt 2: baseDelay = 2000ms, jitter = +/- 20% => [1600, 2400]
        assertThat(delay).isAtLeast(1600L)
        assertThat(delay).isAtMost(2400L)
    }

    @Test
    fun `calculateDelay returns value within expected range for attempt 3`() {
        val interceptor = RetryInterceptor()
        val delay = interceptor.calculateDelay(3)

        // Attempt 3: baseDelay = 4000ms, jitter = +/- 20% => [3200, 4800]
        assertThat(delay).isAtLeast(3200L)
        assertThat(delay).isAtMost(4800L)
    }
}
