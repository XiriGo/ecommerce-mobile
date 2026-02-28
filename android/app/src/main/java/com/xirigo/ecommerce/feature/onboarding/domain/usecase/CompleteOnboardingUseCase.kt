package com.xirigo.ecommerce.feature.onboarding.domain.usecase

import com.xirigo.ecommerce.feature.onboarding.domain.repository.OnboardingRepository
import javax.inject.Inject

class CompleteOnboardingUseCase @Inject constructor(
    private val repository: OnboardingRepository,
) {
    suspend operator fun invoke(): Unit = repository.setOnboardingSeen()
}
