package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@Composable
fun XGQuantityStepper(
    quantity: Int,
    onQuantityChange: (Int) -> Unit,
    modifier: Modifier = Modifier,
    minQuantity: Int = 1,
    maxQuantity: Int = 99,
) {
    val decreaseDescription = stringResource(R.string.common_decrease_quantity)
    val increaseDescription = stringResource(R.string.common_increase_quantity)
    val quantityDescription = stringResource(R.string.common_quantity_value, quantity)

    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
    ) {
        IconButton(
            onClick = { onQuantityChange(quantity - 1) },
            enabled = quantity > minQuantity,
            modifier = Modifier.size(XGSpacing.MinTouchTarget),
        ) {
            Icon(
                imageVector = Icons.Filled.Remove,
                contentDescription = decreaseDescription,
            )
        }

        Text(
            text = quantity.toString(),
            style = MaterialTheme.typography.titleMedium,
            modifier = Modifier.semantics { contentDescription = quantityDescription },
        )

        IconButton(
            onClick = { onQuantityChange(quantity + 1) },
            enabled = quantity < maxQuantity,
            modifier = Modifier.size(XGSpacing.MinTouchTarget),
        ) {
            Icon(
                imageVector = Icons.Filled.Add,
                contentDescription = increaseDescription,
            )
        }
    }
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
