package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGErrorViewTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // region Static XGErrorView (backward compatible)

    @Test
    fun xgErrorView_displaysMessage() {
        composeTestRule.setContent {
            XGTheme {
                XGErrorView(message = "Something went wrong")
            }
        }

        composeTestRule.onNodeWithText("Something went wrong").assertIsDisplayed()
    }

    @Test
    fun xgErrorView_retryButton_shown_whenCallbackProvided() {
        composeTestRule.setContent {
            XGTheme {
                XGErrorView(
                    message = "Network error",
                    onRetry = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Retry").assertIsDisplayed()
    }

    @Test
    fun xgErrorView_retryButton_notShown_whenCallbackNull() {
        composeTestRule.setContent {
            XGTheme {
                XGErrorView(
                    message = "No internet connection",
                    onRetry = null,
                )
            }
        }

        composeTestRule.onNodeWithText("Retry").assertDoesNotExist()
    }

    @Test
    fun xgErrorView_retryClick_firesCallback() {
        var retried = false

        composeTestRule.setContent {
            XGTheme {
                XGErrorView(
                    message = "Error occurred",
                    onRetry = { retried = true },
                )
            }
        }

        composeTestRule.onNodeWithText("Retry").performClick()
        assertThat(retried).isTrue()
    }

    @Test
    fun xgErrorView_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGErrorView(message = "Test error")
            }
        }

        composeTestRule.onNodeWithText("Test error").assertExists()
    }

    // endregion

    // region Crossfade XGErrorView (isError + content)

    @Test
    fun xgErrorView_isErrorTrue_showsErrorNotContent() {
        composeTestRule.setContent {
            XGTheme {
                XGErrorView(
                    message = "Something went wrong",
                    isError = true,
                    onRetry = {},
                ) {
                    Text("Actual content")
                }
            }
        }

        composeTestRule
            .onNode(hasText("Something went wrong"))
            .assertIsDisplayed()
    }

    @Test
    fun xgErrorView_isErrorFalse_showsContent() {
        composeTestRule.setContent {
            XGTheme {
                XGErrorView(
                    message = "Something went wrong",
                    isError = false,
                    onRetry = {},
                ) {
                    Text("Actual content")
                }
            }
        }

        composeTestRule.mainClock.advanceTimeBy(500)

        composeTestRule
            .onNode(hasText("Actual content"))
            .assertIsDisplayed()
    }

    @Test
    fun xgErrorView_crossfade_transitionsFromContentToError() {
        var isError by mutableStateOf(false)

        composeTestRule.setContent {
            XGTheme {
                XGErrorView(
                    message = "Error occurred",
                    isError = isError,
                    onRetry = {},
                ) {
                    Text("Loaded content")
                }
            }
        }

        // Initially showing content
        composeTestRule.mainClock.advanceTimeBy(500)
        composeTestRule
            .onNode(hasText("Loaded content"))
            .assertIsDisplayed()

        // Transition to error
        isError = true
        composeTestRule.mainClock.advanceTimeBy(500)

        composeTestRule
            .onNode(hasText("Error occurred"))
            .assertIsDisplayed()
    }

    @Test
    fun xgErrorView_crossfade_transitionsFromErrorToContent() {
        var isError by mutableStateOf(true)

        composeTestRule.setContent {
            XGTheme {
                XGErrorView(
                    message = "Error occurred",
                    isError = isError,
                    onRetry = {},
                ) {
                    Text("Loaded content")
                }
            }
        }

        // Initially showing error
        composeTestRule
            .onNode(hasText("Error occurred"))
            .assertIsDisplayed()

        // Transition to content
        isError = false
        composeTestRule.mainClock.advanceTimeBy(500)

        composeTestRule
            .onNode(hasText("Loaded content"))
            .assertIsDisplayed()
    }

    @Test
    fun xgErrorView_crossfade_retryButtonShown_whenCallbackProvided() {
        composeTestRule.setContent {
            XGTheme {
                XGErrorView(
                    message = "Error occurred",
                    isError = true,
                    onRetry = {},
                ) {
                    Text("Content")
                }
            }
        }

        composeTestRule.onNodeWithText("Retry").assertIsDisplayed()
    }

    @Test
    fun xgErrorView_crossfade_retryButtonHidden_whenCallbackNull() {
        composeTestRule.setContent {
            XGTheme {
                XGErrorView(
                    message = "Error occurred",
                    isError = true,
                    onRetry = null,
                ) {
                    Text("Content")
                }
            }
        }

        composeTestRule.onNodeWithText("Retry").assertDoesNotExist()
    }

    @Test
    fun xgErrorView_crossfade_retryClick_firesCallback() {
        var retried = false

        composeTestRule.setContent {
            XGTheme {
                XGErrorView(
                    message = "Error occurred",
                    isError = true,
                    onRetry = { retried = true },
                ) {
                    Text("Content")
                }
            }
        }

        composeTestRule.onNodeWithText("Retry").performClick()
        assertThat(retried).isTrue()
    }

    // endregion
}
