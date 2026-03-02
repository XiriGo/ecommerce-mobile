package com.xirigo.ecommerce.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * DQ-19: XGDivider component UI tests.
 *
 * Covers:
 * - [XGDivider]: renders without crash, modifier testTag forwarding,
 *   custom color, custom thickness, multiple instances
 * - [XGLabeledDivider]: renders label text, modifier testTag forwarding,
 *   empty label, long label, multiple instances
 */
@RunWith(AndroidJUnit4::class)
class XGDividerTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // --- XGDivider ---

    @Test
    fun xgDivider_defaultParams_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGDivider(modifier = Modifier.testTag("divider"))
            }
        }

        composeTestRule.onNodeWithTag("divider").assertIsDisplayed()
    }

    @Test
    fun xgDivider_customColor_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGDivider(
                    modifier = Modifier.testTag("dividerCustomColor"),
                    color = XGColors.Outline,
                )
            }
        }

        composeTestRule.onNodeWithTag("dividerCustomColor").assertIsDisplayed()
    }

    @Test
    fun xgDivider_customThickness_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGDivider(
                    modifier = Modifier.testTag("dividerThick"),
                    thickness = 4.dp,
                )
            }
        }

        composeTestRule.onNodeWithTag("dividerThick").assertIsDisplayed()
    }

    @Test
    fun xgDivider_twoInstances_renderIndependently() {
        composeTestRule.setContent {
            XGTheme {
                Column {
                    XGDivider(modifier = Modifier.testTag("dividerA"))
                    XGDivider(modifier = Modifier.testTag("dividerB"))
                }
            }
        }

        composeTestRule.onNodeWithTag("dividerA").assertIsDisplayed()
        composeTestRule.onNodeWithTag("dividerB").assertIsDisplayed()
    }

    @Test
    fun xgDivider_withPadding_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGDivider(
                    modifier = Modifier
                        .padding(horizontal = 16.dp)
                        .testTag("dividerPadded"),
                )
            }
        }

        composeTestRule.onNodeWithTag("dividerPadded").assertIsDisplayed()
    }

    // --- XGLabeledDivider ---

    @Test
    fun xgLabeledDivider_displaysLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGLabeledDivider(label = "OR CONTINUE WITH")
            }
        }

        composeTestRule.onNodeWithText("OR CONTINUE WITH").assertIsDisplayed()
    }

    @Test
    fun xgLabeledDivider_modifierTestTag_tagIsReachable() {
        composeTestRule.setContent {
            XGTheme {
                XGLabeledDivider(
                    label = "OR CONTINUE WITH",
                    modifier = Modifier.testTag("labeledDivider"),
                )
            }
        }

        composeTestRule.onNodeWithTag("labeledDivider").assertIsDisplayed()
        composeTestRule.onNodeWithText("OR CONTINUE WITH").assertIsDisplayed()
    }

    @Test
    fun xgLabeledDivider_emptyLabel_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGLabeledDivider(
                    label = "",
                    modifier = Modifier.testTag("labeledDividerEmpty"),
                )
            }
        }

        composeTestRule.onNodeWithTag("labeledDividerEmpty").assertIsDisplayed()
    }

    @Test
    fun xgLabeledDivider_longLabel_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGLabeledDivider(
                    label = "A VERY LONG DIVIDER LABEL TEXT FOR TESTING",
                    modifier = Modifier.testTag("labeledDividerLong"),
                )
            }
        }

        composeTestRule.onNodeWithTag("labeledDividerLong").assertIsDisplayed()
        composeTestRule.onNodeWithText("A VERY LONG DIVIDER LABEL TEXT FOR TESTING").assertIsDisplayed()
    }

    @Test
    fun xgLabeledDivider_customColor_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGLabeledDivider(
                    label = "TEST",
                    modifier = Modifier.testTag("labeledDividerColor"),
                    color = XGColors.OutlineVariant,
                )
            }
        }

        composeTestRule.onNodeWithTag("labeledDividerColor").assertIsDisplayed()
    }

    @Test
    fun xgLabeledDivider_twoInstances_renderIndependently() {
        composeTestRule.setContent {
            XGTheme {
                Column {
                    XGLabeledDivider(
                        label = "FIRST",
                        modifier = Modifier.testTag("labeledA"),
                    )
                    XGLabeledDivider(
                        label = "SECOND",
                        modifier = Modifier.testTag("labeledB"),
                    )
                }
            }
        }

        composeTestRule.onNodeWithTag("labeledA").assertIsDisplayed()
        composeTestRule.onNodeWithTag("labeledB").assertIsDisplayed()
        composeTestRule.onNodeWithText("FIRST").assertIsDisplayed()
        composeTestRule.onNodeWithText("SECOND").assertIsDisplayed()
    }
}
