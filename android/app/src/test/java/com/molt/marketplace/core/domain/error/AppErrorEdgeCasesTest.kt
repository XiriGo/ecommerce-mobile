package com.molt.marketplace.core.domain.error

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import com.molt.marketplace.R

/**
 * Additional edge-case tests for [AppError] and its extension functions.
 */
class AppErrorEdgeCasesTest {

    // -------------------------------------------------------------------------
    // Custom message variants
    // -------------------------------------------------------------------------

    @Test
    fun `Network error with custom message preserves message`() {
        val error = AppError.Network(message = "Custom network message")
        assertThat(error.message).isEqualTo("Custom network message")
    }

    @Test
    fun `NotFound error with custom message preserves message`() {
        val error = AppError.NotFound(message = "Custom resource not found")
        assertThat(error.message).isEqualTo("Custom resource not found")
    }

    @Test
    fun `Unauthorized error with custom message preserves message`() {
        val error = AppError.Unauthorized(message = "Session expired")
        assertThat(error.message).isEqualTo("Session expired")
    }

    @Test
    fun `Unknown error with custom message preserves message`() {
        val error = AppError.Unknown(message = "Something weird happened")
        assertThat(error.message).isEqualTo("Something weird happened")
    }

    // -------------------------------------------------------------------------
    // toUserMessageResId for all sealed variants
    // -------------------------------------------------------------------------

    @Test
    fun `Server error toUserMessageResId returns common_error_server`() {
        val error = AppError.Server(code = 503, message = "Service unavailable")
        assertThat(error.toUserMessageResId()).isEqualTo(R.string.common_error_server)
    }

    @Test
    fun `Network error toUserMessageResId returns common_error_network regardless of message`() {
        val error = AppError.Network(message = "Wifi down")
        assertThat(error.toUserMessageResId()).isEqualTo(R.string.common_error_network)
    }

    @Test
    fun `NotFound error toUserMessageResId returns common_error_not_found`() {
        val error = AppError.NotFound(message = "Item gone")
        assertThat(error.toUserMessageResId()).isEqualTo(R.string.common_error_not_found)
    }

    @Test
    fun `Unauthorized error toUserMessageResId returns common_error_unauthorized`() {
        val error = AppError.Unauthorized(message = "Please log in")
        assertThat(error.toUserMessageResId()).isEqualTo(R.string.common_error_unauthorized)
    }

    // -------------------------------------------------------------------------
    // Data class equality and copy
    // -------------------------------------------------------------------------

    @Test
    fun `two Network errors with same message are equal`() {
        val first = AppError.Network("same message")
        val second = AppError.Network("same message")
        assertThat(first).isEqualTo(second)
    }

    @Test
    fun `two Network errors with different messages are not equal`() {
        val first = AppError.Network("message A")
        val second = AppError.Network("message B")
        assertThat(first).isNotEqualTo(second)
    }

    @Test
    fun `Server error copy with different code is not equal`() {
        val original = AppError.Server(code = 500, message = "Error")
        val copy = original.copy(code = 503)
        assertThat(original).isNotEqualTo(copy)
    }

    // -------------------------------------------------------------------------
    // AppError IS an Exception
    // -------------------------------------------------------------------------

    @Test
    fun `AppError can be thrown and caught as Exception`() {
        var caught: Exception? = null
        try {
            throw AppError.Network("network failure")
        } catch (e: Exception) {
            caught = e
        }
        assertThat(caught).isInstanceOf(AppError.Network::class.java)
    }

    @Test
    fun `AppError can be thrown and caught as AppError`() {
        var caught: AppError? = null
        try {
            throw AppError.Unauthorized("unauthorized")
        } catch (e: AppError) {
            caught = e
        }
        assertThat(caught).isInstanceOf(AppError.Unauthorized::class.java)
    }
}
