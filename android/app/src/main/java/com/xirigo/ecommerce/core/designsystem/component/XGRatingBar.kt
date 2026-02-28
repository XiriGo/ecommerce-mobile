package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.StarHalf
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@Composable
fun XGRatingBar(
    rating: Float,
    modifier: Modifier = Modifier,
    maxRating: Int = 5,
    starSize: Dp = 16.dp,
    showValue: Boolean = false,
    reviewCount: Int? = null,
) {
    val ratingDescription = stringResource(R.string.common_rating_description, rating, maxRating)
    val reviewsDescription = reviewCount?.let {
        stringResource(R.string.common_reviews_count, it)
    }.orEmpty()

    Row(
        modifier = modifier.semantics {
            contentDescription = "$ratingDescription $reviewsDescription".trim()
        },
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.XXS),
    ) {
        RatingStars(rating = rating, maxRating = maxRating, starSize = starSize)

        RatingValueText(rating = rating, showValue = showValue)

        if (reviewCount != null) {
            Text(
                text = "($reviewCount)",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun RatingStars(
    rating: Float,
    maxRating: Int,
    starSize: Dp,
) {
    for (i in 1..maxRating) {
        val icon = when {
            rating >= i.toFloat() -> Icons.Filled.Star
            rating >= i.toFloat() - 0.5f -> Icons.AutoMirrored.Filled.StarHalf
            else -> Icons.Outlined.StarOutline
        }

        val tint = if (rating >= i.toFloat() - 0.5f) {
            XGColors.RatingStarFilled
        } else {
            XGColors.RatingStarEmpty
        }

        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(starSize),
            tint = tint,
        )
    }
}

@Composable
private fun RatingValueText(rating: Float, showValue: Boolean) {
    if (showValue) {
        Spacer(modifier = Modifier.width(XGSpacing.XS))
        Text(
            text = String.format(java.util.Locale.ROOT, "%.1f", rating),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGRatingBarPreview() {
    XGTheme {
        XGRatingBar(rating = 4.5f, showValue = true, reviewCount = 123)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGRatingBarLowPreview() {
    XGTheme {
        XGRatingBar(rating = 2.0f)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGRatingBarFullPreview() {
    XGTheme {
        XGRatingBar(rating = 5.0f, showValue = true)
    }
}
