package com.xirigo.ecommerce.core.designsystem.component

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
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@Composable
fun XGPriceText(
    price: String,
    modifier: Modifier = Modifier,
    originalPrice: String? = null,
    currencySymbol: String = "EUR",
    size: XGPriceSize = XGPriceSize.Medium,
) {
    val priceStyle: TextStyle
    val originalPriceStyle: TextStyle

    when (size) {
        XGPriceSize.Small -> {
            priceStyle = MaterialTheme.typography.bodySmall
            originalPriceStyle = MaterialTheme.typography.labelSmall
        }
        XGPriceSize.Medium -> {
            priceStyle = MaterialTheme.typography.titleMedium
            originalPriceStyle = MaterialTheme.typography.bodySmall
        }
        XGPriceSize.Large -> {
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
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = formattedPrice,
            style = priceStyle,
            color = if (originalPrice != null) XGColors.PriceSale else XGColors.PriceRegular,
        )

        if (formattedOriginalPrice != null) {
            Text(
                text = formattedOriginalPrice,
                style = originalPriceStyle.copy(textDecoration = TextDecoration.LineThrough),
                color = XGColors.PriceOriginal,
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextRegularPreview() {
    XGTheme {
        XGPriceText(price = "29.99")
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextSalePreview() {
    XGTheme {
        XGPriceText(price = "29.99", originalPrice = "39.99")
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextLargePreview() {
    XGTheme {
        XGPriceText(price = "199.99", originalPrice = "249.99", size = XGPriceSize.Large)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextSmallPreview() {
    XGTheme {
        XGPriceText(price = "9.99", size = XGPriceSize.Small)
    }
}
