package com.molt.marketplace.core.network

interface TokenProvider {
    suspend fun getAccessToken(): String?
    suspend fun refreshToken(): String?
    suspend fun clearTokens()
}
