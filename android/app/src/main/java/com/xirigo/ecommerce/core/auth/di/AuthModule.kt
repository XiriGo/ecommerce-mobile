package com.xirigo.ecommerce.core.auth.di

import com.google.crypto.tink.Aead
import com.google.crypto.tink.KeyTemplates
import com.google.crypto.tink.KeysetHandle
import com.google.crypto.tink.RegistryConfiguration
import com.google.crypto.tink.aead.AeadConfig
import com.google.crypto.tink.integration.android.AndroidKeysetManager
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import javax.inject.Singleton
import android.content.Context
import com.xirigo.ecommerce.BuildConfig
import com.xirigo.ecommerce.core.auth.AuthApi
import com.xirigo.ecommerce.core.auth.AuthStateManager
import com.xirigo.ecommerce.core.auth.AuthStateManagerImpl
import com.xirigo.ecommerce.core.auth.EncryptedTokenStorage
import com.xirigo.ecommerce.core.auth.SessionManager
import com.xirigo.ecommerce.core.auth.TokenStorage
import com.xirigo.ecommerce.core.di.UnauthenticatedClient
import com.xirigo.ecommerce.core.network.ApiClient
import com.xirigo.ecommerce.core.network.TokenProvider

@Module
@InstallIn(SingletonComponent::class)
abstract class AuthBindsModule {

    @Binds
    @Singleton
    abstract fun bindTokenStorage(impl: EncryptedTokenStorage): TokenStorage

    @Binds
    @Singleton
    abstract fun bindAuthStateManager(impl: AuthStateManagerImpl): AuthStateManager
}

@Module
@InstallIn(SingletonComponent::class)
object AuthProvidesModule {

    private const val KEYSET_NAME = "xg_auth_keyset"
    private const val PREF_FILE_NAME = "xg_auth_keyset_prefs"
    private const val MASTER_KEY_URI = "android-keystore://xg_auth_master_key"

    @Provides
    @Singleton
    fun provideAead(@ApplicationContext context: Context): Aead {
        AeadConfig.register()
        val keysetHandle: KeysetHandle = AndroidKeysetManager.Builder()
            .withSharedPref(context, KEYSET_NAME, PREF_FILE_NAME)
            .withKeyTemplate(KeyTemplates.get("AES256_GCM"))
            .withMasterKeyUri(MASTER_KEY_URI)
            .build()
            .keysetHandle
        return keysetHandle.getPrimitive(RegistryConfiguration.get(), Aead::class.java)
    }

    @Provides
    @Singleton
    fun provideAuthApi(@UnauthenticatedClient okHttpClient: OkHttpClient, json: Json): AuthApi {
        val retrofit: Retrofit = ApiClient.createRetrofit(
            baseUrl = BuildConfig.API_BASE_URL,
            okHttpClient = okHttpClient,
            json = json,
        )
        return retrofit.create(AuthApi::class.java)
    }

    @Provides
    @Singleton
    fun provideTokenProvider(tokenStorage: TokenStorage, sessionManager: dagger.Lazy<SessionManager>): TokenProvider =
        SessionTokenProvider(tokenStorage, sessionManager)
}

private class SessionTokenProvider(
    private val tokenStorage: TokenStorage,
    private val sessionManager: dagger.Lazy<SessionManager>,
) : TokenProvider {

    override suspend fun getAccessToken(): String? = tokenStorage.getAccessToken()

    override suspend fun refreshToken(): String? = sessionManager.get().refreshToken().getOrNull()

    override suspend fun clearTokens() {
        tokenStorage.clearTokens()
    }
}
