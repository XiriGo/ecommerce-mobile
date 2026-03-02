package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Animatable
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Token source: components/atoms/xg-wishlist-button.json
private val ButtonSize = 32.dp
private val ButtonIconSize = 16.dp
private val ButtonCornerRadius = 16.dp
private val ButtonElevation = 2.dp

/** Peak scale for the spring bounce effect on toggle. */
private const val BOUNCE_SCALE = 1.2f

/**
 * Toggle button for wishlist state with heart icon.
 *
 * Motion tokens (from `XGMotion`):
 * - Color transition: `XGMotion.Easing.standardTween(XGMotion.Duration.INSTANT)` (100ms)
 * - Scale bounce: `XGMotion.Easing.springSpec()` (dampingRatio=0.7, stiffness=Medium)
 */
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

    val animatedTint by animateColorAsState(
        targetValue = if (isWishlisted) XGColors.BrandPrimary else XGColors.OnSurfaceVariant,
        animationSpec = XGMotion.Easing.standardTween(XGMotion.Duration.INSTANT),
        label = "wishlistTint",
    )

    val scaleAnimatable = remember { Animatable(1f) }
    LaunchedEffect(isWishlisted) {
        scaleAnimatable.snapTo(BOUNCE_SCALE)
        scaleAnimatable.animateTo(
            targetValue = 1f,
            animationSpec = XGMotion.Easing.springSpec(),
        )
    }

    val shape = RoundedCornerShape(ButtonCornerRadius)

    IconButton(
        onClick = onToggle,
        modifier = modifier
            .size(ButtonSize)
            .shadow(elevation = ButtonElevation, shape = shape)
            .clip(shape)
            .scale(scaleAnimatable.value),
        colors = IconButtonDefaults.iconButtonColors(
            containerColor = XGColors.Surface,
        ),
    ) {
        Icon(
            imageVector = icon,
            contentDescription = contentDescription,
            modifier = Modifier.size(ButtonIconSize),
            tint = animatedTint,
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
