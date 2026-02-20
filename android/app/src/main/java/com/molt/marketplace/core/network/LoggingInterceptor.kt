package com.molt.marketplace.core.network

import com.molt.marketplace.BuildConfig
import okhttp3.logging.HttpLoggingInterceptor
import timber.log.Timber

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
