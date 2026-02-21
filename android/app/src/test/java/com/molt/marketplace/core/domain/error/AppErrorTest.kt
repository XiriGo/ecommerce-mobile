package com.molt.marketplace.core.domain.error

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import com.molt.marketplace.R

class AppErrorTest {

    @Test
    fun `Network error returns correct string resource`() {
        val error = AppError.Network()
        assertThat(error.toUserMessageResId()).isEqualTo(R.string.common_error_network)
    }

    @Test
    fun `Server error returns correct string resource`() {
        val error = AppError.Server(code = 500, message = "Internal server error")
        assertThat(error.toUserMessageResId()).isEqualTo(R.string.common_error_server)
    }

    @Test
    fun `Unauthorized error returns correct string resource`() {
        val error = AppError.Unauthorized()
        assertThat(error.toUserMessageResId()).isEqualTo(R.string.common_error_unauthorized)
    }

    @Test
    fun `NotFound error returns correct string resource`() {
        val error = AppError.NotFound()
        assertThat(error.toUserMessageResId()).isEqualTo(R.string.common_error_not_found)
    }

    @Test
    fun `Unknown error returns correct string resource`() {
        val error = AppError.Unknown()
        assertThat(error.toUserMessageResId()).isEqualTo(R.string.common_error_unknown)
    }

    @Test
    fun `non-AppError throwable returns unknown string resource`() {
        val error = RuntimeException("unexpected")
        assertThat(error.toUserMessageResId()).isEqualTo(R.string.common_error_unknown)
    }

    @Test
    fun `Network error has correct default message`() {
        val error = AppError.Network()
        assertThat(error.message).isEqualTo("Network error")
    }

    @Test
    fun `NotFound error has correct default message`() {
        val error = AppError.NotFound()
        assertThat(error.message).isEqualTo("Not found")
    }

    @Test
    fun `Unauthorized error has correct default message`() {
        val error = AppError.Unauthorized()
        assertThat(error.message).isEqualTo("Unauthorized")
    }

    @Test
    fun `Unknown error has correct default message`() {
        val error = AppError.Unknown()
        assertThat(error.message).isEqualTo("Unknown error")
    }

    @Test
    fun `Server error preserves code and message`() {
        val error = AppError.Server(code = 422, message = "Validation failed")
        assertThat(error.code).isEqualTo(422)
        assertThat(error.message).isEqualTo("Validation failed")
    }

    @Test
    fun `AppError is subtype of Exception`() {
        val error: Exception = AppError.Network()
        assertThat(error).isInstanceOf(Exception::class.java)
    }
}
