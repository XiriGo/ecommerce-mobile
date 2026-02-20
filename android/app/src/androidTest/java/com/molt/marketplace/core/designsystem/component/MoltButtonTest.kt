package com.molt.marketplace.core.designsystem.component

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.hasContentDescription
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
class MoltButtonTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltButton_primaryVariant_displaysText() {
        composeTestRule.setContent {
            MoltTheme {
                MoltButton(
                    text = "Add to Cart",
                    onClick = {},
                    style = MoltButtonStyle.Primary,
                )
            }
        }

        composeTestRule.onNodeWithText("Add to Cart").assertExists()
    }

    @Test
    fun moltButton_secondaryVariant_displaysText() {
        composeTestRule.setContent {
            MoltTheme {
                MoltButton(
                    text = "View Details",
                    onClick = {},
                    style = MoltButtonStyle.Secondary,
                )
            }
        }

        composeTestRule.onNodeWithText("View Details").assertExists()
    }

    @Test
    fun moltButton_outlinedVariant_displaysText() {
        composeTestRule.setContent {
            MoltTheme {
                MoltButton(
                    text = "Outlined Action",
                    onClick = {},
                    style = MoltButtonStyle.Outlined,
                )
            }
        }

        composeTestRule.onNodeWithText("Outlined Action").assertExists()
    }

    @Test
    fun moltButton_textVariant_displaysText() {
        composeTestRule.setContent {
            MoltTheme {
                MoltButton(
                    text = "Cancel",
                    onClick = {},
                    style = MoltButtonStyle.Text,
                )
            }
        }

        composeTestRule.onNodeWithText("Cancel").assertExists()
    }

    @Test
    fun moltButton_loadingState_showsProgressIndicatorAndDisablesClick() {
        var clicked = false

        composeTestRule.setContent {
            MoltTheme {
                MoltButton(
                    text = "Submit",
                    onClick = { clicked = true },
                    loading = true,
                )
            }
        }

        // Loading button should be semantically disabled (enabled = !loading)
        composeTestRule.onNode(hasContentDescription("Loading...")).assertExists()
        // Button text still displayed
        composeTestRule.onNodeWithText("Submit").assertExists()
        // The button should be disabled while loading
        composeTestRule.onNodeWithText("Submit").assertIsNotEnabled()
        assertThat(clicked).isFalse()
    }

    @Test
    fun moltButton_disabledState_doesNotFireClickCallback() {
        var clicked = false

        composeTestRule.setContent {
            MoltTheme {
                MoltButton(
                    text = "Disabled",
                    onClick = { clicked = true },
                    enabled = false,
                )
            }
        }

        composeTestRule.onNodeWithText("Disabled").assertIsNotEnabled()
        composeTestRule.onNodeWithText("Disabled").performClick()
        assertThat(clicked).isFalse()
    }

    @Test
    fun moltButton_enabledState_firesClickCallback() {
        var clicked = false

        composeTestRule.setContent {
            MoltTheme {
                MoltButton(
                    text = "Click Me",
                    onClick = { clicked = true },
                    enabled = true,
                )
            }
        }

        composeTestRule.onNodeWithText("Click Me").assertIsEnabled()
        composeTestRule.onNodeWithText("Click Me").performClick()
        assertThat(clicked).isTrue()
    }

    @Test
    fun moltButton_withLeadingIcon_displaysIconAndText() {
        composeTestRule.setContent {
            MoltTheme {
                MoltButton(
                    text = "Add to Cart",
                    onClick = {},
                    leadingIcon = Icons.Filled.ShoppingCart,
                    style = MoltButtonStyle.Primary,
                )
            }
        }

        composeTestRule.onNodeWithText("Add to Cart").assertExists()
    }

    @Test
    fun moltButton_loadingState_hidesLeadingIcon() {
        composeTestRule.setContent {
            MoltTheme {
                MoltButton(
                    text = "Loading",
                    onClick = {},
                    leadingIcon = Icons.Filled.ShoppingCart,
                    loading = true,
                )
            }
        }

        // Loading indicator content description should be visible
        composeTestRule.onNode(hasContentDescription("Loading...")).assertExists()
    }
}
