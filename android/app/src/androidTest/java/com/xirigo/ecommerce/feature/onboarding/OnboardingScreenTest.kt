package com.xirigo.ecommerce.feature.onboarding

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.component.XGBrandGradient
import com.xirigo.ecommerce.core.designsystem.component.XGPaginationDots
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.feature.onboarding.presentation.screen.OnboardingPageContent
import com.xirigo.ecommerce.feature.onboarding.presentation.viewmodel.OnboardingViewModel

private val GetStartedButtonHeight = 56.dp
private val GetStartedCornerRadius = 10.dp
private val GetStartedHorizontalPadding = 20.dp
private val GetStartedBottomMargin = 80.dp
private val DotsBottomMargin = 32.dp
private val SkipTopPadding = 16.dp
private val SkipEndPadding = 20.dp

private val BrandSecondary = Color(0xFF94D63A)
private val BrandOnSecondary = Color(0xFF6000FE)
private val PaginationActiveOnDark = Color.White
private val PaginationInactiveOnDark = Color.White.copy(alpha = 0.4f)

/**
 * Test harness composable that mirrors OnboardingContent from OnboardingScreen.kt
 * to allow direct composition in tests without requiring Hilt.
 */
@Composable
private fun TestOnboardingContent(
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
                .padding(top = SkipTopPadding, end = SkipEndPadding),
        ) {
            TextButton(onClick = onSkip) {
                Text(
                    text = stringResource(R.string.onboarding_skip_button),
                    color = Color.White,
                )
            }
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
            Button(
                onClick = onGetStarted,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(GetStartedButtonHeight),
                shape = RoundedCornerShape(GetStartedCornerRadius),
                colors = ButtonDefaults.buttonColors(
                    containerColor = BrandSecondary,
                    contentColor = BrandOnSecondary,
                ),
            ) {
                Text(text = stringResource(R.string.onboarding_get_started_button))
            }
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
                activeColor = PaginationActiveOnDark,
                inactiveColor = PaginationInactiveOnDark,
            )
        }
    }
}

@RunWith(AndroidJUnit4::class)
class OnboardingScreenTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // region Skip button visibility

    @Test
    fun onboardingContent_skipButtonVisible_onFirstPage() {
        composeTestRule.setContent {
            XGTheme {
                TestOnboardingContent(
                    currentPage = 0,
                    onPageChanged = {},
                    onSkip = {},
                    onGetStarted = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Skip").assertIsDisplayed()
    }

    @Test
    fun onboardingContent_skipButtonVisible_onSecondPage() {
        composeTestRule.setContent {
            XGTheme {
                TestOnboardingContent(
                    currentPage = 1,
                    onPageChanged = {},
                    onSkip = {},
                    onGetStarted = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Skip").assertIsDisplayed()
    }

    @Test
    fun onboardingContent_skipButtonVisible_onThirdPage() {
        composeTestRule.setContent {
            XGTheme {
                TestOnboardingContent(
                    currentPage = 2,
                    onPageChanged = {},
                    onSkip = {},
                    onGetStarted = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Skip").assertIsDisplayed()
    }

    @Test
    fun onboardingContent_skipButtonNotVisible_onLastPage() {
        composeTestRule.setContent {
            XGTheme {
                TestOnboardingContent(
                    currentPage = 3,
                    onPageChanged = {},
                    onSkip = {},
                    onGetStarted = {},
                )
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithText("Skip").assertDoesNotExist()
    }

    // endregion

    // region Get Started button visibility

    @Test
    fun onboardingContent_getStartedButtonNotVisible_onFirstPage() {
        composeTestRule.setContent {
            XGTheme {
                TestOnboardingContent(
                    currentPage = 0,
                    onPageChanged = {},
                    onSkip = {},
                    onGetStarted = {},
                )
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithText("Get Started").assertDoesNotExist()
    }

    @Test
    fun onboardingContent_getStartedButtonVisible_onLastPage() {
        composeTestRule.setContent {
            XGTheme {
                TestOnboardingContent(
                    currentPage = 3,
                    onPageChanged = {},
                    onSkip = {},
                    onGetStarted = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Get Started").assertIsDisplayed()
    }

    // endregion

    // region pagination dots

    @Test
    fun onboardingContent_paginationDotsDisplayed_onFirstPage() {
        composeTestRule.setContent {
            XGTheme {
                TestOnboardingContent(
                    currentPage = 0,
                    onPageChanged = {},
                    onSkip = {},
                    onGetStarted = {},
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Page 1 of 4"))
            .assertIsDisplayed()
    }

    @Test
    fun onboardingContent_paginationDotsDisplayed_onLastPage() {
        composeTestRule.setContent {
            XGTheme {
                TestOnboardingContent(
                    currentPage = 3,
                    onPageChanged = {},
                    onSkip = {},
                    onGetStarted = {},
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Page 4 of 4"))
            .assertIsDisplayed()
    }

    // endregion

    // region Skip callback

    @Test
    fun onboardingContent_skipButton_triggersSkipCallback() {
        var skipCalled = false

        composeTestRule.setContent {
            XGTheme {
                TestOnboardingContent(
                    currentPage = 0,
                    onPageChanged = {},
                    onSkip = { skipCalled = true },
                    onGetStarted = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Skip").performClick()

        composeTestRule.waitForIdle()
        assert(skipCalled) { "Skip callback was not called" }
    }

    // endregion

    // region Get Started callback

    @Test
    fun onboardingContent_getStartedButton_triggersGetStartedCallback() {
        var getStartedCalled = false

        composeTestRule.setContent {
            XGTheme {
                TestOnboardingContent(
                    currentPage = 3,
                    onPageChanged = {},
                    onSkip = {},
                    onGetStarted = { getStartedCalled = true },
                )
            }
        }

        composeTestRule.onNodeWithText("Get Started").performClick()

        composeTestRule.waitForIdle()
        assert(getStartedCalled) { "Get Started callback was not called" }
    }

    // endregion
}
