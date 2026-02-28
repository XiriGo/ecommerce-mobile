package com.xirigo.ecommerce.feature.onboarding

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.feature.onboarding.presentation.screen.SplashScreen
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class SplashScreenTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun splashScreen_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SplashScreen()
            }
        }

        composeTestRule.onNode(hasContentDescription("XiriGo logo")).assertIsDisplayed()
    }

    @Test
    fun splashScreen_logoMarkIsDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SplashScreen()
            }
        }

        composeTestRule
            .onNode(hasContentDescription("XiriGo logo"))
            .assertIsDisplayed()
    }

    @Test
    fun splashScreen_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                SplashScreen()
            }
        }

        composeTestRule.waitForIdle()
    }
}
