package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.core.designsystem.theme.PoppinsFontFamily
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGElevation
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

/** Tappable search bar placeholder that navigates to search screen on click. */
@Composable
fun XGSearchBar(
    hint: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(XGCornerRadius.Medium),
        elevation = CardDefaults.cardElevation(defaultElevation = XGElevation.Level1),
        colors = CardDefaults.cardColors(
            containerColor = XGColors.SurfaceVariant,
        ),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = XGSpacing.Base, vertical = XGSpacing.MD),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                imageVector = Icons.Outlined.Search,
                contentDescription = null,
                tint = XGColors.OnSurfaceVariant,
            )
            Spacer(modifier = Modifier.width(XGSpacing.SM))
            Text(
                text = hint,
                style = XGTypography.bodyLarge,
                fontFamily = PoppinsFontFamily,
                color = XGColors.OnSurfaceVariant,
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGSearchBarPreview() {
    XGTheme {
        XGSearchBar(
            hint = "Search products, brands, categories...",
            onClick = {},
            modifier = Modifier.padding(XGSpacing.Base),
        )
    }
}
