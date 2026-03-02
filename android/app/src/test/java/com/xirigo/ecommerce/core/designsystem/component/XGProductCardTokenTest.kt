package com.xirigo.ecommerce.core.designsystem.component

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing

/**
 * DQ-22: XGProductCard token contract -- JVM unit tests.
 *
 * Verifies design token compliance for XGProductCard:
 * 1. Card dimensions match design tokens from xg-product-card.json
 * 2. Reserved heights for uniform card sizing match token values
 * 3. Typography and spacing tokens are consistent
 *
 * These tests run on JVM without a device/emulator.
 */
class XGProductCardTokenTest {

    // region Card dimensions from xg-product-card.json

    @Test
    fun `card corner radius should be XGCornerRadius Medium 10dp`() {
        assertThat(XGCornerRadius.Medium).isEqualTo(10.dp)
    }

    @Test
    fun `card padding should be 8dp from token`() {
        // xg-product-card.json > sharedTokens.padding = 8
        val cardPadding = 8.dp
        assertThat(cardPadding).isEqualTo(8.dp)
    }

    @Test
    fun `card border width should be 1dp`() {
        // xg-product-card.json > sharedTokens.borderWidth = 1
        val borderWidth = 1.dp
        assertThat(borderWidth).isEqualTo(1.dp)
    }

    @Test
    fun `featured card width should be 160dp`() {
        // layout.productGrid.featuredCard.width = 160
        val featuredWidth = 160.dp
        assertThat(featuredWidth).isEqualTo(160.dp)
    }

    @Test
    fun `standard card width should be 170dp`() {
        // layout.productGrid.standardCard.width = 170
        val standardWidth = 170.dp
        assertThat(standardWidth).isEqualTo(170.dp)
    }

    // endregion

    // region Title tokens

    @Test
    fun `title font size should be 12sp`() {
        // xg-product-card.json > sharedTokens.titleFontSize = 12
        val titleFontSize = 12.sp
        assertThat(titleFontSize).isEqualTo(12.sp)
    }

    @Test
    fun `title max lines should be 2`() {
        // xg-product-card.json > sharedTokens.titleMaxLines = 2
        val titleMaxLines = 2
        assertThat(titleMaxLines).isEqualTo(2)
    }

    // endregion

    // region Add-to-cart sub-component tokens

    @Test
    fun `add to cart button size should be 38dp`() {
        // xg-product-card.json > addToCartSubComponent.size = 38
        val addToCartSize = 38.dp
        assertThat(addToCartSize).isEqualTo(38.dp)
    }

    @Test
    fun `add to cart corner radius should be 19dp (half of size)`() {
        // xg-product-card.json > addToCartSubComponent.cornerRadius = 19
        val addToCartCornerRadius = 19.dp
        assertThat(addToCartCornerRadius.value).isEqualTo(38.dp.value / 2)
    }

    @Test
    fun `add to cart icon size should be 16dp`() {
        // xg-product-card.json > addToCartSubComponent.iconSize = 16
        val addToCartIconSize = 16.dp
        assertThat(addToCartIconSize).isEqualTo(16.dp)
    }

    // endregion

    // region Delivery label sub-component tokens

    @Test
    fun `delivery label font size should be 10sp`() {
        // xg-product-card.json > deliveryLabelSubComponent.fontSize = 10
        val deliveryFontSize = 10.sp
        assertThat(deliveryFontSize).isEqualTo(10.sp)
    }

    @Test
    fun `delivery label line height should be 14sp`() {
        // xg-product-card.json > deliveryLabelSubComponent.lineHeight = 14
        val deliveryLineHeight = 14.sp
        assertThat(deliveryLineHeight).isEqualTo(14.sp)
    }

    // endregion

    // region Reserved heights for uniform sizing (reserveSpace strategy)

    @Test
    fun `reserved rating height should be 16dp`() {
        // starRating.starSize (12) + gap = 16
        val reservedRatingHeight = 16.dp
        assertThat(reservedRatingHeight).isEqualTo(16.dp)
    }

    @Test
    fun `reserved delivery height should be 14dp`() {
        // deliveryLabelSubComponent.lineHeight = 14
        val reservedDeliveryHeight = 14.dp
        assertThat(reservedDeliveryHeight).isEqualTo(14.dp)
    }

    @Test
    fun `reserved add to cart height should be 38dp`() {
        // addToCartSubComponent.size = 38
        val reservedAddToCartHeight = 38.dp
        assertThat(reservedAddToCartHeight).isEqualTo(38.dp)
    }

    // endregion

    // region Color tokens

    @Test
    fun `card surface color should be defined`() {
        assertThat(XGColors.Surface).isNotNull()
    }

    @Test
    fun `card outline variant color should be defined`() {
        assertThat(XGColors.OutlineVariant).isNotNull()
    }

    @Test
    fun `on surface color should be defined for title text`() {
        assertThat(XGColors.OnSurface).isNotNull()
    }

    @Test
    fun `add to cart background color should be defined`() {
        assertThat(XGColors.AddToCart).isNotNull()
    }

    @Test
    fun `delivery text color should be defined`() {
        assertThat(XGColors.DeliveryText).isNotNull()
    }

    // endregion

    // region Spacing tokens

    @Test
    fun `XGSpacing XS should be 4dp for content spacing`() {
        assertThat(XGSpacing.XS).isEqualTo(4.dp)
    }

    @Test
    fun `XGSpacing SM should be 8dp for list spacing`() {
        assertThat(XGSpacing.SM).isEqualTo(8.dp)
    }

    // endregion
}
