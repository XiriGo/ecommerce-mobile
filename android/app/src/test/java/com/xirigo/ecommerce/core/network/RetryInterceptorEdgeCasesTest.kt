package com.xirigo.ecommerce.core.network

import com.google.common.truth.Truth.assertThat
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Before
import org.junit.Test

/**
 * Additional edge-case tests for [RetryInterceptor] covering non-retryable status codes,
 * jitter bounds, constant values and boundary conditions.
 */
class RetryInterceptorEdgeCasesTest {

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

    private fun createClient(): OkHttpClient = OkHttpClient.Builder()
        .addInterceptor(RetryInterceptor())
        .build()

    // -------------------------------------------------------------------------
    // Companion constant verification
    // -------------------------------------------------------------------------

    @Test
    fun `MAX_RETRIES should be 3`() {
        assertThat(RetryInterceptor.MAX_RETRIES).isEqualTo(3)
    }

    @Test
    fun `BASE_DELAY_MS should be 1000`() {
        assertThat(RetryInterceptor.BASE_DELAY_MS).isEqualTo(1000L)
    }

    @Test
    fun `BACKOFF_MULTIPLIER should be 2`() {
        assertThat(RetryInterceptor.BACKOFF_MULTIPLIER).isEqualTo(2.0)
    }

    @Test
    fun `MAX_DELAY_MS should be 8000`() {
        assertThat(RetryInterceptor.MAX_DELAY_MS).isEqualTo(8000L)
    }

    @Test
    fun `JITTER_FACTOR should be 0_2`() {
        assertThat(RetryInterceptor.JITTER_FACTOR).isEqualTo(0.2)
    }

    @Test
    fun `RETRYABLE_CODES should contain 500 502 503 504`() {
        assertThat(RetryInterceptor.RETRYABLE_CODES).containsExactly(500, 502, 503, 504)
    }

    // -------------------------------------------------------------------------
    // Non-retryable HTTP status codes
    // -------------------------------------------------------------------------

    @Test
    fun `does not retry on 403`() {
        server.enqueue(MockResponse().setResponseCode(403))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(403)
        assertThat(server.requestCount).isEqualTo(1)
    }

    @Test
    fun `does not retry on 422`() {
        server.enqueue(MockResponse().setResponseCode(422))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(422)
        assertThat(server.requestCount).isEqualTo(1)
    }

    @Test
    fun `does not retry on 201`() {
        server.enqueue(MockResponse().setResponseCode(201).setBody("""{"created":true}"""))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(201)
        assertThat(server.requestCount).isEqualTo(1)
    }

    @Test
    fun `does not retry on 204`() {
        server.enqueue(MockResponse().setResponseCode(204))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(204)
        assertThat(server.requestCount).isEqualTo(1)
    }

    @Test
    fun `does not retry on 301`() {
        // MockWebServer won't follow redirects unless configured, so 301 is returned directly
        server.enqueue(MockResponse().setResponseCode(301).addHeader("Location", "/other"))

        val client = OkHttpClient.Builder()
            .followRedirects(false)
            .addInterceptor(RetryInterceptor())
            .build()

        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(301)
        assertThat(server.requestCount).isEqualTo(1)
    }

    @Test
    fun `does not retry on 429`() {
        server.enqueue(MockResponse().setResponseCode(429))

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(429)
        assertThat(server.requestCount).isEqualTo(1)
    }

    // -------------------------------------------------------------------------
    // Jitter boundary tests: delay must always be non-negative
    // -------------------------------------------------------------------------

    @Test
    fun `calculateDelay should never return negative value for attempt 1`() {
        val interceptor = RetryInterceptor()
        repeat(50) {
            assertThat(interceptor.calculateDelay(1)).isAtLeast(0L)
        }
    }

    @Test
    fun `calculateDelay should never return negative value for attempt 2`() {
        val interceptor = RetryInterceptor()
        repeat(50) {
            assertThat(interceptor.calculateDelay(2)).isAtLeast(0L)
        }
    }

    @Test
    fun `calculateDelay should never return negative value for attempt 3`() {
        val interceptor = RetryInterceptor()
        repeat(50) {
            assertThat(interceptor.calculateDelay(3)).isAtLeast(0L)
        }
    }

    @Test
    fun `calculateDelay should cap at MAX_DELAY plus jitter for large attempt number`() {
        val interceptor = RetryInterceptor()
        // Attempt 10 would give 1000 * 2^9 = 512000ms uncapped; with cap + 20% jitter = max 9600
        val delay = interceptor.calculateDelay(10)
        val maxAllowed = (RetryInterceptor.MAX_DELAY_MS * (1 + RetryInterceptor.JITTER_FACTOR)).toLong()
        assertThat(delay).isAtMost(maxAllowed)
    }

    // -------------------------------------------------------------------------
    // Retry count boundary: exactly MAX_RETRIES retries are issued
    // -------------------------------------------------------------------------

    @Test
    fun `issues exactly MAX_RETRIES retries before giving up`() {
        // Queue 1 original + MAX_RETRIES (3) = 4 error responses
        repeat(RetryInterceptor.MAX_RETRIES + 1) {
            server.enqueue(MockResponse().setResponseCode(503))
        }

        val client = createClient()
        client.newCall(Request.Builder().url(server.url("/test")).build()).execute()

        assertThat(server.requestCount).isEqualTo(RetryInterceptor.MAX_RETRIES + 1)
    }

    @Test
    fun `stops retrying immediately when a non-retryable code is returned`() {
        server.enqueue(MockResponse().setResponseCode(500))
        server.enqueue(MockResponse().setResponseCode(400)) // stops here

        val client = createClient()
        val response = client.newCall(
            Request.Builder().url(server.url("/test")).build(),
        ).execute()

        assertThat(response.code).isEqualTo(400)
        assertThat(server.requestCount).isEqualTo(2)
    }
}
