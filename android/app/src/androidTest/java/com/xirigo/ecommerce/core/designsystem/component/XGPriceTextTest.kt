package com.xirigo.ecommerce.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGPriceTextTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // region Null price fallback

    @Test
    fun xgPriceText_nullPrice_rendersNothing() {
        composeTestRule.setContent {
            XGTheme {
                Column {
                    Text("before")
                    XGPriceText(price = null)
                    Text("after")
                }
            }
        }

        composeTestRule.onNodeWithText("before").assertIsDisplayed()
        composeTestRule.onNodeWithText("after").assertIsDisplayed()
        // No price text nodes should exist
        composeTestRule.onNodeWithText("\u20AC", substring = true, useUnmergedTree = true)
            .assertDoesNotExist()
    }

    @Test
    fun xgPriceText_nullPriceWithOriginal_rendersNothing() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(price = null, originalPrice = "39.99")
            }
        }

        composeTestRule.onNodeWithText("\u20AC", substring = true, useUnmergedTree = true)
            .assertDoesNotExist()
    }

    // endregion

    // region Regular price display

    @Test
    fun xgPriceText_regularPrice_displaysFormattedPrice() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(price = "29.99")
            }
        }

        composeTestRule.onNodeWithText("\u20AC29,99", useUnmergedTree = true).assertIsDisplayed()
    }

    @Test
    fun xgPriceText_customCurrencySymbol_usedInDisplay() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "49.99",
                    currencySymbol = "$",
                )
            }
        }

        composeTestRule.onNodeWithText("$49,99", useUnmergedTree = true).assertIsDisplayed()
    }

    // endregion

    // region Sale price / strikethrough

    @Test
    fun xgPriceText_withOriginalPrice_showsBothPrices() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "29.99",
                    originalPrice = "39.99",
                )
            }
        }

        composeTestRule.onNodeWithText("\u20AC29,99", useUnmergedTree = true).assertIsDisplayed()
        composeTestRule.onNodeWithText("\u20AC39,99", useUnmergedTree = true).assertIsDisplayed()
    }

    @Test
    fun xgPriceText_noOriginalPrice_onlyCurrentPriceShown() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(price = "9.99")
            }
        }

        composeTestRule.onNodeWithText("\u20AC9,99", useUnmergedTree = true).assertIsDisplayed()
    }

    // endregion

    // region Accessibility

    @Test
    fun xgPriceText_regularPrice_accessibilityDescriptionSet() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(price = "19.99")
            }
        }

        composeTestRule.onNode(
            hasContentDescription("Price:", substring = true),
        ).assertExists()
    }

    @Test
    fun xgPriceText_salePrice_accessibilityDescriptionIncludesBothPrices() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "29.99",
                    originalPrice = "39.99",
                )
            }
        }

        composeTestRule.onNode(
            hasContentDescription("Sale price:", substring = true),
        ).assertExists()
    }

    // endregion

    // region XGPriceStyle variants

    @Test
    fun xgPriceText_smallStyle_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "9.99",
                    style = XGPriceStyle.Small,
                )
            }
        }

        composeTestRule.onNodeWithText("\u20AC9,99", useUnmergedTree = true).assertIsDisplayed()
    }

    @Test
    fun xgPriceText_defaultStyle_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "29.99",
                    style = XGPriceStyle.Default,
                )
            }
        }

        composeTestRule.onNodeWithText("\u20AC29,99", useUnmergedTree = true).assertIsDisplayed()
    }

    @Test
    fun xgPriceText_dealStyle_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "199.99",
                    style = XGPriceStyle.Deal,
                )
            }
        }

        composeTestRule.onNodeWithText("\u20AC199,99", useUnmergedTree = true).assertIsDisplayed()
    }

    @Test
    fun xgPriceText_standardStyle_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "14.99",
                    style = XGPriceStyle.Standard,
                )
            }
        }

        composeTestRule.onNodeWithText("\u20AC14,99", useUnmergedTree = true).assertIsDisplayed()
    }

    // endregion

    // region Layout variants

    @Test
    fun xgPriceText_stackedLayout_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "89.99",
                    originalPrice = "149.99",
                    layout = XGPriceLayout.Stacked,
                )
            }
        }

        composeTestRule.onNodeWithText("\u20AC89,99", useUnmergedTree = true).assertIsDisplayed()
        composeTestRule.onNodeWithText("\u20AC149,99", useUnmergedTree = true).assertIsDisplayed()
    }

    @Test
    fun xgPriceText_inlineLayout_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "29.99",
                    originalPrice = "49.99",
                    layout = XGPriceLayout.Inline,
                )
            }
        }

        composeTestRule.onNodeWithText("\u20AC29,99", useUnmergedTree = true).assertIsDisplayed()
        composeTestRule.onNodeWithText("\u20AC49,99", useUnmergedTree = true).assertIsDisplayed()
    }

    // endregion

    // region Custom strikethrough font size

    @Test
    fun xgPriceText_standardStrikethroughFontSize_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "29.99",
                    originalPrice = "39.99",
                    style = XGPriceStyle.Standard,
                    strikethroughFontSize = 14f,
                )
            }
        }

        composeTestRule.onNodeWithText("\u20AC29,99", useUnmergedTree = true).assertIsDisplayed()
        composeTestRule.onNodeWithText("\u20AC39,99", useUnmergedTree = true).assertIsDisplayed()
    }

    // endregion
}
