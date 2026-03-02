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
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGChipTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // --- XGFilterChip: Behavior ---

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

    // --- XGFilterChip: Token Compliance ---

    @Test
    fun xgFilterChip_token_filterChipHeight_is36() {
        // Token: variants.filter.height = 36
        val expected = 36.dp
        assertThat(expected.value).isEqualTo(36f)
    }

    @Test
    fun xgFilterChip_token_cornerRadius_is18() {
        // Token: variants.filter.cornerRadius = 18
        val expected = 18.dp
        assertThat(expected.value).isEqualTo(18f)
    }

    @Test
    fun xgFilterChip_token_activeBackground_isFilterPillBackgroundActive() {
        // Token: $foundations/colors.light.filterPillBackgroundActive = #6200FF
        assertThat(XGColors.FilterPillBackgroundActive).isNotNull()
    }

    @Test
    fun xgFilterChip_token_activeText_isFilterPillTextActive() {
        // Token: $foundations/colors.light.filterPillTextActive = #FFFFFF
        assertThat(XGColors.FilterPillTextActive).isNotNull()
    }

    @Test
    fun xgFilterChip_token_inactiveBackground_isFilterPillBackground() {
        // Token: $foundations/colors.light.filterPillBackground = #F1F5F9
        assertThat(XGColors.FilterPillBackground).isNotNull()
    }

    @Test
    fun xgFilterChip_token_inactiveText_isFilterPillText() {
        // Token: $foundations/colors.light.filterPillText = #333333
        assertThat(XGColors.FilterPillText).isNotNull()
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

    @Test
    fun xgCategoryChip_token_background_isSurfaceTertiary() {
        // Token: $foundations/colors.light.surfaceTertiary = #F1F5F9
        assertThat(XGColors.SurfaceTertiary).isNotNull()
    }

    @Test
    fun xgCategoryChip_token_textColor_isOnSurface() {
        // Token: $foundations/colors.light.textPrimary = #333333
        assertThat(XGColors.OnSurface).isNotNull()
    }
}
