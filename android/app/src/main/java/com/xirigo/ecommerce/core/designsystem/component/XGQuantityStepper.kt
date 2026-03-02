package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * Increment/decrement stepper for item quantity selection.
 *
 * Token source: `components/atoms/xg-quantity-stepper.json`.
 * - Button size: [XGSpacing.MinTouchTarget] (48dp)
 * - Button background: [XGColors.SurfaceTertiary]
 * - Button corner radius: [XGCornerRadius.Medium] (10dp)
 * - Icon size: [StepperConstants.ICON_SIZE] (24dp)
 * - Disabled opacity: [StepperConstants.DISABLED_OPACITY] (0.38f)
 * - Quantity font: titleMedium (16sp Medium)
 * - Quantity min width: [XGSpacing.XL] (24dp)
 * - Spacing: [XGSpacing.MD] (12dp)
 */
@Composable
fun XGQuantityStepper(
    quantity: Int,
    onQuantityChange: (Int) -> Unit,
    modifier: Modifier = Modifier,
    minQuantity: Int = 1,
    maxQuantity: Int = 99,
) {
    val canDecrease = quantity > minQuantity
    val canIncrease = quantity < maxQuantity

    val decreaseDescription = stringResource(R.string.common_decrease_quantity)
    val increaseDescription = stringResource(R.string.common_increase_quantity)
    val quantityDescription = stringResource(R.string.common_quantity_value, quantity)

    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.MD),
    ) {
        IconButton(
            onClick = { onQuantityChange(quantity - 1) },
            enabled = canDecrease,
            modifier = Modifier
                .size(XGSpacing.MinTouchTarget)
                .clip(RoundedCornerShape(XGCornerRadius.Medium))
                .background(XGColors.SurfaceTertiary)
                .alpha(if (canDecrease) 1f else StepperConstants.DISABLED_OPACITY),
            colors = IconButtonDefaults.iconButtonColors(
                contentColor = XGColors.OnSurface,
                disabledContentColor = XGColors.OnSurfaceVariant,
            ),
        ) {
            Icon(
                imageVector = Icons.Filled.Remove,
                contentDescription = decreaseDescription,
                modifier = Modifier.size(StepperConstants.ICON_SIZE),
            )
        }

        Text(
            text = quantity.toString(),
            style = MaterialTheme.typography.titleMedium,
            color = XGColors.OnSurface,
            textAlign = TextAlign.Center,
            modifier = Modifier
                .widthIn(min = XGSpacing.XL)
                .semantics { contentDescription = quantityDescription },
        )

        IconButton(
            onClick = { onQuantityChange(quantity + 1) },
            enabled = canIncrease,
            modifier = Modifier
                .size(XGSpacing.MinTouchTarget)
                .clip(RoundedCornerShape(XGCornerRadius.Medium))
                .background(XGColors.SurfaceTertiary)
                .alpha(if (canIncrease) 1f else StepperConstants.DISABLED_OPACITY),
            colors = IconButtonDefaults.iconButtonColors(
                contentColor = XGColors.OnSurface,
                disabledContentColor = XGColors.OnSurfaceVariant,
            ),
        ) {
            Icon(
                imageVector = Icons.Filled.Add,
                contentDescription = increaseDescription,
                modifier = Modifier.size(StepperConstants.ICON_SIZE),
            )
        }
    }
}

/** Component-level constants from `xg-quantity-stepper.json` token spec. */
private object StepperConstants {
    /** Icon size: `$foundations/spacing.layout.iconSize.medium` = 24dp. */
    val ICON_SIZE = XGSpacing.XL

    /** Opacity applied to buttons when disabled (spec: 0.38). */
    const val DISABLED_OPACITY = 0.38f
}

@Preview(showBackground = true)
@Composable
private fun XGQuantityStepperPreview() {
    XGTheme {
        XGQuantityStepper(quantity = 3, onQuantityChange = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun XGQuantityStepperMinPreview() {
    XGTheme {
        XGQuantityStepper(quantity = 1, onQuantityChange = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun XGQuantityStepperMaxPreview() {
    XGTheme {
        XGQuantityStepper(quantity = 99, onQuantityChange = {})
    }
}
