package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGTextFieldTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltTextField_labelDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                XGTextField(
                    value = "",
                    onValueChange = {},
                    label = "Email Address",
                )
            }
        }

        composeTestRule.onNodeWithText("Email Address").assertExists()
    }

    @Test
    fun moltTextField_placeholderShownWhenEmpty() {
        composeTestRule.setContent {
            XGTheme {
                XGTextField(
                    value = "",
                    onValueChange = {},
                    label = "Email",
                    placeholder = "Enter your email",
                )
            }
        }

        composeTestRule.onNodeWithText("Enter your email").assertExists()
    }

    @Test
    fun moltTextField_errorState_displaysErrorMessage() {
        composeTestRule.setContent {
            XGTheme {
                XGTextField(
                    value = "bad@",
                    onValueChange = {},
                    label = "Email",
                    errorMessage = "Invalid email address",
                )
            }
        }

        composeTestRule.onNodeWithText("Invalid email address").assertExists()
    }

    @Test
    fun moltTextField_helperText_displaysWhenNoError() {
        composeTestRule.setContent {
            XGTheme {
                XGTextField(
                    value = "",
                    onValueChange = {},
                    label = "Username",
                    helperText = "Must be at least 3 characters",
                )
            }
        }

        composeTestRule.onNodeWithText("Must be at least 3 characters").assertExists()
    }

    @Test
    fun moltTextField_errorMessageOverridesHelperText() {
        composeTestRule.setContent {
            XGTheme {
                XGTextField(
                    value = "x",
                    onValueChange = {},
                    label = "Username",
                    helperText = "Must be at least 3 characters",
                    errorMessage = "Too short",
                )
            }
        }

        composeTestRule.onNodeWithText("Too short").assertExists()
        // Helper text should NOT appear when error is present
        composeTestRule.onNodeWithText("Must be at least 3 characters").assertDoesNotExist()
    }

    @Test
    fun moltTextField_passwordToggle_changesVisibility() {
        composeTestRule.setContent {
            XGTheme {
                XGTextField(
                    value = "secret",
                    onValueChange = {},
                    label = "Password",
                    isPassword = true,
                )
            }
        }

        // Password toggle button should exist (rendered as "S" for show)
        composeTestRule.onNodeWithText("S").assertExists()

        // Click toggle to reveal
        composeTestRule.onNodeWithText("S").performClick()

        // Toggle should now show "H" for hide
        composeTestRule.onNodeWithText("H").assertExists()
    }

    @Test
    fun moltTextField_valueChange_callsCallback() {
        var capturedValue = ""

        composeTestRule.setContent {
            XGTheme {
                XGTextField(
                    value = "",
                    onValueChange = { capturedValue = it },
                    label = "Search",
                )
            }
        }

        composeTestRule.onNodeWithText("Search").performTextInput("hello")
        assertThat(capturedValue).isEqualTo("hello")
    }

    @Test
    fun moltTextField_maxLength_showsCounter() {
        composeTestRule.setContent {
            XGTheme {
                XGTextField(
                    value = "abc",
                    onValueChange = {},
                    label = "Bio",
                    maxLength = 100,
                )
            }
        }

        composeTestRule.onNodeWithText("3/100").assertExists()
    }

    @Test
    fun moltTextField_maxLength_truncatesInput() {
        var capturedValue = ""

        composeTestRule.setContent {
            XGTheme {
                XGTextField(
                    value = "",
                    onValueChange = { capturedValue = it },
                    label = "Short",
                    maxLength = 3,
                )
            }
        }

        composeTestRule.onNodeWithText("Short").performTextInput("abcdefgh")
        // Max length enforced — only up to 3 chars accepted
        assertThat(capturedValue.length).isAtMost(3)
    }
}
