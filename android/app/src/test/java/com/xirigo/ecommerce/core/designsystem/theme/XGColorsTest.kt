package com.xirigo.ecommerce.core.designsystem.theme

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color

class XGColorsTest {

    @Test
    fun `primary colors should match design tokens`() {
        assertThat(XGColors.Primary).isEqualTo(Color(0xFF6000FE))
        assertThat(XGColors.OnPrimary).isEqualTo(Color(0xFFFFFFFF))
        assertThat(XGColors.PrimaryContainer).isEqualTo(Color(0xFFF0EBFF))
        assertThat(XGColors.OnPrimaryContainer).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `dark primary colors should match design tokens`() {
        assertThat(XGColors.DarkPrimary).isEqualTo(Color(0xFFA070FF))
        assertThat(XGColors.DarkOnPrimary).isEqualTo(Color(0xFF1A1A24))
        assertThat(XGColors.DarkPrimaryContainer).isEqualTo(Color(0xFF3C00D2))
        assertThat(XGColors.DarkOnPrimaryContainer).isEqualTo(Color(0xFFF0F0F5))
    }

    @Test
    fun `secondary colors should match design tokens`() {
        assertThat(XGColors.Secondary).isEqualTo(Color(0xFF94D63A))
        assertThat(XGColors.OnSecondary).isEqualTo(Color(0xFF6000FE))
        assertThat(XGColors.SecondaryContainer).isEqualTo(Color(0xFF6200FF))
        assertThat(XGColors.OnSecondaryContainer).isEqualTo(Color(0xFFFFFFFF))
    }

    @Test
    fun `dark secondary colors should match design tokens`() {
        assertThat(XGColors.DarkSecondary).isEqualTo(Color(0xFF94D63A))
        assertThat(XGColors.DarkOnSecondary).isEqualTo(Color(0xFF6000FE))
        assertThat(XGColors.DarkSecondaryContainer).isEqualTo(Color(0xFF6000FE))
        assertThat(XGColors.DarkOnSecondaryContainer).isEqualTo(Color(0xFFF0F0F5))
    }

    @Test
    fun `error colors should match design tokens`() {
        assertThat(XGColors.Error).isEqualTo(Color(0xFFEF4444))
        assertThat(XGColors.OnError).isEqualTo(Color(0xFFFFFFFF))
        assertThat(XGColors.ErrorContainer).isEqualTo(Color(0xFFFEE2E2))
        assertThat(XGColors.OnErrorContainer).isEqualTo(Color(0xFFEF4444))
    }

    @Test
    fun `semantic colors should match design tokens`() {
        assertThat(XGColors.Success).isEqualTo(Color(0xFF22C55E))
        assertThat(XGColors.OnSuccess).isEqualTo(Color(0xFFFFFFFF))
        assertThat(XGColors.Warning).isEqualTo(Color(0xFFFACC15))
        assertThat(XGColors.OnWarning).isEqualTo(Color(0xFF1D1D1B))
        assertThat(XGColors.Info).isEqualTo(Color(0xFF3B82F6))
        assertThat(XGColors.OnInfo).isEqualTo(Color(0xFFFFFFFF))
    }

    @Test
    fun `price colors should match design tokens`() {
        assertThat(XGColors.PriceRegular).isEqualTo(Color(0xFF333333))
        assertThat(XGColors.PriceSale).isEqualTo(Color(0xFF6000FE))
        assertThat(XGColors.PriceOriginal).isEqualTo(Color(0xFF8E8E93))
        assertThat(XGColors.PriceStrikethrough).isEqualTo(Color(0xFF8E8E93))
    }

    @Test
    fun `rating colors should match design tokens`() {
        assertThat(XGColors.RatingStarFilled).isEqualTo(Color(0xFF6000FE))
        assertThat(XGColors.RatingStarEmpty).isEqualTo(Color(0xFF8E8E93))
    }

    @Test
    fun `badge colors should match design tokens`() {
        assertThat(XGColors.BadgeBackground).isEqualTo(Color(0xFF6000FE))
        assertThat(XGColors.BadgeText).isEqualTo(Color(0xFFFFFFFF))
        assertThat(XGColors.BadgeSecondaryBackground).isEqualTo(Color(0xFF94D63A))
        assertThat(XGColors.BadgeSecondaryText).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `utility colors should match design tokens`() {
        assertThat(XGColors.Divider).isEqualTo(Color(0xFFE5E7EB))
        assertThat(XGColors.Shimmer).isEqualTo(Color(0xFFF1F5F9))
    }

    @Test
    fun `surface colors should match design tokens`() {
        assertThat(XGColors.Surface).isEqualTo(Color(0xFFFFFFFF))
        assertThat(XGColors.OnSurface).isEqualTo(Color(0xFF333333))
        assertThat(XGColors.SurfaceVariant).isEqualTo(Color(0xFFF9FAFB))
        assertThat(XGColors.OnSurfaceVariant).isEqualTo(Color(0xFF8E8E93))
    }

    @Test
    fun `outline colors should match design tokens`() {
        assertThat(XGColors.Outline).isEqualTo(Color(0xFFE5E7EB))
        assertThat(XGColors.OutlineVariant).isEqualTo(Color(0xFFF0F0F0))
    }

    @Test
    fun `flash sale colors should match design tokens`() {
        assertThat(XGColors.FlashSaleBackground).isEqualTo(Color(0xFFFFD814))
        assertThat(XGColors.FlashSaleAccentPink).isEqualTo(Color(0xFFF60186))
        assertThat(XGColors.FlashSaleAccentBlue).isEqualTo(Color(0xFF9EBDF4))
        assertThat(XGColors.FlashSaleText).isEqualTo(Color(0xFF1D1D1B))
    }

    @Test
    fun `brand colors should match design tokens`() {
        assertThat(XGColors.BrandPrimary).isEqualTo(Color(0xFF6000FE))
        assertThat(XGColors.BrandOnPrimary).isEqualTo(Color(0xFFFFFFFF))
        assertThat(XGColors.BrandPrimaryLight).isEqualTo(Color(0xFF9000FE))
        assertThat(XGColors.BrandPrimaryDark).isEqualTo(Color(0xFF3C00D2))
        assertThat(XGColors.BrandSecondary).isEqualTo(Color(0xFF94D63A))
        assertThat(XGColors.BrandOnSecondary).isEqualTo(Color(0xFF6000FE))
    }

    @Test
    fun `pagination dot colors should match design tokens`() {
        assertThat(XGColors.PaginationDotsActive).isEqualTo(Color(0xFF6000FE))
        assertThat(XGColors.PaginationDotsInactive).isEqualTo(Color(0xFFD1D5DB))
    }

    @Test
    fun `dark theme surface colors should match design tokens`() {
        assertThat(XGColors.DarkSurface).isEqualTo(Color(0xFF1A1A24))
        assertThat(XGColors.DarkOnSurface).isEqualTo(Color(0xFFF0F0F5))
        assertThat(XGColors.DarkBackground).isEqualTo(Color(0xFF0F0F14))
        assertThat(XGColors.DarkOnBackground).isEqualTo(Color(0xFFF0F0F5))
    }
}
