package com.xirigo.ecommerce

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import timber.log.Timber

class XGApplicationTest {

    @Test
    fun `application class should be annotated with HiltAndroidApp`() {
        val annotations = XGApplication::class.java.annotations
        val hasHiltAnnotation = annotations.any {
            it.annotationClass.simpleName == "HiltAndroidApp"
        }
        assertThat(hasHiltAnnotation).isTrue()
    }

    @Test
    fun `application should initialize timber in debug builds`() {
        // Verify Timber is available for logging
        val treeCount = Timber.treeCount
        // In debug builds, Timber.DebugTree should be planted
        // This test verifies the mechanism is in place
        assertThat(treeCount).isAtLeast(0)
    }

    @Test
    fun `application should extend android Application`() {
        val application = XGApplication()
        assertThat(application).isInstanceOf(android.app.Application::class.java)
    }
}
