package com.molt.marketplace.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@RunWith(AndroidJUnit4::class)
class MoltEmptyViewTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltEmptyView_displaysMessage() {
        composeTestRule.setContent {
            MoltTheme {
                MoltEmptyView(message = "No products found")
            }
        }

        composeTestRule.onNodeWithText("No products found").assertIsDisplayed()
    }

    @Test
    fun moltEmptyView_actionButton_shown_whenBothProvided() {
        composeTestRule.setContent {
            MoltTheme {
                MoltEmptyView(
                    message = "Your cart is empty",
                    actionLabel = "Start Shopping",
                    onAction = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Start Shopping").assertIsDisplayed()
    }

    @Test
    fun moltEmptyView_actionButton_notShown_whenLabelNull() {
        composeTestRule.setContent {
            MoltTheme {
                MoltEmptyView(
                    message = "No results",
                    actionLabel = null,
                    onAction = {},
                )
            }
        }

        // Action button should not be rendered without a label
        composeTestRule.onNodeWithText("Start Shopping").assertDoesNotExist()
    }

    @Test
    fun moltEmptyView_actionButton_notShown_whenActionNull() {
        composeTestRule.setContent {
            MoltTheme {
                MoltEmptyView(
                    message = "No results",
                    actionLabel = "Browse",
                    onAction = null,
                )
            }
        }

        // Action button should not be rendered without an action
        composeTestRule.onNodeWithText("Browse").assertDoesNotExist()
    }

    @Test
    fun moltEmptyView_actionClick_firesCallback() {
        var clicked = false

        composeTestRule.setContent {
            MoltTheme {
                MoltEmptyView(
                    message = "Empty",
                    actionLabel = "Go Shop",
                    onAction = { clicked = true },
                )
            }
        }

        composeTestRule.onNodeWithText("Go Shop").performClick()
        assertThat(clicked).isTrue()
    }

    @Test
    fun moltEmptyView_customIcon_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltEmptyView(
                    message = "Cart is empty",
                    icon = Icons.Outlined.ShoppingCart,
                )
            }
        }

        composeTestRule.onNodeWithText("Cart is empty").assertIsDisplayed()
    }

    @Test
    fun moltEmptyView_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltEmptyView(message = "Nothing here")
            }
        }

        composeTestRule.onNodeWithText("Nothing here").assertExists()
    }
}
