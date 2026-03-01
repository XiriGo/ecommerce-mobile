package com.xirigo.ecommerce.feature.onboarding.domain.model

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.compose.runtime.Immutable

@Immutable
data class OnboardingPage(
    @StringRes val titleResId: Int,
    @StringRes val descriptionResId: Int,
    @DrawableRes val illustrationResId: Int,
)
