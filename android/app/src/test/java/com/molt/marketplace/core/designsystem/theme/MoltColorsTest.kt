package com.molt.marketplace.core.designsystem.theme

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.graphics.Color

class MoltColorsTest {

    @Test
    fun `primary colors should match design tokens`() {
        assertThat(MoltColors.Primary).isEqualTo(Color(0xFF6750A4))
        assertThat(MoltColors.OnPrimary).isEqualTo(Color(0xFFFFFFFF))
        assertThat(MoltColors.PrimaryContainer).isEqualTo(Color(0xFFEADDFF))
        assertThat(MoltColors.OnPrimaryContainer).isEqualTo(Color(0xFF21005D))
    }

    @Test
    fun `dark primary colors should match design tokens`() {
        assertThat(MoltColors.DarkPrimary).isEqualTo(Color(0xFFD0BCFF))
        assertThat(MoltColors.DarkOnPrimary).isEqualTo(Color(0xFF381E72))
        assertThat(MoltColors.DarkPrimaryContainer).isEqualTo(Color(0xFF4F378B))
        assertThat(MoltColors.DarkOnPrimaryContainer).isEqualTo(Color(0xFFEADDFF))
    }

    @Test
    fun `secondary colors should match design tokens`() {
        assertThat(MoltColors.Secondary).isEqualTo(Color(0xFF625B71))
        assertThat(MoltColors.OnSecondary).isEqualTo(Color(0xFFFFFFFF))
        assertThat(MoltColors.SecondaryContainer).isEqualTo(Color(0xFFE8DEF8))
        assertThat(MoltColors.OnSecondaryContainer).isEqualTo(Color(0xFF1D192B))
    }

    @Test
    fun `dark secondary colors should match design tokens`() {
        assertThat(MoltColors.DarkSecondary).isEqualTo(Color(0xFFCCC2DC))
        assertThat(MoltColors.DarkOnSecondary).isEqualTo(Color(0xFF332D41))
        assertThat(MoltColors.DarkSecondaryContainer).isEqualTo(Color(0xFF4A4458))
        assertThat(MoltColors.DarkOnSecondaryContainer).isEqualTo(Color(0xFFE8DEF8))
    }

    @Test
    fun `error colors should match design tokens`() {
        assertThat(MoltColors.Error).isEqualTo(Color(0xFFB3261E))
        assertThat(MoltColors.OnError).isEqualTo(Color(0xFFFFFFFF))
        assertThat(MoltColors.ErrorContainer).isEqualTo(Color(0xFFF9DEDC))
        assertThat(MoltColors.OnErrorContainer).isEqualTo(Color(0xFF410E0B))
    }

    @Test
    fun `semantic colors should match design tokens`() {
        assertThat(MoltColors.Success).isEqualTo(Color(0xFF4CAF50))
        assertThat(MoltColors.OnSuccess).isEqualTo(Color(0xFFFFFFFF))
        assertThat(MoltColors.Warning).isEqualTo(Color(0xFFFF9800))
    }

    @Test
    fun `price colors should match design tokens`() {
        assertThat(MoltColors.PriceRegular).isEqualTo(Color(0xFF1C1B1F))
        assertThat(MoltColors.PriceSale).isEqualTo(Color(0xFFB3261E))
        assertThat(MoltColors.PriceOriginal).isEqualTo(Color(0xFF79747E))
    }

    @Test
    fun `rating colors should match design tokens`() {
        assertThat(MoltColors.RatingStarFilled).isEqualTo(Color(0xFFFFC107))
        assertThat(MoltColors.RatingStarEmpty).isEqualTo(Color(0xFFE0E0E0))
    }

    @Test
    fun `badge colors should match design tokens`() {
        assertThat(MoltColors.BadgeBackground).isEqualTo(Color(0xFFB3261E))
        assertThat(MoltColors.BadgeText).isEqualTo(Color(0xFFFFFFFF))
    }

    @Test
    fun `utility colors should match design tokens`() {
        assertThat(MoltColors.Divider).isEqualTo(Color(0xFFCAC4D0))
        assertThat(MoltColors.Shimmer).isEqualTo(Color(0xFFE7E0EC))
    }

    @Test
    fun `surface colors should match design tokens`() {
        assertThat(MoltColors.Surface).isEqualTo(Color(0xFFFFFBFE))
        assertThat(MoltColors.OnSurface).isEqualTo(Color(0xFF1C1B1F))
        assertThat(MoltColors.SurfaceVariant).isEqualTo(Color(0xFFE7E0EC))
        assertThat(MoltColors.OnSurfaceVariant).isEqualTo(Color(0xFF49454F))
    }

    @Test
    fun `outline colors should match design tokens`() {
        assertThat(MoltColors.Outline).isEqualTo(Color(0xFF79747E))
        assertThat(MoltColors.OutlineVariant).isEqualTo(Color(0xFFCAC4D0))
    }
}
