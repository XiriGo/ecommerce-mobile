package com.molt.marketplace.core.network

import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json
import retrofit2.HttpException
import timber.log.Timber
import java.io.IOException
import com.molt.marketplace.core.domain.error.AppError

object ApiErrorMapper {

    private const val HTTP_UNAUTHORIZED = 401
    private const val HTTP_FORBIDDEN = 403
    private const val HTTP_NOT_FOUND = 404
    private const val HTTP_UNPROCESSABLE = 422
    private const val HTTP_TOO_MANY_REQUESTS = 429

    private val json = Json { ignoreUnknownKeys = true }

    fun Throwable.toAppError(): AppError = when (this) {
        is AppError -> this
        is HttpException -> mapHttpException(this)
        is IOException -> AppError.Network(message = message ?: "Network error")
        is SerializationException -> AppError.Unknown(message = "Failed to parse response")
        else -> AppError.Unknown(message = message ?: "Unknown error")
    }

    private fun mapHttpException(exception: HttpException): AppError {
        val errorBody = parseErrorBody(exception)
        val message = errorBody?.message

        return when (exception.code()) {
            HTTP_UNAUTHORIZED -> AppError.Unauthorized(message = message ?: "Unauthorized")
            HTTP_FORBIDDEN -> AppError.Unauthorized(message = message ?: "Access denied")
            HTTP_NOT_FOUND -> AppError.NotFound(message = message ?: "Not found")
            HTTP_UNPROCESSABLE -> AppError.Server(code = HTTP_UNPROCESSABLE, message = message ?: "Validation error")
            HTTP_TOO_MANY_REQUESTS -> AppError.Server(
                code = HTTP_TOO_MANY_REQUESTS,
                message = message ?: "Too many requests. Please try again later.",
            )
            in 500..599 -> AppError.Server(
                code = exception.code(),
                message = message ?: "Server error",
            )
            else -> AppError.Unknown(message = message ?: "Unexpected error (${exception.code()})")
        }
    }

    private fun parseErrorBody(exception: HttpException): MedusaErrorDto? {
        return try {
            exception.response()?.errorBody()?.string()?.let { body ->
                json.decodeFromString<MedusaErrorDto>(body)
            }
        } catch (e: SerializationException) {
            Timber.d(e, "Failed to parse error body")
            null
        } catch (e: IOException) {
            Timber.d(e, "Failed to parse error body")
            null
        }
    }
}
