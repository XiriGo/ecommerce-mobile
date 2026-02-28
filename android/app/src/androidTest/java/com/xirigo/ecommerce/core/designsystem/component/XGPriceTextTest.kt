package com.xirigo.ecommerce.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
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

    @Test
    fun xgPriceText_regularPrice_displaysFormattedPrice() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(price = "29.99")
            }
        }

        composeTestRule.onNodeWithText("EUR 29.99").assertIsDisplayed()
    }

    @Test
    fun xgPriceText_customCurrencySymbol_usedInDisplay() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "49.99",
                    currencySymbol = "USD",
                )
            }
        }

        composeTestRule.onNodeWithText("USD 49.99").assertIsDisplayed()
    }

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

        composeTestRule.onNodeWithText("EUR 29.99").assertIsDisplayed()
        composeTestRule.onNodeWithText("EUR 39.99").assertIsDisplayed()
    }

    @Test
    fun xgPriceText_noOriginalPrice_onlyCurrentPriceShown() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(price = "9.99")
            }
        }

        composeTestRule.onNodeWithText("EUR 9.99").assertIsDisplayed()
    }

    @Test
    fun xgPriceText_regularPrice_accessibilityDescriptionSet() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(price = "19.99")
            }
        }

        composeTestRule.onNode(
            hasContentDescription("Price: EUR 19.99", substring = true),
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

    @Test
    fun xgPriceText_smallSize_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "9.99",
                    size = XGPriceSize.Small,
                )
            }
        }

        composeTestRule.onNodeWithText("EUR 9.99").assertIsDisplayed()
    }

    @Test
    fun xgPriceText_mediumSize_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "29.99",
                    size = XGPriceSize.Medium,
                )
            }
        }

        composeTestRule.onNodeWithText("EUR 29.99").assertIsDisplayed()
    }

    @Test
    fun xgPriceText_largeSize_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGPriceText(
                    price = "199.99",
                    size = XGPriceSize.Large,
                )
            }
        }

        composeTestRule.onNodeWithText("EUR 199.99").assertIsDisplayed()
    }
}
