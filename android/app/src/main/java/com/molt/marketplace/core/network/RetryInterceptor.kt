package com.molt.marketplace.core.network

import kotlin.math.min
import kotlin.random.Random
import okhttp3.Interceptor
import okhttp3.Response
import timber.log.Timber

class RetryInterceptor : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()
        var response = chain.proceed(request)

        if (response.code !in RETRYABLE_CODES) {
            return response
        }

        var attempt = 0
        while (attempt < MAX_RETRIES && response.code in RETRYABLE_CODES) {
            attempt++
            response.close()

            val delay = calculateDelay(attempt)
            Timber.d("Retry attempt %d/%d after %dms for %s", attempt, MAX_RETRIES, delay, request.url)

            Thread.sleep(delay)

            response = chain.proceed(request)
        }

        return response
    }

    internal fun calculateDelay(attempt: Int): Long {
        val baseDelay = BASE_DELAY_MS * Math.pow(BACKOFF_MULTIPLIER, (attempt - 1).toDouble())
        val cappedDelay = min(baseDelay, MAX_DELAY_MS.toDouble())
        val jitter = cappedDelay * JITTER_FACTOR * (2 * Random.nextDouble() - 1)
        return (cappedDelay + jitter).toLong().coerceAtLeast(0L)
    }

    companion object {
        const val MAX_RETRIES = 3
        const val BASE_DELAY_MS = 1000L
        const val BACKOFF_MULTIPLIER = 2.0
        const val MAX_DELAY_MS = 8000L
        const val JITTER_FACTOR = 0.2
        val RETRYABLE_CODES = setOf(500, 502, 503, 504)
    }
}
