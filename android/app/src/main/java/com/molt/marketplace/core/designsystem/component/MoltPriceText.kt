package com.molt.marketplace.core.designsystem.component

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.tooling.preview.Preview
import com.molt.marketplace.R
import com.molt.marketplace.core.designsystem.theme.MoltColors
import com.molt.marketplace.core.designsystem.theme.MoltSpacing
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Composable
fun MoltPriceText(
    price: String,
    modifier: Modifier = Modifier,
    originalPrice: String? = null,
    currencySymbol: String = "EUR",
    size: MoltPriceSize = MoltPriceSize.Medium,
) {
    val priceStyle: TextStyle
    val originalPriceStyle: TextStyle

    when (size) {
        MoltPriceSize.Small -> {
            priceStyle = MaterialTheme.typography.bodySmall
            originalPriceStyle = MaterialTheme.typography.labelSmall
        }
        MoltPriceSize.Medium -> {
            priceStyle = MaterialTheme.typography.titleMedium
            originalPriceStyle = MaterialTheme.typography.bodySmall
        }
        MoltPriceSize.Large -> {
            priceStyle = MaterialTheme.typography.headlineSmall
            originalPriceStyle = MaterialTheme.typography.bodyMedium
        }
    }

    val formattedPrice = "$currencySymbol $price"
    val formattedOriginalPrice = originalPrice?.let { "$currencySymbol $it" }

    val accessibilityDescription = if (formattedOriginalPrice != null) {
        stringResource(R.string.common_sale_price_label, formattedPrice, formattedOriginalPrice)
    } else {
        stringResource(R.string.common_price_label, formattedPrice)
    }

    Row(
        modifier = modifier.semantics { contentDescription = accessibilityDescription },
        horizontalArrangement = Arrangement.spacedBy(MoltSpacing.SM),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = formattedPrice,
            style = priceStyle,
            color = if (originalPrice != null) MoltColors.PriceSale else MoltColors.PriceRegular,
        )

        if (formattedOriginalPrice != null) {
            Text(
                text = formattedOriginalPrice,
                style = originalPriceStyle.copy(textDecoration = TextDecoration.LineThrough),
                color = MoltColors.PriceOriginal,
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltPriceTextRegularPreview() {
    MoltTheme {
        MoltPriceText(price = "29.99")
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltPriceTextSalePreview() {
    MoltTheme {
        MoltPriceText(price = "29.99", originalPrice = "39.99")
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltPriceTextLargePreview() {
    MoltTheme {
        MoltPriceText(price = "199.99", originalPrice = "249.99", size = MoltPriceSize.Large)
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltPriceTextSmallPreview() {
    MoltTheme {
        MoltPriceText(price = "9.99", size = MoltPriceSize.Small)
    }
}
