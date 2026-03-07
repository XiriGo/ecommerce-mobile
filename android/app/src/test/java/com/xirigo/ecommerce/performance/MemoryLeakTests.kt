package com.xirigo.ecommerce.performance

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.lang.ref.WeakReference

/**
 * Memory leak detection tests for ViewModels and key objects.
 * Maps to ANDROID_TEST.md Section 6.2 — Memory Leak Detection.
 *
 * These are JVM-level tests (no emulator needed).
 * Runtime leak detection is handled by LeakCanary in debug builds.
 */
class MemoryLeakTests {

    private val maxTestMemoryMB = 512.0

    @Test
    fun `test process memory baseline is reasonable`() {
        val runtime = Runtime.getRuntime()
        val usedMemoryMB = (runtime.totalMemory() - runtime.freeMemory()) / BYTES_PER_MB

        assertThat(usedMemoryMB).isLessThan(maxTestMemoryMB)
    }

    // NOTE: Add specific ViewModel leak tests as features are implemented.
    // Example pattern:
    //
    // @Test
    // fun `homeViewModel is deallocated after clear`() {
    //     assertNoDeallocLeak {
    //         val repo = FakeHomeRepository()
    //         HomeViewModel(
    //             getBannersUseCase = GetHomeBannersUseCase(repo),
    //             getCategoriesUseCase = GetHomeCategoriesUseCase(repo),
    //         )
    //     }
    // }

    @Suppress("UnusedPrivateMember", "ExplicitGarbageCollectionCall")
    private fun <T : Any> assertNoDeallocLeak(factory: () -> T) {
        var instance: T? = factory()
        val weakRef = WeakReference(instance)
        instance = null

        System.gc()
        Thread.sleep(GC_SETTLE_MS)

        assertThat(weakRef.get()).isNull()
    }

    companion object {
        private const val BYTES_PER_MB = 1_048_576.0
        private const val GC_SETTLE_MS = 100L
    }
}
