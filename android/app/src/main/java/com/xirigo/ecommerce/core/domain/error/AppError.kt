package com.xirigo.ecommerce.core.domain.error

import com.xirigo.ecommerce.R

sealed class AppError : Exception() {
    data class Network(override val message: String = "Network error") : AppError()
    data class Server(val code: Int, override val message: String) : AppError()
    data class NotFound(override val message: String = "Not found") : AppError()
    data class Unauthorized(override val message: String = "Unauthorized") : AppError()
    data class Unknown(override val message: String = "Unknown error") : AppError()
}

fun Throwable.toUserMessageResId(): Int = when (this) {
    is AppError.Network -> R.string.common_error_network
    is AppError.Server -> R.string.common_error_server
    is AppError.Unauthorized -> R.string.common_error_unauthorized
    is AppError.NotFound -> R.string.common_error_not_found
    else -> R.string.common_error_unknown
}
