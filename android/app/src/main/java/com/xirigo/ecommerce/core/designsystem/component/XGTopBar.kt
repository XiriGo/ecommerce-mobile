package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

// ---------------------------------------------------------------------------
// XGTopBarVariant
// ---------------------------------------------------------------------------

/** Style variants for [XGTopBar], matching `components/molecules/xg-top-bar.json`. */
enum class XGTopBarVariant(
    val backgroundColor: Color,
    val contentColor: Color,
) {
    /** Surface: white background, dark text/icons (filter screen, product list). */
    Surface(
        backgroundColor = XGColors.Surface,
        contentColor = XGColors.OnSurface,
    ),

    /** Transparent: clear background, white text/icons (splash, login over gradient). */
    Transparent(
        backgroundColor = Color.Transparent,
        contentColor = XGColors.TextOnDark,
    ),
}

// ---------------------------------------------------------------------------
// Constants from token spec
// ---------------------------------------------------------------------------

/** Top bar height from token spec: `tokens.height = 56`. */
private val TopBarHeight = 56.dp

/** Icon size from token spec: `tokens.iconSize = layout.iconSize.medium = 24`. */
private val TopBarIconSize = 24.dp

// ---------------------------------------------------------------------------
// XGTopBar
// ---------------------------------------------------------------------------

/**
 * Top app bar with title, optional back navigation, and action slots.
 *
 * Token source: `components/molecules/xg-top-bar.json`.
 * - Height: 56dp
 * - Title font: titleLarge (20sp SemiBold Poppins)
 * - Icon size: 24dp (layout.iconSize.medium)
 * - Horizontal padding: 16dp (spacing.base)
 * - Min touch target: 48dp
 */
@Composable
fun XGTopBar(
    title: String,
    modifier: Modifier = Modifier,
    variant: XGTopBarVariant = XGTopBarVariant.Surface,
    onBackClick: (() -> Unit)? = null,
    actions: @Composable RowScope.() -> Unit = {},
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(TopBarHeight)
            .background(variant.backgroundColor)
            .padding(horizontal = XGSpacing.Base),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (onBackClick != null) {
            IconButton(onClick = onBackClick) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = stringResource(R.string.common_navigate_back),
                    modifier = Modifier.size(TopBarIconSize),
                    tint = variant.contentColor,
                )
            }
        }

        Text(
            text = title,
            style = XGTypography.titleLarge,
            color = variant.contentColor,
        )

        Spacer(modifier = Modifier.weight(1f))

        Row(verticalAlignment = Alignment.CenterVertically) {
            actions()
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGTopBarPreview() {
    XGTheme {
        XGTopBar(title = "Products")
    }
}

@Preview(showBackground = true)
@Composable
private fun XGTopBarWithBackPreview() {
    XGTheme {
        XGTopBar(title = "Product Details", onBackClick = {})
    }
}

@Preview(showBackground = true, backgroundColor = 0xFF6000FE)
@Composable
private fun XGTopBarTransparentPreview() {
    XGTheme {
        XGTopBar(
            title = "Login",
            variant = XGTopBarVariant.Transparent,
            onBackClick = {},
        )
    }
}
