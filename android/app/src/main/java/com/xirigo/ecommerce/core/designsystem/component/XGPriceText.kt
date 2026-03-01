package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.PoppinsFontFamily
import com.xirigo.ecommerce.core.designsystem.theme.SourceSans3FontFamily
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Token source: components/atoms/xg-price-text.json
private val DefaultCurrencyFontSize = 22.78.sp
private val DefaultIntegerFontSize = 27.33.sp
private val DefaultDecimalFontSize = 18.98.sp
private val StandardCurrencyFontSize = 20.sp
private val StandardIntegerFontSize = 20.sp
private val StandardDecimalFontSize = 14.sp
private val SmallCurrencyFontSize = 14.sp
private val SmallIntegerFontSize = 18.sp
private val SmallDecimalFontSize = 14.sp
private val DefaultStrikethroughFontSize = 15.18.sp

/** Formatted price display with currency symbol, integer, and decimal parts. */
@Composable
fun XGPriceText(
    price: String,
    modifier: Modifier = Modifier,
    originalPrice: String? = null,
    currencySymbol: String = "\u20AC",
    size: XGPriceSize = XGPriceSize.Default,
    strikethroughFontSize: Float = DefaultStrikethroughFontSize.value,
    layout: XGPriceLayout = XGPriceLayout.Inline,
) {
    val priceColor: Color
    val currencyFontSize: Float
    val integerFontSize: Float
    val decimalFontSize: Float

    when (size) {
        XGPriceSize.Default -> {
            priceColor = XGColors.PriceSale
            currencyFontSize = DefaultCurrencyFontSize.value
            integerFontSize = DefaultIntegerFontSize.value
            decimalFontSize = DefaultDecimalFontSize.value
        }
        XGPriceSize.Standard -> {
            priceColor = XGColors.PriceSale
            currencyFontSize = StandardCurrencyFontSize.value
            integerFontSize = StandardIntegerFontSize.value
            decimalFontSize = StandardDecimalFontSize.value
        }
        XGPriceSize.Small -> {
            priceColor = XGColors.PriceSale
            currencyFontSize = SmallCurrencyFontSize.value
            integerFontSize = SmallIntegerFontSize.value
            decimalFontSize = SmallDecimalFontSize.value
        }
        XGPriceSize.Deal -> {
            priceColor = XGColors.BrandSecondary
            currencyFontSize = DefaultCurrencyFontSize.value
            integerFontSize = DefaultIntegerFontSize.value
            decimalFontSize = DefaultDecimalFontSize.value
        }
    }

    val parts = splitPrice(price)

    val formattedPrice = "$currencySymbol${parts.first}.${parts.second}"
    val formattedOriginalPrice = originalPrice?.let {
        val origParts = splitPrice(it)
        "$currencySymbol${origParts.first}.${origParts.second}"
    }

    val accessibilityDescription = if (formattedOriginalPrice != null) {
        stringResource(R.string.common_sale_price_label, formattedPrice, formattedOriginalPrice)
    } else {
        stringResource(R.string.common_price_label, formattedPrice)
    }

    val compositePriceText = @Composable {
        Text(
            text = buildAnnotatedString {
                withStyle(
                    SpanStyle(
                        fontFamily = SourceSans3FontFamily,
                        fontWeight = FontWeight.Black,
                        fontSize = currencyFontSize.sp,
                        color = priceColor,
                    ),
                ) {
                    append(currencySymbol)
                }
                withStyle(
                    SpanStyle(
                        fontFamily = SourceSans3FontFamily,
                        fontWeight = FontWeight.Black,
                        fontSize = integerFontSize.sp,
                        color = priceColor,
                    ),
                ) {
                    append(parts.first)
                }
                withStyle(
                    SpanStyle(
                        fontFamily = SourceSans3FontFamily,
                        fontWeight = FontWeight.Black,
                        fontSize = decimalFontSize.sp,
                        color = priceColor,
                    ),
                ) {
                    append(",${parts.second}")
                }
            },
        )
    }

    val strikethroughText = @Composable {
        if (originalPrice != null) {
            val origParts = splitPrice(originalPrice)
            Text(
                text = "$currencySymbol${origParts.first},${origParts.second}",
                style = TextStyle(
                    fontFamily = PoppinsFontFamily,
                    fontWeight = FontWeight.Medium,
                    fontSize = strikethroughFontSize.sp,
                    textDecoration = TextDecoration.LineThrough,
                    color = XGColors.PriceStrikethrough,
                ),
            )
        }
    }

    when (layout) {
        XGPriceLayout.Inline -> {
            Row(
                modifier = modifier.semantics { contentDescription = accessibilityDescription },
                horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
                verticalAlignment = Alignment.Bottom,
            ) {
                compositePriceText()
                strikethroughText()
            }
        }
        XGPriceLayout.Stacked -> {
            Column(
                modifier = modifier.semantics { contentDescription = accessibilityDescription },
            ) {
                strikethroughText()
                compositePriceText()
            }
        }
    }
}

private fun splitPrice(price: String): Pair<String, String> {
    val cleaned = price.replace("[^0-9.,]".toRegex(), "")
    val separator = when {
        cleaned.contains(",") -> ","
        cleaned.contains(".") -> "."
        else -> return Pair(cleaned, "00")
    }
    val parts = cleaned.split(separator)
    val integer = parts.getOrElse(0) { "0" }
    val decimal = parts.getOrElse(1) { "00" }.take(2).padEnd(2, '0')
    return Pair(integer, decimal)
}

private object PreviewPrices {
    const val REGULAR = "29.99"
    const val ORIGINAL = "39.99"
    const val SMALL = "9.99"
    const val DEAL = "89.99"
    const val DEAL_ORIGINAL = "149.99"
    const val STANDARD_STRIKETHROUGH = 14f
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextDefaultPreview() {
    XGTheme {
        XGPriceText(price = PreviewPrices.REGULAR)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextSalePreview() {
    XGTheme {
        XGPriceText(price = PreviewPrices.REGULAR, originalPrice = PreviewPrices.ORIGINAL)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextStandardPreview() {
    XGTheme {
        XGPriceText(
            price = PreviewPrices.REGULAR,
            originalPrice = PreviewPrices.ORIGINAL,
            size = XGPriceSize.Standard,
            strikethroughFontSize = PreviewPrices.STANDARD_STRIKETHROUGH,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextSmallPreview() {
    XGTheme {
        XGPriceText(price = PreviewPrices.SMALL, size = XGPriceSize.Small)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextDealPreview() {
    XGTheme {
        XGPriceText(
            price = PreviewPrices.DEAL,
            originalPrice = PreviewPrices.DEAL_ORIGINAL,
            size = XGPriceSize.Deal,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextStackedPreview() {
    XGTheme {
        XGPriceText(
            price = PreviewPrices.DEAL,
            originalPrice = PreviewPrices.DEAL_ORIGINAL,
            layout = XGPriceLayout.Stacked,
        )
    }
}
