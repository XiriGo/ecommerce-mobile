package com.xirigo.ecommerce.feature.onboarding.presentation.screen

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.component.XGBrandGradient
import com.xirigo.ecommerce.core.designsystem.component.XGButton
import com.xirigo.ecommerce.core.designsystem.component.XGButtonStyle
import com.xirigo.ecommerce.core.designsystem.component.XGPaginationDots
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.feature.onboarding.presentation.state.OnboardingUiState
import com.xirigo.ecommerce.feature.onboarding.presentation.viewmodel.OnboardingViewModel

private val GetStartedHorizontalPadding = 20.dp
private val GetStartedBottomMargin = 80.dp
private val DotsBottomMargin = 32.dp
private val SkipTopPadding = 16.dp
private val SkipEndPadding = 20.dp

@Composable
fun OnboardingScreen(viewModel: OnboardingViewModel = hiltViewModel(), onNavigateToMain: () -> Unit) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val currentPage by viewModel.currentPage.collectAsStateWithLifecycle()

    LaunchedEffect(uiState) {
        if (uiState is OnboardingUiState.OnboardingComplete) {
            onNavigateToMain()
        }
    }

    when (uiState) {
        is OnboardingUiState.Loading -> SplashScreen()
        is OnboardingUiState.ShowOnboarding -> OnboardingContent(
            currentPage = currentPage,
            onPageChanged = viewModel::onPageChanged,
            onSkip = viewModel::onSkip,
            onGetStarted = viewModel::onGetStarted,
        )
        is OnboardingUiState.OnboardingComplete -> Unit
    }
}

@Composable
private fun OnboardingContent(
    currentPage: Int,
    onPageChanged: (Int) -> Unit,
    onSkip: () -> Unit,
    onGetStarted: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val pages = OnboardingViewModel.Pages
    val pagerState = rememberPagerState(pageCount = { pages.size })
    val isLastPage = currentPage == pages.size - 1

    LaunchedEffect(pagerState) {
        snapshotFlow { pagerState.currentPage }.collect { page ->
            onPageChanged(page)
        }
    }

    val skipA11yLabel = stringResource(R.string.onboarding_skip_button_a11y)

    Box(modifier = modifier.fillMaxSize()) {
        XGBrandGradient()

        HorizontalPager(
            state = pagerState,
            modifier = Modifier.fillMaxSize(),
        ) { pageIndex ->
            OnboardingPageContent(page = pages[pageIndex])
        }

        AnimatedVisibility(
            visible = !isLastPage,
            enter = fadeIn(),
            exit = fadeOut(),
            modifier = Modifier
                .align(Alignment.TopEnd)
                .statusBarsPadding()
                .padding(top = SkipTopPadding, end = SkipEndPadding)
                .semantics { contentDescription = skipA11yLabel },
        ) {
            XGButton(
                text = stringResource(R.string.onboarding_skip_button),
                onClick = onSkip,
                style = XGButtonStyle.Text,
                fullWidth = false,
            )
        }

        AnimatedVisibility(
            visible = isLastPage,
            enter = fadeIn(),
            exit = fadeOut(),
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .navigationBarsPadding()
                .padding(
                    start = GetStartedHorizontalPadding,
                    end = GetStartedHorizontalPadding,
                    bottom = GetStartedBottomMargin,
                ),
        ) {
            XGButton(
                text = stringResource(R.string.onboarding_get_started_button),
                onClick = onGetStarted,
                style = XGButtonStyle.Primary,
            )
        }

        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .navigationBarsPadding()
                .padding(bottom = DotsBottomMargin),
        ) {
            XGPaginationDots(
                totalPages = pages.size,
                currentPage = currentPage,
                activeColor = XGColors.TextOnDark,
                inactiveColor = XGColors.TextOnDark.copy(alpha = 0.4f),
            )
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun OnboardingContentFirstPagePreview() {
    XGTheme {
        OnboardingContent(
            currentPage = 0,
            onPageChanged = {},
            onSkip = {},
            onGetStarted = {},
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun OnboardingContentLastPagePreview() {
    XGTheme {
        OnboardingContent(
            currentPage = 3,
            onPageChanged = {},
            onSkip = {},
            onGetStarted = {},
        )
    }
}
