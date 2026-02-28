package com.xirigo.ecommerce.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGBadgeTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // --- XGCountBadge ---

    @Test
    fun xgCountBadge_zeroCount_notRendered() {
        composeTestRule.setContent {
            XGTheme {
                XGCountBadge(count = 0)
            }
        }

        composeTestRule.onNodeWithText("0").assertDoesNotExist()
    }

    @Test
    fun xgCountBadge_negativeCount_notRendered() {
        composeTestRule.setContent {
            XGTheme {
                XGCountBadge(count = -1)
            }
        }

        composeTestRule.onNodeWithText("-1").assertDoesNotExist()
    }

    @Test
    fun xgCountBadge_smallCount_displaysNumber() {
        composeTestRule.setContent {
            XGTheme {
                XGCountBadge(count = 5)
            }
        }

        composeTestRule.onNodeWithText("5").assertIsDisplayed()
    }

    @Test
    fun xgCountBadge_count99_displays99() {
        composeTestRule.setContent {
            XGTheme {
                XGCountBadge(count = 99)
            }
        }

        composeTestRule.onNodeWithText("99").assertIsDisplayed()
    }

    @Test
    fun xgCountBadge_count100_displays99Plus() {
        composeTestRule.setContent {
            XGTheme {
                XGCountBadge(count = 100)
            }
        }

        composeTestRule.onNodeWithText("99+").assertIsDisplayed()
    }

    @Test
    fun xgCountBadge_largeCount_cappedAt99Plus() {
        composeTestRule.setContent {
            XGTheme {
                XGCountBadge(count = 999)
            }
        }

        composeTestRule.onNodeWithText("99+").assertIsDisplayed()
        composeTestRule.onNodeWithText("999").assertDoesNotExist()
    }

    @Test
    fun xgCountBadge_count1_displayed() {
        composeTestRule.setContent {
            XGTheme {
                XGCountBadge(count = 1)
            }
        }

        composeTestRule.onNodeWithText("1").assertIsDisplayed()
    }

    // --- XGStatusBadge ---

    @Test
    fun xgStatusBadge_success_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGStatusBadge(
                    status = XGBadgeStatus.Success,
                    label = "In Stock",
                )
            }
        }

        composeTestRule.onNodeWithText("In Stock").assertIsDisplayed()
    }

    @Test
    fun xgStatusBadge_error_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGStatusBadge(
                    status = XGBadgeStatus.Error,
                    label = "Out of Stock",
                )
            }
        }

        composeTestRule.onNodeWithText("Out of Stock").assertIsDisplayed()
    }

    @Test
    fun xgStatusBadge_warning_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGStatusBadge(
                    status = XGBadgeStatus.Warning,
                    label = "Low Stock",
                )
            }
        }

        composeTestRule.onNodeWithText("Low Stock").assertIsDisplayed()
    }

    @Test
    fun xgStatusBadge_info_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGStatusBadge(
                    status = XGBadgeStatus.Info,
                    label = "Pre-order",
                )
            }
        }

        composeTestRule.onNodeWithText("Pre-order").assertIsDisplayed()
    }

    @Test
    fun xgStatusBadge_neutral_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGStatusBadge(
                    status = XGBadgeStatus.Neutral,
                    label = "Archived",
                )
            }
        }

        composeTestRule.onNodeWithText("Archived").assertIsDisplayed()
    }
}
