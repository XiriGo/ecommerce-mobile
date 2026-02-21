package com.molt.marketplace.core.auth

import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton
import com.molt.marketplace.core.auth.dto.LoginRequest
import com.molt.marketplace.core.auth.dto.RegisterRequest
import com.molt.marketplace.core.domain.error.AppError
import com.molt.marketplace.core.network.ApiErrorMapper.toAppError

@Singleton
class SessionManager @Inject constructor(
    private val authApi: AuthApi,
    private val tokenStorage: TokenStorage,
    private val authStateManager: AuthStateManager,
) {

    private val refreshMutex = Mutex()

    suspend fun login(email: String, password: String): Result<Unit> {
        return try {
            val response = authApi.login(LoginRequest(email = email, password = password))
            val token = response.token
            if (token.isBlank()) {
                return Result.failure(AppError.Unknown(message = EMPTY_TOKEN_MESSAGE))
            }
            tokenStorage.saveAccessToken(token)
            tryCreateSession(token)
            authStateManager.onLoginSuccess(token)
            Result.success(Unit)
        } catch (@Suppress("TooGenericExceptionCaught") e: Exception) {
            Result.failure(e.toAppError())
        }
    }

    suspend fun register(email: String, password: String): Result<Unit> {
        return try {
            val response = authApi.register(RegisterRequest(email = email, password = password))
            val token = response.token
            if (token.isBlank()) {
                return Result.failure(AppError.Unknown(message = EMPTY_TOKEN_MESSAGE))
            }
            tokenStorage.saveAccessToken(token)
            tryCreateSession(token)
            authStateManager.onLoginSuccess(token)
            Result.success(Unit)
        } catch (@Suppress("TooGenericExceptionCaught") e: Exception) {
            Result.failure(e.toAppError())
        }
    }

    suspend fun logout() {
        val token = tokenStorage.getAccessToken()
        if (token != null) {
            try {
                authApi.destroySession("Bearer $token")
            } catch (@Suppress("TooGenericExceptionCaught") e: Exception) {
                Timber.w(e, "Failed to destroy session on server, proceeding with local logout")
            }
        }
        authStateManager.onLogout()
    }

    @Suppress("LabeledExpression")
    suspend fun refreshToken(): Result<String> {
        return refreshMutex.withLock {
            try {
                val currentToken = tokenStorage.getAccessToken()
                    ?: return@withLock Result.failure(AppError.Unauthorized(message = "No token to refresh"))

                val response = authApi.refreshToken("Bearer $currentToken")
                val newToken = response.token
                if (newToken.isBlank()) {
                    return@withLock Result.failure(AppError.Unknown(message = EMPTY_TOKEN_MESSAGE))
                }
                tokenStorage.saveAccessToken(newToken)
                authStateManager.onLoginSuccess(newToken)
                Result.success(newToken)
            } catch (@Suppress("TooGenericExceptionCaught") e: Exception) {
                Timber.w(e, "Token refresh failed, clearing auth state")
                authStateManager.onLogout()
                Result.failure(e.toAppError())
            }
        }
    }

    private suspend fun tryCreateSession(token: String) {
        try {
            authApi.createSession("Bearer $token")
        } catch (@Suppress("TooGenericExceptionCaught") e: Exception) {
            Timber.w(e, "Session creation failed, continuing with valid token")
        }
    }

    companion object {
        private const val EMPTY_TOKEN_MESSAGE = "Empty token received"
    }
}
