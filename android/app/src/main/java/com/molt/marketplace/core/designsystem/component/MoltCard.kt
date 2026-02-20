package com.molt.marketplace.core.designsystem.component

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
import com.molt.marketplace.R
import com.molt.marketplace.core.designsystem.theme.MoltCornerRadius
import com.molt.marketplace.core.designsystem.theme.MoltElevation
import com.molt.marketplace.core.designsystem.theme.MoltSpacing
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Composable
@Suppress("ktlint:standard:function-naming", "CognitiveComplexMethod")
fun MoltProductCard(
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
        shape = RoundedCornerShape(MoltCornerRadius.Medium),
        elevation = CardDefaults.cardElevation(defaultElevation = MoltElevation.Level1),
    ) {
        Column {
            Box {
                MoltImage(
                    url = imageUrl,
                    contentDescription = title,
                    modifier = Modifier
                        .fillMaxWidth()
                        .aspectRatio(16f / 9f),
                )

                if (onWishlistToggle != null) {
                    val wishlistDescription = if (isWishlisted) {
                        stringResource(R.string.common_remove_from_wishlist)
                    } else {
                        stringResource(R.string.common_add_to_wishlist)
                    }

                    IconButton(
                        onClick = onWishlistToggle,
                        modifier = Modifier.align(Alignment.TopEnd),
                    ) {
                        Icon(
                            imageVector = if (isWishlisted) {
                                Icons.Filled.Favorite
                            } else {
                                Icons.Outlined.FavoriteBorder
                            },
                            contentDescription = wishlistDescription,
                            tint = if (isWishlisted) {
                                MaterialTheme.colorScheme.error
                            } else {
                                MaterialTheme.colorScheme.onSurface
                            },
                        )
                    }
                }
            }

            Column(modifier = Modifier.padding(MoltSpacing.CardPadding)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )

                if (vendorName != null) {
                    Spacer(modifier = Modifier.height(MoltSpacing.XS))
                    Text(
                        text = vendorName,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }

                Spacer(modifier = Modifier.height(MoltSpacing.XS))
                MoltPriceText(
                    price = price,
                    originalPrice = originalPrice,
                )

                if (rating != null) {
                    Spacer(modifier = Modifier.height(MoltSpacing.XS))
                    MoltRatingBar(
                        rating = rating,
                        showValue = true,
                        reviewCount = reviewCount,
                    )
                }
            }
        }
    }
}

@Composable
@Suppress("ktlint:standard:function-naming", "CognitiveComplexMethod")
fun MoltInfoCard(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    leadingIcon: ImageVector? = null,
    trailingContent: @Composable (() -> Unit)? = null,
    onClick: (() -> Unit)? = null,
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .then(
                if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier,
            ),
        shape = RoundedCornerShape(MoltCornerRadius.Medium),
        elevation = CardDefaults.cardElevation(defaultElevation = MoltElevation.Level1),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(MoltSpacing.CardPadding),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MoltSpacing.MD),
        ) {
            if (leadingIcon != null) {
                Icon(
                    imageVector = leadingIcon,
                    contentDescription = null,
                    modifier = Modifier.size(MoltSpacing.LG),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                )
                if (subtitle != null) {
                    Spacer(modifier = Modifier.height(MoltSpacing.XS))
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
}

@Preview(showBackground = true)
@Composable
@Suppress("ktlint:standard:function-naming")
private fun MoltProductCardPreview() {
    MoltTheme {
        MoltProductCard(
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
@Suppress("ktlint:standard:function-naming")
private fun MoltProductCardWishlistedPreview() {
    MoltTheme {
        MoltProductCard(
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
@Suppress("ktlint:standard:function-naming")
private fun MoltInfoCardPreview() {
    MoltTheme {
        MoltInfoCard(
            title = "Shipping Address",
            subtitle = "123 Main St, Valletta",
        )
    }
}
