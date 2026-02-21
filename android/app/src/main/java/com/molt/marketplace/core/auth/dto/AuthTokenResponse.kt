package com.molt.marketplace.core.auth.dto

import kotlinx.serialization.Serializable

@Serializable
data class AuthTokenResponse(
    val token: String,
)
