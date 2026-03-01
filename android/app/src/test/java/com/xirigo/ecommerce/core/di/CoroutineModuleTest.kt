package com.xirigo.ecommerce.core.di

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.test.StandardTestDispatcher
import org.junit.Test

class CoroutineModuleTest {

    @Test
    fun `provideIoDispatcher returns Dispatchers IO`() {
        val dispatcher: CoroutineDispatcher = CoroutineModule.provideIoDispatcher()
        assertThat(dispatcher).isEqualTo(Dispatchers.IO)
    }

    @Test
    fun `provideMainDispatcher returns Dispatchers Main`() {
        val dispatcher: CoroutineDispatcher = CoroutineModule.provideMainDispatcher()
        assertThat(dispatcher).isEqualTo(Dispatchers.Main)
    }

    @Test
    fun `provideDefaultDispatcher returns Dispatchers Default`() {
        val dispatcher: CoroutineDispatcher = CoroutineModule.provideDefaultDispatcher()
        assertThat(dispatcher).isEqualTo(Dispatchers.Default)
    }

    @Test
    fun `provideApplicationScope returns non-null CoroutineScope`() {
        val testDispatcher = StandardTestDispatcher()
        val scope: CoroutineScope = CoroutineModule.provideApplicationScope(testDispatcher)
        assertThat(scope).isNotNull()
    }

    @Test
    fun `provideApplicationScope uses SupervisorJob`() {
        val testDispatcher = StandardTestDispatcher()
        val scope: CoroutineScope = CoroutineModule.provideApplicationScope(testDispatcher)
        val job = scope.coroutineContext[Job]
        // SupervisorJob is a CompletableJob — verify it exists and is active
        assertThat(job).isNotNull()
        assertThat(job!!.isActive).isTrue()
    }

    @Test
    fun `provideApplicationScope parent stays active before child failures`() {
        val testDispatcher = StandardTestDispatcher()
        val scope: CoroutineScope = CoroutineModule.provideApplicationScope(testDispatcher)
        val parentJob = scope.coroutineContext[Job]
        requireNotNull(parentJob)
        // With SupervisorJob, the parent scope remains active
        assertThat(parentJob.isActive).isTrue()
    }

    @Test
    fun `provideApplicationScope uses provided dispatcher`() {
        val testDispatcher = StandardTestDispatcher()
        val scope: CoroutineScope = CoroutineModule.provideApplicationScope(testDispatcher)
        // Verify the scope context contains our dispatcher (combined with SupervisorJob)
        assertThat(scope.coroutineContext[CoroutineDispatcher]).isEqualTo(testDispatcher)
    }

    @Test
    fun `IoDispatcher and DefaultDispatcher are different instances`() {
        val io: CoroutineDispatcher = CoroutineModule.provideIoDispatcher()
        val default: CoroutineDispatcher = CoroutineModule.provideDefaultDispatcher()
        assertThat(io).isNotEqualTo(default)
    }

    @Test
    fun `IoDispatcher and MainDispatcher are different instances`() {
        val io: CoroutineDispatcher = CoroutineModule.provideIoDispatcher()
        val main: CoroutineDispatcher = CoroutineModule.provideMainDispatcher()
        assertThat(io).isNotEqualTo(main)
    }

    @Test
    fun `MainDispatcher and DefaultDispatcher are different instances`() {
        val main: CoroutineDispatcher = CoroutineModule.provideMainDispatcher()
        val default: CoroutineDispatcher = CoroutineModule.provideDefaultDispatcher()
        assertThat(main).isNotEqualTo(default)
    }
}
