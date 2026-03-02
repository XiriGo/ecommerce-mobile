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
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/** Arrow icon size from token spec: `arrowIconSize = 12`. */
private val ArrowIconSize = 12.dp

/**
 * Section header with title, optional subtitle, and optional "See All" action.
 *
 * Token source: `shared/design-tokens/components/atoms/xg-section-header.json`
 *
 * @param title Section title text — rendered in `XGTypography.titleMedium` (18sp SemiBold).
 * @param modifier Optional [Modifier] for the root row.
 * @param subtitle Optional subtitle — rendered in `XGTypography.labelLarge` (14sp Medium).
 * @param onSeeAllClick If non-null, displays a "See All" action link with arrow icon.
 */
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
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(XGSpacing.XXS),
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                color = XGColors.OnSurface,
            )
            if (subtitle != null) {
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.labelLarge,
                    color = XGColors.OnSurfaceVariant,
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
                    modifier = Modifier.size(ArrowIconSize),
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
