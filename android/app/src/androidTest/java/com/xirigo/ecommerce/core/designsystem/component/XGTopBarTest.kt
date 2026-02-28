package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGTopBarTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltTopBar_displaysTitle() {
        composeTestRule.setContent {
            XGTheme {
                XGTopBar(title = "Products")
            }
        }

        composeTestRule.onNodeWithText("Products").assertIsDisplayed()
    }

    @Test
    fun moltTopBar_backButton_notShown_whenCallbackNull() {
        composeTestRule.setContent {
            XGTheme {
                XGTopBar(title = "Home", onBackClick = null)
            }
        }

        composeTestRule.onNodeWithContentDescription("Navigate back").assertDoesNotExist()
    }

    @Test
    fun moltTopBar_backButton_shown_whenCallbackProvided() {
        composeTestRule.setContent {
            XGTheme {
                XGTopBar(title = "Details", onBackClick = {})
            }
        }

        composeTestRule.onNodeWithContentDescription("Navigate back").assertIsDisplayed()
    }

    @Test
    fun moltTopBar_backButton_click_firesCallback() {
        var backClicked = false

        composeTestRule.setContent {
            XGTheme {
                XGTopBar(
                    title = "Cart",
                    onBackClick = { backClicked = true },
                )
            }
        }

        composeTestRule.onNodeWithContentDescription("Navigate back").performClick()
        assertThat(backClicked).isTrue()
    }

    @Test
    fun moltTopBar_actionButton_rendered_andClickable() {
        var actionClicked = false

        composeTestRule.setContent {
            XGTheme {
                XGTopBar(
                    title = "Search Screen",
                    actions = {
                        IconButton(onClick = { actionClicked = true }) {
                            Icon(
                                imageVector = Icons.Filled.Search,
                                contentDescription = "Search",
                            )
                        }
                    },
                )
            }
        }

        composeTestRule.onNodeWithContentDescription("Search").assertIsDisplayed()
        composeTestRule.onNodeWithContentDescription("Search").performClick()
        assertThat(actionClicked).isTrue()
    }

    @Test
    fun moltTopBar_noActions_noBackButton_displaysOnlyTitle() {
        composeTestRule.setContent {
            XGTheme {
                XGTopBar(title = "Simple Title")
            }
        }

        composeTestRule.onNodeWithText("Simple Title").assertIsDisplayed()
        composeTestRule.onNodeWithContentDescription("Navigate back").assertDoesNotExist()
    }
}
