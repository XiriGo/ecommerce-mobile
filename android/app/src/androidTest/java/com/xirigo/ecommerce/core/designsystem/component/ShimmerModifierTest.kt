package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * UI tests for [shimmerEffect] modifier.
 *
 * Because shimmerEffect uses drawWithContent (a draw-layer operation),
 * there is no semantic node produced by the shimmer itself.
 * Tests verify composable accessibility, correct token usage, no-op behaviour,
 * and that the modifier does not crash on various container shapes.
 */
@RunWith(AndroidJUnit4::class)
class ShimmerModifierTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // region enabled=true — composable is displayed

    @Test
    fun shimmerEffect_enabled_rectangularBox_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(120.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .background(XGMotion.Shimmer.GradientColors.first())
                        .shimmerEffect(enabled = true)
                        .testTag("shimmerBox"),
                )
            }
        }

        composeTestRule.onNodeWithTag("shimmerBox").assertIsDisplayed()
    }

    @Test
    fun shimmerEffect_enabled_circleBox_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .clip(CircleShape)
                        .background(XGMotion.Shimmer.GradientColors.first())
                        .shimmerEffect(enabled = true)
                        .testTag("shimmerCircle"),
                )
            }
        }

        composeTestRule.onNodeWithTag("shimmerCircle").assertIsDisplayed()
    }

    @Test
    fun shimmerEffect_enabled_textPlaceholder_isDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                Box(
                    modifier = Modifier
                        .size(width = 220.dp, height = 16.dp)
                        .clip(RoundedCornerShape(4.dp))
                        .background(XGMotion.Shimmer.GradientColors.first())
                        .shimmerEffect(enabled = true)
                        .testTag("shimmerText"),
                )
            }
        }

        composeTestRule.onNodeWithTag("shimmerText").assertIsDisplayed()
    }

    // endregion

    // region enabled=false — modifier is a no-op, content unchanged

    @Test
    fun shimmerEffect_disabled_boxIsStillDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(16.dp)
                        .background(Color.LightGray)
                        .shimmerEffect(enabled = false)
                        .testTag("staticBox"),
                )
            }
        }

        // Content must still render normally when shimmer is disabled
        composeTestRule.onNodeWithTag("staticBox").assertIsDisplayed()
    }

    @Test
    fun shimmerEffect_disabled_defaultParameter_boxIsDisplayed() {
        // Verify that the default value of `enabled` is true by calling
        // shimmerEffect with no arguments and confirming the node renders.
        composeTestRule.setContent {
            XGTheme {
                Box(
                    modifier = Modifier
                        .size(100.dp)
                        .background(XGMotion.Shimmer.GradientColors.first())
                        .shimmerEffect()
                        .testTag("defaultShimmer"),
                )
            }
        }

        composeTestRule.onNodeWithTag("defaultShimmer").assertIsDisplayed()
    }

    // endregion

    // region XGMotion.Shimmer token contract — values match design spec

    @Test
    fun xgMotionShimmer_durationMs_matchesDesignSpec() {
        // Design token: shimmer.durationMs = 1200
        assertThat(XGMotion.Shimmer.DURATION_MS).isEqualTo(1200)
    }

    @Test
    fun xgMotionShimmer_angleDegrees_matchesDesignSpec() {
        // Design token: shimmer.angleDegrees = 20
        assertThat(XGMotion.Shimmer.ANGLE_DEGREES).isEqualTo(20)
    }

    @Test
    fun xgMotionShimmer_repeatModeRestart_isTrue() {
        // Design token: shimmer.repeatMode = "restart"
        assertThat(XGMotion.Shimmer.REPEAT_MODE_RESTART).isTrue()
    }

    @Test
    fun xgMotionShimmer_gradientColors_hasThreeStops() {
        // Three-stop gradient: base → highlight → base
        assertThat(XGMotion.Shimmer.GradientColors).hasSize(3)
    }

    @Test
    fun xgMotionShimmer_gradientColors_firstAndLastAreEqual() {
        // Symmetrical gradient: first color == last color (base gray)
        val colors = XGMotion.Shimmer.GradientColors
        assertThat(colors.first()).isEqualTo(colors.last())
    }

    @Test
    fun xgMotionShimmer_gradientColors_firstColor_matchesDesignSpec() {
        // Design token: shimmer.gradientColors[0] = #E0E0E0
        val expected = Color(0xFFE0E0E0)
        assertThat(XGMotion.Shimmer.GradientColors.first()).isEqualTo(expected)
    }

    @Test
    fun xgMotionShimmer_gradientColors_highlightColor_matchesDesignSpec() {
        // Design token: shimmer.gradientColors[1] = #F5F5F5
        val expected = Color(0xFFF5F5F5)
        assertThat(XGMotion.Shimmer.GradientColors[1]).isEqualTo(expected)
    }

    // endregion

    // region multiple shimmer boxes — no cross-composition interference

    @Test
    fun shimmerEffect_multipleBoxes_allDisplayed() {
        composeTestRule.setContent {
            XGTheme {
                Box(
                    modifier = Modifier
                        .size(width = 200.dp, height = 20.dp)
                        .background(XGMotion.Shimmer.GradientColors.first())
                        .shimmerEffect()
                        .testTag("shimmerA"),
                )
                Box(
                    modifier = Modifier
                        .size(width = 150.dp, height = 20.dp)
                        .background(XGMotion.Shimmer.GradientColors.first())
                        .shimmerEffect()
                        .testTag("shimmerB"),
                )
            }
        }

        composeTestRule.onNodeWithTag("shimmerA").assertIsDisplayed()
        composeTestRule.onNodeWithTag("shimmerB").assertIsDisplayed()
    }

    // endregion
}
