package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class XGPaginationDotsTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun xgPaginationDots_showsCorrectContentDescriptionForFirstPage() {
        composeTestRule.setContent {
            XGTheme {
                XGPaginationDots(
                    totalPages = 4,
                    currentPage = 0,
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Page 1 of 4"))
            .assertIsDisplayed()
    }

    @Test
    fun xgPaginationDots_showsCorrectContentDescriptionForLastPage() {
        composeTestRule.setContent {
            XGTheme {
                XGPaginationDots(
                    totalPages = 4,
                    currentPage = 3,
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Page 4 of 4"))
            .assertIsDisplayed()
    }

    @Test
    fun xgPaginationDots_showsCorrectContentDescriptionForMiddlePage() {
        composeTestRule.setContent {
            XGTheme {
                XGPaginationDots(
                    totalPages = 4,
                    currentPage = 1,
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Page 2 of 4"))
            .assertIsDisplayed()
    }

    @Test
    fun xgPaginationDots_isDisplayedWithSinglePage() {
        composeTestRule.setContent {
            XGTheme {
                XGPaginationDots(
                    totalPages = 1,
                    currentPage = 0,
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Page 1 of 1"))
            .assertIsDisplayed()
    }

    @Test
    fun xgPaginationDots_updatesContentDescriptionWhenCurrentPageChanges() {
        var currentPage = 0

        composeTestRule.setContent {
            XGTheme {
                XGPaginationDots(
                    totalPages = 4,
                    currentPage = currentPage,
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Page 1 of 4"))
            .assertIsDisplayed()

        currentPage = 2
        composeTestRule.setContent {
            XGTheme {
                XGPaginationDots(
                    totalPages = 4,
                    currentPage = currentPage,
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Page 3 of 4"))
            .assertIsDisplayed()
    }

    @Test
    fun xgPaginationDots_rendersWithCustomColors() {
        composeTestRule.setContent {
            XGTheme {
                XGPaginationDots(
                    totalPages = 4,
                    currentPage = 0,
                    activeColor = Color.White,
                    inactiveColor = Color.White.copy(alpha = 0.4f),
                )
            }
        }

        composeTestRule
            .onNode(hasContentDescription("Page 1 of 4"))
            .assertIsDisplayed()
    }
}
