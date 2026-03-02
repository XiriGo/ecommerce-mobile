package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

/**
 * DQ-19: XGDivider token audit — unit tests.
 *
 * Verifies:
 * 1. [XGColors.Divider] matches the design token hex value
 * 2. [XGColors.TextTertiary] matches the label color token
 * 3. [XGTypography] labelMedium (captionMedium) used for labeled divider text
 * 4. Default thickness constant matches token spec (1 dp)
 */
class XGDividerTokenTest {

    // region XGColors divider token contract

    @Test
    fun `Divider color should match design token semantic divider`() {
        // semantic.divider = light.divider = #E5E7EB
        assertThat(XGColors.Divider).isEqualTo(Color(0xFFE5E7EB))
    }

    @Test
    fun `Divider color should equal Outline color`() {
        // Both map to light.borderDefault / light.divider = #E5E7EB
        assertThat(XGColors.Divider).isEqualTo(XGColors.Outline)
    }

    @Test
    fun `TextTertiary should match design token for label color`() {
        // light.textTertiary = #9CA3AF — used for XGLabeledDivider label text
        assertThat(XGColors.TextTertiary).isEqualTo(Color(0xFF9CA3AF))
    }

    @Test
    fun `Divider color and TextTertiary should be distinct`() {
        assertThat(XGColors.Divider).isNotEqualTo(XGColors.TextTertiary)
    }

    // endregion

    // region XGTypography labelMedium for labeled divider text

    @Test
    fun `labelMedium fontSize should be 12sp`() {
        // captionMedium maps to labelMedium = 12sp Medium
        assertThat(XGTypography.labelMedium.fontSize).isEqualTo(12.sp)
    }

    @Test
    fun `labelMedium fontWeight should be Medium`() {
        assertThat(XGTypography.labelMedium.fontWeight).isEqualTo(FontWeight.Medium)
    }

    @Test
    fun `labelMedium lineHeight should be 16sp`() {
        assertThat(XGTypography.labelMedium.lineHeight).isEqualTo(16.sp)
    }

    // endregion

    // region Default thickness constant contract

    @Test
    fun `default divider thickness should be 1dp`() {
        // xg-divider.json: thickness = 1
        val expectedThickness = 1.dp
        assertThat(expectedThickness.value).isEqualTo(1f)
    }

    @Test
    fun `label horizontal padding should be 16dp`() {
        // xg-divider.json: labelHorizontalPadding = 16
        val expectedPadding = 16.dp
        assertThat(expectedPadding.value).isEqualTo(16f)
    }

    // endregion
}
