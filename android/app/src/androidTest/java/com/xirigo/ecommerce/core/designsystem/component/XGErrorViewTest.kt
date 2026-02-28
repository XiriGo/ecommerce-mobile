package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGErrorViewTest {

    @get:Rule
    val composeTestRule = createComposeRule()

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
}
