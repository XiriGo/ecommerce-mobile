package com.xirigo.ecommerce.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.foundation.layout.Row
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * DQ-15: XGWishlistButton UI tests.
 *
 * Covers:
 * - Inactive state rendering and accessibility
 * - Active state rendering and accessibility
 * - Toggle callback invocation
 * - State toggle flow (inactive -> active -> inactive)
 * - Modifier forwarding
 * - Multiple independent instances
 */
@RunWith(AndroidJUnit4::class)
class XGWishlistButtonTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // --- Inactive state ---

    @Test
    fun inactiveState_displaysAddToWishlistLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGWishlistButton(isWishlisted = false, onToggle = {})
            }
        }

        composeTestRule
            .onNodeWithContentDescription("Add to wishlist")
            .assertIsDisplayed()
    }

    // --- Active state ---

    @Test
    fun activeState_displaysRemoveFromWishlistLabel() {
        composeTestRule.setContent {
            XGTheme {
                XGWishlistButton(isWishlisted = true, onToggle = {})
            }
        }

        composeTestRule
            .onNodeWithContentDescription("Remove from wishlist")
            .assertIsDisplayed()
    }

    // --- Toggle callback ---

    @Test
    fun click_invokesOnToggle() {
        var toggled = false
        composeTestRule.setContent {
            XGTheme {
                XGWishlistButton(
                    isWishlisted = false,
                    onToggle = { toggled = true },
                )
            }
        }

        composeTestRule
            .onNodeWithContentDescription("Add to wishlist")
            .performClick()

        assert(toggled) { "onToggle was not called" }
    }

    // --- State toggle flow ---

    @Test
    fun toggle_switchesAccessibilityLabel() {
        var wishlisted by mutableStateOf(false)

        composeTestRule.setContent {
            XGTheme {
                XGWishlistButton(
                    isWishlisted = wishlisted,
                    onToggle = { wishlisted = !wishlisted },
                )
            }
        }

        // Initially inactive
        composeTestRule
            .onNodeWithContentDescription("Add to wishlist")
            .assertIsDisplayed()
            .performClick()

        // Now active
        composeTestRule
            .onNodeWithContentDescription("Remove from wishlist")
            .assertIsDisplayed()
            .performClick()

        // Back to inactive
        composeTestRule
            .onNodeWithContentDescription("Add to wishlist")
            .assertIsDisplayed()
    }

    // --- Modifier forwarding ---

    @Test
    fun modifierTestTag_isReachable() {
        composeTestRule.setContent {
            XGTheme {
                XGWishlistButton(
                    isWishlisted = false,
                    onToggle = {},
                    modifier = Modifier.testTag("wishlistBtn"),
                )
            }
        }

        composeTestRule
            .onNodeWithTag("wishlistBtn")
            .assertIsDisplayed()
    }

    // --- Multiple instances ---

    @Test
    fun twoInstances_renderIndependently() {
        composeTestRule.setContent {
            XGTheme {
                Row {
                    XGWishlistButton(
                        isWishlisted = false,
                        onToggle = {},
                        modifier = Modifier.testTag("btnA"),
                    )
                    XGWishlistButton(
                        isWishlisted = true,
                        onToggle = {},
                        modifier = Modifier.testTag("btnB"),
                    )
                }
            }
        }

        composeTestRule.onNodeWithTag("btnA").assertIsDisplayed()
        composeTestRule.onNodeWithTag("btnB").assertIsDisplayed()
    }

    // --- Animation does not crash ---

    @Test
    fun rapidToggle_doesNotCrash() {
        var wishlisted by mutableStateOf(false)

        composeTestRule.setContent {
            XGTheme {
                XGWishlistButton(
                    isWishlisted = wishlisted,
                    onToggle = { wishlisted = !wishlisted },
                    modifier = Modifier.testTag("rapidBtn"),
                )
            }
        }

        val node = composeTestRule.onNodeWithTag("rapidBtn")
        repeat(6) {
            node.performClick()
            composeTestRule.waitForIdle()
        }
        node.assertIsDisplayed()
    }
}
