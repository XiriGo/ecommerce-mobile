package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AddShoppingCart
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.core.designsystem.theme.PoppinsFontFamily
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Token source: components/molecules/xg-product-card.json
private val FeaturedCardWidth = 160.dp
private val StandardCardWidth = 170.dp
private val CardPadding = 8.dp
private val TitleFontSize = 12.sp
private val TitleLineHeight = 16.sp
private val InfoCardTitleFontSize = 16.sp
private val InfoCardSubtitleFontSize = 12.sp
private val DeliveryLabelLineHeight = 14.sp
private const val TITLE_MAX_LINES = 2
private val DeliveryLabelFontSize = 10.sp
private val AddToCartButtonSize = 38.dp
private val AddToCartIconSize = 16.dp
private val AddToCartCornerRadius = 19.dp
private val BorderWidth = 1.dp

/** Product card with image, title, price, rating, delivery label, and optional add-to-cart. */
@Composable
fun XGProductCard(
    imageUrl: String?,
    title: String,
    price: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    originalPrice: String? = null,
    rating: Float? = null,
    reviewCount: Int? = null,
    isWishlisted: Boolean = false,
    onWishlistToggle: (() -> Unit)? = null,
    deliveryLabel: String? = null,
    onAddToCartClick: (() -> Unit)? = null,
    priceStyle: XGPriceStyle = XGPriceStyle.Default,
    strikethroughFontSize: Float = 15.18f,
    priceLayout: XGPriceLayout = XGPriceLayout.Inline,
    showRatingAbovePrice: Boolean = false,
    showDeliveryAbovePrice: Boolean = false,
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(XGCornerRadius.Medium),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp),
        colors = CardDefaults.cardColors(containerColor = XGColors.Surface),
        border = BorderStroke(BorderWidth, XGColors.OutlineVariant),
    ) {
        Column {
            ProductCardImageSection(
                imageUrl = imageUrl,
                title = title,
                isWishlisted = isWishlisted,
                onWishlistToggle = onWishlistToggle,
            )

            ProductCardDetailsSection(
                title = title,
                price = price,
                originalPrice = originalPrice,
                rating = rating,
                reviewCount = reviewCount,
                deliveryLabel = deliveryLabel,
                onAddToCartClick = onAddToCartClick,
                priceStyle = priceStyle,
                strikethroughFontSize = strikethroughFontSize,
                priceLayout = priceLayout,
                showRatingAbovePrice = showRatingAbovePrice,
                showDeliveryAbovePrice = showDeliveryAbovePrice,
            )
        }
    }
}

@Composable
private fun ProductCardImageSection(
    imageUrl: String?,
    title: String,
    isWishlisted: Boolean,
    onWishlistToggle: (() -> Unit)?,
) {
    Box(modifier = Modifier.padding(CardPadding)) {
        XGImage(
            url = imageUrl,
            contentDescription = title,
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
                .clip(RoundedCornerShape(XGCornerRadius.Medium)),
        )

        if (onWishlistToggle != null) {
            XGWishlistButton(
                isWishlisted = isWishlisted,
                onToggle = onWishlistToggle,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(XGSpacing.XS),
            )
        }
    }
}

