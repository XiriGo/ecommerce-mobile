package com.molt.marketplace.core.auth

import kotlinx.coroutines.flow.Flow

interface TokenStorage {
    suspend fun getAccessToken(): String?
    suspend fun saveAccessToken(token: String)
    suspend fun clearTokens()
    fun getAccessTokenFlow(): Flow<String?>
}
