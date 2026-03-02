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
import androidx.compose.ui.draw.alpha
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

// Reserved heights for uniform card sizing (reserveSpace strategy)
// Token source: spacing.json > starRating.starSize (12) + gap
private val ReservedRatingHeight = 16.dp

// Token source: xg-product-card.json > deliveryLabelSubComponent.lineHeight
private val ReservedDeliveryHeight = 14.dp

// Token source: xg-product-card.json > addToCartSubComponent.size
private val ReservedAddToCartHeight = 38.dp

// Skeleton line height for title placeholder
private val SkeletonTitleLineSmallHeight = 12.dp
private const val SKELETON_PRICE_LINE_WIDTH = 0.6f
private const val SKELETON_RATING_LINE_WIDTH = 0.4f

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
    priceSize: XGPriceSize = XGPriceSize.Default,
    strikethroughFontSize: Float = 15.18f,
    priceLayout: XGPriceLayout = XGPriceLayout.Inline,
    showRatingAbovePrice: Boolean = false,
    showDeliveryAbovePrice: Boolean = false,
    reserveSpace: Boolean = false,
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
                priceSize = priceSize,
                strikethroughFontSize = strikethroughFontSize,
                priceLayout = priceLayout,
                showRatingAbovePrice = showRatingAbovePrice,
                showDeliveryAbovePrice = showDeliveryAbovePrice,
                reserveSpace = reserveSpace,
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
    priceSize: XGPriceSize,
    strikethroughFontSize: Float,
    priceLayout: XGPriceLayout,
    showRatingAbovePrice: Boolean,
    showDeliveryAbovePrice: Boolean,
    reserveSpace: Boolean,
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
            RatingSection(
                rating = rating,
                reviewCount = reviewCount,
                reserveSpace = reserveSpace,
            )
        }

        if (showDeliveryAbovePrice) {
            DeliverySection(
                deliveryLabel = deliveryLabel,
                reserveSpace = reserveSpace,
            )
            PriceWithCartRow(
                price = price,
                originalPrice = originalPrice,
                priceSize = priceSize,
                strikethroughFontSize = strikethroughFontSize,
                priceLayout = priceLayout,
                onAddToCartClick = onAddToCartClick,
                reserveSpace = reserveSpace,
            )
        } else {
            Spacer(modifier = Modifier.height(XGSpacing.XS))
            XGPriceText(
                price = price,
                originalPrice = originalPrice,
                size = priceSize,
                strikethroughFontSize = strikethroughFontSize,
                layout = priceLayout,
            )
            if (!showRatingAbovePrice) {
                RatingSection(
                    rating = rating,
                    reviewCount = reviewCount,
                    reserveSpace = reserveSpace,
                )
            }
            DeliverySection(
                deliveryLabel = deliveryLabel,
                reserveSpace = reserveSpace,
            )
            StandaloneCartSection(
                onAddToCartClick = onAddToCartClick,
                reserveSpace = reserveSpace,
            )
        }

        Spacer(modifier = Modifier.height(CardPadding))
    }
}

@Composable
private fun RatingSection(
    rating: Float?,
    reviewCount: Int?,
    reserveSpace: Boolean = false,
) {
    if (rating != null) {
        Spacer(modifier = Modifier.height(XGSpacing.XS))
        XGRatingBar(rating = rating, showValue = false, reviewCount = reviewCount)
    } else if (reserveSpace) {
        Spacer(modifier = Modifier.height(XGSpacing.XS))
        Spacer(modifier = Modifier.height(ReservedRatingHeight))
    }
}

@Composable
private fun DeliverySection(deliveryLabel: String?, reserveSpace: Boolean = false) {
    if (deliveryLabel != null) {
        Spacer(modifier = Modifier.height(XGSpacing.XS))
        DeliveryLabelText(deliveryLabel = deliveryLabel)
    } else if (reserveSpace) {
        Spacer(modifier = Modifier.height(XGSpacing.XS))
        Spacer(modifier = Modifier.height(ReservedDeliveryHeight))
    }
}

@Composable
private fun PriceWithCartRow(
    price: String,
    originalPrice: String?,
    priceSize: XGPriceSize,
    strikethroughFontSize: Float,
    priceLayout: XGPriceLayout,
    onAddToCartClick: (() -> Unit)?,
    reserveSpace: Boolean = false,
) {
    Spacer(modifier = Modifier.height(XGSpacing.XS))
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.Bottom,
    ) {
        XGPriceText(
            price = price,
            originalPrice = originalPrice,
            size = priceSize,
            strikethroughFontSize = strikethroughFontSize,
            layout = priceLayout,
        )
        Spacer(modifier = Modifier.weight(1f))
        if (onAddToCartClick != null) {
            AddToCartButton(onClick = onAddToCartClick)
        } else if (reserveSpace) {
            Spacer(modifier = Modifier.size(AddToCartButtonSize).alpha(0f))
        }
    }
}

