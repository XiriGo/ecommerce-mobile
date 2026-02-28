package com.xirigo.ecommerce.core.auth

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * In-memory [TokenStorage] implementation for use in unit tests.
 * Thread-safe via [MutableStateFlow].
 */
class FakeTokenStorage : TokenStorage {

    private val tokenFlow = MutableStateFlow<String?>(null)

    override suspend fun getAccessToken(): String? = tokenFlow.value

    override suspend fun saveAccessToken(token: String) {
        tokenFlow.value = token
    }

    override suspend fun clearTokens() {
        tokenFlow.value = null
    }

    override fun getAccessTokenFlow(): Flow<String?> = tokenFlow.asStateFlow()
}
