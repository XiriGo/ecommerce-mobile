package com.xirigo.ecommerce.core.di

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import javax.inject.Qualifier

class QualifiersTest {

    @Test
    fun `IoDispatcher annotation is a Qualifier`() {
        val annotations = IoDispatcher::class.java.annotations
        val hasQualifier = annotations.any { it is Qualifier }
        assertThat(hasQualifier).isTrue()
    }

    @Test
    fun `IoDispatcher annotation has BINARY retention`() {
        val retention = IoDispatcher::class.java.annotations
            .filterIsInstance<Retention>()
            .firstOrNull()
        assertThat(retention).isNotNull()
        assertThat(retention!!.value).isEqualTo(AnnotationRetention.BINARY)
    }

    @Test
    fun `MainDispatcher annotation is a Qualifier`() {
        val annotations = MainDispatcher::class.java.annotations
        val hasQualifier = annotations.any { it is Qualifier }
        assertThat(hasQualifier).isTrue()
    }

    @Test
    fun `MainDispatcher annotation has BINARY retention`() {
        val retention = MainDispatcher::class.java.annotations
            .filterIsInstance<Retention>()
            .firstOrNull()
        assertThat(retention).isNotNull()
        assertThat(retention!!.value).isEqualTo(AnnotationRetention.BINARY)
    }

    @Test
    fun `DefaultDispatcher annotation is a Qualifier`() {
        val annotations = DefaultDispatcher::class.java.annotations
        val hasQualifier = annotations.any { it is Qualifier }
        assertThat(hasQualifier).isTrue()
    }

    @Test
    fun `DefaultDispatcher annotation has BINARY retention`() {
        val retention = DefaultDispatcher::class.java.annotations
            .filterIsInstance<Retention>()
            .firstOrNull()
        assertThat(retention).isNotNull()
        assertThat(retention!!.value).isEqualTo(AnnotationRetention.BINARY)
    }

    @Test
    fun `AuthenticatedClient annotation is a Qualifier`() {
        val annotations = AuthenticatedClient::class.java.annotations
        val hasQualifier = annotations.any { it is Qualifier }
        assertThat(hasQualifier).isTrue()
    }

    @Test
    fun `AuthenticatedClient annotation has BINARY retention`() {
        val retention = AuthenticatedClient::class.java.annotations
            .filterIsInstance<Retention>()
            .firstOrNull()
        assertThat(retention).isNotNull()
        assertThat(retention!!.value).isEqualTo(AnnotationRetention.BINARY)
    }

    @Test
    fun `UnauthenticatedClient annotation is a Qualifier`() {
        val annotations = UnauthenticatedClient::class.java.annotations
        val hasQualifier = annotations.any { it is Qualifier }
        assertThat(hasQualifier).isTrue()
    }

    @Test
    fun `UnauthenticatedClient annotation has BINARY retention`() {
        val retention = UnauthenticatedClient::class.java.annotations
            .filterIsInstance<Retention>()
            .firstOrNull()
        assertThat(retention).isNotNull()
        assertThat(retention!!.value).isEqualTo(AnnotationRetention.BINARY)
    }

    @Test
    fun `all five qualifier annotation classes can be referenced`() {
        val qualifiers = listOf(
            IoDispatcher::class.java,
            MainDispatcher::class.java,
            DefaultDispatcher::class.java,
            AuthenticatedClient::class.java,
            UnauthenticatedClient::class.java,
        )
        assertThat(qualifiers).hasSize(5)
        qualifiers.forEach { clazz ->
            assertThat(clazz.isAnnotation).isTrue()
        }
    }
}
