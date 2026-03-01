package com.xirigo.ecommerce.feature.home.usecase

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import java.io.IOException
import com.xirigo.ecommerce.feature.home.domain.model.DailyDeal
import com.xirigo.ecommerce.feature.home.domain.usecase.GetDailyDealUseCase
import com.xirigo.ecommerce.feature.home.repository.FakeHomeRepository

class GetDailyDealUseCaseTest {

    private lateinit var fakeRepository: FakeHomeRepository
    private lateinit var useCase: GetDailyDealUseCase

    @Before
    fun setUp() {
        fakeRepository = FakeHomeRepository()
        useCase = GetDailyDealUseCase(fakeRepository)
    }

    @Test
    fun `invoke returns daily deal from repository`() = runTest {
        val result = useCase()

        assertThat(result).isEqualTo(fakeRepository.dailyDeal)
    }

    @Test
    fun `invoke returns non-null deal when repository has deal`() = runTest {
        val result = useCase()

        assertThat(result).isNotNull()
    }

    @Test
    fun `invoke returns null when repository has no deal`() = runTest {
        fakeRepository.dailyDeal = null

        val result = useCase()

        assertThat(result).isNull()
    }

    @Test
    fun `invoke returns custom deal set on repository`() = runTest {
        val endTime = System.currentTimeMillis() + 3_600_000L
        val customDeal = DailyDeal(
            productId = "deal-test",
            title = "Test Deal",
            imageUrl = null,
            price = "49.99",
            originalPrice = "99.99",
            currencyCode = "usd",
            endTime = endTime,
        )
        fakeRepository.dailyDeal = customDeal

        val result = useCase()

        assertThat(result).isEqualTo(customDeal)
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
    fun `invoke returns deal with endTime in the future`() = runTest {
        val result = useCase()

        assertThat(result).isNotNull()
        assertThat(result!!.endTime).isGreaterThan(System.currentTimeMillis())
    }
}
