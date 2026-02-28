package com.xirigo.ecommerce.feature.onboarding.domain.usecase

import javax.inject.Inject
import com.xirigo.ecommerce.feature.onboarding.domain.repository.OnboardingRepository

class CompleteOnboardingUseCase @Inject constructor(
    private val repository: OnboardingRepository,
) {
    suspend operator fun invoke() = repository.setOnboardingSeen()
}
