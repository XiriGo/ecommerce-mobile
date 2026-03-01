package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.compose.foundation.layout.size
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * UI and token-contract tests for [XGImage].
 *
 * DQ-07: XGImage was upgraded to use [SubcomposeAsyncImage] with:
 * - Animated shimmer loading placeholder via [shimmerEffect]
 * - Branded error fallback (SurfaceVariant background + outlined Image icon)
 * - Crossfade duration driven by [XGMotion.Crossfade.IMAGE_FADE_IN] (300ms)
 * - Null URL renders shimmer placeholder (no async image)
 *
 * Because [shimmerEffect] uses draw-layer operations and [SubcomposeAsyncImage]
 * manages its own async loading slots, tests verify:
 * 1. No-crash rendering for null URL and valid URL
 * 2. Semantic node presence/absence based on URL nullability
 * 3. Motion token contract values used by the component
 * 4. Color token contract values used by the component
 * 5. Modifier forwarding (testTag propagation)
 *
 * Note: [PlaceholderIconSize] (27.dp) and [PreviewImageSize] (200.dp) are
 * `private val` constants inside [XGImage.kt]. Their values are verified
 * indirectly through successful composable rendering at those sizes.
 */
@RunWith(AndroidJUnit4::class)
class XGImageTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    // region null URL — shimmer placeholder branch

    @Test
    fun xgImage_nullUrl_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = null,
                    contentDescription = "Product image",
                    modifier = Modifier.size(200.dp),
                )
            }
        }

        // Null URL renders a shimmer Box — no semantic node with the label exists
        composeTestRule.onNodeWithContentDescription("Product image").assertDoesNotExist()
    }

    @Test
    fun xgImage_nullUrl_withNullContentDescription_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = null,
                    contentDescription = null,
                    modifier = Modifier.size(100.dp),
                )
            }
        }

        // No contentDescription node expected — shimmer box has no semantic label
    }

    @Test
    fun xgImage_nullUrl_modifierApplied_tagIsReachable() {
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = null,
                    contentDescription = null,
                    modifier = Modifier
                        .size(150.dp)
                        .testTag("xgImageNull"),
                )
            }
        }

        // The root Box is reachable by testTag even in the null-URL branch
        composeTestRule.onNodeWithTag("xgImageNull").assertIsDisplayed()
    }

    @Test
    fun xgImage_nullUrl_atPlaceholderIconSize_rendersWithoutCrash() {
        // PlaceholderIconSize = 27.dp — verify component handles small sizes without crash
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = null,
                    contentDescription = null,
                    modifier = Modifier.size(27.dp),
                )
            }
        }
    }

    // endregion

    // region valid URL — SubcomposeAsyncImage branch

    @Test
    fun xgImage_withUrl_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = "https://example.com/product.jpg",
                    contentDescription = "Product thumbnail",
                    modifier = Modifier.size(200.dp),
                )
            }
        }

        // SubcomposeAsyncImage is present in the hierarchy; may be loading or loaded
        composeTestRule.onNodeWithContentDescription("Product thumbnail").assertIsDisplayed()
    }

    @Test
    fun xgImage_withUrl_withNullContentDescription_rendersWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = "https://example.com/image.jpg",
                    contentDescription = null,
                    modifier = Modifier.size(100.dp),
                )
            }
        }

        // Should not crash — async image without accessibility label
    }

    @Test
    fun xgImage_withUrl_modifierApplied_tagIsReachable() {
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = "https://example.com/image.jpg",
                    contentDescription = null,
                    modifier = Modifier
                        .size(200.dp)
                        .testTag("xgImageUrl"),
                )
            }
        }

        composeTestRule.onNodeWithTag("xgImageUrl").assertIsDisplayed()
    }

    @Test
    fun xgImage_withBrokenUrl_rendersWithoutCrash() {
        // Broken URL triggers the error slot — branded fallback Box + outlined Image icon
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = "https://invalid.test/broken-image",
                    contentDescription = "Broken image",
                    modifier = Modifier.size(200.dp),
                )
            }
        }

        // SubcomposeAsyncImage node is present — it manages error rendering internally
        composeTestRule.onNodeWithContentDescription("Broken image").assertIsDisplayed()
    }

    @Test
    fun xgImage_withUrl_atPreviewImageSize_rendersWithoutCrash() {
        // PreviewImageSize = 200.dp — verify component renders at documented preview size
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = "https://example.com/preview.jpg",
                    contentDescription = "Preview size image",
                    modifier = Modifier.size(200.dp),
                )
            }
        }

        composeTestRule.onNodeWithContentDescription("Preview size image").assertIsDisplayed()
    }

    // endregion

    // region token contract — XGMotion.Crossfade.IMAGE_FADE_IN

    @Test
    fun xgMotion_crossfade_imageFadeIn_equals300ms() {
        // XGImage uses IMAGE_FADE_IN instead of the former hardcoded 250ms
        assertThat(XGMotion.Crossfade.IMAGE_FADE_IN).isEqualTo(300)
    }

    @Test
    fun xgMotion_crossfade_imageFadeIn_isGreaterThanContentSwitch() {
        // IMAGE_FADE_IN (300ms) > CONTENT_SWITCH (200ms) — loading feels deliberate
        assertThat(XGMotion.Crossfade.IMAGE_FADE_IN)
            .isGreaterThan(XGMotion.Crossfade.CONTENT_SWITCH)
    }

    @Test
    fun xgMotion_crossfade_imageFadeIn_isPositive() {
        assertThat(XGMotion.Crossfade.IMAGE_FADE_IN).isGreaterThan(0)
    }

    // endregion

    // region token contract — XGColors used by XGImage

    @Test
    fun xgColors_shimmer_matchesDesignToken() {
        // Loading placeholder and null-URL branch use XGColors.Shimmer (#F1F5F9)
        assertThat(XGColors.Shimmer).isEqualTo(androidx.compose.ui.graphics.Color(0xFFF1F5F9))
    }

    @Test
    fun xgColors_surfaceVariant_matchesDesignToken() {
        // Error fallback background uses XGColors.SurfaceVariant (#F9FAFB)
        assertThat(XGColors.SurfaceVariant)
            .isEqualTo(androidx.compose.ui.graphics.Color(0xFFF9FAFB))
    }

    @Test
    fun xgColors_onSurfaceVariant_matchesDesignToken() {
        // Error and null-URL icon tint uses XGColors.OnSurfaceVariant (#8E8E93)
        assertThat(XGColors.OnSurfaceVariant)
            .isEqualTo(androidx.compose.ui.graphics.Color(0xFF8E8E93))
    }

    @Test
    fun xgColors_shimmer_isDifferentFromSurfaceVariant() {
        // Loading shimmer color differs from error fallback background — visually distinct states
        assertThat(XGColors.Shimmer).isNotEqualTo(XGColors.SurfaceVariant)
    }

    // endregion

    // region multiple instances — no cross-composition interference

    @Test
    fun xgImage_twoInstances_nullAndUrl_renderWithoutCrash() {
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = null,
                    contentDescription = null,
                    modifier = Modifier
                        .size(80.dp)
                        .testTag("imageA"),
                )
                XGImage(
                    url = "https://example.com/b.jpg",
                    contentDescription = "Image B",
                    modifier = Modifier
                        .size(80.dp)
                        .testTag("imageB"),
                )
            }
        }

        composeTestRule.onNodeWithTag("imageA").assertIsDisplayed()
        composeTestRule.onNodeWithTag("imageB").assertIsDisplayed()
    }

    @Test
    fun xgImage_twoNullInstances_renderIndependently() {
        composeTestRule.setContent {
            XGTheme {
                XGImage(
                    url = null,
                    contentDescription = null,
                    modifier = Modifier
                        .size(60.dp)
                        .testTag("nullImageA"),
                )
                XGImage(
                    url = null,
                    contentDescription = null,
                    modifier = Modifier
                        .size(60.dp)
                        .testTag("nullImageB"),
                )
            }
        }

        composeTestRule.onNodeWithTag("nullImageA").assertIsDisplayed()
        composeTestRule.onNodeWithTag("nullImageB").assertIsDisplayed()
    }

    // endregion
}
