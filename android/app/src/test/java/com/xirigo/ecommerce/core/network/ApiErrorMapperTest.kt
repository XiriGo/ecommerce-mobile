package com.xirigo.ecommerce.core.network

import com.google.common.truth.Truth.assertThat
import kotlinx.serialization.SerializationException
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.ResponseBody.Companion.toResponseBody
import org.junit.Test
import retrofit2.HttpException
import retrofit2.Response
import java.io.IOException
import java.net.SocketTimeoutException
import java.net.UnknownHostException
import com.xirigo.ecommerce.core.domain.error.AppError
import com.xirigo.ecommerce.core.network.ApiErrorMapper.toAppError

class ApiErrorMapperTest {

    private fun createHttpException(code: Int, errorBody: String? = null): HttpException {
        val body = errorBody?.toResponseBody("application/json".toMediaType())
        val response = Response.error<Any>(code, body ?: "".toResponseBody())
        return HttpException(response)
    }

    @Test
    fun `maps 401 to Unauthorized`() {
        val error = createHttpException(
            401,
            """{"type":"unauthorized","message":"Token expired"}""",
        ).toAppError()

        assertThat(error).isInstanceOf(AppError.Unauthorized::class.java)
        assertThat(error.message).isEqualTo("Token expired")
    }

    @Test
    fun `maps 401 without body to Unauthorized with default message`() {
        val error = createHttpException(401).toAppError()

        assertThat(error).isInstanceOf(AppError.Unauthorized::class.java)
        assertThat(error.message).isEqualTo("Unauthorized")
    }

    @Test
    fun `maps 403 to Unauthorized with access denied`() {
        val error = createHttpException(403).toAppError()

        assertThat(error).isInstanceOf(AppError.Unauthorized::class.java)
        assertThat(error.message).isEqualTo("Access denied")
    }

    @Test
    fun `maps 404 to NotFound`() {
        val error = createHttpException(
            404,
            """{"type":"not_found","message":"Product not found"}""",
        ).toAppError()

        assertThat(error).isInstanceOf(AppError.NotFound::class.java)
        assertThat(error.message).isEqualTo("Product not found")
    }

    @Test
    fun `maps 404 without body to NotFound with default message`() {
        val error = createHttpException(404).toAppError()

        assertThat(error).isInstanceOf(AppError.NotFound::class.java)
        assertThat(error.message).isEqualTo("Not found")
    }

    @Test
    fun `maps 422 to Server with parsed message`() {
        val error = createHttpException(
            422,
            """{"type":"invalid_data","message":"Email is required"}""",
        ).toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        val serverError = error as AppError.Server
        assertThat(serverError.code).isEqualTo(422)
        assertThat(serverError.message).isEqualTo("Email is required")
    }

    @Test
    fun `maps 429 to Server`() {
        val error = createHttpException(429).toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        val serverError = error as AppError.Server
        assertThat(serverError.code).isEqualTo(429)
    }

    @Test
    fun `maps 500 to Server`() {
        val error = createHttpException(
            500,
            """{"type":"server_error","message":"Internal server error"}""",
        ).toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        val serverError = error as AppError.Server
        assertThat(serverError.code).isEqualTo(500)
        assertThat(serverError.message).isEqualTo("Internal server error")
    }

    @Test
    fun `maps 503 to Server`() {
        val error = createHttpException(503).toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        val serverError = error as AppError.Server
        assertThat(serverError.code).isEqualTo(503)
    }

    @Test
    fun `maps IOException to Network`() {
        val error = IOException("Connection reset").toAppError()

        assertThat(error).isInstanceOf(AppError.Network::class.java)
    }

    @Test
    fun `maps UnknownHostException to Network`() {
        val error = UnknownHostException("Unable to resolve host").toAppError()

        assertThat(error).isInstanceOf(AppError.Network::class.java)
    }

    @Test
    fun `maps SocketTimeoutException to Network`() {
        val error = SocketTimeoutException("Read timed out").toAppError()

        assertThat(error).isInstanceOf(AppError.Network::class.java)
    }

    @Test
    fun `maps SerializationException to Unknown`() {
        val error = SerializationException("Failed to decode").toAppError()

        assertThat(error).isInstanceOf(AppError.Unknown::class.java)
        assertThat(error.message).isEqualTo("Failed to parse response")
    }

    @Test
    fun `maps unknown throwable to Unknown`() {
        val error = RuntimeException("Something unexpected").toAppError()

        assertThat(error).isInstanceOf(AppError.Unknown::class.java)
        assertThat(error.message).isEqualTo("Something unexpected")
    }

    @Test
    fun `returns same AppError if already an AppError`() {
        val original = AppError.NotFound("Already mapped")
        val result = original.toAppError()

        assertThat(result).isSameInstanceAs(original)
    }

    @Test
    fun `handles malformed error body gracefully`() {
        val error = createHttpException(500, "not json at all").toAppError()

        assertThat(error).isInstanceOf(AppError.Server::class.java)
        val serverError = error as AppError.Server
        assertThat(serverError.code).isEqualTo(500)
        assertThat(serverError.message).isEqualTo("Server error")
    }
}
