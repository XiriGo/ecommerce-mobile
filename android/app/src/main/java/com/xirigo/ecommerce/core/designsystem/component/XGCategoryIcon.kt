package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Devices
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.core.designsystem.theme.PoppinsFontFamily
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// components.json: XGCategoryIcon
private val TileSize = 79.dp
private val IconSize = 40.dp
private val LabelSpacing = 6.dp
private val LabelFontSize = 12.sp
private val LabelLineHeight = 16.sp

/** Category icon tile with colored background, icon, and label text. */
@Composable
fun XGCategoryIcon(
    name: String,
    icon: ImageVector,
    backgroundColor: androidx.compose.ui.graphics.Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .widthIn(max = TileSize)
            .clickable(onClick = onClick),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            modifier = Modifier
                .size(TileSize)
                .clip(RoundedCornerShape(XGCornerRadius.Medium))
                .background(backgroundColor),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(IconSize),
                tint = XGColors.IconOnDark,
            )
        }
        Spacer(modifier = Modifier.height(LabelSpacing))
        Text(
            text = name,
            fontFamily = PoppinsFontFamily,
            fontSize = LabelFontSize,
            fontWeight = FontWeight.Medium,
            color = XGColors.OnSurface,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            lineHeight = LabelLineHeight,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGCategoryIconPreview() {
    XGTheme {
        XGCategoryIcon(
            name = "Electronics",
            icon = Icons.Outlined.Devices,
            backgroundColor = XGColors.CategoryBlue,
            onClick = {},
        )
    }
}
