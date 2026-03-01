package com.xirigo.ecommerce.core.designsystem.component

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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AddShoppingCart
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGElevation
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

private val AddToCartButtonSize = 32.dp
private val AddToCartIconSize = 16.dp
private val DeliveryLabelFontSize = 10.sp

@Composable
fun XGProductCard(
    imageUrl: String?,
    title: String,
    price: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    originalPrice: String? = null,
    vendorName: String? = null,
    rating: Float? = null,
    reviewCount: Int? = null,
    isWishlisted: Boolean = false,
    onWishlistToggle: (() -> Unit)? = null,
    deliveryLabel: String? = null,
    onAddToCartClick: (() -> Unit)? = null,
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(XGCornerRadius.Medium),
        elevation = CardDefaults.cardElevation(defaultElevation = XGElevation.Level1),
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
                vendorName = vendorName,
                rating = rating,
                reviewCount = reviewCount,
                deliveryLabel = deliveryLabel,
                onAddToCartClick = onAddToCartClick,
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
    Box {
        XGImage(
            url = imageUrl,
            contentDescription = title,
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1f),
        )

        if (onWishlistToggle != null) {
            XGWishlistButton(
                isWishlisted = isWishlisted,
                onToggle = onWishlistToggle,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(XGSpacing.SM),
            )
        }
    }
}

@Composable
private fun ProductCardDetailsSection(
    title: String,
    price: String,
    originalPrice: String?,
    vendorName: String?,
    rating: Float?,
    reviewCount: Int?,
    deliveryLabel: String? = null,
    onAddToCartClick: (() -> Unit)? = null,
) {
    Column(modifier = Modifier.padding(XGSpacing.SM)) {
        Text(
            text = title,
            style = MaterialTheme.typography.labelMedium,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )

        if (vendorName != null) {
            Spacer(modifier = Modifier.height(XGSpacing.XS))
            Text(
                text = vendorName,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }

        Spacer(modifier = Modifier.height(XGSpacing.XS))
        XGPriceText(
            price = price,
            originalPrice = originalPrice,
        )

        if (rating != null) {
            Spacer(modifier = Modifier.height(XGSpacing.XS))
            XGRatingBar(
                rating = rating,
                showValue = true,
                reviewCount = reviewCount,
            )
        }

        if (deliveryLabel != null) {
            Spacer(modifier = Modifier.height(XGSpacing.XS))
            Text(
                text = deliveryLabel,
                style = MaterialTheme.typography.labelSmall.copy(fontSize = DeliveryLabelFontSize),
                color = XGColors.BrandSecondary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }

        if (onAddToCartClick != null) {
            Spacer(modifier = Modifier.height(XGSpacing.SM))
            Box(modifier = Modifier.fillMaxWidth()) {
                IconButton(
                    onClick = onAddToCartClick,
                    modifier = Modifier
                        .size(AddToCartButtonSize)
                        .clip(CircleShape)
                        .align(Alignment.CenterEnd),
                    colors = IconButtonDefaults.iconButtonColors(
                        containerColor = XGColors.BrandSecondary,
                    ),
                ) {
                    Icon(
                        imageVector = Icons.Outlined.AddShoppingCart,
                        contentDescription = null,
                        modifier = Modifier.size(AddToCartIconSize),
                        tint = Color.White,
                    )
                }
            }
        }
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
        elevation = CardDefaults.cardElevation(defaultElevation = XGElevation.Level1),
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
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
            )
            if (subtitle != null) {
                Spacer(modifier = Modifier.height(XGSpacing.XS))
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
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
private fun XGProductCardPreview() {
    XGTheme {
        XGProductCard(
            imageUrl = null,
            title = "Premium Wireless Headphones with Noise Cancellation",
            price = "29.99",
            originalPrice = "39.99",
            vendorName = "TechStore",
            rating = 4.5f,
            reviewCount = 123,
            isWishlisted = false,
            onWishlistToggle = {},
            onClick = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGProductCardWishlistedPreview() {
    XGTheme {
        XGProductCard(
            imageUrl = null,
            title = "Simple Product",
            price = "9.99",
            isWishlisted = true,
            onWishlistToggle = {},
            onClick = {},
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
