package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGElevation
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

private val ButtonSize = 32.dp
private val IconSize = 16.dp

@Composable
fun XGWishlistButton(
    isWishlisted: Boolean,
    onToggle: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val contentDescription = if (isWishlisted) {
        stringResource(R.string.common_remove_from_wishlist)
    } else {
        stringResource(R.string.common_add_to_wishlist)
    }

    val icon = if (isWishlisted) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder
    val tint = if (isWishlisted) XGColors.BrandPrimary else XGColors.OnSurfaceVariant

    IconButton(
        onClick = onToggle,
        modifier = modifier
            .size(ButtonSize)
            .shadow(elevation = XGElevation.Level2, shape = CircleShape)
            .clip(CircleShape),
        colors = IconButtonDefaults.iconButtonColors(
            containerColor = MaterialTheme.colorScheme.surface,
        ),
    ) {
        Icon(
            imageVector = icon,
            contentDescription = contentDescription,
            modifier = Modifier.size(IconSize),
            tint = tint,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGWishlistButtonInactivePreview() {
    XGTheme {
        XGWishlistButton(isWishlisted = false, onToggle = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun XGWishlistButtonActivePreview() {
    XGTheme {
        XGWishlistButton(isWishlisted = true, onToggle = {})
    }
}
