package com.xirigo.ecommerce.core.designsystem.component

import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * UI tests for [HeroBannerSkeleton].
 *
 * Verifies rendering and layout of the shimmer skeleton placeholder
 * for the hero banner component.
 */
@RunWith(AndroidJUnit4::class)
class HeroBannerSkeletonTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // region Rendering

    @Test
    fun heroBannerSkeleton_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                HeroBannerSkeleton(
                    modifier = Modifier.testTag("heroBannerSkeleton"),
                )
            }
        }

        composeTestRule.onNodeWithTag("heroBannerSkeleton").assertIsDisplayed()
    }

    @Test
    fun heroBannerSkeleton_withCustomModifier_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                HeroBannerSkeleton(
                    modifier = Modifier.testTag("skeletonCustom"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonCustom").assertIsDisplayed()
    }

    @Test
    fun heroBannerSkeleton_rendersWithinXGSkeleton() {
        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = true,
                    placeholder = {
                        HeroBannerSkeleton(
                            modifier = Modifier.testTag("skeletonInWrapper"),
                        )
                    },
                ) {
                    XGHeroBanner(
                        title = "Summer Sale",
                        subtitle = "Up to 50% off",
                        modifier = Modifier.testTag("realBanner"),
                    )
                }
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithTag("skeletonInWrapper").assertIsDisplayed()
    }

    @Test
    fun heroBannerSkeleton_hidesWhenXGSkeletonNotVisible() {
        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = false,
                    placeholder = {
                        HeroBannerSkeleton(
                            modifier = Modifier.testTag("skeletonHidden"),
                        )
                    },
                ) {
                    XGHeroBanner(
                        title = "Summer Sale",
                        subtitle = "Up to 50% off",
                        modifier = Modifier.testTag("realBannerShown"),
                    )
                }
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithTag("skeletonHidden").assertDoesNotExist()
        composeTestRule.onNodeWithTag("realBannerShown").assertIsDisplayed()
    }

    // endregion
}
