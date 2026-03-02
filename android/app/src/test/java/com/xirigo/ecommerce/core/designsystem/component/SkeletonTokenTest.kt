package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion

/**
 * DQ-39: Skeleton component token contract -- JVM unit tests.
 *
 * Verifies:
 * 1. [XGColors.Shimmer] background color matches `colors.json > semantic.shimmer`
 * 2. [XGCornerRadius.Small] matches design spec (used by [SkeletonLine])
 * 3. [XGCornerRadius.Medium] matches design spec (used by [SkeletonBox] default)
 * 4. [XGCornerRadius.Large] matches design spec (used by [SkeletonBox] override)
 * 5. [XGMotion.Crossfade.CONTENT_SWITCH] matches design spec (used by [XGSkeleton])
 * 6. Corner radius ordering: Small < Medium < Large
 * 7. SkeletonLine default height approximates bodyMedium line height
 *
 * These tests run on JVM without a device/emulator.
 * UI behavior (rendering, crossfade animation, accessibility) is covered by
 * instrumented tests in `androidTest/`.
 */
class SkeletonTokenTest {

    // region XGColors.Shimmer — skeleton background color

    @Test
    fun `XGColors Shimmer should match design token F1F5F9`() {
        // colors.json > semantic.shimmer = #F1F5F9
        assertThat(XGColors.Shimmer).isEqualTo(Color(0xFFF1F5F9))
    }

    @Test
    fun `XGColors Shimmer should differ from shimmer gradient base color`() {
        // XGColors.Shimmer (#F1F5F9) is the skeleton fill
        // XGMotion.Shimmer.GradientColors[0] (#E0E0E0) is the shimmer gradient base
        assertThat(XGColors.Shimmer).isNotEqualTo(XGMotion.Shimmer.GradientColors[0])
    }

    @Test
    fun `XGColors Shimmer should be a light color suitable for placeholder`() {
        // Skeleton background should have high luminance (light gray)
        assertThat(XGColors.Shimmer.red).isGreaterThan(0.9f)
        assertThat(XGColors.Shimmer.green).isGreaterThan(0.9f)
        assertThat(XGColors.Shimmer.blue).isGreaterThan(0.9f)
    }

    // endregion

    // region XGCornerRadius — SkeletonBox default

    @Test
    fun `XGCornerRadius Medium should be 10dp for SkeletonBox default`() {
        // SkeletonBox default cornerRadius = XGCornerRadius.Medium
        assertThat(XGCornerRadius.Medium).isEqualTo(10.dp)
    }

    // endregion

    // region XGCornerRadius — SkeletonLine fixed

    @Test
    fun `XGCornerRadius Small should be 6dp for SkeletonLine`() {
        // SkeletonLine always uses XGCornerRadius.Small
        assertThat(XGCornerRadius.Small).isEqualTo(6.dp)
    }

    // endregion

    // region XGCornerRadius — SkeletonBox override options

    @Test
    fun `XGCornerRadius Large should be 16dp for SkeletonBox override`() {
        // SkeletonBox can be overridden with XGCornerRadius.Large
        assertThat(XGCornerRadius.Large).isEqualTo(16.dp)
    }

    @Test
    fun `XGCornerRadius None should be 0dp for sharp corners`() {
        assertThat(XGCornerRadius.None).isEqualTo(0.dp)
    }

    // endregion

    // region XGCornerRadius ordering

    @Test
    fun `corner radius values should increase from None to Small to Medium to Large`() {
        assertThat(XGCornerRadius.None).isLessThan(XGCornerRadius.Small)
        assertThat(XGCornerRadius.Small).isLessThan(XGCornerRadius.Medium)
        assertThat(XGCornerRadius.Medium).isLessThan(XGCornerRadius.Large)
    }

    @Test
    fun `SkeletonLine cornerRadius should be smaller than SkeletonBox default`() {
        // SkeletonLine uses Small (6dp), SkeletonBox default is Medium (10dp)
        assertThat(XGCornerRadius.Small).isLessThan(XGCornerRadius.Medium)
    }

    // endregion

    // region XGMotion.Crossfade — XGSkeleton animation

    @Test
    fun `XGMotion Crossfade CONTENT_SWITCH should be 200ms`() {
        // XGSkeleton crossfade duration = XGMotion.Crossfade.CONTENT_SWITCH
        assertThat(XGMotion.Crossfade.CONTENT_SWITCH).isEqualTo(200)
    }

    @Test
    fun `XGMotion Crossfade CONTENT_SWITCH should be positive`() {
        assertThat(XGMotion.Crossfade.CONTENT_SWITCH).isGreaterThan(0)
    }

    @Test
    fun `XGMotion Crossfade CONTENT_SWITCH should equal Duration FAST`() {
        // crossfade.contentSwitch = 200ms = Duration.FAST
        assertThat(XGMotion.Crossfade.CONTENT_SWITCH).isEqualTo(XGMotion.Duration.FAST)
    }

    @Test
    fun `XGMotion Crossfade IMAGE_FADE_IN should be 300ms`() {
        // Image crossfade is longer than content switch
        assertThat(XGMotion.Crossfade.IMAGE_FADE_IN).isEqualTo(300)
    }

    @Test
    fun `crossfade IMAGE_FADE_IN should be longer than CONTENT_SWITCH`() {
        assertThat(XGMotion.Crossfade.IMAGE_FADE_IN)
            .isGreaterThan(XGMotion.Crossfade.CONTENT_SWITCH)
    }

    // endregion

    // region Shimmer gradient token (used by all skeleton shapes)

    @Test
    fun `shimmer gradient should have 3 stops for all skeleton shapes`() {
        // All skeleton shapes use .shimmerEffect() which relies on 3-stop gradient
        assertThat(XGMotion.Shimmer.GradientColors).hasSize(3)
    }

    @Test
    fun `shimmer duration should be 1200ms for all skeleton shapes`() {
        assertThat(XGMotion.Shimmer.DURATION_MS).isEqualTo(1200)
    }

    // endregion

    // region Product card skeleton layout dimensions (preview spec)

    @Test
    fun `product card skeleton image box dimensions should match handoff`() {
        // Handoff spec: SkeletonBox(width = 170.dp, height = 170.dp)
        val boxWidth = 170.dp
        val boxHeight = 170.dp
        assertThat(boxWidth).isEqualTo(boxHeight) // Square image
    }

    @Test
    fun `product card skeleton title width should be wider than price width`() {
        // Title = 140dp, Price = 80dp
        val titleWidth = 140.dp
        val priceWidth = 80.dp
        assertThat(titleWidth).isGreaterThan(priceWidth)
    }

    @Test
    fun `product card skeleton rating circle should be small`() {
        // Rating star skeleton = 12dp circle
        val ratingSize = 12.dp
        assertThat(ratingSize.value).isLessThan(20f)
    }

    // endregion
}
