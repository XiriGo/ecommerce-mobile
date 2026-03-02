package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGBottomBarTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    private val sampleTabs = listOf(
        XGTabItem(
            label = "Home",
            icon = Icons.Outlined.Home,
            selectedIcon = Icons.Filled.Home,
        ),
        XGTabItem(
            label = "Search",
            icon = Icons.Outlined.Search,
            selectedIcon = Icons.Filled.Search,
        ),
        XGTabItem(
            label = "Cart",
            icon = Icons.Outlined.ShoppingCart,
            selectedIcon = Icons.Filled.ShoppingCart,
            badgeCount = 3,
        ),
        XGTabItem(
            label = "Profile",
            icon = Icons.Outlined.Person,
            selectedIcon = Icons.Filled.Person,
        ),
    )

    // region Tab rendering

    @Test
    fun xgBottomBar_rendersAllTabs() {
        composeTestRule.setContent {
            XGTheme {
                XGBottomBar(
                    items = sampleTabs,
                    selectedIndex = 0,
                    onTabSelected = {},
                )
            }
        }

        composeTestRule.onNodeWithContentDescription("Home").assertIsDisplayed()
        composeTestRule.onNodeWithContentDescription("Search").assertIsDisplayed()
        composeTestRule.onNodeWithContentDescription("Cart").assertIsDisplayed()
        composeTestRule.onNodeWithContentDescription("Profile").assertIsDisplayed()
    }

    // endregion

    // region Tab selection

    @Test
    fun xgBottomBar_tabClick_firesCallbackWithIndex() {
        var selectedIndex = 0

        composeTestRule.setContent {
            XGTheme {
                XGBottomBar(
                    items = sampleTabs,
                    selectedIndex = selectedIndex,
                    onTabSelected = { selectedIndex = it },
                )
            }
        }

        composeTestRule.onNodeWithContentDescription("Cart").performClick()
        assertThat(selectedIndex).isEqualTo(2)
    }

    @Test
    fun xgBottomBar_selectingDifferentTab_updatesSelection() {
        var selectedIndex = 0

        composeTestRule.setContent {
            XGTheme {
                XGBottomBar(
                    items = sampleTabs,
                    selectedIndex = selectedIndex,
                    onTabSelected = { selectedIndex = it },
                )
            }
        }

        composeTestRule.onNodeWithContentDescription("Profile").performClick()
        assertThat(selectedIndex).isEqualTo(3)
    }

    // endregion

    // region Badge display

    @Test
    fun xgBottomBar_badgeCount_displayedOnTab() {
        composeTestRule.setContent {
            XGTheme {
                XGBottomBar(
                    items = sampleTabs,
                    selectedIndex = 0,
                    onTabSelected = {},
                )
            }
        }

        // Badge "3" should appear on the Cart tab
        composeTestRule.onNodeWithText("3").assertIsDisplayed()
    }

    @Test
    fun xgBottomBar_badgeCount_zeroBadge_notShown() {
        val tabsWithZeroBadge = listOf(
            XGTabItem(
                label = "Home",
                icon = Icons.Outlined.Home,
                selectedIcon = Icons.Filled.Home,
                badgeCount = 0,
            ),
        )

        composeTestRule.setContent {
            XGTheme {
                XGBottomBar(
                    items = tabsWithZeroBadge,
                    selectedIndex = 0,
                    onTabSelected = {},
                )
            }
        }

        // Badge "0" should not be shown
        composeTestRule.onNodeWithText("0").assertDoesNotExist()
    }

    @Test
    fun xgBottomBar_badgeCount_99Plus_displayedCorrectly() {
        val tabsWithHighBadge = listOf(
            XGTabItem(
                label = "Cart",
                icon = Icons.Outlined.ShoppingCart,
                selectedIcon = Icons.Filled.ShoppingCart,
                badgeCount = 100,
            ),
        )

        composeTestRule.setContent {
            XGTheme {
                XGBottomBar(
                    items = tabsWithHighBadge,
                    selectedIndex = 0,
                    onTabSelected = {},
                )
            }
        }

        composeTestRule.onNodeWithText("99+").assertIsDisplayed()
    }

    // endregion

    // region Token contract tests

    @Test
    fun xgColors_bottomNavBackground_matchesToken() {
        // bottomNav.background = #FFFFFF
        assertThat(XGColors.BottomNavBackground).isEqualTo(Color(0xFFFFFFFF))
    }

    @Test
    fun xgColors_bottomNavIconActive_matchesToken() {
        // bottomNav.iconActive = #6000FE
        assertThat(XGColors.BottomNavIconActive).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun xgColors_bottomNavIconInactive_matchesToken() {
        // bottomNav.iconInactive = #8E8E93
        assertThat(XGColors.BottomNavIconInactive).isEqualTo(Color(0xFF8E8E93))
    }

    @Test
    fun xgColors_outlineVariant_matchesBorderSubtleToken() {
        // light.borderSubtle = #F0F0F0
        assertThat(XGColors.OutlineVariant).isEqualTo(Color(0xFFF0F0F0))
    }

    // endregion

    // region Accessibility

    @Test
    fun xgBottomBar_eachTab_hasContentDescription() {
        composeTestRule.setContent {
            XGTheme {
                XGBottomBar(
                    items = sampleTabs,
                    selectedIndex = 0,
                    onTabSelected = {},
                )
            }
        }

        sampleTabs.forEach { tab ->
            composeTestRule.onNodeWithContentDescription(tab.label).assertExists()
        }
    }

    // endregion
}
