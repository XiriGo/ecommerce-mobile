package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

/**
 * DQ-08: XGBadge token audit — unit tests.
 *
 * Verifies:
 * 1. [XGBadgeStatus] enum exhaustiveness (all 5 values present)
 * 2. Badge-related [XGColors] token contract (hex values from design-tokens JSON)
 * 3. Semantic status colors consumed by [XGStatusBadge]
 * 4. [XGCornerRadius.Full] pill shape used by [XGStatusBadge]
 * 5. [XGSpacing] tokens used by badge padding
 * 6. [XGTypography] labelSmall style used for badge text
 *
 * Note: [XGBadgeVariant] (Primary/Secondary) from the JSON spec is not yet
 * implemented as an enum in XGBadge.kt — the implementation uses separate
 * [XGCountBadge] and [XGStatusBadge] composables instead. Variant token
 * contracts are covered through [XGColors] assertions below.
 */
class XGBadgeTokenTest {

    // region XGBadgeStatus enum

    @Test
    fun `XGBadgeStatus should have exactly 5 values`() {
        assertThat(XGBadgeStatus.values()).hasLength(5)
    }

    @Test
    fun `XGBadgeStatus should contain Success`() {
        assertThat(XGBadgeStatus.values()).asList().contains(XGBadgeStatus.Success)
    }

    @Test
    fun `XGBadgeStatus should contain Warning`() {
        assertThat(XGBadgeStatus.values()).asList().contains(XGBadgeStatus.Warning)
    }

    @Test
    fun `XGBadgeStatus should contain Error`() {
        assertThat(XGBadgeStatus.values()).asList().contains(XGBadgeStatus.Error)
    }

    @Test
    fun `XGBadgeStatus should contain Info`() {
        assertThat(XGBadgeStatus.values()).asList().contains(XGBadgeStatus.Info)
    }

    @Test
    fun `XGBadgeStatus should contain Neutral`() {
        assertThat(XGBadgeStatus.values()).asList().contains(XGBadgeStatus.Neutral)
    }

    @Test
    fun `XGBadgeStatus valueOf should resolve all status names`() {
        assertThat(XGBadgeStatus.valueOf("Success")).isEqualTo(XGBadgeStatus.Success)
        assertThat(XGBadgeStatus.valueOf("Warning")).isEqualTo(XGBadgeStatus.Warning)
        assertThat(XGBadgeStatus.valueOf("Error")).isEqualTo(XGBadgeStatus.Error)
        assertThat(XGBadgeStatus.valueOf("Info")).isEqualTo(XGBadgeStatus.Info)
        assertThat(XGBadgeStatus.valueOf("Neutral")).isEqualTo(XGBadgeStatus.Neutral)
    }

    // endregion

    // region XGColors badge token contract

