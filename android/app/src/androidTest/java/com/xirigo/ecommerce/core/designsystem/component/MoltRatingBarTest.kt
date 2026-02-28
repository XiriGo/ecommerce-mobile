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
class MoltRatingBarTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltRatingBar_showValue_displaysRatingText() {
        composeTestRule.setContent {
            MoltTheme {
                MoltRatingBar(
                    rating = 4.5f,
                    showValue = true,
                )
            }
        }

        composeTestRule.onNodeWithText("4.5").assertIsDisplayed()
    }

    @Test
    fun moltRatingBar_noShowValue_doesNotDisplayRatingText() {
        composeTestRule.setContent {
            MoltTheme {
                MoltRatingBar(
                    rating = 4.5f,
                    showValue = false,
                )
            }
        }

        composeTestRule.onNodeWithText("4.5").assertDoesNotExist()
    }

    @Test
    fun moltRatingBar_withReviewCount_displaysReviewCount() {
        composeTestRule.setContent {
            MoltTheme {
                MoltRatingBar(
                    rating = 4.0f,
                    reviewCount = 123,
                )
            }
        }

        composeTestRule.onNodeWithText("(123)").assertIsDisplayed()
    }

    @Test
    fun moltRatingBar_noReviewCount_doesNotDisplayParentheses() {
        composeTestRule.setContent {
            MoltTheme {
                MoltRatingBar(
                    rating = 3.0f,
                    reviewCount = null,
                )
            }
        }

        composeTestRule.onNodeWithText("(0)").assertDoesNotExist()
    }

    @Test
    fun moltRatingBar_fullRating_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltRatingBar(
                    rating = 5.0f,
                    showValue = true,
                )
            }
        }

        composeTestRule.onNodeWithText("5.0").assertIsDisplayed()
    }

    @Test
    fun moltRatingBar_zeroRating_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltRatingBar(
                    rating = 0.0f,
                    showValue = true,
                )
            }
        }

        composeTestRule.onNodeWithText("0.0").assertIsDisplayed()
    }

    @Test
    fun moltRatingBar_halfRating_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltRatingBar(
                    rating = 2.5f,
                    showValue = true,
                )
            }
        }

        composeTestRule.onNodeWithText("2.5").assertIsDisplayed()
    }

    @Test
    fun moltRatingBar_accessibilityDescription_isSet() {
        composeTestRule.setContent {
            MoltTheme {
                MoltRatingBar(rating = 4.0f)
            }
        }

        // Rating bar should have a content description for accessibility
        composeTestRule.onNode(
            hasContentDescription("Rating: 4.0 out of 5", substring = true),
        ).assertExists()
    }

    @Test
    fun moltRatingBar_showValue_andReviewCount_bothDisplayed() {
        composeTestRule.setContent {
            MoltTheme {
                MoltRatingBar(
                    rating = 3.5f,
                    showValue = true,
                    reviewCount = 42,
                )
            }
        }

        composeTestRule.onNodeWithText("3.5").assertIsDisplayed()
        composeTestRule.onNodeWithText("(42)").assertIsDisplayed()
    }
}
