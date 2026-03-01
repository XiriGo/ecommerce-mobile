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
class XGRatingBarTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun xgRatingBar_showValue_displaysRatingText() {
        composeTestRule.setContent {
            XGTheme {
                XGRatingBar(
                    rating = 4.5f,
                    showValue = true,
                )
            }
        }

        composeTestRule.onNodeWithText("4.5").assertIsDisplayed()
    }

    @Test
    fun xgRatingBar_noShowValue_doesNotDisplayRatingText() {
        composeTestRule.setContent {
            XGTheme {
                XGRatingBar(
                    rating = 4.5f,
                    showValue = false,
                )
            }
        }

        composeTestRule.onNodeWithText("4.5").assertDoesNotExist()
    }

    @Test
    fun xgRatingBar_withReviewCount_displaysReviewCount() {
        composeTestRule.setContent {
            XGTheme {
                XGRatingBar(
                    rating = 4.0f,
                    reviewCount = 123,
                )
            }
        }

        composeTestRule.onNodeWithText("(123)").assertIsDisplayed()
    }

    @Test
    fun xgRatingBar_noReviewCount_doesNotDisplayParentheses() {
        composeTestRule.setContent {
            XGTheme {
                XGRatingBar(
                    rating = 3.0f,
                    reviewCount = null,
                )
            }
        }

        composeTestRule.onNodeWithText("(0)").assertDoesNotExist()
    }

    @Test
    fun xgRatingBar_fullRating_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGRatingBar(
                    rating = 5.0f,
                    showValue = true,
                )
            }
        }

        composeTestRule.onNodeWithText("5.0").assertIsDisplayed()
    }

    @Test
    fun xgRatingBar_zeroRating_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGRatingBar(
                    rating = 0.0f,
                    showValue = true,
                )
            }
        }

        composeTestRule.onNodeWithText("0.0").assertIsDisplayed()
    }

    @Test
    fun xgRatingBar_halfRating_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGRatingBar(
                    rating = 2.5f,
                    showValue = true,
                )
            }
        }

        composeTestRule.onNodeWithText("2.5").assertIsDisplayed()
    }

    @Test
    fun xgRatingBar_accessibilityDescription_isSet() {
        composeTestRule.setContent {
            XGTheme {
                XGRatingBar(rating = 4.0f)
            }
        }

        // Rating bar should have a content description for accessibility
        composeTestRule.onNode(
            hasContentDescription("Rating: 4.0 out of 5", substring = true),
        ).assertExists()
    }

    @Test
    fun xgRatingBar_showValue_andReviewCount_bothDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                XGRatingBar(
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
