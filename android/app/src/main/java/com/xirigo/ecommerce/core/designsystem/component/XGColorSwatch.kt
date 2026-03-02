package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/*
 * Token source: shared/design-tokens/components/atoms/xg-color-swatch.json
 */

/** Overall diameter of the swatch circle (token `size` = 40). */
private val SwatchSize = 40.dp

/** Stroke width of the selection ring (token `selectedRingWidth` = 2). */
private val SelectedRingWidth = 2.dp

/** Gap between the swatch edge and the selection ring (token `selectedRingGap` = 3). */
private val SelectedRingGap = 3.dp

/** Width of the always-visible border (token `whiteBorderWidth` = 1). */
private val WhiteBorderWidth = 1.dp

/** Icon size for the checkmark overlay. */
private val CheckmarkSize = 16.dp

/** Luminance threshold for choosing dark vs light checkmark. */
private const val LUMINANCE_THRESHOLD = 0.6f

/** Total outer diameter including the ring and gap on both sides. */
private val TotalSize = SwatchSize + (SelectedRingGap + SelectedRingWidth) * 2

/** Returns the appropriate checkmark tint for the given swatch [color]. */
private fun checkmarkTint(color: Color): Color =
    if (color.luminance() > LUMINANCE_THRESHOLD) XGColors.OnSurface else XGColors.OnPrimary

/**
 * Circular color swatch with optional selection state.
 *
 * When [isSelected] is `true`, a branded ring surrounds the swatch and a
 * checkmark icon is overlaid at the centre. The checkmark colour adapts
 * automatically based on the luminance of [color] so it remains visible
 * against both light and dark swatches.
 *
 * @param color The fill colour of the swatch.
 * @param isSelected Whether this swatch is currently selected.
 * @param onClick Callback invoked when the swatch is tapped.
 * @param colorName Human-readable colour name used for accessibility.
 * @param modifier Optional [Modifier] applied to the outer container.
 */
@Composable
fun XGColorSwatch(
    color: Color,
    isSelected: Boolean,
    onClick: () -> Unit,
    colorName: String,
    modifier: Modifier = Modifier,
) {
    val description = swatchDescription(isSelected, colorName)

    val ringAlpha by animateFloatAsState(
        targetValue = if (isSelected) 1f else 0f,
        animationSpec = XGMotion.Easing.standardTween(),
        label = "ringAlpha",
    )

    val animatedRingColor by animateColorAsState(
        targetValue = if (isSelected) XGColors.Primary else Color.Transparent,
        animationSpec = XGMotion.Easing.standardTween(),
        label = "ringColor",
    )

    Box(
        modifier = modifier
            .size(TotalSize)
            .semantics(mergeDescendants = true) {
                contentDescription = description
                role = Role.RadioButton
                selected = isSelected
            }
            .clickable(onClick = onClick)
            .clip(CircleShape),
        contentAlignment = Alignment.Center,
    ) {
        SelectionRing(ringColor = animatedRingColor, ringAlpha = ringAlpha)
        SwatchCircle(color = color, isSelected = isSelected)
    }
}

/** Accessibility description for the swatch. */
@Composable
private fun swatchDescription(isSelected: Boolean, colorName: String): String = if (isSelected) {
    stringResource(R.string.common_color_swatch_selected_a11y, colorName)
} else {
    stringResource(R.string.common_color_swatch_a11y, colorName)
}

/** Outer selection ring that animates in/out. */
@Composable
private fun SelectionRing(ringColor: Color, ringAlpha: Float) {
    Box(
        modifier = Modifier
            .size(TotalSize)
            .border(
                width = SelectedRingWidth,
                color = ringColor.copy(alpha = ringAlpha),
                shape = CircleShape,
            ),
    )
}

/** Inner filled circle with border and optional checkmark overlay. */
@Composable
private fun SwatchCircle(color: Color, isSelected: Boolean) {
    Box(
        modifier = Modifier
            .size(SwatchSize)
            .clip(CircleShape)
            .background(color)
            .border(
                width = WhiteBorderWidth,
                color = XGColors.Outline,
                shape = CircleShape,
            ),
        contentAlignment = Alignment.Center,
    ) {
        if (isSelected) {
            Icon(
                imageVector = Icons.Filled.Check,
                contentDescription = null,
                modifier = Modifier.size(CheckmarkSize),
                tint = checkmarkTint(color),
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGColorSwatchUnselectedPreview() {
    XGTheme {
        Row(
            modifier = Modifier.padding(XGSpacing.Base),
            horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            XGColorSwatch(
                color = Color(0xFF1D1D1B),
                isSelected = false,
                onClick = {},
                colorName = "Black",
            )
            XGColorSwatch(
                color = Color(0xFFEF4444),
                isSelected = false,
                onClick = {},
                colorName = "Red",
            )
            XGColorSwatch(
                color = Color(0xFFFFFFFF),
                isSelected = false,
                onClick = {},
                colorName = "White",
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGColorSwatchSelectedDarkPreview() {
    XGTheme {
        Row(
            modifier = Modifier.padding(XGSpacing.Base),
            horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            XGColorSwatch(
                color = Color(0xFF1D1D1B),
                isSelected = true,
                onClick = {},
                colorName = "Black",
            )
            XGColorSwatch(
                color = Color(0xFF3B82F6),
                isSelected = true,
                onClick = {},
                colorName = "Blue",
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGColorSwatchSelectedLightPreview() {
    XGTheme {
        Row(
            modifier = Modifier.padding(XGSpacing.Base),
            horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            XGColorSwatch(
                color = Color(0xFFFFFFFF),
                isSelected = true,
                onClick = {},
                colorName = "White",
            )
            XGColorSwatch(
                color = Color(0xFF22C55E),
                isSelected = true,
                onClick = {},
                colorName = "Green",
            )
        }
    }
}
