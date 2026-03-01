package com.xirigo.ecommerce.feature.onboarding.usecase

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import com.xirigo.ecommerce.feature.onboarding.domain.usecase.CompleteOnboardingUseCase
import com.xirigo.ecommerce.feature.onboarding.repository.FakeOnboardingRepository

class CompleteOnboardingUseCaseTest {

    private lateinit var fakeRepository: FakeOnboardingRepository
    private lateinit var useCase: CompleteOnboardingUseCase

    @Before
    fun setUp() {
        fakeRepository = FakeOnboardingRepository()
        useCase = CompleteOnboardingUseCase(fakeRepository)
    }

    @Test
    fun `invoke calls setOnboardingSeen on repository`() = runTest {
        useCase()

        assertThat(fakeRepository.setOnboardingSeenCallCount).isEqualTo(1)
    }

    @Test
    fun `invoke marks onboarding as seen in repository`() = runTest {
        fakeRepository.setHasSeen(false)

        useCase()

        assertThat(fakeRepository.hasSeenOnboarding()).isTrue()
    }

    @Test
    fun `invoke called multiple times increments repository call count`() = runTest {
        useCase()
        useCase()
        useCase()

        assertThat(fakeRepository.setOnboardingSeenCallCount).isEqualTo(3)
    }
}
