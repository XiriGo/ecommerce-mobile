package com.molt.marketplace.core.auth

import com.google.crypto.tink.Aead
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import timber.log.Timber
import java.io.IOException
import java.security.GeneralSecurityException
import java.util.Base64
import javax.inject.Inject
import javax.inject.Singleton
import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore

private val Context.authDataStore: DataStore<Preferences> by preferencesDataStore(
    name = "molt_auth_encrypted",
)

@Singleton
class EncryptedTokenStorage @Inject constructor(
    @ApplicationContext private val context: Context,
    private val aead: Aead,
) : TokenStorage {

    private val dataStore: DataStore<Preferences> get() = context.authDataStore

    override suspend fun getAccessToken(): String? {
        return try {
            val preferences = dataStore.data.first()
            val encrypted = preferences[KEY_ACCESS_TOKEN] ?: return null
            decrypt(encrypted)
        } catch (e: GeneralSecurityException) {
            Timber.w(e, "Failed to read access token, clearing corrupted data")
            clearTokens()
            null
        } catch (e: IOException) {
            Timber.w(e, "Failed to read access token, clearing corrupted data")
            clearTokens()
            null
        }
    }

    override suspend fun saveAccessToken(token: String) {
        val encrypted = encrypt(token)
        dataStore.edit { preferences ->
            preferences[KEY_ACCESS_TOKEN] = encrypted
        }
    }

    override suspend fun clearTokens() {
        dataStore.edit { preferences ->
            preferences.remove(KEY_ACCESS_TOKEN)
        }
    }

    override fun getAccessTokenFlow(): Flow<String?> {
        return dataStore.data.map { preferences ->
            decryptTokenFromPreferences(preferences)
        }
    }

    private fun decryptTokenFromPreferences(preferences: Preferences): String? {
        val encrypted = preferences[KEY_ACCESS_TOKEN] ?: return null
        return try {
            decrypt(encrypted)
        } catch (e: GeneralSecurityException) {
            Timber.w(e, "Failed to decrypt token in flow")
            null
        } catch (e: IOException) {
            Timber.w(e, "Failed to decrypt token in flow")
            null
        }
    }

    private fun encrypt(plaintext: String): String {
        val ciphertext = aead.encrypt(plaintext.toByteArray(Charsets.UTF_8), ASSOCIATED_DATA)
        return Base64.getEncoder().encodeToString(ciphertext)
    }

    private fun decrypt(base64Ciphertext: String): String {
        val ciphertext = Base64.getDecoder().decode(base64Ciphertext)
        val plaintext = aead.decrypt(ciphertext, ASSOCIATED_DATA)
        return String(plaintext, Charsets.UTF_8)
    }

    companion object {
        private val KEY_ACCESS_TOKEN = stringPreferencesKey("access_token")
        private val ASSOCIATED_DATA = "molt_auth_token".toByteArray(Charsets.UTF_8)
    }
}
