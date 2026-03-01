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
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

private val BannerHeight = 133.dp

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
        Canvas(modifier = Modifier.fillMaxSize()) {
            val canvasWidth = size.width
            val canvasHeight = size.height
            val stripeWidth = canvasWidth * 0.12f

            val leftPath = Path().apply {
                moveTo(0f, 0f)
                lineTo(stripeWidth, 0f)
                lineTo(stripeWidth * 1.5f, canvasHeight)
                lineTo(stripeWidth * 0.5f, canvasHeight)
                close()
            }
            drawPath(leftPath, XGColors.FlashSaleAccentBlue)

            val rightPath = Path().apply {
                moveTo(canvasWidth - stripeWidth * 1.5f, 0f)
                lineTo(canvasWidth - stripeWidth * 0.5f, 0f)
                lineTo(canvasWidth, canvasHeight)
                lineTo(canvasWidth - stripeWidth, canvasHeight)
                close()
            }
            drawPath(rightPath, XGColors.FlashSaleAccentPink)
        }

        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            if (imageUrl != null) {
                XGImage(
                    url = imageUrl,
                    contentDescription = null,
                    modifier = Modifier
                        .height(50.dp)
                        .fillMaxWidth(0.4f),
                )
            }
            Text(
                text = title,
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold,
                color = XGColors.FlashSaleText,
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
