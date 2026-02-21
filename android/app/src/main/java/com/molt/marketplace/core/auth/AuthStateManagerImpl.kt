package com.molt.marketplace.core.auth

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import timber.log.Timber
import java.io.IOException
import java.security.GeneralSecurityException
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthStateManagerImpl @Inject constructor(
    private val tokenStorage: TokenStorage,
) : AuthStateManager {

    private val _authState = MutableStateFlow<AuthState>(AuthState.Loading)
    override val authState: StateFlow<AuthState> = _authState.asStateFlow()

    override suspend fun onLoginSuccess(token: String) {
        tokenStorage.saveAccessToken(token)
        _authState.value = AuthState.Authenticated(token)
    }

    override suspend fun onLogout() {
        tokenStorage.clearTokens()
        _authState.value = AuthState.Guest
    }

    override suspend fun checkStoredToken() {
        val token = try {
            tokenStorage.getAccessToken()
        } catch (e: GeneralSecurityException) {
            Timber.w(e, "Failed to read stored token")
            null
        } catch (e: IOException) {
            Timber.w(e, "Failed to read stored token")
            null
        }

        if (token != null) {
            _authState.value = AuthState.Authenticated(token)
        } else {
            _authState.value = AuthState.Guest
        }
    }
}
