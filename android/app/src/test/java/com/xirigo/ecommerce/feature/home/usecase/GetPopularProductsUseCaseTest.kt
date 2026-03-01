package com.xirigo.ecommerce.feature.home.usecase

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import java.io.IOException
import com.xirigo.ecommerce.feature.home.domain.model.HomeProduct
import com.xirigo.ecommerce.feature.home.domain.usecase.GetPopularProductsUseCase
import com.xirigo.ecommerce.feature.home.repository.FakeHomeRepository

class GetPopularProductsUseCaseTest {

    private lateinit var fakeRepository: FakeHomeRepository
    private lateinit var useCase: GetPopularProductsUseCase

    @Before
    fun setUp() {
        fakeRepository = FakeHomeRepository()
        useCase = GetPopularProductsUseCase(fakeRepository)
    }

    @Test
    fun `invoke returns popular products from repository`() = runTest {
        val result = useCase()

        assertThat(result).isEqualTo(fakeRepository.popularProducts)
    }

    @Test
    fun `invoke returns non-empty list when repository has products`() = runTest {
        val result = useCase()

        assertThat(result).isNotEmpty()
    }

    @Test
    fun `invoke returns empty list when repository has no products`() = runTest {
        fakeRepository.popularProducts = emptyList()

        val result = useCase()

        assertThat(result).isEmpty()
    }

    @Test
    fun `invoke returns custom products set on repository`() = runTest {
        val customProduct = HomeProduct(
            id = "test-prod",
            title = "Test Product",
            imageUrl = null,
            price = "10.00",
            currencyCode = "usd",
            originalPrice = null,
            vendor = "TestVendor",
            rating = 4.0f,
            reviewCount = 10,
            isNew = false,
        )
        fakeRepository.popularProducts = listOf(customProduct)

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

    @Test
    fun `invoke delegates to repository getPopularProducts`() = runTest {
        fakeRepository.popularProducts = listOf(
            HomeProduct("p1", "Product 1", null, "9.99", "usd", null, "Vendor", 4.5f, 100, false),
            HomeProduct("p2", "Product 2", null, "19.99", "usd", "29.99", "Vendor", 4.0f, 50, false),
        )

        val result = useCase()

        assertThat(result).hasSize(2)
        assertThat(result[0].id).isEqualTo("p1")
        assertThat(result[1].originalPrice).isEqualTo("29.99")
    }
}
