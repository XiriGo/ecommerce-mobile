package com.xirigo.ecommerce.feature.home.usecase

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import java.io.IOException
import com.xirigo.ecommerce.feature.home.domain.model.HomeCategory
import com.xirigo.ecommerce.feature.home.domain.usecase.GetHomeCategoriesUseCase
import com.xirigo.ecommerce.feature.home.repository.FakeHomeRepository

class GetHomeCategoriesUseCaseTest {

    private lateinit var fakeRepository: FakeHomeRepository
    private lateinit var useCase: GetHomeCategoriesUseCase

    @Before
    fun setUp() {
        fakeRepository = FakeHomeRepository()
        useCase = GetHomeCategoriesUseCase(fakeRepository)
    }

    @Test
    fun `invoke returns categories from repository`() = runTest {
        val result = useCase()

        assertThat(result).isEqualTo(fakeRepository.categories)
    }

    @Test
    fun `invoke returns non-empty list when repository has categories`() = runTest {
        val result = useCase()

        assertThat(result).isNotEmpty()
    }

    @Test
    fun `invoke returns empty list when repository has no categories`() = runTest {
        fakeRepository.categories = emptyList()

        val result = useCase()

        assertThat(result).isEmpty()
    }

    @Test
    fun `invoke returns custom categories set on repository`() = runTest {
        val customCategory = HomeCategory("cat-test", "Test", "test", "Icon", "#FFFFFF")
        fakeRepository.categories = listOf(customCategory)

        val result = useCase()

        assertThat(result).containsExactly(customCategory)
    }

    @Test
    fun `invoke propagates IOException from repository`() = runTest {
        val error = IOException("Network error")
        fakeRepository.shouldThrow = error

        var caught: IOException? = null
        try {
            useCase()
        } catch (e: IOException) {
            caught = e
        }

        assertThat(caught).isEqualTo(error)
    }

    @Test
    fun `invoke delegates to repository getCategories`() = runTest {
        fakeRepository.categories = listOf(
            HomeCategory("cat-1", "Electronics", "electronics", "Devices", "#37B4F2"),
            HomeCategory("cat-2", "Fashion", "fashion", "Checkroom", "#FE75D4"),
            HomeCategory("cat-3", "Home", "home-garden", "Home", "#FDF29C"),
        )

        val result = useCase()

        assertThat(result).hasSize(3)
        assertThat(result[0].id).isEqualTo("cat-1")
    }
}
