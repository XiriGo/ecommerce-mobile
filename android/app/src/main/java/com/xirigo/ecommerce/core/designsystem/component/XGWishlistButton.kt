package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// components.json: XGWishlistButton
private val ButtonSize = 32.dp
private val ButtonIconSize = 16.dp
private val ButtonCornerRadius = 16.dp
private val ButtonElevation = 2.dp

/** Toggle button for wishlist state with heart icon. */
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

    val shape = RoundedCornerShape(ButtonCornerRadius)

    IconButton(
        onClick = onToggle,
        modifier = modifier
            .size(ButtonSize)
            .shadow(elevation = ButtonElevation, shape = shape)
            .clip(shape),
        colors = IconButtonDefaults.iconButtonColors(
            containerColor = XGColors.Surface,
        ),
    ) {
        Icon(
            imageVector = icon,
            contentDescription = contentDescription,
            modifier = Modifier.size(ButtonIconSize),
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
