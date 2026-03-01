package com.xirigo.ecommerce.feature.home.usecase

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import java.io.IOException
import com.xirigo.ecommerce.feature.home.domain.model.FlashSale
import com.xirigo.ecommerce.feature.home.domain.usecase.GetFlashSaleUseCase
import com.xirigo.ecommerce.feature.home.repository.FakeHomeRepository

class GetFlashSaleUseCaseTest {

    private lateinit var fakeRepository: FakeHomeRepository
    private lateinit var useCase: GetFlashSaleUseCase

    @Before
    fun setUp() {
        fakeRepository = FakeHomeRepository()
        useCase = GetFlashSaleUseCase(fakeRepository)
    }

    @Test
    fun `invoke returns flash sale from repository`() = runTest {
        val result = useCase()

        assertThat(result).isEqualTo(fakeRepository.flashSale)
    }

    @Test
    fun `invoke returns non-null flash sale when repository has sale`() = runTest {
        val result = useCase()

        assertThat(result).isNotNull()
    }

    @Test
    fun `invoke returns null when repository has no flash sale`() = runTest {
        fakeRepository.flashSale = null

        val result = useCase()

        assertThat(result).isNull()
    }

    @Test
    fun `invoke returns custom flash sale set on repository`() = runTest {
        val customSale = FlashSale(
            id = "sale-test",
            title = "Test Flash Sale",
            imageUrl = "https://example.com/sale.jpg",
            actionUrl = "https://example.com/action",
        )
        fakeRepository.flashSale = customSale

        val result = useCase()

        assertThat(result).isEqualTo(customSale)
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
    fun `invoke delegates to repository getFlashSale`() = runTest {
        fakeRepository.flashSale = FlashSale(
            id = "flash-unique",
            title = "Big Sale",
            imageUrl = null,
            actionUrl = null,
        )

        val result = useCase()

        assertThat(result).isNotNull()
        assertThat(result!!.id).isEqualTo("flash-unique")
        assertThat(result.title).isEqualTo("Big Sale")
    }
}
