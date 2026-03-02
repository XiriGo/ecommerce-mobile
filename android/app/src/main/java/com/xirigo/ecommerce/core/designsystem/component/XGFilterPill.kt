package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/*
 * Token source: shared/design-tokens/components/molecules/xg-filter-pill.json
 * Wraps XGFilterChip (DQ-18) with dismiss capability and horizontal list variant.
 */

/** Height from token `tokens.height` = 36. */
private val FilterPillHeight = 36.dp

/** Corner radius from token `tokens.cornerRadius` = 18 (half of height). */
private val FilterPillCornerRadius = 18.dp

/** Icon size from `$foundations/spacing.layout.iconSize.small` = 16. */
private val IconSize = 16.dp

/** Data model for a single filter pill item. */
@Immutable
data class XGFilterPillItem(
    val label: String,
    val isSelected: Boolean,
)

/**
 * A single filter pill with optional dismiss (X) button.
 *
 * Wraps [XGFilterChip] with filter-specific behavior:
 * - **Selected state**: filled background + leading checkmark icon
 * - **Unselected state**: outlined border + inactive colors
 * - **Dismiss**: trailing X icon when [selected] is `true` AND [onDismiss] is provided
 *
 * @param label Display text for the pill.
 * @param selected Whether the pill is in the selected state.
 * @param onClick Callback invoked when the pill is tapped.
 * @param modifier Modifier to apply to this composable.
 * @param onDismiss Optional callback for the dismiss (X) button; only shown when [selected] is `true`.
 */
@Composable
fun XGFilterPill(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    onDismiss: (() -> Unit)? = null,
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
        modifier = modifier.height(FilterPillHeight),
        shape = RoundedCornerShape(FilterPillCornerRadius),
        leadingIcon = if (selected) {
            {
                Icon(
                    imageVector = Icons.Filled.Check,
                    contentDescription = null,
                    modifier = Modifier.size(IconSize),
                )
            }
        } else {
            null
        },
        trailingIcon = if (selected && onDismiss != null) {
            {
                IconButton(
                    onClick = onDismiss,
                    modifier = Modifier.size(IconSize),
                ) {
                    Icon(
                        imageVector = Icons.Filled.Close,
                        contentDescription = stringResource(
                            R.string.common_filter_pill_dismiss_a11y,
                            label,
                        ),
                        modifier = Modifier.size(IconSize),
                    )
                }
            }
        } else {
            null
        },
        colors = FilterChipDefaults.filterChipColors(
            containerColor = XGColors.FilterPillBackground,
            labelColor = XGColors.FilterPillText,
            iconColor = XGColors.FilterPillText,
            selectedContainerColor = XGColors.FilterPillBackgroundActive,
            selectedLabelColor = XGColors.FilterPillTextActive,
            selectedLeadingIconColor = XGColors.FilterPillTextActive,
            selectedTrailingIconColor = XGColors.FilterPillTextActive,
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

/**
 * Horizontally scrollable row of [XGFilterPill] items.
 *
 * @param items List of pill data (label + selection state).
 * @param onSelect Callback invoked with the item index when a pill is tapped.
 * @param modifier Modifier to apply to the row.
 * @param onDismiss Optional callback invoked with the item index when a dismiss button is tapped.
 * @param contentPadding Padding around the row content.
 */
@Composable
fun XGFilterPillRow(
    items: List<XGFilterPillItem>,
    onSelect: (index: Int) -> Unit,
    modifier: Modifier = Modifier,
    onDismiss: ((index: Int) -> Unit)? = null,
    contentPadding: PaddingValues = PaddingValues(horizontal = XGSpacing.Base),
) {
    LazyRow(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        contentPadding = contentPadding,
    ) {
        itemsIndexed(items) { index, item ->
            XGFilterPill(
                label = item.label,
                selected = item.isSelected,
                onClick = { onSelect(index) },
                onDismiss = onDismiss?.let { callback -> { callback(index) } },
            )
        }
    }
}

// region Previews

@Preview(showBackground = true)
@Composable
private fun XGFilterPillUnselectedPreview() {
    XGTheme {
        XGFilterPill(
            label = "Electronics",
            selected = false,
            onClick = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGFilterPillSelectedPreview() {
    XGTheme {
        XGFilterPill(
            label = "Electronics",
            selected = true,
            onClick = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGFilterPillSelectedWithDismissPreview() {
    XGTheme {
        XGFilterPill(
            label = "Electronics",
            selected = true,
            onClick = {},
            onDismiss = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGFilterPillRowPreview() {
    XGTheme {
        XGFilterPillRow(
            items = listOf(
                XGFilterPillItem(label = "All", isSelected = true),
                XGFilterPillItem(label = "Electronics", isSelected = false),
                XGFilterPillItem(label = "Fashion", isSelected = true),
                XGFilterPillItem(label = "Home", isSelected = false),
                XGFilterPillItem(label = "Sports", isSelected = false),
            ),
            onSelect = {},
            onDismiss = {},
            modifier = Modifier.padding(vertical = XGSpacing.SM),
        )
    }
}

// endregion
