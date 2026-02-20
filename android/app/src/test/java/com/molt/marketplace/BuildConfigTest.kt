package com.molt.marketplace

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class BuildConfigTest {

    @Test
    fun `application id should match namespace`() {
        // BuildConfig.APPLICATION_ID is generated based on build variant
        // In unit tests, it defaults to the debug variant
        assertThat(BuildConfig.APPLICATION_ID).isNotEmpty()
        assertThat(BuildConfig.APPLICATION_ID).contains("com.molt.marketplace")
    }

    @Test
    fun `version code should be positive`() {
        assertThat(BuildConfig.VERSION_CODE).isGreaterThan(0)
    }

    @Test
    fun `version name should follow semantic versioning pattern`() {
        assertThat(BuildConfig.VERSION_NAME).isNotEmpty()
        assertThat(BuildConfig.VERSION_NAME).matches("\\d+\\.\\d+\\.\\d+")
    }

    @Test
    fun `api base url should be valid https url`() {
        assertThat(BuildConfig.API_BASE_URL).isNotEmpty()
        assertThat(BuildConfig.API_BASE_URL).startsWith("https://")
        assertThat(BuildConfig.API_BASE_URL).contains("molt.mt")
    }

    @Test
    fun `build type should be a known variant`() {
        assertThat(BuildConfig.BUILD_TYPE).isIn(listOf("debug", "release", "staging"))
    }
}
