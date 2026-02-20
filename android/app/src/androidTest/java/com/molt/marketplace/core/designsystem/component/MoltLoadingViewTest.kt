package com.molt.marketplace.core.designsystem.component

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.molt.marketplace.core.designsystem.theme.MoltTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MoltLoadingViewTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltLoadingView_fullScreen_showsProgressIndicator() {
        composeTestRule.setContent {
            MoltTheme {
                MoltLoadingView()
            }
        }

        composeTestRule.onNode(hasContentDescription("Loading...")).assertIsDisplayed()
    }

    @Test
    fun moltLoadingIndicator_inline_showsProgressIndicator() {
        composeTestRule.setContent {
            MoltTheme {
                MoltLoadingIndicator()
            }
        }

        composeTestRule.onNode(hasContentDescription("Loading...")).assertIsDisplayed()
    }

    @Test
    fun moltLoadingView_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltLoadingView()
            }
        }

        // If we get here without an exception the composable rendered successfully
        composeTestRule.onNode(hasContentDescription("Loading...")).assertExists()
    }

    @Test
    fun moltLoadingIndicator_rendersWithoutCrash() {
        composeTestRule.setContent {
            MoltTheme {
                MoltLoadingIndicator()
            }
        }

        composeTestRule.onNode(hasContentDescription("Loading...")).assertExists()
    }
}
