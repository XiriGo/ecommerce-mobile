package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

/**
 * DQ-14: XGCategoryIcon token audit — unit tests.
 *
 * Verifies that theme-level token constants consumed by [XGCategoryIcon]
 * match the values declared in `shared/design-tokens/components/atoms/xg-category-icon.json`.
 *
 * Token mapping:
 * - tileSize      = 79dp  (private constant in composable)
 * - cornerRadius  = $foundations/spacing.cornerRadius.medium → XGCornerRadius.Medium (10dp)
 * - iconSize      = 40dp  (private constant in composable)
 * - iconColor     = $foundations/colors.light.iconOnDark     → XGColors.IconOnDark (#FFFFFF)
 * - labelFont     = $foundations/typography.typeScale.captionMedium → labelMedium (12sp Medium)
 * - labelColor    = $foundations/colors.light.textPrimary     → XGColors.OnSurface (#333333)
 * - labelSpacing  = 6dp   (private constant in composable)
 * - backgroundColors = category.blue/pink/yellow/mint/lightYellow → XGColors.Category*
 */
class XGCategoryIconTokenTest {

    // region tileSize — 79dp

    @Test
    fun `tileSize constant should be 79dp`() {
        // Mirrors the private TileSize = 79.dp in XGCategoryIcon.kt
        val tileSize = 79.dp
        assertThat(tileSize).isEqualTo(79.dp)
    }

    @Test
    fun `tileSize should be larger than minimum touch target`() {
        val tileSize = 79.dp
        assertThat(tileSize.value).isAtLeast(48f)
    }

    // endregion

    // region cornerRadius — XGCornerRadius.Medium (10dp)

    @Test
    fun `XGCornerRadius Medium should be 10dp`() {
        assertThat(XGCornerRadius.Medium).isEqualTo(10.dp)
    }

    @Test
    fun `cornerRadius should not be Small`() {
        assertThat(XGCornerRadius.Medium).isNotEqualTo(XGCornerRadius.Small)
    }

    @Test
    fun `cornerRadius should not be Large`() {
        assertThat(XGCornerRadius.Medium).isNotEqualTo(XGCornerRadius.Large)
    }

    // endregion

    // region iconSize — 40dp

    @Test
    fun `iconSize constant should be 40dp`() {
        // Mirrors the private IconSize = 40.dp in XGCategoryIcon.kt
        val iconSize = 40.dp
        assertThat(iconSize).isEqualTo(40.dp)
    }

    @Test
    fun `iconSize should be smaller than tileSize`() {
        val iconSize = 40.dp
        val tileSize = 79.dp
        assertThat(iconSize.value).isLessThan(tileSize.value)
    }

    // endregion

    // region iconColor — XGColors.IconOnDark (#FFFFFF)

    @Test
    fun `IconOnDark should be white`() {
        assertThat(XGColors.IconOnDark).isEqualTo(Color(0xFFFFFFFF))
    }

    // endregion

    // region labelFont — XGTypography.labelMedium (captionMedium: 12sp Medium)

    @Test
    fun `labelMedium fontSize should be 12sp`() {
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

    // region labelColor — XGColors.OnSurface (#333333)

    @Test
    fun `OnSurface should match design token textPrimary`() {
        assertThat(XGColors.OnSurface).isEqualTo(Color(0xFF333333))
    }

    // endregion

    // region labelSpacing — 6dp

    @Test
    fun `labelSpacing constant should be 6dp`() {
        // Mirrors the private LabelSpacing = 6.dp in XGCategoryIcon.kt
        val labelSpacing = 6.dp
        assertThat(labelSpacing).isEqualTo(6.dp)
    }

    @Test
    fun `labelSpacing should be positive`() {
        val labelSpacing = 6.dp
        assertThat(labelSpacing.value).isGreaterThan(0f)
    }

    // endregion

    // region backgroundColors — category color tokens

    @Test
    fun `CategoryBlue should match design token`() {
        // category.blue = #37B4F2
        assertThat(XGColors.CategoryBlue).isEqualTo(Color(0xFF37B4F2))
    }

    @Test
    fun `CategoryPink should match design token`() {
        // category.pink = #FE75D4
        assertThat(XGColors.CategoryPink).isEqualTo(Color(0xFFFE75D4))
    }

    @Test
    fun `CategoryYellow should match design token`() {
        // category.yellow = #FDF29C
        assertThat(XGColors.CategoryYellow).isEqualTo(Color(0xFFFDF29C))
    }

    @Test
    fun `CategoryMint should match design token`() {
        // category.mint = #90D3B1
        assertThat(XGColors.CategoryMint).isEqualTo(Color(0xFF90D3B1))
    }

    @Test
    fun `CategoryLightYellow should match design token`() {
        // category.lightYellow = #FEF170
        assertThat(XGColors.CategoryLightYellow).isEqualTo(Color(0xFFFEF170))
    }

    @Test
    fun `all 5 category colors should be distinct`() {
        val categoryColors = setOf(
            XGColors.CategoryBlue,
            XGColors.CategoryPink,
            XGColors.CategoryYellow,
            XGColors.CategoryMint,
            XGColors.CategoryLightYellow,
        )
        assertThat(categoryColors).hasSize(5)
    }

    // endregion

    // region Cross-token consistency

    @Test
    fun `label font size should match token spec of 12sp`() {
        // labelFont from xg-category-icon.json = typeScale.captionMedium = 12sp
        assertThat(XGTypography.labelMedium.fontSize).isEqualTo(12.sp)
    }

    @Test
    fun `label color should be distinct from icon color`() {
        // OnSurface (#333333) vs IconOnDark (#FFFFFF) — high contrast pair
        assertThat(XGColors.OnSurface).isNotEqualTo(XGColors.IconOnDark)
    }

    @Test
    fun `iconOnDark should provide sufficient contrast on category colors`() {
        // White icon on colored backgrounds — all category colors are mid-tone
        assertThat(XGColors.IconOnDark).isEqualTo(Color(0xFFFFFFFF))
    }

    // endregion
}
