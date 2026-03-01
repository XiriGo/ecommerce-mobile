package com.xirigo.ecommerce.feature.onboarding.presentation.state

import androidx.compose.runtime.Stable

@Stable
sealed interface OnboardingUiState {
    data object Loading : OnboardingUiState
    data object ShowOnboarding : OnboardingUiState
    data object OnboardingComplete : OnboardingUiState
}
