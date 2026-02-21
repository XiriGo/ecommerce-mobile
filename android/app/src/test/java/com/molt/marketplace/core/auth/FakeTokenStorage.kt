package com.molt.marketplace.core.auth

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * In-memory [TokenStorage] implementation for use in unit tests.
 * Thread-safe via [MutableStateFlow].
 */
class FakeTokenStorage : TokenStorage {

    private val _tokenFlow = MutableStateFlow<String?>(null)

    override suspend fun getAccessToken(): String? = _tokenFlow.value

    override suspend fun saveAccessToken(token: String) {
        _tokenFlow.value = token
    }

    override suspend fun clearTokens() {
        _tokenFlow.value = null
    }

    override fun getAccessTokenFlow(): Flow<String?> = _tokenFlow.asStateFlow()
}
