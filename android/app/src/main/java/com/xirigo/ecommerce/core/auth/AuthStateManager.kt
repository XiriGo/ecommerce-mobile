package com.xirigo.ecommerce.core.auth

import kotlinx.coroutines.flow.StateFlow

interface AuthStateManager {
    val authState: StateFlow<AuthState>
    suspend fun onLoginSuccess(token: String)
    suspend fun onLogout()
    suspend fun checkStoredToken()
}
