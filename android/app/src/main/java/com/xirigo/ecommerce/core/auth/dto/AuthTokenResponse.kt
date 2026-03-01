package com.xirigo.ecommerce.core.auth.dto

import kotlinx.serialization.Serializable

@Serializable
data class AuthTokenResponse(
    val token: String,
)