@Composable
private fun StandaloneCartSection(onAddToCartClick: (() -> Unit)?, reserveSpace: Boolean = false) {
    if (onAddToCartClick != null) {
        Spacer(modifier = Modifier.height(CardPadding))
        Box(modifier = Modifier.fillMaxWidth()) {
            AddToCartButton(
                onClick = onAddToCartClick,
                modifier = Modifier.align(Alignment.CenterEnd),
            )
        }
    } else if (reserveSpace) {
        Spacer(modifier = Modifier.height(CardPadding))
        Spacer(modifier = Modifier.height(ReservedAddToCartHeight))
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

/** Skeleton loading placeholder that mirrors the [XGProductCard] layout. */
@Composable
fun ProductCardSkeleton(modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(XGCornerRadius.Medium),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp),
        colors = CardDefaults.cardColors(containerColor = XGColors.Surface),
        border = BorderStroke(BorderWidth, XGColors.OutlineVariant),
    ) {
        Column {
            // Image area: 1:1 aspect ratio
            SkeletonBox(
                width = 0.dp,
                height = 0.dp,
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(1f)
                    .padding(CardPadding),
            )

            // Content area
            Column(
                modifier = Modifier.padding(horizontal = CardPadding),
                verticalArrangement = Arrangement.spacedBy(XGSpacing.XS),
            ) {
                // Title line 1 (full width)
                SkeletonLine(
                    width = 0.dp,
                    modifier = Modifier.fillMaxWidth(),
                )
                // Title line 2 (80% width)
                SkeletonLine(
                    width = 0.dp,
                    modifier = Modifier.fillMaxWidth(fraction = 0.8f),
                )
                // Price line (60% width)
                SkeletonLine(
                    width = 0.dp,
                    modifier = Modifier.fillMaxWidth(fraction = SKELETON_PRICE_LINE_WIDTH),
                )
                // Rating line (40% width)
                SkeletonLine(
                    width = 0.dp,
                    height = SkeletonTitleLineSmallHeight,
                    modifier = Modifier.fillMaxWidth(fraction = SKELETON_RATING_LINE_WIDTH),
                )
                Spacer(modifier = Modifier.height(CardPadding))
            }
        }
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
            priceSize = XGPriceSize.Standard,
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
private fun ProductCardSkeletonPreview() {
    XGTheme {
        ProductCardSkeleton(modifier = Modifier.width(StandardCardWidth))
    }
}

@Preview(showBackground = true)
@Composable
private fun ProductCardSkeletonAndRealPreview() {
    XGTheme {
        Row(
            modifier = Modifier.padding(XGSpacing.SM),
            horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            ProductCardSkeleton(modifier = Modifier.width(FeaturedCardWidth))
            XGProductCard(
                imageUrl = null,
                title = "Premium Wireless Headphones",
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
}

@Preview(showBackground = true)
@Composable
private fun ProductCardUniformHeightPreview() {
    XGTheme {
        Row(
            modifier = Modifier.padding(XGSpacing.SM),
            horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            // Card with all optional content
            XGProductCard(
                imageUrl = null,
                title = "Product With Rating & Delivery",
                price = "9.99",
                rating = 3.5f,
                reviewCount = 42,
                deliveryLabel = "Order before **23:59**, delivered **Monday**",
                onAddToCartClick = {},
                onClick = {},
                priceSize = XGPriceSize.Standard,
                priceLayout = XGPriceLayout.Stacked,
                showRatingAbovePrice = true,
                showDeliveryAbovePrice = true,
                reserveSpace = true,
                modifier = Modifier.weight(1f),
            )
            // Card with NO optional content (but reserveSpace = true)
            XGProductCard(
                imageUrl = null,
                title = "Minimal Product",
                price = "4.99",
                onClick = {},
                priceSize = XGPriceSize.Standard,
                priceLayout = XGPriceLayout.Stacked,
                showRatingAbovePrice = true,
                showDeliveryAbovePrice = true,
                reserveSpace = true,
                modifier = Modifier.weight(1f),
            )
        }
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
