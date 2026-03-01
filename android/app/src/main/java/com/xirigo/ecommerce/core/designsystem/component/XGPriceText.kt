package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Arrangement
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

// components.json: XGPriceText
private val DefaultCurrencyFontSize = 22.78.sp
private val DefaultIntegerFontSize = 27.33.sp
private val DefaultDecimalFontSize = 18.98.sp
private val SmallCurrencyFontSize = 14.sp
private val SmallIntegerFontSize = 18.sp
private val SmallDecimalFontSize = 14.sp
private val StrikethroughFontSize = 15.18.sp

@Composable
fun XGPriceText(
    price: String,
    modifier: Modifier = Modifier,
    originalPrice: String? = null,
    currencySymbol: String = "\u20AC",
    size: XGPriceSize = XGPriceSize.Default,
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

    Row(
        modifier = modifier.semantics { contentDescription = accessibilityDescription },
        horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        verticalAlignment = Alignment.Bottom,
    ) {
        // 3-part price: currency + integer + decimal
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

        // Strikethrough original price
        if (originalPrice != null) {
            val origParts = splitPrice(originalPrice)
            Text(
                text = "$currencySymbol${origParts.first},${origParts.second}",
                style = TextStyle(
                    fontFamily = PoppinsFontFamily,
                    fontWeight = FontWeight.Medium,
                    fontSize = StrikethroughFontSize,
                    textDecoration = TextDecoration.LineThrough,
                    color = XGColors.PriceStrikethrough,
                ),
            )
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

@Preview(showBackground = true)
@Composable
private fun XGPriceTextDefaultPreview() {
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
private fun XGPriceTextSmallPreview() {
    XGTheme {
        XGPriceText(price = "9.99", size = XGPriceSize.Small)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGPriceTextDealPreview() {
    XGTheme {
        XGPriceText(price = "89.99", originalPrice = "149.99", size = XGPriceSize.Deal)
    }
}
