package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGChipTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // --- XGFilterChip ---

    @Test
    fun xgFilterChip_unselected_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGFilterChip(
                    label = "Electronics",
                    selected = false,
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Electronics").assertIsDisplayed()
    }

    @Test
    fun xgFilterChip_selected_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGFilterChip(
                    label = "Electronics",
                    selected = true,
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Electronics").assertIsDisplayed()
    }

    @Test
    fun xgFilterChip_click_firesCallback() {
        var clicked = false

        composeTestRule.setContent {
            XGTheme {
                XGFilterChip(
                    label = "Shoes",
                    selected = false,
                    onClick = { clicked = true },
                )
            }
        }

        composeTestRule.onNodeWithText("Shoes").performClick()
        assertThat(clicked).isTrue()
    }

    @Test
    fun xgFilterChip_selected_hasSelectedState() {
        composeTestRule.setContent {
            XGTheme {
                XGFilterChip(
                    label = "Selected",
                    selected = true,
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Selected").assertIsSelected()
    }

    @Test
    fun xgFilterChip_toggling_callsCallbackEachTime() {
        val clickList = mutableListOf<Int>()

        composeTestRule.setContent {
            XGTheme {
                XGFilterChip(
                    label = "Toggle",
                    selected = false,
                    onClick = { clickList.add(clickList.size + 1) },
                )
            }
        }

        composeTestRule.onNodeWithText("Toggle").performClick()
        composeTestRule.onNodeWithText("Toggle").performClick()
        assertThat(clickList).hasSize(2)
    }

    // --- XGCategoryChip ---

    @Test
    fun xgCategoryChip_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGCategoryChip(
                    label = "Clothing",
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Clothing").assertIsDisplayed()
    }

    @Test
    fun xgCategoryChip_click_firesCallback() {
        var clicked = false

        composeTestRule.setContent {
            XGTheme {
                XGCategoryChip(
                    label = "Shoes",
                    onClick = { clicked = true },
                )
            }
        }

        composeTestRule.onNodeWithText("Shoes").performClick()
        assertThat(clicked).isTrue()
    }
}