@Composable
private fun ProductCardDetailsSection(
    title: String,
    price: String,
    originalPrice: String?,
    rating: Float?,
    reviewCount: Int?,
    deliveryLabel: String?,
    onAddToCartClick: (() -> Unit)?,
    priceStyle: XGPriceStyle,
    strikethroughFontSize: Float,
    priceLayout: XGPriceLayout,
    showRatingAbovePrice: Boolean,
    showDeliveryAbovePrice: Boolean,
) {
    Column(modifier = Modifier.padding(horizontal = CardPadding)) {
        Text(
            text = title,
            fontFamily = PoppinsFontFamily,
            fontSize = TitleFontSize,
            fontWeight = FontWeight.SemiBold,
            color = XGColors.OnSurface,
            maxLines = TITLE_MAX_LINES,
            overflow = TextOverflow.Ellipsis,
            lineHeight = TitleLineHeight,
        )

        if (showRatingAbovePrice) {
            RatingSection(rating = rating, reviewCount = reviewCount)
        }

        if (showDeliveryAbovePrice) {
            DeliverySection(deliveryLabel = deliveryLabel)
            PriceWithCartRow(
                price = price,
                originalPrice = originalPrice,
                priceStyle = priceStyle,
                strikethroughFontSize = strikethroughFontSize,
                priceLayout = priceLayout,
                onAddToCartClick = onAddToCartClick,
            )
        } else {
            Spacer(modifier = Modifier.height(XGSpacing.XS))
            XGPriceText(
                price = price,
                originalPrice = originalPrice,
                style = priceStyle,
                strikethroughFontSize = strikethroughFontSize,
                layout = priceLayout,
            )
            if (!showRatingAbovePrice) {
                RatingSection(rating = rating, reviewCount = reviewCount)
            }
            DeliverySection(deliveryLabel = deliveryLabel)
            StandaloneCartSection(onAddToCartClick = onAddToCartClick)
        }

        Spacer(modifier = Modifier.height(CardPadding))
    }
}

@Composable
private fun RatingSection(rating: Float?, reviewCount: Int?) {
    if (rating != null) {
        Spacer(modifier = Modifier.height(XGSpacing.XS))
        XGRatingBar(rating = rating, showValue = false, reviewCount = reviewCount)
    }
}

@Composable
private fun DeliverySection(deliveryLabel: String?) {
    if (deliveryLabel != null) {
        Spacer(modifier = Modifier.height(XGSpacing.XS))
        DeliveryLabelText(deliveryLabel = deliveryLabel)
    }
}

@Composable
private fun PriceWithCartRow(
    price: String,
    originalPrice: String?,
    priceStyle: XGPriceStyle,
    strikethroughFontSize: Float,
    priceLayout: XGPriceLayout,
    onAddToCartClick: (() -> Unit)?,
) {
    Spacer(modifier = Modifier.height(XGSpacing.XS))
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.Bottom,
    ) {
        XGPriceText(
            price = price,
            originalPrice = originalPrice,
            style = priceStyle,
            strikethroughFontSize = strikethroughFontSize,
            layout = priceLayout,
        )
        Spacer(modifier = Modifier.weight(1f))
        if (onAddToCartClick != null) {
            AddToCartButton(onClick = onAddToCartClick)
        }
    }
}

@Composable
private fun StandaloneCartSection(onAddToCartClick: (() -> Unit)?) {
    if (onAddToCartClick != null) {
        Spacer(modifier = Modifier.height(CardPadding))
        Box(modifier = Modifier.fillMaxWidth()) {
            AddToCartButton(
                onClick = onAddToCartClick,
                modifier = Modifier.align(Alignment.CenterEnd),
            )
        }
    }
}

@Composable
private fun AddToCartButton(onClick: () -> Unit, modifier: Modifier = Modifier) {
    IconButton(
        onClick = onClick,
        modifier = modifier
            .size(AddToCartButtonSize)
            .clip(RoundedCornerShape(AddToCartCornerRadius)),
        colors = IconButtonDefaults.iconButtonColors(
            containerColor = XGColors.AddToCart,
        ),
    ) {
        Icon(
            imageVector = Icons.Outlined.AddShoppingCart,
            contentDescription = null,
            modifier = Modifier.size(AddToCartIconSize),
            tint = XGColors.OnSurface,
        )
    }
}

