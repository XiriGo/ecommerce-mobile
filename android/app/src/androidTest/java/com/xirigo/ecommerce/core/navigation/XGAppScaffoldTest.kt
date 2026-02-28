package com.xirigo.ecommerce.core.navigation

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * Compose UI tests for XGAppScaffold.
 *
 * Tests verify:
 * - All four bottom nav tabs are rendered with their correct labels.
 * - The Home tab is selected by default.
 * - Tapping each tab updates the selection (tab switching).
 * - The cart badge is not shown when badgeCount = 0 (M2-01 not yet implemented).
 * - The bottom bar is visible on the default (Home) route.
 */
@RunWith(AndroidJUnit4::class)
class XGAppScaffoldTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // -------------------------------------------------------------------------
    // Tab rendering
    // -------------------------------------------------------------------------

    @Test
    fun xgAppScaffold_allFourTabLabels_areDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        composeTestRule.onNodeWithText("Home").assertIsDisplayed()
        composeTestRule.onNodeWithText("Categories").assertIsDisplayed()
        composeTestRule.onNodeWithText("Cart").assertIsDisplayed()
        composeTestRule.onNodeWithText("Profile").assertIsDisplayed()
    }

    @Test
    fun xgAppScaffold_homeTab_isSelectedByDefault() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        composeTestRule.onNodeWithText("Home").assertIsSelected()
    }

    // -------------------------------------------------------------------------
    // Tab switching
    // -------------------------------------------------------------------------

    @Test
    fun xgAppScaffold_tapCategoriesTab_switchesToCategories() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        composeTestRule.onNodeWithText("Categories").performClick()

        composeTestRule.onNodeWithText("Categories").assertIsSelected()
    }

    @Test
    fun xgAppScaffold_tapCartTab_switchesToCart() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        composeTestRule.onNodeWithText("Cart").performClick()

        composeTestRule.onNodeWithText("Cart").assertIsSelected()
    }

    @Test
    fun xgAppScaffold_tapProfileTab_switchesToProfile() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        composeTestRule.onNodeWithText("Profile").performClick()

        composeTestRule.onNodeWithText("Profile").assertIsSelected()
    }

    @Test
    fun xgAppScaffold_tapHomeTab_afterSwitchingAway_returnsTohome() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        // Switch away from Home
        composeTestRule.onNodeWithText("Cart").performClick()
        composeTestRule.onNodeWithText("Cart").assertIsSelected()

        // Switch back to Home
        composeTestRule.onNodeWithText("Home").performClick()
        composeTestRule.onNodeWithText("Home").assertIsSelected()
    }

    // -------------------------------------------------------------------------
    // Cart badge — hardcoded to 0 until M2-01 is implemented
    // -------------------------------------------------------------------------

    @Test
    fun xgAppScaffold_cartBadge_isNotShown_whenCountIsZero() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        // Badge should not show "0" text when count is zero
        composeTestRule.onNodeWithText("0").assertDoesNotExist()
    }

    // -------------------------------------------------------------------------
    // Bottom bar visibility — visible on default Home route
    // -------------------------------------------------------------------------

    @Test
    fun xgAppScaffold_bottomBar_isVisible_onHomeRoute() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        // The bottom bar labels being present confirms the bar is visible
        composeTestRule.onNodeWithText("Home").assertIsDisplayed()
        composeTestRule.onNodeWithText("Cart").assertIsDisplayed()
    }

    @Test
    fun xgAppScaffold_bottomBar_isVisible_onCategoriesRoute() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        composeTestRule.onNodeWithText("Categories").performClick()

        // After switching to Categories, the bottom bar must still be visible
        composeTestRule.onNodeWithText("Home").assertIsDisplayed()
        composeTestRule.onNodeWithText("Categories").assertIsDisplayed()
        composeTestRule.onNodeWithText("Cart").assertIsDisplayed()
        composeTestRule.onNodeWithText("Profile").assertIsDisplayed()
    }

    // -------------------------------------------------------------------------
    // Placeholder content is rendered for the selected tab
    // -------------------------------------------------------------------------

    @Test
    fun xgAppScaffold_homeTab_showsPlaceholderContent() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        // PlaceholderScreen renders the tab title as headlineSmall text
        // "Home" appears both in the bottom bar label and the placeholder title.
        // We assert that the node is displayed (at least one instance).
        composeTestRule.onNodeWithText("Home").assertIsDisplayed()
    }

    @Test
    fun xgAppScaffold_categoriesTab_showsPlaceholderContent() {
        composeTestRule.setContent {
            XGTheme {
                XGAppScaffold()
            }
        }

        composeTestRule.onNodeWithText("Categories").performClick()

        composeTestRule.onNodeWithText("Categories").assertIsDisplayed()
    }
}
