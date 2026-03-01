package com.xirigo.ecommerce.core.di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonNamingStrategy
import okhttp3.Cache
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import java.io.File
import java.util.concurrent.TimeUnit
import javax.inject.Singleton
import android.content.Context
import com.xirigo.ecommerce.BuildConfig
import com.xirigo.ecommerce.core.network.ApiClient
import com.xirigo.ecommerce.core.network.AuthInterceptor
import com.xirigo.ecommerce.core.network.LoggingInterceptor
import com.xirigo.ecommerce.core.network.NetworkConfig
import com.xirigo.ecommerce.core.network.OkHttpClientFactory
import com.xirigo.ecommerce.core.network.TokenProvider
import com.xirigo.ecommerce.core.network.TokenRefreshAuthenticator

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideJson(): Json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
        isLenient = true
        explicitNulls = false
        encodeDefaults = false
        @OptIn(kotlinx.serialization.ExperimentalSerializationApi::class)
        namingStrategy = JsonNamingStrategy.SnakeCase
    }

    @Provides
    @Singleton
    fun provideAuthInterceptor(tokenProvider: TokenProvider): AuthInterceptor = AuthInterceptor(tokenProvider)

    @Provides
    @Singleton
    fun provideTokenRefreshAuthenticator(tokenProvider: TokenProvider): TokenRefreshAuthenticator =
        TokenRefreshAuthenticator(tokenProvider)

    @Provides
    @Singleton
    @AuthenticatedClient
    fun provideAuthenticatedClient(
        @ApplicationContext context: Context,
        authInterceptor: AuthInterceptor,
        tokenRefreshAuthenticator: TokenRefreshAuthenticator,
    ): OkHttpClient = OkHttpClientFactory.create(
        context = context,
        authInterceptor = authInterceptor,
        tokenRefreshAuthenticator = tokenRefreshAuthenticator,
    )

    @Provides
    @Singleton
    @UnauthenticatedClient
    fun provideUnauthenticatedClient(@ApplicationContext context: Context): OkHttpClient {
        val cache = Cache(
            directory = File(context.cacheDir, "http_cache_public"),
            maxSize = NetworkConfig.CACHE_SIZE_BYTES,
        )
        return OkHttpClient.Builder()
            .connectTimeout(NetworkConfig.CONNECT_TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .readTimeout(NetworkConfig.READ_TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .writeTimeout(NetworkConfig.WRITE_TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .cache(cache)
            .addNetworkInterceptor(LoggingInterceptor.create())
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(@AuthenticatedClient okHttpClient: OkHttpClient, json: Json): Retrofit =
        ApiClient.createRetrofit(
            baseUrl = BuildConfig.API_BASE_URL,
            okHttpClient = okHttpClient,
            json = json,
        )
}
