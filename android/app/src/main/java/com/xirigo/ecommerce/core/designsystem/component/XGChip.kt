package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/*
 * Token source: shared/design-tokens/components/atoms/xg-chip.json
 */

/** Height from token `variants.filter.height` = 36. */
private val FilterChipHeight = 36.dp

/** Corner radius from token `variants.filter.cornerRadius` = 18 (half of height). */
private val FilterChipCornerRadius = 18.dp

/** Icon size from `$foundations/spacing.layout.iconSize.small` = 16. */
private val SelectedIconSize = 16.dp

/** Icon size for category chip from `$foundations/spacing.layout.iconSize.medium` = 24. */
private val CategoryIconSize = 24.dp

/** Selectable filter chip with optional leading icon and check mark. */
@Composable
fun XGFilterChip(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    leadingIcon: ImageVector? = null,
) {
    FilterChip(
        selected = selected,
        onClick = onClick,
        label = {
            Text(
                text = label,
                style = MaterialTheme.typography.bodyMedium,
            )
        },
        modifier = modifier.height(FilterChipHeight),
        shape = RoundedCornerShape(FilterChipCornerRadius),
        leadingIcon = if (selected) {
            {
                Icon(
                    imageVector = Icons.Filled.Check,
                    contentDescription = null,
                    modifier = Modifier.size(SelectedIconSize),
                )
            }
        } else {
            leadingIcon?.let {
                {
                    Icon(
                        imageVector = it,
                        contentDescription = null,
                        modifier = Modifier.size(SelectedIconSize),
                    )
                }
            }
        },
        colors = FilterChipDefaults.filterChipColors(
            containerColor = XGColors.FilterPillBackground,
            labelColor = XGColors.FilterPillText,
            iconColor = XGColors.FilterPillText,
            selectedContainerColor = XGColors.FilterPillBackgroundActive,
            selectedLabelColor = XGColors.FilterPillTextActive,
            selectedLeadingIconColor = XGColors.FilterPillTextActive,
        ),
        border = if (selected) {
            null
        } else {
            FilterChipDefaults.filterChipBorder(
                enabled = true,
                selected = false,
                borderColor = XGColors.Outline,
                selectedBorderColor = Color.Transparent,
                borderWidth = 1.dp,
                selectedBorderWidth = 0.dp,
            )
        },
    )
}

/** Category chip with optional leading icon loaded from URL. */
@Composable
fun XGCategoryChip(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    iconUrl: String? = null,
) {
    FilterChip(
        selected = false,
        onClick = onClick,
        label = {
            Text(
                text = label,
                style = MaterialTheme.typography.labelLarge,
            )
        },
        modifier = modifier,
        shape = RoundedCornerShape(FilterChipCornerRadius),
        leadingIcon = iconUrl?.let {
            {
                XGImage(
                    url = it,
                    contentDescription = null,
                    modifier = Modifier.size(CategoryIconSize),
                )
            }
        },
        colors = FilterChipDefaults.filterChipColors(
            containerColor = XGColors.SurfaceTertiary,
            labelColor = XGColors.OnSurface,
            iconColor = XGColors.OnSurface,
        ),
        border = FilterChipDefaults.filterChipBorder(
            enabled = true,
            selected = false,
            borderColor = Color.Transparent,
            selectedBorderColor = Color.Transparent,
            borderWidth = 0.dp,
            selectedBorderWidth = 0.dp,
        ),
    )
}

@Preview(showBackground = true)
@Composable
private fun XGFilterChipUnselectedPreview() {
    XGTheme {
        XGFilterChip(label = "Electronics", selected = false, onClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun XGFilterChipSelectedPreview() {
    XGTheme {
        XGFilterChip(label = "Electronics", selected = true, onClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun XGCategoryChipPreview() {
    XGTheme {
        XGCategoryChip(label = "Shoes", onClick = {})
    }
}
