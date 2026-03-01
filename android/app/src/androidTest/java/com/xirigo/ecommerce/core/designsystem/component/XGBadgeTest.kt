package com.xirigo.ecommerce.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * DQ-08: XGBadge component UI tests.
 *
 * Covers:
 * - [XGCountBadge]: zero/negative (not rendered), small, 99, 100 (capped), 150 (capped),
 *   count=1, modifier testTag forwarding, multiple instances
 * - [XGStatusBadge]: all 5 [XGBadgeStatus] values render without crash,
 *   label is displayed, modifier testTag forwarding, multiple instances
 */
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

    // --- XGCountBadge additional cases ---

    @Test
    fun xgCountBadge_count150_cappedAt99Plus() {
        composeTestRule.setContent {
            XGTheme {
                XGCountBadge(count = 150)
            }
        }

        composeTestRule.onNodeWithText("99+").assertIsDisplayed()
        composeTestRule.onNodeWithText("150").assertDoesNotExist()
    }

    @Test
    fun xgCountBadge_modifierTestTag_tagIsReachable() {
        composeTestRule.setContent {
            XGTheme {
                XGCountBadge(
                    count = 3,
                    modifier = Modifier.testTag("countBadge"),
                )
            }
        }

        composeTestRule.onNodeWithTag("countBadge").assertIsDisplayed()
    }

    @Test
    fun xgCountBadge_twoInstances_renderIndependently() {
        composeTestRule.setContent {
            XGTheme {
                Row {
                    XGCountBadge(
                        count = 4,
                        modifier = Modifier.testTag("countBadgeA"),
                    )
                    XGCountBadge(
                        count = 200,
                        modifier = Modifier.testTag("countBadgeB"),
                    )
                }
            }
        }

        composeTestRule.onNodeWithTag("countBadgeA").assertIsDisplayed()
        composeTestRule.onNodeWithTag("countBadgeB").assertIsDisplayed()
        composeTestRule.onNodeWithText("4").assertIsDisplayed()
        composeTestRule.onNodeWithText("99+").assertIsDisplayed()
    }

    // --- XGStatusBadge additional cases ---

    @Test
    fun xgStatusBadge_modifierTestTag_tagIsReachable() {
        composeTestRule.setContent {
            XGTheme {
                XGStatusBadge(
                    status = XGBadgeStatus.Success,
                    label = "Available",
                    modifier = Modifier.testTag("statusBadge"),
                )
            }
        }

        composeTestRule.onNodeWithTag("statusBadge").assertIsDisplayed()
        composeTestRule.onNodeWithText("Available").assertIsDisplayed()
    }

    @Test
    fun xgStatusBadge_twoInstances_renderIndependently() {
        composeTestRule.setContent {
            XGTheme {
                Row {
                    XGStatusBadge(
                        status = XGBadgeStatus.Success,
                        label = "In Stock",
                        modifier = Modifier
                            .size(120.dp, 32.dp)
                            .testTag("badgeSuccess"),
                    )
                    XGStatusBadge(
                        status = XGBadgeStatus.Error,
                        label = "Out of Stock",
                        modifier = Modifier
                            .size(140.dp, 32.dp)
                            .testTag("badgeError"),
                    )
                }
            }
        }

        composeTestRule.onNodeWithTag("badgeSuccess").assertIsDisplayed()
        composeTestRule.onNodeWithTag("badgeError").assertIsDisplayed()
        composeTestRule.onNodeWithText("In Stock").assertIsDisplayed()
        composeTestRule.onNodeWithText("Out of Stock").assertIsDisplayed()
    }

    @Test
    fun xgStatusBadge_allFiveStatuses_renderWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                Row {
                    XGStatusBadge(
                        status = XGBadgeStatus.Success,
                        label = "Success",
                        modifier = Modifier.testTag("s_success"),
                    )
                    XGStatusBadge(
                        status = XGBadgeStatus.Warning,
                        label = "Warning",
                        modifier = Modifier.testTag("s_warning"),
                    )
                    XGStatusBadge(
                        status = XGBadgeStatus.Error,
                        label = "Error",
                        modifier = Modifier.testTag("s_error"),
                    )
                    XGStatusBadge(
                        status = XGBadgeStatus.Info,
                        label = "Info",
                        modifier = Modifier.testTag("s_info"),
                    )
                    XGStatusBadge(
                        status = XGBadgeStatus.Neutral,
                        label = "Neutral",
                        modifier = Modifier.testTag("s_neutral"),
                    )
                }
            }
        }

        composeTestRule.onNodeWithTag("s_success").assertIsDisplayed()
        composeTestRule.onNodeWithTag("s_warning").assertIsDisplayed()
        composeTestRule.onNodeWithTag("s_error").assertIsDisplayed()
        composeTestRule.onNodeWithTag("s_info").assertIsDisplayed()
        composeTestRule.onNodeWithTag("s_neutral").assertIsDisplayed()
    }

    @Test
    fun xgStatusBadge_emptyLabel_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGStatusBadge(
                    status = XGBadgeStatus.Neutral,
                    label = "",
                    modifier = Modifier.testTag("emptyLabelBadge"),
                )
            }
        }

        // Empty label badge should not crash — the Box is still composed
        composeTestRule.onNodeWithTag("emptyLabelBadge").assertIsDisplayed()
    }
}
