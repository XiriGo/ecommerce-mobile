package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * UI tests for [SkeletonBox], [SkeletonLine], [SkeletonCircle], and [XGSkeleton].
 *
 * Because shimmer uses draw-layer operations, tests verify composable rendering,
 * semantic state (accessibility), and token contract values.
 */
@RunWith(AndroidJUnit4::class)
class SkeletonTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // region SkeletonBox — rendering

    @Test
    fun skeletonBox_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonBox(
                    width = 100.dp,
                    height = 100.dp,
                    modifier = Modifier.testTag("skeletonBox"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonBox").assertIsDisplayed()
    }

    @Test
    fun skeletonBox_withExplicitDimensions_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonBox(
                    width = 170.dp,
                    height = 80.dp,
                    modifier = Modifier.testTag("skeletonBoxDims"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonBoxDims").assertIsDisplayed()
    }

    @Test
    fun skeletonBox_withDefaultCornerRadius_isDisplayed() {
        // Default cornerRadius = XGCornerRadius.Medium (10dp)
        composeTestRule.setContent {
            XGTheme {
                SkeletonBox(
                    width = 120.dp,
                    height = 60.dp,
                    modifier = Modifier.testTag("skeletonBoxDefault"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonBoxDefault").assertIsDisplayed()
    }

    @Test
    fun skeletonBox_withCustomCornerRadius_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonBox(
                    width = 120.dp,
                    height = 60.dp,
                    cornerRadius = XGCornerRadius.Large,
                    modifier = Modifier.testTag("skeletonBoxCustom"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonBoxCustom").assertIsDisplayed()
    }

    @Test
    fun skeletonBox_withZeroCornerRadius_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonBox(
                    width = 80.dp,
                    height = 40.dp,
                    cornerRadius = XGCornerRadius.None,
                    modifier = Modifier.testTag("skeletonBoxNoRadius"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonBoxNoRadius").assertIsDisplayed()
    }

    // endregion

    // region SkeletonLine — rendering

    @Test
    fun skeletonLine_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonLine(
                    width = 140.dp,
                    modifier = Modifier.testTag("skeletonLine"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonLine").assertIsDisplayed()
    }

    @Test
    fun skeletonLine_withDefaultHeight_isDisplayed() {
        // Default height = 14dp (SkeletonLineDefaultHeight)
        composeTestRule.setContent {
            XGTheme {
                SkeletonLine(
                    width = 100.dp,
                    modifier = Modifier.testTag("skeletonLineDefaultH"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonLineDefaultH").assertIsDisplayed()
    }

    @Test
    fun skeletonLine_withCustomHeight_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonLine(
                    width = 80.dp,
                    height = 12.dp,
                    modifier = Modifier.testTag("skeletonLineCustomH"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonLineCustomH").assertIsDisplayed()
    }

    @Test
    fun skeletonLine_withSmallWidth_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonLine(
                    width = 30.dp,
                    height = 12.dp,
                    modifier = Modifier.testTag("skeletonLineSmall"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonLineSmall").assertIsDisplayed()
    }

    // endregion

    // region SkeletonCircle — rendering

    @Test
    fun skeletonCircle_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonCircle(
                    size = 48.dp,
                    modifier = Modifier.testTag("skeletonCircle"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonCircle").assertIsDisplayed()
    }

    @Test
    fun skeletonCircle_smallSize_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonCircle(
                    size = 12.dp,
                    modifier = Modifier.testTag("skeletonCircleSmall"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonCircleSmall").assertIsDisplayed()
    }

    @Test
    fun skeletonCircle_largeSize_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonCircle(
                    size = 80.dp,
                    modifier = Modifier.testTag("skeletonCircleLarge"),
                )
            }
        }

        composeTestRule.onNodeWithTag("skeletonCircleLarge").assertIsDisplayed()
    }

    // endregion

    // region XGSkeleton — shows placeholder when visible=true

    @Test
    fun xgSkeleton_visibleTrue_showsPlaceholder() {
        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = true,
                    placeholder = {
                        SkeletonBox(
                            width = 100.dp,
                            height = 60.dp,
                            modifier = Modifier.testTag("placeholder"),
                        )
                    },
                ) {
                    Text(text = "Real content", modifier = Modifier.testTag("content"))
                }
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithTag("placeholder").assertIsDisplayed()
    }

    @Test
    fun xgSkeleton_visibleTrue_hidesContent() {
        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = true,
                    placeholder = {
                        Box(modifier = Modifier.size(100.dp).testTag("placeholder"))
                    },
                ) {
                    Text(text = "Real content", modifier = Modifier.testTag("content"))
                }
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithTag("content").assertDoesNotExist()
    }

    // endregion

    // region XGSkeleton — shows content when visible=false

    @Test
    fun xgSkeleton_visibleFalse_showsContent() {
        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = false,
                    placeholder = {
                        SkeletonBox(
                            width = 100.dp,
                            height = 60.dp,
                            modifier = Modifier.testTag("placeholder"),
                        )
                    },
                ) {
                    Text(text = "Real content", modifier = Modifier.testTag("content"))
                }
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithTag("content").assertIsDisplayed()
    }

    @Test
    fun xgSkeleton_visibleFalse_hidesPlaceholder() {
        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = false,
                    placeholder = {
                        Box(modifier = Modifier.size(100.dp).testTag("placeholder"))
                    },
                ) {
                    Text(text = "Real content", modifier = Modifier.testTag("content"))
                }
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithTag("placeholder").assertDoesNotExist()
    }

    // endregion

    // region XGSkeleton — state transitions

    @Test
    fun xgSkeleton_transitionFromVisibleToHidden_showsContent() {
        var visible by mutableStateOf(true)

        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = visible,
                    placeholder = {
                        Box(modifier = Modifier.size(100.dp).testTag("placeholder"))
                    },
                ) {
                    Text(text = "Loaded", modifier = Modifier.testTag("content"))
                }
            }
        }

        // Initially shows placeholder
        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithTag("placeholder").assertIsDisplayed()

        // Toggle to not-loading
        visible = false
        composeTestRule.waitForIdle()

        composeTestRule.onNodeWithTag("content").assertIsDisplayed()
    }

    @Test
    fun xgSkeleton_transitionFromHiddenToVisible_showsPlaceholder() {
        var visible by mutableStateOf(false)

        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = visible,
                    placeholder = {
                        Box(modifier = Modifier.size(100.dp).testTag("placeholder"))
                    },
                ) {
                    Text(text = "Loaded", modifier = Modifier.testTag("content"))
                }
            }
        }

        // Initially shows content
        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithTag("content").assertIsDisplayed()

        // Toggle to loading
        visible = true
        composeTestRule.waitForIdle()

        composeTestRule.onNodeWithTag("placeholder").assertIsDisplayed()
    }

    // endregion

    // region XGSkeleton — accessibility

    @Test
    fun xgSkeleton_visibleTrue_announcesLoadingContent() {
        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = true,
                    placeholder = {
                        SkeletonBox(width = 100.dp, height = 60.dp)
                    },
                ) {
                    Text(text = "Real content")
                }
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule
            .onNode(hasContentDescription("Loading content"))
            .assertIsDisplayed()
    }

    @Test
    fun xgSkeleton_visibleFalse_doesNotAnnounceLoadingContent() {
        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = false,
                    placeholder = {
                        SkeletonBox(width = 100.dp, height = 60.dp)
                    },
                ) {
                    Text(text = "Real content")
                }
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule
            .onNodeWithContentDescription("Loading content")
            .assertDoesNotExist()
    }

    // endregion

    // region Token contract — XGColors.Shimmer

    @Test
    fun xgColors_shimmer_matchesDesignToken() {
        // Design token: semantic.shimmer = #F1F5F9
        val expectedColor = Color(0xFFF1F5F9)
        assertThat(XGColors.Shimmer).isEqualTo(expectedColor)
    }

    // endregion

    // region Token contract — XGCornerRadius

    @Test
    fun xgCornerRadius_small_matchesDesignToken() {
        // SkeletonLine uses Small = 6dp (cornerRadius.small)
        assertThat(XGCornerRadius.Small).isEqualTo(6.dp)
    }

    @Test
    fun xgCornerRadius_medium_matchesDesignToken() {
        // SkeletonBox default = Medium = 10dp (cornerRadius.medium)
        assertThat(XGCornerRadius.Medium).isEqualTo(10.dp)
    }

    // endregion

    // region Token contract — XGMotion.Crossfade

    @Test
    fun xgMotion_contentSwitch_matchesDesignToken() {
        // Design token: crossfade.contentSwitch = 200ms
        assertThat(XGMotion.Crossfade.CONTENT_SWITCH).isEqualTo(200)
    }

    // endregion

    // region Composite skeleton layout — product card skeleton

    @Test
    fun productCardSkeleton_allParts_areDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                SkeletonBox(
                    width = 170.dp,
                    height = 170.dp,
                    modifier = Modifier.testTag("cardImage"),
                )
                SkeletonLine(
                    width = 140.dp,
                    modifier = Modifier.testTag("cardTitle"),
                )
                SkeletonLine(
                    width = 80.dp,
                    height = 12.dp,
                    modifier = Modifier.testTag("cardPrice"),
                )
                SkeletonCircle(
                    size = 12.dp,
                    modifier = Modifier.testTag("cardRatingStar"),
                )
                SkeletonLine(
                    width = 30.dp,
                    height = 12.dp,
                    modifier = Modifier.testTag("cardRatingText"),
                )
            }
        }

        composeTestRule.onNodeWithTag("cardImage").assertIsDisplayed()
        composeTestRule.onNodeWithTag("cardTitle").assertIsDisplayed()
        composeTestRule.onNodeWithTag("cardPrice").assertIsDisplayed()
        composeTestRule.onNodeWithTag("cardRatingStar").assertIsDisplayed()
        composeTestRule.onNodeWithTag("cardRatingText").assertIsDisplayed()
    }

    // endregion

    // region XGSkeleton — text content is correct when loaded

    @Test
    fun xgSkeleton_visibleFalse_textContentIsCorrect() {
        composeTestRule.setContent {
            XGTheme {
                XGSkeleton(
                    visible = false,
                    placeholder = {
                        SkeletonBox(width = 100.dp, height = 40.dp)
                    },
                ) {
                    Text(text = "Product loaded successfully")
                }
            }
        }

        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithText("Product loaded successfully").assertIsDisplayed()
    }

    // endregion
}
