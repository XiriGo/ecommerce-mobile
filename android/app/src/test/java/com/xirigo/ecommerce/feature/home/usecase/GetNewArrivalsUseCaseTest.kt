package com.xirigo.ecommerce.feature.home.usecase

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import java.io.IOException
import com.xirigo.ecommerce.feature.home.domain.model.HomeProduct
import com.xirigo.ecommerce.feature.home.domain.usecase.GetNewArrivalsUseCase
import com.xirigo.ecommerce.feature.home.repository.FakeHomeRepository

class GetNewArrivalsUseCaseTest {

    private lateinit var fakeRepository: FakeHomeRepository
    private lateinit var useCase: GetNewArrivalsUseCase

    @Before
    fun setUp() {
        fakeRepository = FakeHomeRepository()
        useCase = GetNewArrivalsUseCase(fakeRepository)
    }

    @Test
    fun `invoke returns new arrivals from repository`() = runTest {
        val result = useCase()

        assertThat(result).isEqualTo(fakeRepository.newArrivals)
    }

    @Test
    fun `invoke returns non-empty list when repository has new arrivals`() = runTest {
        val result = useCase()

        assertThat(result).isNotEmpty()
    }

    @Test
    fun `invoke returns empty list when repository has no new arrivals`() = runTest {
        fakeRepository.newArrivals = emptyList()

        val result = useCase()

        assertThat(result).isEmpty()
    }

    @Test
    fun `invoke returns products all marked as isNew`() = runTest {
        val result = useCase()

        result.forEach { product ->
            assertThat(product.isNew).isTrue()
        }
    }

    @Test
    fun `invoke returns custom new arrivals set on repository`() = runTest {
        val customProduct = HomeProduct(
            id = "new-test",
            title = "New Test Product",
            imageUrl = null,
            price = "25.00",
            currencyCode = "usd",
            originalPrice = null,
            vendor = "NewBrand",
            rating = 4.2f,
            reviewCount = 5,
            isNew = true,
        )
        fakeRepository.newArrivals = listOf(customProduct)

        val result = useCase()

        assertThat(result).containsExactly(customProduct)
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
}
