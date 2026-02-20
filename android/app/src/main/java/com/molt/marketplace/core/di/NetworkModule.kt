package com.molt.marketplace.core.di

import android.content.Context
import com.molt.marketplace.BuildConfig
import com.molt.marketplace.core.network.ApiClient
import com.molt.marketplace.core.network.AuthInterceptor
import com.molt.marketplace.core.network.OkHttpClientFactory
import com.molt.marketplace.core.network.TokenProvider
import com.molt.marketplace.core.network.TokenRefreshAuthenticator
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonNamingStrategy
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import javax.inject.Singleton

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
    fun provideTokenProvider(): TokenProvider = InMemoryTokenProvider()

    @Provides
    @Singleton
    fun provideAuthInterceptor(tokenProvider: TokenProvider): AuthInterceptor =
        AuthInterceptor(tokenProvider)

    @Provides
    @Singleton
    fun provideTokenRefreshAuthenticator(tokenProvider: TokenProvider): TokenRefreshAuthenticator =
        TokenRefreshAuthenticator(tokenProvider)

    @Provides
    @Singleton
    fun provideOkHttpClient(
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
    fun provideRetrofit(
        okHttpClient: OkHttpClient,
        json: Json,
    ): Retrofit = ApiClient.createRetrofit(
        baseUrl = BuildConfig.API_BASE_URL,
        okHttpClient = okHttpClient,
        json = json,
    )
}

/**
 * No-op token provider placeholder. Replaced by a real implementation in M0-06 (Auth Infra).
 */
private class InMemoryTokenProvider : TokenProvider {
    override suspend fun getAccessToken(): String? = null
    override suspend fun refreshToken(): String? = null
    override suspend fun clearTokens() { /* no-op */ }
}
