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
import androidx.compose.ui.graphics.Color
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

// components.json: XGCard.productFeatured / productStandard
private val FeaturedCardWidth = 160.dp
private val StandardCardWidth = 170.dp
private val CardCornerRadius = 10.dp
private val CardPadding = 8.dp
private val TitleFontSize = 12.sp
private const val TITLE_MAX_LINES = 2
private val DeliveryLabelFontSize = 10.sp
private val AddToCartButtonSize = 38.dp
private val AddToCartIconSize = 16.dp
private val AddToCartCornerRadius = 19.dp
private val AddToCartIconColor = Color(0xFF333333)
private val BorderWidth = 1.dp

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
    priceSize: XGPriceSize = XGPriceSize.Default,
    strikethroughFontSize: Float = 15.18f,
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(CardCornerRadius),
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
                priceSize = priceSize,
                strikethroughFontSize = strikethroughFontSize,
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
                .clip(RoundedCornerShape(CardCornerRadius)),
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
    priceSize: XGPriceSize,
    strikethroughFontSize: Float,
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
            lineHeight = 16.sp,
        )

        Spacer(modifier = Modifier.height(XGSpacing.XS))
        XGPriceText(
            price = price,
            originalPrice = originalPrice,
            size = priceSize,
            strikethroughFontSize = strikethroughFontSize,
        )

        if (rating != null) {
            Spacer(modifier = Modifier.height(XGSpacing.XS))
            XGRatingBar(
                rating = rating,
                showValue = false,
                reviewCount = reviewCount,
            )
        }

        if (deliveryLabel != null) {
            Spacer(modifier = Modifier.height(XGSpacing.XS))
            DeliveryLabelText(deliveryLabel = deliveryLabel)
        }

        if (onAddToCartClick != null) {
            Spacer(modifier = Modifier.height(CardPadding))
            Box(modifier = Modifier.fillMaxWidth()) {
                IconButton(
                    onClick = onAddToCartClick,
                    modifier = Modifier
                        .size(AddToCartButtonSize)
                        .clip(RoundedCornerShape(AddToCartCornerRadius))
                        .align(Alignment.CenterEnd),
                    colors = IconButtonDefaults.iconButtonColors(
                        containerColor = XGColors.AddToCart,
                    ),
                ) {
                    Icon(
                        imageVector = Icons.Outlined.AddShoppingCart,
                        contentDescription = null,
                        modifier = Modifier.size(AddToCartIconSize),
                        tint = AddToCartIconColor,
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(CardPadding))
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
            lineHeight = 14.sp,
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
            lineHeight = 14.sp,
        )
    }
}

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
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
                color = XGColors.OnSurface,
            )
            if (subtitle != null) {
                Spacer(modifier = Modifier.height(XGSpacing.XS))
                Text(
                    text = subtitle,
                    fontFamily = PoppinsFontFamily,
                    fontSize = 12.sp,
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
            isWishlisted = true,
            onWishlistToggle = {},
            deliveryLabel = "Order before **23:59**, delivered **Monday**",
            onAddToCartClick = {},
            onClick = {},
            priceSize = XGPriceSize.Standard,
            strikethroughFontSize = 14f,
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
