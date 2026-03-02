package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import com.xirigo.ecommerce.core.designsystem.theme.XGColors

/**
 * DQ-33: XGBrandPattern token audit -- unit tests.
 *
 * Verifies:
 * 1. [XGColors.BRAND_PATTERN_OPACITY] matches `gradients.json > splashPatternOverlay.patternOpacity`
 * 2. Opacity value is within valid range (0..1)
 * 3. Opacity is subtle (below 0.1 threshold)
 */
class XGBrandPatternTokenTest {

    // region Pattern opacity token contract

    @Test
    fun `BRAND_PATTERN_OPACITY should match design token 0_06`() {
        assertThat(XGColors.BRAND_PATTERN_OPACITY).isEqualTo(0.06f)
    }

    @Test
    fun `BRAND_PATTERN_OPACITY should be positive`() {
        assertThat(XGColors.BRAND_PATTERN_OPACITY).isGreaterThan(0f)
    }

    @Test
    fun `BRAND_PATTERN_OPACITY should be at most 1`() {
        assertThat(XGColors.BRAND_PATTERN_OPACITY).isAtMost(1f)
    }

    @Test
    fun `BRAND_PATTERN_OPACITY should be subtle below 10 percent`() {
        assertThat(XGColors.BRAND_PATTERN_OPACITY).isLessThan(0.10f)
    }

    // endregion
}
