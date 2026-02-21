package com.molt.marketplace.core.designsystem.component

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
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@RunWith(AndroidJUnit4::class)
class MoltChipTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // --- MoltFilterChip ---

    @Test
    fun moltFilterChip_unselected_displaysLabel() {
        composeTestRule.setContent {
            MoltTheme {
                MoltFilterChip(
                    label = "Electronics",
                    selected = false,
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Electronics").assertIsDisplayed()
    }

    @Test
    fun moltFilterChip_selected_displaysLabel() {
        composeTestRule.setContent {
            MoltTheme {
                MoltFilterChip(
                    label = "Electronics",
                    selected = true,
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Electronics").assertIsDisplayed()
    }

    @Test
    fun moltFilterChip_click_firesCallback() {
        var clicked = false

        composeTestRule.setContent {
            MoltTheme {
                MoltFilterChip(
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
    fun moltFilterChip_selected_hasSelectedState() {
        composeTestRule.setContent {
            MoltTheme {
                MoltFilterChip(
                    label = "Selected",
                    selected = true,
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Selected").assertIsSelected()
    }

    @Test
    fun moltFilterChip_toggling_callsCallbackEachTime() {
        val clickList = mutableListOf<Int>()

        composeTestRule.setContent {
            MoltTheme {
                MoltFilterChip(
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

    // --- MoltCategoryChip ---

    @Test
    fun moltCategoryChip_displaysLabel() {
        composeTestRule.setContent {
            MoltTheme {
                MoltCategoryChip(
                    label = "Clothing",
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Clothing").assertIsDisplayed()
    }

    @Test
    fun moltCategoryChip_click_firesCallback() {
        var clicked = false

        composeTestRule.setContent {
            MoltTheme {
                MoltCategoryChip(
                    label = "Shoes",
                    onClick = { clicked = true },
                )
            }
        }

        composeTestRule.onNodeWithText("Shoes").performClick()
        assertThat(clicked).isTrue()
    }
}
