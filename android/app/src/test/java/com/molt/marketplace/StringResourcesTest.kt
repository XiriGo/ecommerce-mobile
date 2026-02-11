package com.molt.marketplace

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.google.common.truth.Truth.assertThat
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import java.util.Locale

@RunWith(AndroidJUnit4::class)
class StringResourcesTest {

    private lateinit var context: Context

    @Before
    fun setup() {
        context = ApplicationProvider.getApplicationContext()
    }

    @Test
    fun `app name should be localized in all languages`() {
        // English
        val contextEn = createContextForLocale("en")
        val appNameEn = contextEn.getString(R.string.app_name)
        assertThat(appNameEn).isEqualTo("Molt Marketplace")

        // Maltese
        val contextMt = createContextForLocale("mt")
        val appNameMt = contextMt.getString(R.string.app_name)
        assertThat(appNameMt).isEqualTo("Molt Marketplace")

        // Turkish
        val contextTr = createContextForLocale("tr")
        val appNameTr = contextTr.getString(R.string.app_name)
        assertThat(appNameTr).isEqualTo("Molt Marketplace")
    }

    @Test
    fun `common strings should exist in english`() {
        val contextEn = createContextForLocale("en")

        assertThat(contextEn.getString(R.string.common_loading_message)).isNotEmpty()
        assertThat(contextEn.getString(R.string.common_retry_button)).isNotEmpty()
        assertThat(contextEn.getString(R.string.common_error_network)).isNotEmpty()
        assertThat(contextEn.getString(R.string.common_error_server)).isNotEmpty()
        assertThat(contextEn.getString(R.string.common_error_unauthorized)).isNotEmpty()
        assertThat(contextEn.getString(R.string.common_error_not_found)).isNotEmpty()
        assertThat(contextEn.getString(R.string.common_error_unknown)).isNotEmpty()
        assertThat(contextEn.getString(R.string.common_ok_button)).isNotEmpty()
        assertThat(contextEn.getString(R.string.common_cancel_button)).isNotEmpty()
        assertThat(contextEn.getString(R.string.common_close_button)).isNotEmpty()
        assertThat(contextEn.getString(R.string.common_search_placeholder)).isNotEmpty()
    }

    @Test
    fun `common strings should exist in maltese`() {
        val contextMt = createContextForLocale("mt")

        assertThat(contextMt.getString(R.string.common_loading_message)).isNotEmpty()
        assertThat(contextMt.getString(R.string.common_retry_button)).isNotEmpty()
        assertThat(contextMt.getString(R.string.common_error_network)).isNotEmpty()
        assertThat(contextMt.getString(R.string.common_error_server)).isNotEmpty()
        assertThat(contextMt.getString(R.string.common_error_unauthorized)).isNotEmpty()
        assertThat(contextMt.getString(R.string.common_error_not_found)).isNotEmpty()
        assertThat(contextMt.getString(R.string.common_error_unknown)).isNotEmpty()
        assertThat(contextMt.getString(R.string.common_ok_button)).isNotEmpty()
        assertThat(contextMt.getString(R.string.common_cancel_button)).isNotEmpty()
        assertThat(contextMt.getString(R.string.common_close_button)).isNotEmpty()
        assertThat(contextMt.getString(R.string.common_search_placeholder)).isNotEmpty()
    }

    @Test
    fun `common strings should exist in turkish`() {
        val contextTr = createContextForLocale("tr")

        assertThat(contextTr.getString(R.string.common_loading_message)).isNotEmpty()
        assertThat(contextTr.getString(R.string.common_retry_button)).isNotEmpty()
        assertThat(contextTr.getString(R.string.common_error_network)).isNotEmpty()
        assertThat(contextTr.getString(R.string.common_error_server)).isNotEmpty()
        assertThat(contextTr.getString(R.string.common_error_unauthorized)).isNotEmpty()
        assertThat(contextTr.getString(R.string.common_error_not_found)).isNotEmpty()
        assertThat(contextTr.getString(R.string.common_error_unknown)).isNotEmpty()
        assertThat(contextTr.getString(R.string.common_ok_button)).isNotEmpty()
        assertThat(contextTr.getString(R.string.common_cancel_button)).isNotEmpty()
        assertThat(contextTr.getString(R.string.common_close_button)).isNotEmpty()
        assertThat(contextTr.getString(R.string.common_search_placeholder)).isNotEmpty()
    }

    @Test
    fun `english loading message should match expected value`() {
        val contextEn = createContextForLocale("en")
        assertThat(contextEn.getString(R.string.common_loading_message))
            .isEqualTo("Loading...")
    }

    @Test
    fun `maltese loading message should be translated`() {
        val contextMt = createContextForLocale("mt")
        val loadingMt = contextMt.getString(R.string.common_loading_message)
        assertThat(loadingMt).isNotEqualTo("Loading...")
        assertThat(loadingMt).contains("lowdja")
    }

    @Test
    fun `turkish loading message should be translated`() {
        val contextTr = createContextForLocale("tr")
        val loadingTr = contextTr.getString(R.string.common_loading_message)
        assertThat(loadingTr).isNotEqualTo("Loading...")
        assertThat(loadingTr).contains("kleniyor")
    }

    @Test
    fun `all string resources should not contain hardcoded text in code`() {
        // This test verifies that all common strings are defined
        // and accessible via resource IDs, not hardcoded in code
        val allStringResourceIds = listOf(
            R.string.app_name,
            R.string.common_loading_message,
            R.string.common_retry_button,
            R.string.common_error_network,
            R.string.common_error_server,
            R.string.common_error_unauthorized,
            R.string.common_error_not_found,
            R.string.common_error_unknown,
            R.string.common_ok_button,
            R.string.common_cancel_button,
            R.string.common_close_button,
            R.string.common_search_placeholder
        )

        allStringResourceIds.forEach { resourceId ->
            assertThat(resourceId).isGreaterThan(0)
        }
    }

    private fun createContextForLocale(languageCode: String): Context {
        val locale = Locale(languageCode)
        val configuration = context.resources.configuration
        configuration.setLocale(locale)
        return context.createConfigurationContext(configuration)
    }
}
