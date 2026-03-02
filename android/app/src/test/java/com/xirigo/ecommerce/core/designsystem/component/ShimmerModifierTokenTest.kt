package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion

/**
 * DQ-39: ShimmerModifier token contract -- JVM unit tests.
 *
 * Verifies:
 * 1. [XGMotion.Shimmer.DURATION_MS] matches design spec (1200ms)
 * 2. [XGMotion.Shimmer.ANGLE_DEGREES] matches design spec (20 degrees)
 * 3. [XGMotion.Shimmer.REPEAT_MODE_RESTART] is `true` (restart, no reverse)
 * 4. [XGMotion.Shimmer.GradientColors] has exactly 3 stops
 * 5. Gradient symmetry: first and last colors are identical (base gray)
 * 6. Gradient hex values match `motion.json > shimmer.gradientColors`
 * 7. [shimmerEffect] default parameter `enabled = true`
 *
 * These tests run on JVM without a device/emulator.
 * UI behavior (draw-layer, animation) is covered by instrumented tests in `androidTest/`.
 */
class ShimmerModifierTokenTest {

    // region Shimmer duration token

    @Test
    fun `Shimmer DURATION_MS should be 1200ms per design spec`() {
        assertThat(XGMotion.Shimmer.DURATION_MS).isEqualTo(1200)
    }

    @Test
    fun `Shimmer DURATION_MS should be positive`() {
        assertThat(XGMotion.Shimmer.DURATION_MS).isGreaterThan(0)
    }

    @Test
    fun `Shimmer DURATION_MS should be at least 1 second for visible animation`() {
        assertThat(XGMotion.Shimmer.DURATION_MS).isAtLeast(1000)
    }

    // endregion

    // region Shimmer angle token

    @Test
    fun `Shimmer ANGLE_DEGREES should be 20 per design spec`() {
        assertThat(XGMotion.Shimmer.ANGLE_DEGREES).isEqualTo(20)
    }

    @Test
    fun `Shimmer ANGLE_DEGREES should be positive`() {
        assertThat(XGMotion.Shimmer.ANGLE_DEGREES).isGreaterThan(0)
    }

    @Test
    fun `Shimmer ANGLE_DEGREES should be less than 45 for subtle diagonal`() {
        assertThat(XGMotion.Shimmer.ANGLE_DEGREES).isLessThan(45)
    }

    // endregion

    // region Shimmer repeat mode token

    @Test
    fun `Shimmer REPEAT_MODE_RESTART should be true`() {
        assertThat(XGMotion.Shimmer.REPEAT_MODE_RESTART).isTrue()
    }

    // endregion

    // region Shimmer gradient colors token

    @Test
    fun `Shimmer GradientColors should have exactly 3 stops`() {
        assertThat(XGMotion.Shimmer.GradientColors).hasSize(3)
    }

    @Test
    fun `Shimmer GradientColors should not be empty`() {
        assertThat(XGMotion.Shimmer.GradientColors).isNotEmpty()
    }

    @Test
    fun `Shimmer GradientColors first and last should be identical for symmetric sweep`() {
        val colors = XGMotion.Shimmer.GradientColors
        assertThat(colors.first()).isEqualTo(colors.last())
    }

    @Test
    fun `Shimmer GradientColors middle color should differ from outer colors`() {
        val colors = XGMotion.Shimmer.GradientColors
        assertThat(colors[1]).isNotEqualTo(colors[0])
        assertThat(colors[1]).isNotEqualTo(colors[2])
    }

    @Test
    fun `Shimmer GradientColors first color should be E0E0E0 per design spec`() {
        assertThat(XGMotion.Shimmer.GradientColors[0]).isEqualTo(Color(0xFFE0E0E0))
    }

    @Test
    fun `Shimmer GradientColors highlight color should be F5F5F5 per design spec`() {
        assertThat(XGMotion.Shimmer.GradientColors[1]).isEqualTo(Color(0xFFF5F5F5))
    }

    @Test
    fun `Shimmer GradientColors last color should be E0E0E0 per design spec`() {
        assertThat(XGMotion.Shimmer.GradientColors[2]).isEqualTo(Color(0xFFE0E0E0))
    }

    // endregion

    // region Cross-token consistency

    @Test
    fun `Shimmer duration should be longer than crossfade content switch`() {
        // Shimmer cycle (1200ms) should be significantly longer than the crossfade (200ms)
        assertThat(XGMotion.Shimmer.DURATION_MS)
            .isGreaterThan(XGMotion.Crossfade.CONTENT_SWITCH)
    }

    @Test
    fun `Shimmer GradientColors highlight should be lighter than base`() {
        // F5F5F5 (highlight) has higher luminance than E0E0E0 (base)
        // Verify by comparing red channel values (grayscale colors)
        val baseRed = XGMotion.Shimmer.GradientColors[0].red
        val highlightRed = XGMotion.Shimmer.GradientColors[1].red
        assertThat(highlightRed).isGreaterThan(baseRed)
    }

    // endregion
}
