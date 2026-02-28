package com.xirigo.ecommerce.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@RunWith(AndroidJUnit4::class)
class XGLoadingViewTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun moltLoadingView_fullScreen_showsProgressIndicator() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingView()
            }
        }

        composeTestRule.onNode(hasContentDescription("Loading...")).assertIsDisplayed()
    }

    @Test
    fun moltLoadingIndicator_inline_showsProgressIndicator() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingIndicator()
            }
        }

        composeTestRule.onNode(hasContentDescription("Loading...")).assertIsDisplayed()
    }

    @Test
    fun moltLoadingView_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingView()
            }
        }

        // If we get here without an exception the composable rendered successfully
        composeTestRule.onNode(hasContentDescription("Loading...")).assertExists()
    }

    @Test
    fun moltLoadingIndicator_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGLoadingIndicator()
            }
        }

        composeTestRule.onNode(hasContentDescription("Loading...")).assertExists()
    }
}
