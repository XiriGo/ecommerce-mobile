package com.xirigo.ecommerce.feature.onboarding.data.repository

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import com.xirigo.ecommerce.feature.onboarding.domain.repository.OnboardingRepository
import kotlinx.coroutines.flow.first
import timber.log.Timber
import java.io.IOException
import javax.inject.Inject

class OnboardingRepositoryImpl @Inject constructor(
    private val dataStore: DataStore<Preferences>,
) : OnboardingRepository {

    override suspend fun hasSeenOnboarding(): Boolean = try {
        dataStore.data.first()[HAS_SEEN_ONBOARDING] ?: false
    } catch (e: IOException) {
        Timber.e(e, "Failed to read onboarding flag from DataStore")
        false
    }

    override suspend fun setOnboardingSeen() {
        try {
            dataStore.edit { prefs ->
                prefs[HAS_SEEN_ONBOARDING] = true
            }
        } catch (e: IOException) {
            Timber.e(e, "Failed to write onboarding flag to DataStore")
        }
    }

    private companion object {
        val HAS_SEEN_ONBOARDING = booleanPreferencesKey("has_seen_onboarding")
    }
}
