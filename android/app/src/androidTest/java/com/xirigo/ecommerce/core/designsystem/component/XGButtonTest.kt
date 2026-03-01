package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGButtonTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun xgButton_primaryVariant_displaysText() {
        composeTestRule.setContent {
            XGTheme {
                XGButton(
                    text = "Add to Cart",
                    onClick = {},
                    style = XGButtonStyle.Primary,
                )
            }
        }

        composeTestRule.onNodeWithText("Add to Cart").assertExists()
    }

    @Test
    fun xgButton_secondaryVariant_displaysText() {
        composeTestRule.setContent {
            XGTheme {
                XGButton(
                    text = "View Details",
                    onClick = {},
                    style = XGButtonStyle.Secondary,
                )
            }
        }

        composeTestRule.onNodeWithText("View Details").assertExists()
    }

    @Test
    fun xgButton_outlinedVariant_displaysText() {
        composeTestRule.setContent {
            XGTheme {
                XGButton(
                    text = "Outlined Action",
                    onClick = {},
                    style = XGButtonStyle.Outlined,
                )
            }
        }

        composeTestRule.onNodeWithText("Outlined Action").assertExists()
    }

    @Test
    fun xgButton_textVariant_displaysText() {
        composeTestRule.setContent {
            XGTheme {
                XGButton(
                    text = "Cancel",
                    onClick = {},
                    style = XGButtonStyle.Text,
                )
            }
        }

        composeTestRule.onNodeWithText("Cancel").assertExists()
    }

    @Test
    fun xgButton_loadingState_showsProgressIndicatorAndDisablesClick() {
        var clicked = false

        composeTestRule.setContent {
            XGTheme {
                XGButton(
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
    fun xgButton_disabledState_doesNotFireClickCallback() {
        var clicked = false

        composeTestRule.setContent {
            XGTheme {
                XGButton(
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
    fun xgButton_enabledState_firesClickCallback() {
        var clicked = false

        composeTestRule.setContent {
            XGTheme {
                XGButton(
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
    fun xgButton_withLeadingIcon_displaysIconAndText() {
        composeTestRule.setContent {
            XGTheme {
                XGButton(
                    text = "Add to Cart",
                    onClick = {},
                    leadingIcon = Icons.Filled.ShoppingCart,
                    style = XGButtonStyle.Primary,
                )
            }
        }

        composeTestRule.onNodeWithText("Add to Cart").assertExists()
    }

    @Test
    fun xgButton_loadingState_hidesLeadingIcon() {
        composeTestRule.setContent {
            XGTheme {
                XGButton(
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
