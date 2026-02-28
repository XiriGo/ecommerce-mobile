package com.xirigo.ecommerce.feature.onboarding.presentation.viewmodel

import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.feature.onboarding.domain.model.OnboardingPage
import com.xirigo.ecommerce.feature.onboarding.domain.usecase.CheckOnboardingUseCase
import com.xirigo.ecommerce.feature.onboarding.domain.usecase.CompleteOnboardingUseCase
import com.xirigo.ecommerce.feature.onboarding.presentation.state.OnboardingUiState

@HiltViewModel
class OnboardingViewModel @Inject constructor(
    private val checkOnboarding: CheckOnboardingUseCase,
    private val completeOnboarding: CompleteOnboardingUseCase,
) : ViewModel() {

    private val _uiState = MutableStateFlow<OnboardingUiState>(OnboardingUiState.Loading)
    val uiState: StateFlow<OnboardingUiState> = _uiState.asStateFlow()

    private val _currentPage = MutableStateFlow(0)
    val currentPage: StateFlow<Int> = _currentPage.asStateFlow()

    init {
        viewModelScope.launch {
            val hasSeen = checkOnboarding()
            delay(SPLASH_DURATION_MS)
            _uiState.value = if (hasSeen) {
                OnboardingUiState.OnboardingComplete
            } else {
                OnboardingUiState.ShowOnboarding
            }
        }
    }

    fun onPageChanged(page: Int) {
        _currentPage.value = page
    }

    fun onSkip() {
        viewModelScope.launch {
            completeOnboarding()
            _uiState.value = OnboardingUiState.OnboardingComplete
        }
    }

    fun onGetStarted() {
        viewModelScope.launch {
            completeOnboarding()
            _uiState.value = OnboardingUiState.OnboardingComplete
        }
    }

    companion object {
        private const val SPLASH_DURATION_MS = 2_000L

        val Pages: List<OnboardingPage> = listOf(
            OnboardingPage(
                titleResId = R.string.onboarding_page_browse_title,
                descriptionResId = R.string.onboarding_page_browse_description,
                illustrationResId = R.drawable.onboarding_illustration_browse,
            ),
            OnboardingPage(
                titleResId = R.string.onboarding_page_compare_title,
                descriptionResId = R.string.onboarding_page_compare_description,
                illustrationResId = R.drawable.onboarding_illustration_compare,
            ),
            OnboardingPage(
                titleResId = R.string.onboarding_page_checkout_title,
                descriptionResId = R.string.onboarding_page_checkout_description,
                illustrationResId = R.drawable.onboarding_illustration_checkout,
            ),
            OnboardingPage(
                titleResId = R.string.onboarding_page_track_title,
                descriptionResId = R.string.onboarding_page_track_description,
                illustrationResId = R.drawable.onboarding_illustration_track,
            ),
        )
    }
}
