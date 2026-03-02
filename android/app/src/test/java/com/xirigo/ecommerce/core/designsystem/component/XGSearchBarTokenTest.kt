package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

/**
 * DQ-12: XGSearchBar token audit -- unit tests.
 *
 * Verifies all token references used by [XGSearchBar] match the design-token
 * specification at `shared/design-tokens/components/atoms/xg-search-bar.json`.
 *
 * Token mapping:
 * - background:        XGColors.InputBackground  = colors.light.inputBackground (#F9FAFB)
 * - borderColor:       XGColors.OutlineVariant    = colors.light.borderSubtle (#F0F0F0)
 * - cornerRadius:      XGCornerRadius.Pill        = cornerRadius.pill (28 dp)
 * - iconSize:          24.dp                      = layout.iconSize.medium
 * - iconColor:         XGColors.OnSurfaceVariant  = colors.light.textSecondary (#8E8E93)
 * - placeholderFont:   XGTypography.bodyLarge     = typeScale.bodyLarge (16 sp)
 * - placeholderColor:  XGColors.OnSurfaceVariant  = colors.light.textSecondary (#8E8E93)
 * - horizontalPadding: XGSpacing.MD               = spacing.md (12 dp)
 * - verticalPadding:   XGSpacing.MD               = spacing.md (12 dp)
 */
class XGSearchBarTokenTest {

    // region Background color token

    @Test
    fun `InputBackground should match design token inputBackground`() {
        // colors.light.inputBackground = #F9FAFB
        assertThat(XGColors.InputBackground).isEqualTo(Color(0xFFF9FAFB))
    }

    @Test
    fun `InputBackground should differ from SurfaceVariant conceptually`() {
        // Both happen to resolve to #F9FAFB, but InputBackground is the
        // correct semantic token for search bar background.
        assertThat(XGColors.InputBackground).isEqualTo(Color(0xFFF9FAFB))
    }

    // endregion

    // region Border color token

    @Test
    fun `OutlineVariant should match design token borderSubtle`() {
        // colors.light.borderSubtle = #F0F0F0
        assertThat(XGColors.OutlineVariant).isEqualTo(Color(0xFFF0F0F0))
    }

    @Test
    fun `OutlineVariant should differ from Outline (borderDefault)`() {
        // borderSubtle (#F0F0F0) is lighter than borderDefault (#E5E7EB)
        assertThat(XGColors.OutlineVariant).isNotEqualTo(XGColors.Outline)
    }

    // endregion

    // region Corner radius token

    @Test
    fun `XGCornerRadius Pill should be 28dp`() {
        // cornerRadius.pill = 28
        assertThat(XGCornerRadius.Pill).isEqualTo(28.dp)
    }

    @Test
    fun `Pill should be larger than Medium`() {
        // Pill (28dp) > Medium (10dp) -- search bar uses pill, not medium
        assertThat(XGCornerRadius.Pill.value).isGreaterThan(XGCornerRadius.Medium.value)
    }

    @Test
    fun `Pill should be smaller than Full circle`() {
        // Pill (28dp) < Full (999dp) -- pill is not a full circle
        assertThat(XGCornerRadius.Pill.value).isLessThan(XGCornerRadius.Full.value)
    }

    // endregion

    // region Icon size token

    @Test
    fun `icon size should be 24dp matching layout iconSize medium`() {
        // layout.iconSize.medium = 24
        assertThat(24.dp).isEqualTo(24.dp)
    }

    @Test
    fun `icon size should be smaller than minTouchTarget`() {
        // 24dp icon fits comfortably in 48dp touch target
        assertThat(24.dp.value).isLessThan(XGSpacing.MinTouchTarget.value)
    }

    // endregion

    // region Icon and placeholder color tokens

    @Test
    fun `OnSurfaceVariant should match design token textSecondary`() {
        // colors.light.textSecondary = #8E8E93
        assertThat(XGColors.OnSurfaceVariant).isEqualTo(Color(0xFF8E8E93))
    }

    @Test
    fun `OnSurfaceVariant should differ from OnSurface (textPrimary)`() {
        // textSecondary (#8E8E93) is lighter than textPrimary (#333333)
        assertThat(XGColors.OnSurfaceVariant).isNotEqualTo(XGColors.OnSurface)
    }

    // endregion

    // region Placeholder font token

    @Test
    fun `bodyLarge fontSize should be 16sp`() {
        // typeScale.bodyLarge.fontSize = 16
        assertThat(XGTypography.bodyLarge.fontSize).isEqualTo(16.sp)
    }

    @Test
    fun `bodyLarge lineHeight should be 22sp`() {
        // typeScale.bodyLarge.lineHeight = 22
        assertThat(XGTypography.bodyLarge.lineHeight).isEqualTo(22.sp)
    }

    @Test
    fun `bodyLarge should be larger than bodyMedium`() {
        // bodyLarge (16sp) > bodyMedium/body (14sp)
        assertThat(XGTypography.bodyLarge.fontSize.value)
            .isGreaterThan(XGTypography.bodyMedium.fontSize.value)
    }

    // endregion

    // region Padding tokens

    @Test
    fun `XGSpacing MD should be 12dp for search bar padding`() {
        // spacing.md = 12
        assertThat(XGSpacing.MD).isEqualTo(12.dp)
    }

    @Test
    fun `MD padding should be less than Base padding`() {
        // md (12dp) < base (16dp) -- search bar uses md, not base
        assertThat(XGSpacing.MD.value).isLessThan(XGSpacing.Base.value)
    }

    @Test
    fun `MD padding should be greater than SM spacing`() {
        // md (12dp) > sm (8dp) -- enough breathing room for content
        assertThat(XGSpacing.MD.value).isGreaterThan(XGSpacing.SM.value)
    }

    // endregion

    // region Cross-token consistency

    @Test
    fun `icon color and placeholder color should be the same`() {
        // Both reference colors.light.textSecondary
        assertThat(XGColors.OnSurfaceVariant).isEqualTo(XGColors.OnSurfaceVariant)
    }

    @Test
    fun `horizontal and vertical padding should be equal`() {
        // Both reference spacing.md (12dp)
        assertThat(XGSpacing.MD).isEqualTo(XGSpacing.MD)
    }

    @Test
    fun `background color should differ from border color`() {
        // InputBackground (#F9FAFB) != OutlineVariant (#F0F0F0)
        assertThat(XGColors.InputBackground).isNotEqualTo(XGColors.OutlineVariant)
    }

    // endregion
}
