package com.xirigo.ecommerce.core.designsystem.component

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
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGEmptyViewTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun xgEmptyView_displaysMessage() {
        composeTestRule.setContent {
            XGTheme {
                XGEmptyView(message = "No products found")
            }
        }

        composeTestRule.onNodeWithText("No products found").assertIsDisplayed()
    }

    @Test
    fun xgEmptyView_actionButton_shown_whenBothProvided() {
        composeTestRule.setContent {
            XGTheme {
                XGEmptyView(
                    message = "Your cart is empty",
                    actionLabel = "Start Shopping",
                    onAction = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Start Shopping").assertIsDisplayed()
    }

    @Test
    fun xgEmptyView_actionButton_notShown_whenLabelNull() {
        composeTestRule.setContent {
            XGTheme {
                XGEmptyView(
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
    fun xgEmptyView_actionButton_notShown_whenActionNull() {
        composeTestRule.setContent {
            XGTheme {
                XGEmptyView(
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
    fun xgEmptyView_actionClick_firesCallback() {
        var clicked = false

        composeTestRule.setContent {
            XGTheme {
                XGEmptyView(
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
    fun xgEmptyView_customIcon_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGEmptyView(
                    message = "Cart is empty",
                    icon = Icons.Outlined.ShoppingCart,
                )
            }
        }

        composeTestRule.onNodeWithText("Cart is empty").assertIsDisplayed()
    }

    @Test
    fun xgEmptyView_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGEmptyView(message = "Nothing here")
            }
        }

        composeTestRule.onNodeWithText("Nothing here").assertExists()
    }
}
