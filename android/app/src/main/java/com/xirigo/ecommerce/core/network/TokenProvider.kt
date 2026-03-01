package com.xirigo.ecommerce.core.network

interface TokenProvider {
    suspend fun getAccessToken(): String?
    suspend fun refreshToken(): String?
    suspend fun clearTokens()
}
