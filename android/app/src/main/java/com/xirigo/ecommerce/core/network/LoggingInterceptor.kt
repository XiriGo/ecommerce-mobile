package com.xirigo.ecommerce.core.network

import okhttp3.logging.HttpLoggingInterceptor
import timber.log.Timber
import com.xirigo.ecommerce.BuildConfig

object LoggingInterceptor {

    fun create(): HttpLoggingInterceptor {
        val logger = HttpLoggingInterceptor.Logger { message ->
            Timber.tag("OkHttp").d(message)
        }

        return HttpLoggingInterceptor(logger).apply {
            level = if (BuildConfig.DEBUG) {
                HttpLoggingInterceptor.Level.BODY
            } else {
                HttpLoggingInterceptor.Level.NONE
            }
        }
    }
}
