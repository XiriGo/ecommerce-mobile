package com.xirigo.ecommerce.core.navigation

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Category
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * Compose UI tests for PlaceholderScreen.
 *
 * Tests verify:
 * - The title text is rendered correctly.
 * - The "Coming soon" subtitle text is displayed.
 * - Multiple distinct route names render their respective titles.
 */
@RunWith(AndroidJUnit4::class)
class PlaceholderScreenTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // -------------------------------------------------------------------------
    // Title rendering
    // -------------------------------------------------------------------------

    @Test
    fun placeholderScreen_rendersRouteTitle_home() {
        composeTestRule.setContent {
            XGTheme {
                PlaceholderScreen(
                    title = "Home",
                    icon = Icons.Outlined.Home,
                )
            }
        }

        composeTestRule.onNodeWithText("Home").assertIsDisplayed()
    }

    @Test
    fun placeholderScreen_rendersRouteTitle_categories() {
        composeTestRule.setContent {
            XGTheme {
                PlaceholderScreen(
                    title = "Categories",
                    icon = Icons.Outlined.Category,
                )
            }
        }

        composeTestRule.onNodeWithText("Categories").assertIsDisplayed()
    }

    @Test
    fun placeholderScreen_rendersRouteTitle_cart() {
        composeTestRule.setContent {
            XGTheme {
                PlaceholderScreen(
                    title = "Cart",
                    icon = Icons.Outlined.ShoppingCart,
                )
            }
        }

        composeTestRule.onNodeWithText("Cart").assertIsDisplayed()
    }

    @Test
    fun placeholderScreen_rendersRouteTitle_profile() {
        composeTestRule.setContent {
            XGTheme {
                PlaceholderScreen(
                    title = "Profile",
                    icon = Icons.Outlined.Person,
                )
            }
        }

        composeTestRule.onNodeWithText("Profile").assertIsDisplayed()
    }

    @Test
    fun placeholderScreen_rendersRouteTitle_productDetail() {
        composeTestRule.setContent {
            XGTheme {
                PlaceholderScreen(
                    title = "Product Detail",
                    icon = Icons.Outlined.Home,
                )
            }
        }

        composeTestRule.onNodeWithText("Product Detail").assertIsDisplayed()
    }

    // -------------------------------------------------------------------------
    // "Coming soon" subtitle is always present
    // -------------------------------------------------------------------------

    @Test
    fun placeholderScreen_showsComingSoonText_forHomeRoute() {
        composeTestRule.setContent {
            XGTheme {
                PlaceholderScreen(
                    title = "Home",
                    icon = Icons.Outlined.Home,
                )
            }
        }

        composeTestRule.onNodeWithText("Coming soon").assertIsDisplayed()
    }

    @Test
    fun placeholderScreen_showsComingSoonText_forArbitraryTitle() {
        composeTestRule.setContent {
            XGTheme {
                PlaceholderScreen(
                    title = "Order Detail",
                    icon = Icons.Outlined.Home,
                )
            }
        }

        composeTestRule.onNodeWithText("Coming soon").assertIsDisplayed()
    }

    // -------------------------------------------------------------------------
    // Both title and subtitle coexist
    // -------------------------------------------------------------------------

    @Test
    fun placeholderScreen_rendersBothTitleAndSubtitle() {
        composeTestRule.setContent {
            XGTheme {
                PlaceholderScreen(
                    title = "Wishlist",
                    icon = Icons.Outlined.Person,
                )
            }
        }

        composeTestRule.onNodeWithText("Wishlist").assertIsDisplayed()
        composeTestRule.onNodeWithText("Coming soon").assertIsDisplayed()
    }

    @Test
    fun placeholderScreen_rendersBothTitleAndSubtitle_forSettings() {
        composeTestRule.setContent {
            XGTheme {
                PlaceholderScreen(
                    title = "Settings",
                    icon = Icons.Outlined.Person,
                )
            }
        }

        composeTestRule.onNodeWithText("Settings").assertIsDisplayed()
        composeTestRule.onNodeWithText("Coming soon").assertIsDisplayed()
    }

    // -------------------------------------------------------------------------
    // Title uniqueness — different titles produce different text nodes
    // -------------------------------------------------------------------------

    @Test
    fun placeholderScreen_differentTitles_showDistinctText() {
        composeTestRule.setContent {
            XGTheme {
                PlaceholderScreen(
                    title = "Checkout",
                    icon = Icons.Outlined.ShoppingCart,
                )
            }
        }

        composeTestRule.onNodeWithText("Checkout").assertIsDisplayed()
        composeTestRule.onNodeWithText("Home").assertDoesNotExist()
    }
}
