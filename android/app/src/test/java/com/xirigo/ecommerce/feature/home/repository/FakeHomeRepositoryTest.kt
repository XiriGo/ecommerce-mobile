package com.xirigo.ecommerce.feature.home.repository

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import java.io.IOException

class FakeHomeRepositoryTest {

    private lateinit var repository: FakeHomeRepository

    @Before
    fun setUp() {
        repository = FakeHomeRepository()
    }

    // region getBanners

    @Test
    fun `getBanners returns non-empty list by default`() = runTest {
        val result = repository.getBanners()

        assertThat(result).isNotEmpty()
    }

    @Test
    fun `getBanners returns correct number of banners`() = runTest {
        val result = repository.getBanners()

        assertThat(result).hasSize(2)
    }

    @Test
    fun `getBanners returns banners with valid ids`() = runTest {
        val result = repository.getBanners()

        result.forEach { banner ->
            assertThat(banner.id).isNotEmpty()
        }
    }

    @Test
    fun `getBanners throws when shouldThrow is set`() = runTest {
        val error = IOException("Network error")
        repository.shouldThrow = error

        var caught: IOException? = null
        try {
            repository.getBanners()
        } catch (e: IOException) {
            caught = e
        }

        assertThat(caught).isEqualTo(error)
    }

    @Test
    fun `getBanners returns custom banners when set`() = runTest {
        val customBanners = listOf(
            com.xirigo.ecommerce.feature.home.domain.model.HomeBanner(
                id = "custom-banner",
                title = "Custom",
                subtitle = "Custom subtitle",
                imageUrl = null,
                tag = null,
                actionProductId = null,
                actionCategoryId = null,
            ),
        )
        repository.banners = customBanners

        val result = repository.getBanners()

        assertThat(result).isEqualTo(customBanners)
    }

    // endregion

    // region getCategories

    @Test
    fun `getCategories returns non-empty list by default`() = runTest {
        val result = repository.getCategories()

        assertThat(result).isNotEmpty()
    }

    @Test
    fun `getCategories returns categories with valid ids`() = runTest {
        val result = repository.getCategories()

        result.forEach { category ->
            assertThat(category.id).isNotEmpty()
        }
    }

    @Test
    fun `getCategories throws when shouldThrow is set`() = runTest {
        repository.shouldThrow = IOException("Network error")

        var caught: IOException? = null
        try {
            repository.getCategories()
        } catch (e: IOException) {
            caught = e
        }

        assertThat(caught).isNotNull()
    }

    // endregion

    // region getPopularProducts

    @Test
    fun `getPopularProducts returns non-empty list by default`() = runTest {
        val result = repository.getPopularProducts()

        assertThat(result).isNotEmpty()
    }

    @Test
    fun `getPopularProducts returns products with valid ids`() = runTest {
        val result = repository.getPopularProducts()

        result.forEach { product ->
            assertThat(product.id).isNotEmpty()
        }
    }

    @Test
    fun `getPopularProducts throws when shouldThrow is set`() = runTest {
        repository.shouldThrow = IOException("Network error")

        var caught: IOException? = null
        try {
            repository.getPopularProducts()
        } catch (e: IOException) {
            caught = e
        }

        assertThat(caught).isNotNull()
    }

    // endregion

    // region getDailyDeal

    @Test
    fun `getDailyDeal returns non-null value by default`() = runTest {
        val result = repository.getDailyDeal()

        assertThat(result).isNotNull()
    }

    @Test
    fun `getDailyDeal endTime is in the future`() = runTest {
        val result = repository.getDailyDeal()

        assertThat(result).isNotNull()
        assertThat(result!!.endTime).isGreaterThan(System.currentTimeMillis())
    }

    @Test
    fun `getDailyDeal returns null when set to null`() = runTest {
        repository.dailyDeal = null

        val result = repository.getDailyDeal()

        assertThat(result).isNull()
    }

    @Test
    fun `getDailyDeal throws when shouldThrow is set`() = runTest {
        repository.shouldThrow = IOException("Network error")

        var caught: IOException? = null
        try {
            repository.getDailyDeal()
        } catch (e: IOException) {
            caught = e
        }

        assertThat(caught).isNotNull()
    }

    // endregion

    // region getNewArrivals

    @Test
    fun `getNewArrivals returns non-empty list by default`() = runTest {
        val result = repository.getNewArrivals()

        assertThat(result).isNotEmpty()
    }

    @Test
    fun `getNewArrivals returns products with isNew true`() = runTest {
        val result = repository.getNewArrivals()

        result.forEach { product ->
            assertThat(product.isNew).isTrue()
        }
    }

    @Test
    fun `getNewArrivals throws when shouldThrow is set`() = runTest {
        repository.shouldThrow = IOException("Network error")

        var caught: IOException? = null
        try {
            repository.getNewArrivals()
        } catch (e: IOException) {
            caught = e
        }

        assertThat(caught).isNotNull()
    }

    // endregion

    // region getFlashSale

    @Test
    fun `getFlashSale returns non-null value by default`() = runTest {
        val result = repository.getFlashSale()

        assertThat(result).isNotNull()
    }

    @Test
    fun `getFlashSale returns flash sale with valid id`() = runTest {
        val result = repository.getFlashSale()

        assertThat(result).isNotNull()
        assertThat(result!!.id).isNotEmpty()
    }

    @Test
    fun `getFlashSale returns null when set to null`() = runTest {
        repository.flashSale = null

        val result = repository.getFlashSale()

        assertThat(result).isNull()
    }

    @Test
    fun `getFlashSale throws when shouldThrow is set`() = runTest {
        repository.shouldThrow = IOException("Network error")

        var caught: IOException? = null
        try {
            repository.getFlashSale()
        } catch (e: IOException) {
            caught = e
        }

        assertThat(caught).isNotNull()
    }

    // endregion
}
