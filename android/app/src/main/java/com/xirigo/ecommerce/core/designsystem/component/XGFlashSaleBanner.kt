package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.PoppinsFontFamily
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Token source: components/molecules/xg-flash-sale-banner.json
private val BannerHeight = 133.dp
private val BadgeFontSize = 14.sp
private val TitleFontSize = 20.sp
private val TitleLineHeight = 28.sp
private const val STRIPE_WIDTH_FRACTION = 0.12f
private const val STRIPE_SHEAR_MULTIPLIER = 1.5f
private const val STRIPE_OFFSET_MULTIPLIER = 0.5f

/** Flash sale promotional banner with decorative diagonal stripes and title text. */
@Composable
fun XGFlashSaleBanner(
    title: String,
    modifier: Modifier = Modifier,
    imageUrl: String? = null,
    onClick: (() -> Unit)? = null,
) {
    val clickModifier = if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(BannerHeight)
            .clip(RoundedCornerShape(XGCornerRadius.Medium))
            .background(XGColors.FlashSaleBackground)
            .then(clickModifier),
        contentAlignment = Alignment.Center,
    ) {
        if (imageUrl != null) {
            XGImage(
                url = imageUrl,
                contentDescription = null,
                modifier = Modifier.fillMaxSize(),
            )
        }

        Canvas(modifier = Modifier.fillMaxSize()) {
            val canvasWidth = size.width
            val canvasHeight = size.height
            val stripeWidth = canvasWidth * STRIPE_WIDTH_FRACTION

            val leftPath = Path().apply {
                moveTo(0f, 0f)
                lineTo(stripeWidth, 0f)
                lineTo(stripeWidth * STRIPE_SHEAR_MULTIPLIER, canvasHeight)
                lineTo(stripeWidth * STRIPE_OFFSET_MULTIPLIER, canvasHeight)
                close()
            }
            drawPath(leftPath, XGColors.FlashSaleAccentBlue)

            val rightPath = Path().apply {
                moveTo(canvasWidth - stripeWidth * STRIPE_SHEAR_MULTIPLIER, 0f)
                lineTo(canvasWidth - stripeWidth * STRIPE_OFFSET_MULTIPLIER, 0f)
                lineTo(canvasWidth, canvasHeight)
                lineTo(canvasWidth - stripeWidth, canvasHeight)
                close()
            }
            drawPath(rightPath, XGColors.FlashSaleAccentPink)
        }

        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = stringResource(R.string.home_flash_sale_badge),
                fontFamily = PoppinsFontFamily,
                fontSize = BadgeFontSize,
                fontWeight = FontWeight.Bold,
                color = XGColors.FlashSaleText,
            )
            Text(
                text = title,
                fontFamily = PoppinsFontFamily,
                fontSize = TitleFontSize,
                fontWeight = FontWeight.Bold,
                color = XGColors.FlashSaleText,
                lineHeight = TitleLineHeight,
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGFlashSaleBannerPreview() {
    XGTheme {
        XGFlashSaleBanner(
            title = "Flash Sale - Up to 70% Off!",
            onClick = {},
        )
    }
}