@Composable
private fun DeliveryLabelText(deliveryLabel: String) {
    val boldPattern = "\\*\\*(.+?)\\*\\*".toRegex()
    val matches = boldPattern.findAll(deliveryLabel).toList()

    if (matches.isEmpty()) {
        Text(
            text = deliveryLabel,
            fontFamily = PoppinsFontFamily,
            fontSize = DeliveryLabelFontSize,
            fontWeight = FontWeight.Normal,
            color = XGColors.DeliveryText,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            lineHeight = DeliveryLabelLineHeight,
        )
    } else {
        Text(
            text = buildAnnotatedString {
                var lastIndex = 0
                matches.forEach { match ->
                    append(deliveryLabel.substring(lastIndex, match.range.first))
                    withStyle(SpanStyle(fontWeight = FontWeight.Bold)) {
                        append(match.groupValues[1])
                    }
                    lastIndex = match.range.last + 1
                }
                if (lastIndex < deliveryLabel.length) {
                    append(deliveryLabel.substring(lastIndex))
                }
            },
            fontFamily = PoppinsFontFamily,
            fontSize = DeliveryLabelFontSize,
            fontWeight = FontWeight.Normal,
            color = XGColors.DeliveryText,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            lineHeight = DeliveryLabelLineHeight,
        )
    }
}

/** Informational card with optional leading icon, title, subtitle, and trailing content. */
@Composable
fun XGInfoCard(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    leadingIcon: ImageVector? = null,
    trailingContent: @Composable (() -> Unit)? = null,
    onClick: (() -> Unit)? = null,
) {
    val clickModifier = if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier

    Card(
        modifier = modifier
            .fillMaxWidth()
            .then(clickModifier),
        shape = RoundedCornerShape(XGCornerRadius.Medium),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp),
        colors = CardDefaults.cardColors(containerColor = XGColors.Surface),
        border = BorderStroke(BorderWidth, XGColors.OutlineVariant),
    ) {
        InfoCardContent(
            title = title,
            subtitle = subtitle,
            leadingIcon = leadingIcon,
            trailingContent = trailingContent,
        )
    }
}

@Composable
private fun InfoCardContent(
    title: String,
    subtitle: String?,
    leadingIcon: ImageVector?,
    trailingContent: @Composable (() -> Unit)?,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(XGSpacing.CardPadding),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.MD),
    ) {
        if (leadingIcon != null) {
            Icon(
                imageVector = leadingIcon,
                contentDescription = null,
                modifier = Modifier.size(XGSpacing.LG),
                tint = XGColors.OnSurfaceVariant,
            )
        }

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                fontFamily = PoppinsFontFamily,
                fontSize = InfoCardTitleFontSize,
                fontWeight = FontWeight.Medium,
                color = XGColors.OnSurface,
            )
            if (subtitle != null) {
                Spacer(modifier = Modifier.height(XGSpacing.XS))
                Text(
                    text = subtitle,
                    fontFamily = PoppinsFontFamily,
                    fontSize = InfoCardSubtitleFontSize,
                    fontWeight = FontWeight.Normal,
                    color = XGColors.OnSurfaceVariant,
                )
            }
        }

        if (trailingContent != null) {
            trailingContent()
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGProductCardFeaturedPreview() {
    XGTheme {
        XGProductCard(
            imageUrl = null,
            title = "Premium Wireless Headphones with Noise Cancellation",
            price = "29.99",
            originalPrice = "39.99",
            rating = 4.5f,
            reviewCount = 123,
            isWishlisted = false,
            onWishlistToggle = {},
            onClick = {},
            priceLayout = XGPriceLayout.Stacked,
            showRatingAbovePrice = true,
            modifier = Modifier.width(FeaturedCardWidth),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGProductCardStandardPreview() {
    XGTheme {
        XGProductCard(
            imageUrl = null,
            title = "Simple Product",
            price = "9.99",
            originalPrice = "14.99",
            rating = 3.5f,
            reviewCount = 42,
            isWishlisted = true,
            onWishlistToggle = {},
            deliveryLabel = "Order before **23:59**, delivered **Monday**",
            onAddToCartClick = {},
            onClick = {},
            priceStyle = XGPriceStyle.Standard,
            strikethroughFontSize = 14f,
            priceLayout = XGPriceLayout.Stacked,
            showRatingAbovePrice = true,
            showDeliveryAbovePrice = true,
            modifier = Modifier.width(StandardCardWidth),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGInfoCardPreview() {
    XGTheme {
        XGInfoCard(
            title = "Shipping Address",
            subtitle = "123 Main St, Valletta",
        )
    }
}
