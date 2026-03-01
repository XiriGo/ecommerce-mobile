package com.xirigo.ecommerce.core.auth

import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.serialization.SerializationException
import retrofit2.HttpException
import timber.log.Timber
import java.io.IOException
import javax.inject.Inject
import javax.inject.Singleton
import com.xirigo.ecommerce.core.auth.dto.LoginRequest
import com.xirigo.ecommerce.core.auth.dto.RegisterRequest
import com.xirigo.ecommerce.core.domain.error.AppError
import com.xirigo.ecommerce.core.network.ApiErrorMapper.toAppError

@Singleton
class SessionManager @Inject constructor(
    private val authApi: AuthApi,
    private val tokenStorage: TokenStorage,
    private val authStateManager: AuthStateManager,
) {

    private val refreshMutex = Mutex()

    suspend fun login(email: String, password: String): Result<Unit> = runAuthCall {
        val response = authApi.login(LoginRequest(email = email, password = password))
        processAuthToken(response.token)
    }

    suspend fun register(email: String, password: String): Result<Unit> = runAuthCall {
        val response = authApi.register(RegisterRequest(email = email, password = password))
        processAuthToken(response.token)
    }

    private suspend fun processAuthToken(token: String): Result<Unit> {
        if (token.isBlank()) {
            return Result.failure(AppError.Unknown(message = EMPTY_TOKEN_MESSAGE))
        }
        tokenStorage.saveAccessToken(token)
        tryCreateSession(token)
        authStateManager.onLoginSuccess(token)
        return Result.success(Unit)
    }

    suspend fun logout() {
        val token = tokenStorage.getAccessToken()
        if (token != null) {
            runCatching { authApi.destroySession("Bearer $token") }
                .onFailure { logApiWarning(it, LOG_DESTROY_SESSION_FAILED) }
        }
        authStateManager.onLogout()
    }

    suspend fun refreshToken(): Result<String> = refreshMutex.withLock {
        executeTokenRefresh()
    }

    private suspend fun executeTokenRefresh(): Result<String> {
        return try {
            val currentToken = tokenStorage.getAccessToken()
                ?: return Result.failure(AppError.Unauthorized(message = "No token to refresh"))

            val response = authApi.refreshToken("Bearer $currentToken")
            val newToken = response.token
            if (newToken.isBlank()) {
                return Result.failure(AppError.Unknown(message = EMPTY_TOKEN_MESSAGE))
            }
            tokenStorage.saveAccessToken(newToken)
            authStateManager.onLoginSuccess(newToken)
            Result.success(newToken)
        } catch (e: HttpException) {
            handleRefreshFailure(e)
        } catch (e: IOException) {
            handleRefreshFailure(e)
        } catch (e: SerializationException) {
            handleRefreshFailure(e)
        }
    }

    private suspend fun handleRefreshFailure(exception: Throwable): Result<String> {
        Timber.w(exception, LOG_REFRESH_FAILED)
        authStateManager.onLogout()
        return Result.failure(exception.toAppError())
    }

    private suspend fun tryCreateSession(token: String) {
        runCatching { authApi.createSession("Bearer $token") }
            .onFailure { logApiWarning(it, LOG_SESSION_CREATION_FAILED) }
    }

    private fun logApiWarning(throwable: Throwable, message: String) {
        Timber.w(throwable, message)
    }

    private suspend inline fun runAuthCall(crossinline block: suspend () -> Result<Unit>): Result<Unit> {
        return try {
            block()
        } catch (e: HttpException) {
            Result.failure(e.toAppError())
        } catch (e: IOException) {
            Result.failure(e.toAppError())
        } catch (e: SerializationException) {
            Result.failure(e.toAppError())
        }
    }

    companion object {
        private const val EMPTY_TOKEN_MESSAGE = "Empty token received"
        private const val LOG_DESTROY_SESSION_FAILED =
            "Failed to destroy session on server, proceeding with local logout"
        private const val LOG_REFRESH_FAILED = "Token refresh failed, clearing auth state"
        private const val LOG_SESSION_CREATION_FAILED =
            "Session creation failed, continuing with valid token"
    }
}
