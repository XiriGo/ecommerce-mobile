package com.xirigo.ecommerce.core.designsystem.theme

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color

class XGColorsTest {

    @Test
    fun `primary colors should match design tokens`() {
        assertThat(XGColors.Primary).isEqualTo(Color(0xFF6750A4))
        assertThat(XGColors.OnPrimary).isEqualTo(Color(0xFFFFFFFF))
        assertThat(XGColors.PrimaryContainer).isEqualTo(Color(0xFFEADDFF))
        assertThat(XGColors.OnPrimaryContainer).isEqualTo(Color(0xFF21005D))
    }

    @Test
    fun `dark primary colors should match design tokens`() {
        assertThat(XGColors.DarkPrimary).isEqualTo(Color(0xFFD0BCFF))
        assertThat(XGColors.DarkOnPrimary).isEqualTo(Color(0xFF381E72))
        assertThat(XGColors.DarkPrimaryContainer).isEqualTo(Color(0xFF4F378B))
        assertThat(XGColors.DarkOnPrimaryContainer).isEqualTo(Color(0xFFEADDFF))
    }

    @Test
    fun `secondary colors should match design tokens`() {
        assertThat(XGColors.Secondary).isEqualTo(Color(0xFF625B71))
        assertThat(XGColors.OnSecondary).isEqualTo(Color(0xFFFFFFFF))
        assertThat(XGColors.SecondaryContainer).isEqualTo(Color(0xFFE8DEF8))
        assertThat(XGColors.OnSecondaryContainer).isEqualTo(Color(0xFF1D192B))
    }

    @Test
    fun `dark secondary colors should match design tokens`() {
        assertThat(XGColors.DarkSecondary).isEqualTo(Color(0xFFCCC2DC))
        assertThat(XGColors.DarkOnSecondary).isEqualTo(Color(0xFF332D41))
        assertThat(XGColors.DarkSecondaryContainer).isEqualTo(Color(0xFF4A4458))
        assertThat(XGColors.DarkOnSecondaryContainer).isEqualTo(Color(0xFFE8DEF8))
    }

    @Test
    fun `error colors should match design tokens`() {
        assertThat(XGColors.Error).isEqualTo(Color(0xFFB3261E))
        assertThat(XGColors.OnError).isEqualTo(Color(0xFFFFFFFF))
        assertThat(XGColors.ErrorContainer).isEqualTo(Color(0xFFF9DEDC))
        assertThat(XGColors.OnErrorContainer).isEqualTo(Color(0xFF410E0B))
    }

    @Test
    fun `semantic colors should match design tokens`() {
        assertThat(XGColors.Success).isEqualTo(Color(0xFF4CAF50))
        assertThat(XGColors.OnSuccess).isEqualTo(Color(0xFFFFFFFF))
        assertThat(XGColors.Warning).isEqualTo(Color(0xFFFF9800))
    }

    @Test
    fun `price colors should match design tokens`() {
        assertThat(XGColors.PriceRegular).isEqualTo(Color(0xFF1C1B1F))
        assertThat(XGColors.PriceSale).isEqualTo(Color(0xFFB3261E))
        assertThat(XGColors.PriceOriginal).isEqualTo(Color(0xFF79747E))
    }

    @Test
    fun `rating colors should match design tokens`() {
        assertThat(XGColors.RatingStarFilled).isEqualTo(Color(0xFFFFC107))
        assertThat(XGColors.RatingStarEmpty).isEqualTo(Color(0xFFE0E0E0))
    }

    @Test
    fun `badge colors should match design tokens`() {
        assertThat(XGColors.BadgeBackground).isEqualTo(Color(0xFFB3261E))
        assertThat(XGColors.BadgeText).isEqualTo(Color(0xFFFFFFFF))
    }

    @Test
    fun `utility colors should match design tokens`() {
        assertThat(XGColors.Divider).isEqualTo(Color(0xFFCAC4D0))
        assertThat(XGColors.Shimmer).isEqualTo(Color(0xFFE7E0EC))
    }

    @Test
    fun `surface colors should match design tokens`() {
        assertThat(XGColors.Surface).isEqualTo(Color(0xFFFFFBFE))
        assertThat(XGColors.OnSurface).isEqualTo(Color(0xFF1C1B1F))
        assertThat(XGColors.SurfaceVariant).isEqualTo(Color(0xFFE7E0EC))
        assertThat(XGColors.OnSurfaceVariant).isEqualTo(Color(0xFF49454F))
    }

    @Test
    fun `outline colors should match design tokens`() {
        assertThat(XGColors.Outline).isEqualTo(Color(0xFF79747E))
        assertThat(XGColors.OutlineVariant).isEqualTo(Color(0xFFCAC4D0))
    }
}
