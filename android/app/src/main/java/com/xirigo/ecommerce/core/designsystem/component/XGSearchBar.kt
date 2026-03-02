package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

/**
 * Tappable search bar placeholder that navigates to search screen on click.
 *
 * Token source: `shared/design-tokens/components/atoms/xg-search-bar.json`.
 *
 * - Background: [XGColors.InputBackground] (`colors.light.inputBackground`)
 * - Border: [XGColors.OutlineVariant] (`colors.light.borderSubtle`), 1 dp
 * - Corner radius: [XGCornerRadius.Pill] (`cornerRadius.pill` = 28 dp)
 * - Icon: [Icons.Outlined.Search], 24 dp, [XGColors.OnSurfaceVariant]
 * - Placeholder font: [XGTypography.bodyLarge] (16 sp Poppins Regular)
 * - Placeholder color: [XGColors.OnSurfaceVariant] (`colors.light.textSecondary`)
 * - Padding: horizontal = [XGSpacing.MD], vertical = [XGSpacing.MD]
 */
@Composable
fun XGSearchBar(
    hint: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val shape = RoundedCornerShape(XGCornerRadius.Pill)

    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(shape)
            .background(color = XGColors.InputBackground, shape = shape)
            .border(width = 1.dp, color = XGColors.OutlineVariant, shape = shape)
            .clickable(role = Role.Button, onClick = onClick)
            .padding(horizontal = XGSpacing.MD, vertical = XGSpacing.MD),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            imageVector = Icons.Outlined.Search,
            contentDescription = null,
            modifier = Modifier.size(IconSize),
            tint = XGColors.OnSurfaceVariant,
        )
        Spacer(modifier = Modifier.width(XGSpacing.SM))
        Text(
            text = hint,
            style = XGTypography.bodyLarge,
            color = XGColors.OnSurfaceVariant,
        )
    }
}

/** Icon size from `$foundations/spacing.layout.iconSize.medium` (24 dp). */
private val IconSize = 24.dp

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
