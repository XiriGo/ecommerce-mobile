package com.xirigo.ecommerce.feature.onboarding.viewmodel

import app.cash.turbine.test
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import com.xirigo.ecommerce.feature.onboarding.domain.usecase.CheckOnboardingUseCase
import com.xirigo.ecommerce.feature.onboarding.domain.usecase.CompleteOnboardingUseCase
import com.xirigo.ecommerce.feature.onboarding.presentation.state.OnboardingUiState
import com.xirigo.ecommerce.feature.onboarding.presentation.viewmodel.OnboardingViewModel
import com.xirigo.ecommerce.feature.onboarding.repository.FakeOnboardingRepository

@OptIn(ExperimentalCoroutinesApi::class)
class OnboardingViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private lateinit var fakeRepository: FakeOnboardingRepository
    private lateinit var checkOnboardingUseCase: CheckOnboardingUseCase
    private lateinit var completeOnboardingUseCase: CompleteOnboardingUseCase

    @Before
    fun setUp() {
        fakeRepository = FakeOnboardingRepository()
        checkOnboardingUseCase = CheckOnboardingUseCase(fakeRepository)
        completeOnboardingUseCase = CompleteOnboardingUseCase(fakeRepository)
    }

    private fun createViewModel(): OnboardingViewModel = OnboardingViewModel(
        checkOnboarding = checkOnboardingUseCase,
        completeOnboarding = completeOnboardingUseCase,
    )

    // region initial state

    @Test
    fun `uiState initial value is Loading`() {
        val viewModel = createViewModel()

        assertThat(viewModel.uiState.value).isEqualTo(OnboardingUiState.Loading)
    }

    @Test
    fun `currentPage initial value is 0`() {
        val viewModel = createViewModel()

        assertThat(viewModel.currentPage.value).isEqualTo(0)
    }

    // endregion

    // region state transitions after init

    @Test
    fun `uiState transitions to ShowOnboarding when onboarding not yet seen`() = runTest {
        fakeRepository.setHasSeen(false)
        val viewModel = createViewModel()

        advanceUntilIdle()

        assertThat(viewModel.uiState.value).isEqualTo(OnboardingUiState.ShowOnboarding)
    }

    @Test
    fun `uiState transitions to OnboardingComplete when onboarding already seen`() = runTest {
        fakeRepository.setHasSeen(true)
        val viewModel = createViewModel()

        advanceUntilIdle()

        assertThat(viewModel.uiState.value).isEqualTo(OnboardingUiState.OnboardingComplete)
    }

    @Test
    fun `uiState emits Loading then ShowOnboarding for first-time user`() = runTest {
        fakeRepository.setHasSeen(false)

        val viewModel = createViewModel()

        viewModel.uiState.test {
            assertThat(awaitItem()).isEqualTo(OnboardingUiState.Loading)
            advanceUntilIdle()
            assertThat(awaitItem()).isEqualTo(OnboardingUiState.ShowOnboarding)
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `uiState emits Loading then OnboardingComplete for returning user`() = runTest {
        fakeRepository.setHasSeen(true)

        val viewModel = createViewModel()

        viewModel.uiState.test {
            assertThat(awaitItem()).isEqualTo(OnboardingUiState.Loading)
            advanceUntilIdle()
            assertThat(awaitItem()).isEqualTo(OnboardingUiState.OnboardingComplete)
            cancelAndIgnoreRemainingEvents()
        }
    }

    // endregion

    // region onPageChanged

    @Test
    fun `onPageChanged updates currentPage to given value`() = runTest {
        val viewModel = createViewModel()

        viewModel.onPageChanged(2)

        assertThat(viewModel.currentPage.value).isEqualTo(2)
    }

    @Test
    fun `onPageChanged to last page updates currentPage to 3`() = runTest {
        val viewModel = createViewModel()

        viewModel.onPageChanged(3)

        assertThat(viewModel.currentPage.value).isEqualTo(3)
    }

    @Test
    fun `onPageChanged updates currentPage back to first page`() = runTest {
        val viewModel = createViewModel()
        viewModel.onPageChanged(3)

        viewModel.onPageChanged(0)

        assertThat(viewModel.currentPage.value).isEqualTo(0)
    }

    @Test
    fun `currentPage emits each page change via flow`() = runTest {
        val viewModel = createViewModel()

        viewModel.currentPage.test {
            assertThat(awaitItem()).isEqualTo(0)
            viewModel.onPageChanged(1)
            assertThat(awaitItem()).isEqualTo(1)
            viewModel.onPageChanged(2)
            assertThat(awaitItem()).isEqualTo(2)
            cancelAndIgnoreRemainingEvents()
        }
    }

    // endregion

    // region onSkip

    @Test
    fun `onSkip transitions uiState to OnboardingComplete`() = runTest {
        fakeRepository.setHasSeen(false)
        val viewModel = createViewModel()
        advanceUntilIdle()

        viewModel.onSkip()
        advanceUntilIdle()

        assertThat(viewModel.uiState.value).isEqualTo(OnboardingUiState.OnboardingComplete)
    }

    @Test
    fun `onSkip calls setOnboardingSeen on repository`() = runTest {
        fakeRepository.setHasSeen(false)
        val viewModel = createViewModel()
        advanceUntilIdle()

        viewModel.onSkip()
        advanceUntilIdle()

        assertThat(fakeRepository.setOnboardingSeenCallCount).isEqualTo(1)
    }

    @Test
    fun `onSkip marks onboarding as seen in repository`() = runTest {
        fakeRepository.setHasSeen(false)
        val viewModel = createViewModel()
        advanceUntilIdle()

        viewModel.onSkip()
        advanceUntilIdle()

        assertThat(fakeRepository.hasSeenOnboarding()).isTrue()
    }

    // endregion

    // region onGetStarted

    @Test
    fun `onGetStarted transitions uiState to OnboardingComplete`() = runTest {
        fakeRepository.setHasSeen(false)
        val viewModel = createViewModel()
        advanceUntilIdle()

        viewModel.onGetStarted()
        advanceUntilIdle()

        assertThat(viewModel.uiState.value).isEqualTo(OnboardingUiState.OnboardingComplete)
    }

    @Test
    fun `onGetStarted calls setOnboardingSeen on repository`() = runTest {
        fakeRepository.setHasSeen(false)
        val viewModel = createViewModel()
        advanceUntilIdle()

        viewModel.onGetStarted()
        advanceUntilIdle()

        assertThat(fakeRepository.setOnboardingSeenCallCount).isEqualTo(1)
    }

    @Test
    fun `onGetStarted marks onboarding as seen in repository`() = runTest {
        fakeRepository.setHasSeen(false)
        val viewModel = createViewModel()
        advanceUntilIdle()

        viewModel.onGetStarted()
        advanceUntilIdle()

        assertThat(fakeRepository.hasSeenOnboarding()).isTrue()
    }

    // endregion

    // region companion object pages

    @Test
    fun `pages list contains exactly 4 onboarding pages`() {
        assertThat(OnboardingViewModel.Pages).hasSize(4)
    }

    @Test
    fun `pages list has distinct resource IDs for each page`() {
        val titleIds = OnboardingViewModel.Pages.map { it.titleResId }
        val descriptionIds = OnboardingViewModel.Pages.map { it.descriptionResId }
        val illustrationIds = OnboardingViewModel.Pages.map { it.illustrationResId }

        assertThat(titleIds.distinct()).hasSize(4)
        assertThat(descriptionIds.distinct()).hasSize(4)
        assertThat(illustrationIds.distinct()).hasSize(4)
    }

    // endregion
}
