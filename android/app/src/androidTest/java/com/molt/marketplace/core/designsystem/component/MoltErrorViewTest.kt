package com.molt.marketplace.core.designsystem.component

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.google.common.truth.Truth.assertThat
import com.molt.marketplace.core.designsystem.theme.MoltTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MoltErrorViewTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltErrorView_displaysMessage() {
        composeTestRule.setContent {
            MoltTheme {
                MoltErrorView(message = "Something went wrong")
            }
        }

        composeTestRule.onNodeWithText("Something went wrong").assertIsDisplayed()
    }

    @Test
    fun moltErrorView_retryButton_shown_whenCallbackProvided() {
        composeTestRule.setContent {
            MoltTheme {
                MoltErrorView(
                    message = "Network error",
                    onRetry = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Retry").assertIsDisplayed()
    }

    @Test
    fun moltErrorView_retryButton_notShown_whenCallbackNull() {
        composeTestRule.setContent {
            MoltTheme {
                MoltErrorView(
                    message = "No internet connection",
                    onRetry = null,
                )
            }
        }

        composeTestRule.onNodeWithText("Retry").assertDoesNotExist()
    }

    @Test
    fun moltErrorView_retryClick_firesCallback() {
        var retried = false

        composeTestRule.setContent {
            MoltTheme {
                MoltErrorView(
                    message = "Error occurred",
                    onRetry = { retried = true },
                )
            }
        }

        composeTestRule.onNodeWithText("Retry").performClick()
        assertThat(retried).isTrue()
    }

    @Test
    fun moltErrorView_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltErrorView(message = "Test error")
            }
        }

        composeTestRule.onNodeWithText("Test error").assertExists()
    }
}
