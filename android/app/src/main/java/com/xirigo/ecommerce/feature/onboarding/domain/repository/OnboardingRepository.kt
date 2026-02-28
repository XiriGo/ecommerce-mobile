package com.xirigo.ecommerce.feature.onboarding.domain.repository

interface OnboardingRepository {
    suspend fun hasSeenOnboarding(): Boolean
    suspend fun setOnboardingSeen()
}
