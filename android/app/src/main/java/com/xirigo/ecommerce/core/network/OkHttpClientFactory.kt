package com.xirigo.ecommerce.core.network

import okhttp3.Cache
import okhttp3.OkHttpClient
import java.io.File
import java.util.concurrent.TimeUnit
import android.content.Context

object OkHttpClientFactory {

    fun create(
        context: Context,
        authInterceptor: AuthInterceptor,
        tokenRefreshAuthenticator: TokenRefreshAuthenticator,
    ): OkHttpClient {
        val cache = Cache(
            directory = File(context.cacheDir, "http_cache"),
            maxSize = NetworkConfig.CACHE_SIZE_BYTES,
        )

        return OkHttpClient.Builder()
            .connectTimeout(NetworkConfig.CONNECT_TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .readTimeout(NetworkConfig.READ_TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .writeTimeout(NetworkConfig.WRITE_TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .cache(cache)
            .addInterceptor(authInterceptor)
            .addInterceptor(RetryInterceptor())
            .addNetworkInterceptor(LoggingInterceptor.create())
            .authenticator(tokenRefreshAuthenticator)
            .build()
    }
}
