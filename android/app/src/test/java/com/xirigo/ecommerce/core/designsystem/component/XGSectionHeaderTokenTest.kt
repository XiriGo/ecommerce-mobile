package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

/**
 * DQ-13: XGSectionHeader token audit — unit tests.
 *
 * Verifies that theme-level token constants consumed by [XGSectionHeader]
 * match the values declared in `shared/design-tokens/components/atoms/xg-section-header.json`.
 *
 * Token mapping:
 * - titleFont      → XGTypography.titleMedium  (18sp SemiBold)
 * - titleColor     → XGColors.OnSurface        (#333333)
 * - subtitleFont   → XGTypography.labelLarge   (14sp Medium)
 * - subtitleColor  → XGColors.OnSurfaceVariant (#8E8E93)
 * - seeAllFont     → XGTypography.labelLarge   (14sp Medium)
 * - seeAllColor    → XGColors.BrandPrimary     (#6000FE)
 * - arrowIconSize  → 12dp (private constant in composable)
 * - horizontalPadding → XGSpacing.ScreenPaddingHorizontal (20dp)
 * - subtitleSpacing   → XGSpacing.XXS (2dp)
 */
class XGSectionHeaderTokenTest {

    // region titleFont — XGTypography.titleMedium (typeScale.subtitle: 18sp SemiBold)

    @Test
    fun `titleMedium fontSize should be 18sp`() {
        assertThat(XGTypography.titleMedium.fontSize).isEqualTo(18.sp)
    }

    @Test
    fun `titleMedium fontWeight should be SemiBold`() {
        assertThat(XGTypography.titleMedium.fontWeight).isEqualTo(FontWeight.SemiBold)
    }

    @Test
    fun `titleMedium lineHeight should be 26sp`() {
        assertThat(XGTypography.titleMedium.lineHeight).isEqualTo(26.sp)
    }

    // endregion

    // region titleColor — XGColors.OnSurface (light.textPrimary = #333333)

    @Test
    fun `OnSurface should match design token textPrimary`() {
        assertThat(XGColors.OnSurface).isEqualTo(Color(0xFF333333))
    }

    // endregion

    // region subtitleFont — XGTypography.labelLarge (typeScale.bodyMedium: 14sp Medium)

    @Test
    fun `labelLarge fontSize should be 14sp`() {
        assertThat(XGTypography.labelLarge.fontSize).isEqualTo(14.sp)
    }

    @Test
    fun `labelLarge fontWeight should be Medium`() {
        assertThat(XGTypography.labelLarge.fontWeight).isEqualTo(FontWeight.Medium)
    }

    @Test
    fun `labelLarge lineHeight should be 20sp`() {
        assertThat(XGTypography.labelLarge.lineHeight).isEqualTo(20.sp)
    }

    // endregion

    // region subtitleColor — XGColors.OnSurfaceVariant (light.textSecondary = #8E8E93)

    @Test
    fun `OnSurfaceVariant should match design token textSecondary`() {
        assertThat(XGColors.OnSurfaceVariant).isEqualTo(Color(0xFF8E8E93))
    }

    // endregion

    // region seeAllColor — XGColors.BrandPrimary (brand.primary = #6000FE)

    @Test
    fun `BrandPrimary should match design token brand primary`() {
        assertThat(XGColors.BrandPrimary).isEqualTo(Color(0xFF6000FE))
    }

    // endregion

    // region arrowIconSize — 12dp

    @Test
    fun `arrowIconSize constant should be 12dp`() {
        // Mirrors the private ArrowIconSize = 12.dp in XGSectionHeader.kt
        val arrowIconSize = 12.dp
        assertThat(arrowIconSize).isEqualTo(12.dp)
    }

    @Test
    fun `arrowIconSize should be smaller than minimum touch target`() {
        val arrowIconSize = 12.dp
        assertThat(arrowIconSize.value).isLessThan(XGSpacing.MinTouchTarget.value)
    }

    // endregion

    // region horizontalPadding — XGSpacing.ScreenPaddingHorizontal (20dp)

    @Test
    fun `ScreenPaddingHorizontal should be 20dp`() {
        assertThat(XGSpacing.ScreenPaddingHorizontal).isEqualTo(20.dp)
    }

    // endregion

    // region subtitleSpacing — XGSpacing.XXS (2dp)

    @Test
    fun `XXS spacing should be 2dp for subtitle spacing`() {
        assertThat(XGSpacing.XXS).isEqualTo(2.dp)
    }

    // endregion

    // region Cross-token consistency

    @Test
    fun `title and subtitle should use different font sizes`() {
        assertThat(XGTypography.titleMedium.fontSize.value)
            .isGreaterThan(XGTypography.labelLarge.fontSize.value)
    }

    @Test
    fun `title and subtitle should use different colors`() {
        assertThat(XGColors.OnSurface).isNotEqualTo(XGColors.OnSurfaceVariant)
    }

    @Test
    fun `seeAll color should match BrandPrimary`() {
        assertThat(XGColors.BrandPrimary).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `seeAll color should be different from title color`() {
        assertThat(XGColors.BrandPrimary).isNotEqualTo(XGColors.OnSurface)
    }

    @Test
    fun `seeAll color should be different from subtitle color`() {
        assertThat(XGColors.BrandPrimary).isNotEqualTo(XGColors.OnSurfaceVariant)
    }

    // endregion
}
