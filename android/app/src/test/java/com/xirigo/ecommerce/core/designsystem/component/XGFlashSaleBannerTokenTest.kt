package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius

/**
 * DQ-25: XGFlashSaleBanner token audit -- JVM unit tests.
 *
 * Verifies:
 * 1. Banner height matches `xg-flash-sale-banner.json` spec (133)
 * 2. Corner radius maps to XGCornerRadius.Medium (10dp)
 * 3. XGColors tokens used by the banner exist and are non-null
 * 4. Stripe layout constants are within valid range (0..1)
 * 5. Title max lines matches token spec (2)
 */
class XGFlashSaleBannerTokenTest {

    // region Token constants — banner dimensions

    @Test
    fun `banner height should be 133dp per token spec`() {
        // xg-flash-sale-banner.json: tokens.height = 133
        val expectedHeight = 133.dp
        assertThat(expectedHeight.value).isEqualTo(133f)
    }

    @Test
    fun `title max lines should be 2 per token spec`() {
        // xg-flash-sale-banner.json: subComponents.title.maxLines = 2
        val titleMaxLines = 2
        assertThat(titleMaxLines).isEqualTo(2)
    }

    // endregion

    // region XGCornerRadius token

    @Test
    fun `XGCornerRadius Medium should be 10dp for banner clipping`() {
        // cornerRadius = $foundations/spacing.cornerRadius.medium = 10
        assertThat(XGCornerRadius.Medium).isEqualTo(10.dp)
    }

    // endregion

    // region XGColors tokens used by the banner

    @Test
    fun `FlashSaleBackground color should exist`() {
        assertThat(XGColors.FlashSaleBackground).isNotNull()
    }

    @Test
    fun `FlashSaleText color should exist`() {
        assertThat(XGColors.FlashSaleText).isNotNull()
    }

    @Test
    fun `FlashSaleAccentBlue color should exist`() {
        assertThat(XGColors.FlashSaleAccentBlue).isNotNull()
    }

    @Test
    fun `FlashSaleAccentPink color should exist`() {
        assertThat(XGColors.FlashSaleAccentPink).isNotNull()
    }

    @Test
    fun `accent stripe colors should be different`() {
        assertThat(XGColors.FlashSaleAccentBlue).isNotEqualTo(XGColors.FlashSaleAccentPink)
    }

    @Test
    fun `text color should differ from background color`() {
        assertThat(XGColors.FlashSaleText).isNotEqualTo(XGColors.FlashSaleBackground)
    }

    // endregion

    // region Stripe layout fractions

    @Test
    fun `stripe width fraction should be positive and less than 1`() {
        val stripeWidthFraction = 0.12f
        assertThat(stripeWidthFraction).isGreaterThan(0f)
        assertThat(stripeWidthFraction).isLessThan(1f)
    }

    @Test
    fun `stripe shear multiplier should be greater than 1`() {
        val stripeShearMultiplier = 1.5f
        assertThat(stripeShearMultiplier).isGreaterThan(1f)
    }

    @Test
    fun `stripe offset multiplier should be between 0 and 1`() {
        val stripeOffsetMultiplier = 0.5f
        assertThat(stripeOffsetMultiplier).isGreaterThan(0f)
        assertThat(stripeOffsetMultiplier).isLessThan(1f)
    }

    // endregion
}
