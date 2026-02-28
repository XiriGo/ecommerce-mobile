package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
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

    @Test
    fun moltBottomBar_rendersAllTabs() {
        composeTestRule.setContent {
            XGTheme {
                XGBottomBar(
                    items = sampleTabs,
                    selectedIndex = 0,
                    onTabSelected = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Home").assertIsDisplayed()
        composeTestRule.onNodeWithText("Cart").assertIsDisplayed()
        composeTestRule.onNodeWithText("Profile").assertIsDisplayed()
    }

    @Test
    fun moltBottomBar_selectedTab_hasSelectedState() {
        composeTestRule.setContent {
            XGTheme {
                XGBottomBar(
                    items = sampleTabs,
                    selectedIndex = 0,
                    onTabSelected = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Home").assertIsSelected()
    }

    @Test
    fun moltBottomBar_tabClick_firesCallbackWithIndex() {
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

        composeTestRule.onNodeWithText("Cart").performClick()
        assertThat(selectedIndex).isEqualTo(1)
    }

    @Test
    fun moltBottomBar_badgeCount_displayedOnTab() {
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
    fun moltBottomBar_badgeCount_zeroBadge_notShown() {
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
    fun moltBottomBar_badgeCount_99Plus_displayedCorrectly() {
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

    @Test
    fun moltBottomBar_selectingDifferentTab_updatesSelection() {
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

        composeTestRule.onNodeWithText("Profile").performClick()
        assertThat(selectedIndex).isEqualTo(2)
    }
}
