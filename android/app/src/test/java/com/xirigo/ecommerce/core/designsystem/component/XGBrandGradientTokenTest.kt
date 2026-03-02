package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import com.xirigo.ecommerce.core.designsystem.theme.XGColors

/**
 * DQ-33: XGBrandGradient token audit -- unit tests.
 *
 * Verifies:
 * 1. Brand gradient color tokens match `gradients.json > brandHeader` hex values
 * 2. Base gradient reuses [XGColors.BrandPrimaryLight] for edge stops
 * 3. Dark overlay reuses [XGColors.BrandPrimary] and [XGColors.BrandPrimaryDark]
 * 4. Intermediate overlay tokens have correct hex values
 * 5. All gradient tokens are distinct (no accidental duplicates)
 */
class XGBrandGradientTokenTest {

    // region Base gradient token contract

    @Test
    fun `BrandPrimaryLight should match 9000FE for gradient edge stops`() {
        assertThat(XGColors.BrandPrimaryLight).isEqualTo(Color(0xFF9000FE))
    }

    @Test
    fun `BrandGradientMid should match 6900FE for gradient mid stops`() {
        assertThat(XGColors.BrandGradientMid).isEqualTo(Color(0xFF6900FE))
    }

    @Test
    fun `base gradient edge and mid tokens should be distinct`() {
        assertThat(XGColors.BrandPrimaryLight).isNotEqualTo(XGColors.BrandGradientMid)
    }

    // endregion

    // region Dark overlay token contract

    @Test
    fun `BrandPrimary should match 6000FE for overlay start`() {
        assertThat(XGColors.BrandPrimary).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `BrandOverlayMid1 should match 5D00FB`() {
        assertThat(XGColors.BrandOverlayMid1).isEqualTo(Color(0xFF5D00FB))
    }

    @Test
    fun `BrandOverlayMid2 should match 5800F4`() {
        assertThat(XGColors.BrandOverlayMid2).isEqualTo(Color(0xFF5800F4))
    }

    @Test
    fun `BrandOverlayMid3 should match 4F00E9`() {
        assertThat(XGColors.BrandOverlayMid3).isEqualTo(Color(0xFF4F00E9))
    }

    @Test
    fun `BrandOverlayMid4 should match 4200DA`() {
        assertThat(XGColors.BrandOverlayMid4).isEqualTo(Color(0xFF4200DA))
    }

    @Test
    fun `BrandPrimaryDark should match 3C00D2 for overlay end`() {
        assertThat(XGColors.BrandPrimaryDark).isEqualTo(Color(0xFF3C00D2))
    }

    // endregion

    // region Cross-token distinctness

    @Test
    fun `all overlay tokens should be distinct from each other`() {
        val overlayColors = setOf(
            XGColors.BrandPrimary,
            XGColors.BrandOverlayMid1,
            XGColors.BrandOverlayMid2,
            XGColors.BrandOverlayMid3,
            XGColors.BrandOverlayMid4,
            XGColors.BrandPrimaryDark,
        )
        assertThat(overlayColors).hasSize(6)
    }

    @Test
    fun `overlay stops should form a decreasing brightness progression`() {
        // Overlay goes from lighter (#6000FE) to darker (#3C00D2)
        // Verify blue channel decreases across the series
        val blueValues = listOf(
            XGColors.BrandPrimary.blue,
            XGColors.BrandOverlayMid1.blue,
            XGColors.BrandOverlayMid2.blue,
            XGColors.BrandOverlayMid3.blue,
            XGColors.BrandOverlayMid4.blue,
            XGColors.BrandPrimaryDark.blue,
        )
        for (i in 0 until blueValues.size - 1) {
            assertThat(blueValues[i]).isAtLeast(blueValues[i + 1])
        }
    }

    // endregion
}
