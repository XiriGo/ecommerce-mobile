package com.molt.marketplace.core.designsystem.component

import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Composable
fun MoltFilterChip(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    leadingIcon: ImageVector? = null,
) {
    FilterChip(
        selected = selected,
        onClick = onClick,
        label = { Text(text = label) },
        modifier = modifier,
        leadingIcon = if (selected) {
            {
                Icon(
                    imageVector = Icons.Filled.Check,
                    contentDescription = null,
                    modifier = Modifier.size(FilterChipDefaults.IconSize),
                )
            }
        } else {
            leadingIcon?.let {
                {
                    Icon(
                        imageVector = it,
                        contentDescription = null,
                        modifier = Modifier.size(FilterChipDefaults.IconSize),
                    )
                }
            }
        },
        colors = FilterChipDefaults.filterChipColors(
            selectedContainerColor = MaterialTheme.colorScheme.secondaryContainer,
            selectedLabelColor = MaterialTheme.colorScheme.onSecondaryContainer,
            selectedLeadingIconColor = MaterialTheme.colorScheme.onSecondaryContainer,
        ),
    )
}

@Composable
fun MoltCategoryChip(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    iconUrl: String? = null,
) {
    FilterChip(
        selected = false,
        onClick = onClick,
        label = { Text(text = label) },
        modifier = modifier,
        leadingIcon = iconUrl?.let {
            {
                MoltImage(
                    url = it,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp),
                )
            }
        },
    )
}

@Preview(showBackground = true)
@Composable
private fun MoltFilterChipUnselectedPreview() {
    MoltTheme {
        MoltFilterChip(label = "Electronics", selected = false, onClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltFilterChipSelectedPreview() {
    MoltTheme {
        MoltFilterChip(label = "Electronics", selected = true, onClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltCategoryChipPreview() {
    MoltTheme {
        MoltCategoryChip(label = "Shoes", onClick = {})
    }
}
