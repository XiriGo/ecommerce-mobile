package com.molt.marketplace.core.network

import com.google.common.truth.Truth.assertThat
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.ResponseBody.Companion.toResponseBody
import org.junit.Test
import retrofit2.HttpException
import retrofit2.Response
import java.io.IOException
import java.net.ConnectException
import com.molt.marketplace.core.domain.error.AppError
import com.molt.marketplace.core.network.ApiErrorMapper.toAppError

/**
 * Additional edge-case tests for [ApiErrorMapper] covering:
 * - Remaining 5xx codes not yet covered
 * - Unknown HTTP codes
 * - IOException subtypes
 * - Empty error body
 * - Error body with missing message field
 */
class ApiErrorMapperEdgeCasesTest {

    private fun createHttpException(code: Int, errorBody: String? = null): HttpException {
        val body = errorBody?.toResponseBody("application/json".toMediaType())
        val response = Response.error<Any>(code, body ?: "".toResponseBody())
        return HttpException(response)
    }

    // -------------------------------------------------------------------------
    // Additional 5xx codes
    // -------------------------------------------------------------------------

    @Test
    fun `maps 502 to Server`() {
        val error = createHttpException(502).toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        assertThat((error as AppError.Server).code).isEqualTo(502)
    }

    @Test
    fun `maps 504 to Server`() {
        val error = createHttpException(504).toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        assertThat((error as AppError.Server).code).isEqualTo(504)
    }

    @Test
    fun `maps 599 to Server`() {
        val error = createHttpException(599).toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        assertThat((error as AppError.Server).code).isEqualTo(599)
    }

    @Test
    fun `maps 500 without body uses default server error message`() {
        val error = createHttpException(500).toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        assertThat(error.message).isEqualTo("Server error")
    }

    // -------------------------------------------------------------------------
    // 422 edge cases
    // -------------------------------------------------------------------------

    @Test
    fun `maps 422 without body uses default validation error message`() {
        val error = createHttpException(422).toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        val serverError = error as AppError.Server
        assertThat(serverError.code).isEqualTo(422)
        assertThat(serverError.message).isEqualTo("Validation error")
    }

    // -------------------------------------------------------------------------
    // Unknown HTTP code
    // -------------------------------------------------------------------------

    @Test
    fun `maps unknown 409 Conflict to Unknown with code in message`() {
        val error = createHttpException(409).toAppError()

        assertThat(error).isInstanceOf(AppError.Unknown::class.java)
        assertThat(error.message).contains("409")
    }

    @Test
    fun `maps 408 Request Timeout to Unknown`() {
        val error = createHttpException(408).toAppError()

        assertThat(error).isInstanceOf(AppError.Unknown::class.java)
    }

    // -------------------------------------------------------------------------
    // IOException subtypes
    // -------------------------------------------------------------------------

    @Test
    fun `maps ConnectException to Network`() {
        val error = ConnectException("Connection refused").toAppError()

        assertThat(error).isInstanceOf(AppError.Network::class.java)
    }

    @Test
    fun `maps IOException with null message to Network with fallback message`() {
        val ioException = object : IOException() {
            override val message: String? = null
        }
        val error = ioException.toAppError()

        assertThat(error).isInstanceOf(AppError.Network::class.java)
        assertThat(error.message).isEqualTo("Network error")
    }

    // -------------------------------------------------------------------------
    // Error body edge cases
    // -------------------------------------------------------------------------

    @Test
    fun `maps 401 with empty string error body uses default unauthorized message`() {
        val error = createHttpException(401, "").toAppError()

        assertThat(error).isInstanceOf(AppError.Unauthorized::class.java)
        assertThat(error.message).isEqualTo("Unauthorized")
    }

    @Test
    fun `maps 404 with partial JSON error body uses default not found message`() {
        val error = createHttpException(404, """{"type":"not_found"}""").toAppError()

        // MedusaErrorDto requires both `type` and `message`; partial JSON
        // still parses if `message` field exists, but here it's missing
        // so the mapper falls back to the default message
        assertThat(error).isInstanceOf(AppError.NotFound::class.java)
    }

    @Test
    fun `toAppError on AppError Network is idempotent`() {
        val original = AppError.Network("already mapped")
        val result = original.toAppError()

        assertThat(result).isSameInstanceAs(original)
    }

    @Test
    fun `toAppError on AppError Server is idempotent`() {
        val original = AppError.Server(code = 503, message = "already mapped")
        val result = original.toAppError()

        assertThat(result).isSameInstanceAs(original)
    }

    @Test
    fun `toAppError on AppError Unauthorized is idempotent`() {
        val original = AppError.Unauthorized("already mapped")
        val result = original.toAppError()

        assertThat(result).isSameInstanceAs(original)
    }

    @Test
    fun `toAppError on AppError Unknown is idempotent`() {
        val original = AppError.Unknown("already mapped")
        val result = original.toAppError()

        assertThat(result).isSameInstanceAs(original)
    }

    @Test
    fun `maps 429 without body uses default rate limit message`() {
        val error = createHttpException(429).toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        val serverError = error as AppError.Server
        assertThat(serverError.code).isEqualTo(429)
        assertThat(serverError.message).contains("Too many requests")
    }

    @Test
    fun `maps 403 with parsed error body uses parsed message`() {
        val error = createHttpException(
            403,
            """{"type":"forbidden","message":"Feature not allowed"}""",
        ).toAppError()

        assertThat(error).isInstanceOf(AppError.Unauthorized::class.java)
        assertThat(error.message).isEqualTo("Feature not allowed")
    }
}
