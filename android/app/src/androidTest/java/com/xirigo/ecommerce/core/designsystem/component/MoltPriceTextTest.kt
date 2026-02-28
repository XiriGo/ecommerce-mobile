package com.xirigo.ecommerce.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.MoltTheme

@RunWith(AndroidJUnit4::class)
class MoltPriceTextTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltPriceText_regularPrice_displaysFormattedPrice() {
        composeTestRule.setContent {
            MoltTheme {
                MoltPriceText(price = "29.99")
            }
        }

        composeTestRule.onNodeWithText("EUR 29.99").assertIsDisplayed()
    }

    @Test
    fun moltPriceText_customCurrencySymbol_usedInDisplay() {
        composeTestRule.setContent {
            MoltTheme {
                MoltPriceText(
                    price = "49.99",
                    currencySymbol = "USD",
                )
            }
        }

        composeTestRule.onNodeWithText("USD 49.99").assertIsDisplayed()
    }

    @Test
    fun moltPriceText_withOriginalPrice_showsBothPrices() {
        composeTestRule.setContent {
            MoltTheme {
                MoltPriceText(
                    price = "29.99",
                    originalPrice = "39.99",
                )
            }
        }

        composeTestRule.onNodeWithText("EUR 29.99").assertIsDisplayed()
        composeTestRule.onNodeWithText("EUR 39.99").assertIsDisplayed()
    }

    @Test
    fun moltPriceText_noOriginalPrice_onlyCurrentPriceShown() {
        composeTestRule.setContent {
            MoltTheme {
                MoltPriceText(price = "9.99")
            }
        }

        composeTestRule.onNodeWithText("EUR 9.99").assertIsDisplayed()
    }

    @Test
    fun moltPriceText_regularPrice_accessibilityDescriptionSet() {
        composeTestRule.setContent {
            MoltTheme {
                MoltPriceText(price = "19.99")
            }
        }

        composeTestRule.onNode(
            hasContentDescription("Price: EUR 19.99", substring = true),
        ).assertExists()
    }

    @Test
    fun moltPriceText_salePrice_accessibilityDescriptionIncludesBothPrices() {
        composeTestRule.setContent {
            MoltTheme {
                MoltPriceText(
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
    fun moltPriceText_smallSize_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltPriceText(
                    price = "9.99",
                    size = MoltPriceSize.Small,
                )
            }
        }

        composeTestRule.onNodeWithText("EUR 9.99").assertIsDisplayed()
    }

    @Test
    fun moltPriceText_mediumSize_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltPriceText(
                    price = "29.99",
                    size = MoltPriceSize.Medium,
                )
            }
        }

        composeTestRule.onNodeWithText("EUR 29.99").assertIsDisplayed()
    }

    @Test
    fun moltPriceText_largeSize_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltPriceText(
                    price = "199.99",
                    size = MoltPriceSize.Large,
                )
            }
        }

        composeTestRule.onNodeWithText("EUR 199.99").assertIsDisplayed()
    }
}
