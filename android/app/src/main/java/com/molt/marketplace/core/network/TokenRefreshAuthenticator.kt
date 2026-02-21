package com.molt.marketplace.core.network

import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import okhttp3.Authenticator
import okhttp3.Request
import okhttp3.Response
import okhttp3.Route
import timber.log.Timber
import javax.inject.Inject

class TokenRefreshAuthenticator @Inject constructor(
    private val tokenProvider: TokenProvider,
) : Authenticator {

    private val mutex = Mutex()

    override fun authenticate(route: Route?, response: Response): Request? {
        if (responseCount(response) >= MAX_RETRY_COUNT) {
            Timber.w("Token refresh retry limit reached")
            return null
        }

        return runBlocking {
            mutex.withLock {
                val failedToken = extractFailedToken(response)
                val currentToken = tokenProvider.getAccessToken()
                resolveToken(response.request, failedToken, currentToken)
            }
        }
    }

    private fun extractFailedToken(response: Response): String? =
        response.request.header("Authorization")?.removePrefix("Bearer ")

    private suspend fun resolveToken(
        request: Request,
        failedToken: String?,
        currentToken: String?,
    ): Request? {
        if (currentToken != null && currentToken != failedToken) {
            return rebuildRequestWithToken(request, currentToken)
        }
        val newToken = tokenProvider.refreshToken()
        if (newToken != null) {
            return rebuildRequestWithToken(request, newToken)
        }
        Timber.w("Token refresh failed, clearing tokens")
        tokenProvider.clearTokens()
        return null
    }

    private fun rebuildRequestWithToken(request: Request, token: String): Request {
        return request.newBuilder()
            .header("Authorization", "Bearer $token")
            .build()
    }

    private fun responseCount(response: Response): Int {
        var count = 1
        var prior = response.priorResponse
        while (prior != null) {
            count++
            prior = prior.priorResponse
        }
        return count
    }

    companion object {
        private const val MAX_RETRY_COUNT = 2
    }
}
