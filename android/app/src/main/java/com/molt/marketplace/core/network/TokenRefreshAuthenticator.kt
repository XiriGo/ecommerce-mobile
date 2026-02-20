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
                val failedToken = response.request.header("Authorization")
                    ?.removePrefix("Bearer ")

                val currentToken = tokenProvider.getAccessToken()

                if (currentToken != null && currentToken != failedToken) {
                    rebuildRequestWithToken(response.request, currentToken)
                } else {
                    val newToken = tokenProvider.refreshToken()
                    if (newToken != null) {
                        rebuildRequestWithToken(response.request, newToken)
                    } else {
                        Timber.w("Token refresh failed, clearing tokens")
                        tokenProvider.clearTokens()
                        null
                    }
                }
            }
        }
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
