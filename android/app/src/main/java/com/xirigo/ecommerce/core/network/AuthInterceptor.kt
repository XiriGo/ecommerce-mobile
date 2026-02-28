package com.xirigo.ecommerce.core.network

import kotlinx.coroutines.runBlocking
import okhttp3.Interceptor
import okhttp3.Response
import javax.inject.Inject

class AuthInterceptor @Inject constructor(
    private val tokenProvider: TokenProvider,
) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()
        val requestBuilder = originalRequest.newBuilder()
            .header("Accept", "application/json")

        if (!isPublicEndpoint(originalRequest.url.encodedPath) &&
            originalRequest.header("Authorization") == null
        ) {
            val token = runBlocking { tokenProvider.getAccessToken() }
            if (token != null) {
                requestBuilder.header("Authorization", "Bearer $token")
            }
        }

        return chain.proceed(requestBuilder.build())
    }

    private fun isPublicEndpoint(path: String): Boolean {
        return path.endsWith("/auth/customer/emailpass") ||
            path.endsWith("/auth/customer/emailpass/register")
    }
}
