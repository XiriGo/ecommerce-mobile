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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGElevation
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

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
                .aspectRatio(16f / 9f),
        )

        if (onWishlistToggle != null) {
            WishlistButton(
                isWishlisted = isWishlisted,
                onToggle = onWishlistToggle,
                modifier = Modifier.align(Alignment.TopEnd),
            )
        }
    }
}

@Composable
private fun WishlistButton(
    isWishlisted: Boolean,
    onToggle: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val wishlistDescription = if (isWishlisted) {
        stringResource(R.string.common_remove_from_wishlist)
    } else {
        stringResource(R.string.common_add_to_wishlist)
    }

    val icon = if (isWishlisted) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder
    val tint = if (isWishlisted) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface

    IconButton(onClick = onToggle, modifier = modifier) {
        Icon(
            imageVector = icon,
            contentDescription = wishlistDescription,
            tint = tint,
        )
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
) {
    Column(modifier = Modifier.padding(XGSpacing.CardPadding)) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
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
