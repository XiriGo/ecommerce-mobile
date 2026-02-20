package com.molt.marketplace.core.network

import com.molt.marketplace.core.domain.error.AppError
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json
import retrofit2.HttpException
import timber.log.Timber
import java.io.IOException

object ApiErrorMapper {

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
            401 -> AppError.Unauthorized(message = message ?: "Unauthorized")
            403 -> AppError.Unauthorized(message = message ?: "Access denied")
            404 -> AppError.NotFound(message = message ?: "Not found")
            422 -> AppError.Server(code = 422, message = message ?: "Validation error")
            429 -> AppError.Server(code = 429, message = message ?: "Too many requests. Please try again later.")
            in 500..599 -> AppError.Server(
                code = exception.code(),
                message = message ?: "Server error",
            )
            else -> AppError.Unknown(message = message ?: "Unexpected error (${exception.code()})")
        }
    }

    private fun parseErrorBody(exception: HttpException): MedusaErrorDto? {
        return try {
            val body = exception.response()?.errorBody()?.string()
            if (body != null) {
                json.decodeFromString<MedusaErrorDto>(body)
            } else {
                null
            }
        } catch (e: Exception) {
            Timber.d(e, "Failed to parse error body")
            null
        }
    }
}
