package com.xirigo.ecommerce.feature.onboarding.usecase

import com.google.common.truth.Truth.assertThat
import com.xirigo.ecommerce.feature.onboarding.domain.usecase.CheckOnboardingUseCase
import com.xirigo.ecommerce.feature.onboarding.repository.FakeOnboardingRepository
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test

class CheckOnboardingUseCaseTest {

    private lateinit var fakeRepository: FakeOnboardingRepository
    private lateinit var useCase: CheckOnboardingUseCase

    @Before
    fun setUp() {
        fakeRepository = FakeOnboardingRepository()
        useCase = CheckOnboardingUseCase(fakeRepository)
    }

    @Test
    fun `invoke returns false when onboarding has not been seen`() = runTest {
        fakeRepository.setHasSeen(false)

        val result = useCase()

        assertThat(result).isFalse()
    }

    @Test
    fun `invoke returns true when onboarding has been seen`() = runTest {
        fakeRepository.setHasSeen(true)

        val result = useCase()

        assertThat(result).isTrue()
    }

    @Test
    fun `invoke delegates to repository hasSeenOnboarding`() = runTest {
        fakeRepository.setHasSeen(true)
        val firstResult = useCase()
        assertThat(firstResult).isTrue()

        fakeRepository.setHasSeen(false)
        val secondResult = useCase()
        assertThat(secondResult).isFalse()
    }
}
