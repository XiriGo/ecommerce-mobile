package com.xirigo.ecommerce.feature.onboarding.repository

import com.xirigo.ecommerce.feature.onboarding.domain.repository.OnboardingRepository

class FakeOnboardingRepository : OnboardingRepository {

    private var hasSeen: Boolean = false
    var setOnboardingSeenCallCount: Int = 0

    fun setHasSeen(value: Boolean) {
        hasSeen = value
    }

    override suspend fun hasSeenOnboarding(): Boolean = hasSeen

    override suspend fun setOnboardingSeen() {
        hasSeen = true
        setOnboardingSeenCallCount++
    }
}
