package com.molt.marketplace.core.network

import kotlinx.serialization.Serializable

@Serializable
data class MedusaErrorDto(
    val type: String,
    val message: String,
    val code: String? = null,
)
