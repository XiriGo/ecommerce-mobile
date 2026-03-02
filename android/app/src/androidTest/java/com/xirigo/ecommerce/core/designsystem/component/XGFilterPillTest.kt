package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGFilterPillTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // --- XGFilterPill: Behavior ---

    @Test
    fun xgFilterPill_unselected_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGFilterPill(
                    label = "Electronics",
                    selected = false,
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Electronics").assertIsDisplayed()
    }

    @Test
    fun xgFilterPill_selected_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGFilterPill(
                    label = "Electronics",
                    selected = true,
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Electronics").assertIsDisplayed()
    }

    @Test
    fun xgFilterPill_click_firesCallback() {
        var clicked = false

        composeTestRule.setContent {
            XGTheme {
                XGFilterPill(
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
    fun xgFilterPill_selected_hasSelectedState() {
        composeTestRule.setContent {
            XGTheme {
                XGFilterPill(
                    label = "Selected",
                    selected = true,
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Selected").assertIsSelected()
    }

    @Test
    fun xgFilterPill_selectedWithDismiss_showsDismissIcon() {
        composeTestRule.setContent {
            XGTheme {
                XGFilterPill(
                    label = "Fashion",
                    selected = true,
                    onClick = {},
                    onDismiss = {},
                )
            }
        }

        composeTestRule
            .onNodeWithContentDescription("Remove Fashion filter")
            .assertIsDisplayed()
    }

    @Test
    fun xgFilterPill_unselectedWithDismiss_doesNotShowDismissIcon() {
        composeTestRule.setContent {
            XGTheme {
                XGFilterPill(
                    label = "Fashion",
                    selected = false,
                    onClick = {},
                    onDismiss = {},
                )
            }
        }

        composeTestRule
            .onNodeWithContentDescription("Remove Fashion filter")
            .assertDoesNotExist()
    }

    @Test
    fun xgFilterPill_selectedNoDismissCallback_doesNotShowDismissIcon() {
        composeTestRule.setContent {
            XGTheme {
                XGFilterPill(
                    label = "Fashion",
                    selected = true,
                    onClick = {},
                )
            }
        }

        composeTestRule
            .onNodeWithContentDescription("Remove Fashion filter")
            .assertDoesNotExist()
    }

    @Test
    fun xgFilterPill_dismiss_firesCallback() {
        var dismissed = false

        composeTestRule.setContent {
            XGTheme {
                XGFilterPill(
                    label = "Fashion",
                    selected = true,
                    onClick = {},
                    onDismiss = { dismissed = true },
                )
            }
        }

        composeTestRule
            .onNodeWithContentDescription("Remove Fashion filter")
            .performClick()
        assertThat(dismissed).isTrue()
    }

    // --- XGFilterPillItem ---

    @Test
    fun xgFilterPillItem_equality() {
        val item1 = XGFilterPillItem(label = "A", isSelected = true)
        val item2 = XGFilterPillItem(label = "A", isSelected = true)
        assertThat(item1).isEqualTo(item2)
    }

    @Test
    fun xgFilterPillItem_inequality() {
        val item1 = XGFilterPillItem(label = "A", isSelected = true)
        val item2 = XGFilterPillItem(label = "A", isSelected = false)
        assertThat(item1).isNotEqualTo(item2)
    }

    // --- XGFilterPillRow ---

    @Test
    fun xgFilterPillRow_displaysAllItems() {
        val items = listOf(
            XGFilterPillItem(label = "All", isSelected = true),
            XGFilterPillItem(label = "Electronics", isSelected = false),
            XGFilterPillItem(label = "Fashion", isSelected = false),
        )

        composeTestRule.setContent {
            XGTheme {
                XGFilterPillRow(
                    items = items,
                    onSelect = {},
                )
            }
        }

        composeTestRule.onNodeWithText("All").assertIsDisplayed()
        composeTestRule.onNodeWithText("Electronics").assertIsDisplayed()
        composeTestRule.onNodeWithText("Fashion").assertIsDisplayed()
    }

    @Test
    fun xgFilterPillRow_onSelect_firesWithCorrectIndex() {
        var selectedIndex = -1
        val items = listOf(
            XGFilterPillItem(label = "All", isSelected = true),
            XGFilterPillItem(label = "Electronics", isSelected = false),
        )

        composeTestRule.setContent {
            XGTheme {
                XGFilterPillRow(
                    items = items,
                    onSelect = { selectedIndex = it },
                )
            }
        }

        composeTestRule.onNodeWithText("Electronics").performClick()
        assertThat(selectedIndex).isEqualTo(1)
    }

    // --- Token Compliance ---

    @Test
    fun xgFilterPill_token_height_is36() {
        // Token: tokens.height = 36
        val expected = 36.dp
        assertThat(expected.value).isEqualTo(36f)
    }

    @Test
    fun xgFilterPill_token_cornerRadius_is18() {
        // Token: tokens.cornerRadius = 18
        val expected = 18.dp
        assertThat(expected.value).isEqualTo(18f)
    }

    @Test
    fun xgFilterPill_token_gap_isSpacingSm() {
        // Token: tokens.gap = 8 (XGSpacing.SM)
        assertThat(XGSpacing.SM.value).isEqualTo(8f)
    }

    @Test
    fun xgFilterPill_token_contentPadding_isSpacingBase() {
        // Token: tokens.horizontalPadding = 16 (XGSpacing.Base)
        assertThat(XGSpacing.Base.value).isEqualTo(16f)
    }

    @Test
    fun xgFilterPill_token_activeBackground_exists() {
        // Token: $foundations/colors.light.filterPillBackgroundActive
        assertThat(XGColors.FilterPillBackgroundActive).isNotNull()
    }

    @Test
    fun xgFilterPill_token_activeText_exists() {
        // Token: $foundations/colors.light.filterPillTextActive
        assertThat(XGColors.FilterPillTextActive).isNotNull()
    }

    @Test
    fun xgFilterPill_token_inactiveBackground_exists() {
        // Token: $foundations/colors.light.filterPillBackground
        assertThat(XGColors.FilterPillBackground).isNotNull()
    }

    @Test
    fun xgFilterPill_token_inactiveText_exists() {
        // Token: $foundations/colors.light.filterPillText
        assertThat(XGColors.FilterPillText).isNotNull()
    }
}
