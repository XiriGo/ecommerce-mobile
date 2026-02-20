package com.molt.marketplace.core.designsystem.component

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.google.common.truth.Truth.assertThat
import com.molt.marketplace.core.designsystem.theme.MoltTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MoltCardTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // --- MoltProductCard ---

    @Test
    fun moltProductCard_rendersTitle() {
        composeTestRule.setContent {
            MoltTheme {
                MoltProductCard(
                    imageUrl = null,
                    title = "Premium Headphones",
                    price = "29.99",
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Premium Headphones").assertIsDisplayed()
    }

    @Test
    fun moltProductCard_rendersPrice() {
        composeTestRule.setContent {
            MoltTheme {
                MoltProductCard(
                    imageUrl = null,
                    title = "Test Product",
                    price = "49.99",
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("EUR 49.99").assertIsDisplayed()
    }

    @Test
    fun moltProductCard_rendersVendorName() {
        composeTestRule.setContent {
            MoltTheme {
                MoltProductCard(
                    imageUrl = null,
                    title = "Product",
                    price = "9.99",
                    vendorName = "TechStore",
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("TechStore").assertIsDisplayed()
    }

    @Test
    fun moltProductCard_clickCallback_fires() {
        var clicked = false

        composeTestRule.setContent {
            MoltTheme {
                MoltProductCard(
                    imageUrl = null,
                    title = "Clickable Product",
                    price = "15.00",
                    onClick = { clicked = true },
                )
            }
        }

        composeTestRule.onNodeWithText("Clickable Product").performClick()
        assertThat(clicked).isTrue()
    }

    @Test
    fun moltProductCard_wishlistButton_shown_whenCallbackProvided() {
        composeTestRule.setContent {
            MoltTheme {
                MoltProductCard(
                    imageUrl = null,
                    title = "Wishlist Product",
                    price = "19.99",
                    isWishlisted = false,
                    onWishlistToggle = {},
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithContentDescription("Add to wishlist").assertIsDisplayed()
    }

    @Test
    fun moltProductCard_wishlistButton_showsFilled_whenWishlisted() {
        composeTestRule.setContent {
            MoltTheme {
                MoltProductCard(
                    imageUrl = null,
                    title = "Wishlisted Product",
                    price = "19.99",
                    isWishlisted = true,
                    onWishlistToggle = {},
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithContentDescription("Remove from wishlist").assertIsDisplayed()
    }

    @Test
    fun moltProductCard_wishlistToggle_firesCallback() {
        var toggled = false

        composeTestRule.setContent {
            MoltTheme {
                MoltProductCard(
                    imageUrl = null,
                    title = "Toggle Product",
                    price = "9.99",
                    isWishlisted = false,
                    onWishlistToggle = { toggled = true },
                    onClick = {},
                )
            }
        }

        composeTestRule.onNodeWithContentDescription("Add to wishlist").performClick()
        assertThat(toggled).isTrue()
    }

    // --- MoltInfoCard ---

    @Test
    fun moltInfoCard_rendersTitle() {
        composeTestRule.setContent {
            MoltTheme {
                MoltInfoCard(
                    title = "Shipping Address",
                )
            }
        }

        composeTestRule.onNodeWithText("Shipping Address").assertIsDisplayed()
    }

    @Test
    fun moltInfoCard_rendersSubtitle_whenProvided() {
        composeTestRule.setContent {
            MoltTheme {
                MoltInfoCard(
                    title = "Delivery",
                    subtitle = "123 Main St, Valletta",
                )
            }
        }

        composeTestRule.onNodeWithText("Delivery").assertIsDisplayed()
        composeTestRule.onNodeWithText("123 Main St, Valletta").assertIsDisplayed()
    }

    @Test
    fun moltInfoCard_clickCallback_fires_whenProvided() {
        var clicked = false

        composeTestRule.setContent {
            MoltTheme {
                MoltInfoCard(
                    title = "Clickable Card",
                    onClick = { clicked = true },
                )
            }
        }

        composeTestRule.onNodeWithText("Clickable Card").performClick()
        assertThat(clicked).isTrue()
    }
}