    @Test
    fun `BadgeBackground should match design token brand primary`() {
        // semantic.badgeBackground = brand.primary = #6000FE
        assertThat(XGColors.BadgeBackground).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `BadgeText should match design token onPrimary white`() {
        // semantic.badgeText = #FFFFFF
        assertThat(XGColors.BadgeText).isEqualTo(Color(0xFFFFFFFF))
    }

    @Test
    fun `BadgeSecondaryBackground should match design token brand secondary`() {
        // semantic.badgeSecondaryBackground = brand.secondary = #94D63A
        assertThat(XGColors.BadgeSecondaryBackground).isEqualTo(Color(0xFF94D63A))
    }

    @Test
    fun `BadgeSecondaryText should match design token brand primary`() {
        // semantic.badgeSecondaryText = brand.primary = #6000FE
        assertThat(XGColors.BadgeSecondaryText).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `BadgeBackground and BadgeSecondaryBackground should be distinct`() {
        assertThat(XGColors.BadgeBackground).isNotEqualTo(XGColors.BadgeSecondaryBackground)
    }

    @Test
    fun `BadgeText and BadgeSecondaryText should be distinct`() {
        // Primary badge: white text; Secondary badge: brand-primary text
        assertThat(XGColors.BadgeText).isNotEqualTo(XGColors.BadgeSecondaryText)
    }

    // endregion

    // region XGColors status badge semantic colors

    @Test
    fun `Success color should match design token`() {
        // semantic.success = #22C55E
        assertThat(XGColors.Success).isEqualTo(Color(0xFF22C55E))
    }

    @Test
    fun `OnSuccess color should be white`() {
        assertThat(XGColors.OnSuccess).isEqualTo(Color(0xFFFFFFFF))
    }

    @Test
    fun `Warning color should match design token`() {
        // semantic.warning = #FACC15
        assertThat(XGColors.Warning).isEqualTo(Color(0xFFFACC15))
    }

    @Test
    fun `OnWarning color should match design token`() {
        // semantic.onWarning = #1D1D1B (dark, for legibility on yellow)
        assertThat(XGColors.OnWarning).isEqualTo(Color(0xFF1D1D1B))
    }

    @Test
    fun `Error color should match design token`() {
        // semantic.error = #EF4444
        assertThat(XGColors.Error).isEqualTo(Color(0xFFEF4444))
    }

    @Test
    fun `Info color should match design token`() {
        // semantic.info = #3B82F6
        assertThat(XGColors.Info).isEqualTo(Color(0xFF3B82F6))
    }

    @Test
    fun `OnInfo color should be white`() {
        assertThat(XGColors.OnInfo).isEqualTo(Color(0xFFFFFFFF))
    }

    @Test
    fun `SurfaceVariant should match design token for Neutral badge background`() {
        // XGBadgeStatus.Neutral uses MaterialTheme.colorScheme.surfaceVariant
        // which maps to XGColors.SurfaceVariant in XGTheme = #F9FAFB
        assertThat(XGColors.SurfaceVariant).isEqualTo(Color(0xFFF9FAFB))
    }

    @Test
    fun `OnSurfaceVariant should match design token for Neutral badge text`() {
        // XGBadgeStatus.Neutral uses MaterialTheme.colorScheme.onSurfaceVariant = #8E8E93
        assertThat(XGColors.OnSurfaceVariant).isEqualTo(Color(0xFF8E8E93))
    }

    @Test
    fun `all 5 status background colors should be distinct`() {
        val backgrounds = setOf(
            XGColors.Success,
            XGColors.Warning,
            XGColors.Error,
            XGColors.Info,
            XGColors.SurfaceVariant,
        )
        assertThat(backgrounds).hasSize(5)
    }

    // endregion

    // region XGCornerRadius token contract

    @Test
    fun `XGCornerRadius Full should be 999dp for pill shape`() {
        // XGStatusBadge uses RoundedCornerShape(XGCornerRadius.Full)
        assertThat(XGCornerRadius.Full).isEqualTo(999.dp)
    }

    @Test
    fun `XGCornerRadius Full should be large enough to create a pill shape`() {
        assertThat(XGCornerRadius.Full.value).isAtLeast(100f)
    }

    // endregion

    // region XGSpacing token contract for badge padding

    @Test
    fun `XGSpacing XXS should be 2dp for count badge vertical padding`() {
        // XGCountBadge uses vertical = XGSpacing.XXS
        assertThat(XGSpacing.XXS).isEqualTo(2.dp)
    }

    @Test
    fun `XGSpacing XS should be 4dp for count badge horizontal padding`() {
        // XGCountBadge uses horizontal = XGSpacing.XS
        assertThat(XGSpacing.XS).isEqualTo(4.dp)
    }

    @Test
    fun `XGSpacing SM should be 8dp for status badge vertical padding`() {
        // XGStatusBadge uses vertical = XGSpacing.XS and horizontal = XGSpacing.SM
        assertThat(XGSpacing.SM).isEqualTo(8.dp)
    }

    @Test
    fun `status badge horizontal padding should be larger than vertical padding`() {
        // SM (8dp) > XS (4dp) — pill shape is wider than tall
        assertThat(XGSpacing.SM).isGreaterThan(XGSpacing.XS)
    }

    @Test
    fun `count badge horizontal padding should be larger than vertical padding`() {
        // XS (4dp) > XXS (2dp) — count badge is wider than tall
        assertThat(XGSpacing.XS).isGreaterThan(XGSpacing.XXS)
    }

    // endregion

    // region XGTypography labelSmall for badge text

    @Test
    fun `labelSmall fontSize should be 10sp`() {
        // XGCountBadge and XGStatusBadge use MaterialTheme.typography.labelSmall
        // which maps to XGTypography.labelSmall = 10sp normal (micro scale)
        assertThat(XGTypography.labelSmall.fontSize).isEqualTo(10.sp)
    }

    @Test
    fun `labelSmall fontWeight should be Normal`() {
        assertThat(XGTypography.labelSmall.fontWeight).isEqualTo(FontWeight.Normal)
    }

    @Test
    fun `labelSmall lineHeight should be 14sp`() {
        assertThat(XGTypography.labelSmall.lineHeight).isEqualTo(14.sp)
    }

    @Test
    fun `labelSmall fontSize should be smaller than labelMedium`() {
        // Badge uses the smallest label scale — micro (10sp) vs captionMedium (12sp)
        assertThat(XGTypography.labelSmall.fontSize)
            .isLessThan(XGTypography.labelMedium.fontSize)
    }

    // endregion
}
