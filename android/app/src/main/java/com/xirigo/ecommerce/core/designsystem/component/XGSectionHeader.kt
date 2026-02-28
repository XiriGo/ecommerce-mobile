package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowForward
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

private val SeeAllIconSize = 16.dp

@Composable
fun XGSectionHeader(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    onSeeAllClick: (() -> Unit)? = null,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.onSurface,
            )
            if (subtitle != null) {
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }

        if (onSeeAllClick != null) {
            Row(
                modifier = Modifier
                    .clickable(role = Role.Button, onClick = onSeeAllClick)
                    .padding(vertical = XGSpacing.SM),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = stringResource(R.string.common_see_all),
                    style = MaterialTheme.typography.labelLarge,
                    color = XGColors.BrandPrimary,
                )
                Spacer(modifier = Modifier.width(XGSpacing.XS))
                Icon(
                    imageVector = Icons.AutoMirrored.Outlined.ArrowForward,
                    contentDescription = null,
                    modifier = Modifier.size(SeeAllIconSize),
                    tint = XGColors.BrandPrimary,
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGSectionHeaderPreview() {
    XGTheme {
        XGSectionHeader(title = "Popular Products", onSeeAllClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun XGSectionHeaderWithSubtitlePreview() {
    XGTheme {
        XGSectionHeader(
            title = "Categories",
            subtitle = "Browse by category",
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGSectionHeaderNoActionPreview() {
    XGTheme {
        XGSectionHeader(title = "Daily Deal")
    }
}
