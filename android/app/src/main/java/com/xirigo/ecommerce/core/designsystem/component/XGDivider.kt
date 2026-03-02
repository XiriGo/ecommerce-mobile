package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// ---------------------------------------------------------------------------
// XGDivider
// ---------------------------------------------------------------------------

/**
 * Design-system divider component.
 *
 * Token source: `components/atoms/xg-divider.json`.
 * - Default color: [XGColors.Divider] (`#E5E7EB`)
 * - Default thickness: 1 dp
 *
 * Feature screens **must** use this instead of raw `HorizontalDivider`.
 */
@Composable
fun XGDivider(
    modifier: Modifier = Modifier,
    color: Color = XGColors.Divider,
    thickness: Dp = DividerConstants.DefaultThickness,
) {
    HorizontalDivider(
        modifier = modifier,
        thickness = thickness,
        color = color,
    )
}

// ---------------------------------------------------------------------------
// XGLabeledDivider
// ---------------------------------------------------------------------------

/**
 * Divider with a centered text label (line — label — line).
 *
 * Token source: `components/atoms/xg-divider.json` (withLabel variant).
 * - Label font: captionMedium (12 sp Medium) via `MaterialTheme.typography.labelMedium`
 * - Label color: [XGColors.TextTertiary] (`#9CA3AF`)
 * - Label horizontal padding: 16 dp
 * - Line color: [XGColors.Divider] (`#E5E7EB`)
 *
 * Usage: "OR CONTINUE WITH" on the Login screen.
 */
@Composable
fun XGLabeledDivider(
    label: String,
    modifier: Modifier = Modifier,
    color: Color = XGColors.Divider,
    thickness: Dp = DividerConstants.DefaultThickness,
) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        HorizontalDivider(
            modifier = Modifier.weight(1f),
            thickness = thickness,
            color = color,
        )
        Text(
            text = label,
            modifier = Modifier.padding(horizontal = DividerConstants.LabelHorizontalPadding),
            style = MaterialTheme.typography.labelMedium,
            color = XGColors.TextTertiary,
        )
        HorizontalDivider(
            modifier = Modifier.weight(1f),
            thickness = thickness,
            color = color,
        )
    }
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/** Component-level constants from xg-divider.json token spec. */
private object DividerConstants {
    val DefaultThickness = 1.dp
    val LabelHorizontalPadding = 16.dp
}

// ---------------------------------------------------------------------------
// Previews
// ---------------------------------------------------------------------------

@Preview(showBackground = true)
@Composable
private fun XGDividerPreview() {
    XGTheme {
        XGDivider(
            modifier = Modifier.padding(horizontal = XGSpacing.Base),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGLabeledDividerPreview() {
    XGTheme {
        XGLabeledDivider(
            label = "OR CONTINUE WITH",
            modifier = Modifier.padding(horizontal = XGSpacing.Base),
        )
    }
}
