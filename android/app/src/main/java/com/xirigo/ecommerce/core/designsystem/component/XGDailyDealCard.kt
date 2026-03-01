package com.xirigo.ecommerce.core.designsystem.component

import kotlinx.coroutines.delay
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

private val CardHeight = 163.dp
private val BadgeFontSize = 12.sp
private val TitleFontSize = 20.sp
private val CountdownFontSize = 12.sp
private val PriceFontSize = 20.sp
private val OriginalPriceFontSize = 14.sp
private const val COUNTDOWN_DELAY_MS = 1000L
private const val MILLIS_PER_SECOND = 1000L
private const val SECONDS_PER_MINUTE = 60L
private const val MINUTES_PER_HOUR = 60L

private val DailyDealGradient = Brush.horizontalGradient(
    colorStops = arrayOf(
        // gradients.dailyDealCard: #111827 → #6000FE
        0.0f to XGColors.TextDark,
        1.0f to XGColors.BrandPrimary,
    ),
)

@Composable
fun XGDailyDealCard(
    title: String,
    price: String,
    originalPrice: String,
    endTime: Long,
    modifier: Modifier = Modifier,
    imageUrl: String? = null,
    onClick: (() -> Unit)? = null,
) {
    var remainingMillis by remember { mutableLongStateOf(endTime - System.currentTimeMillis()) }

    LaunchedEffect(endTime) {
        while (remainingMillis > 0) {
            delay(COUNTDOWN_DELAY_MS)
            remainingMillis = endTime - System.currentTimeMillis()
        }
    }

    val clickModifier = if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(CardHeight)
            .clip(RoundedCornerShape(XGCornerRadius.Medium))
            .background(DailyDealGradient)
            .then(clickModifier)
            .padding(XGSpacing.Base),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
            ) {
                Box(
                    modifier = Modifier
                        .background(
                            color = XGColors.BrandSecondary,
                            shape = RoundedCornerShape(XGCornerRadius.Medium),
                        )
                        .padding(horizontal = XGSpacing.SM, vertical = XGSpacing.XS),
                ) {
                    Text(
                        text = stringResource(R.string.home_daily_deal_badge),
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontSize = BadgeFontSize,
                            fontWeight = FontWeight.SemiBold,
                        ),
                        color = XGColors.BrandPrimary,
                    )
                }

                Text(
                    text = title,
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontSize = TitleFontSize,
                        fontWeight = FontWeight.SemiBold,
                    ),
                    color = Color.White,
                    maxLines = 2,
                )

                Text(
                    text = formatCountdown(remainingMillis),
                    style = MaterialTheme.typography.bodySmall.copy(fontSize = CountdownFontSize),
                    color = Color.White,
                )

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
                ) {
                    Text(
                        text = price,
                        style = MaterialTheme.typography.titleLarge.copy(
                            fontSize = PriceFontSize,
                            fontWeight = FontWeight.Bold,
                        ),
                        color = XGColors.BrandSecondary,
                    )
                    Text(
                        text = originalPrice,
                        style = MaterialTheme.typography.bodyMedium.copy(
                            fontSize = OriginalPriceFontSize,
                            textDecoration = TextDecoration.LineThrough,
                        ),
                        color = XGColors.PriceOriginal,
                    )
                }
            }

            Spacer(modifier = Modifier.width(XGSpacing.MD))

            XGImage(
                url = imageUrl,
                contentDescription = title,
                modifier = Modifier
                    .weight(0.6f)
                    .aspectRatio(1f)
                    .clip(RoundedCornerShape(XGCornerRadius.Medium)),
            )
        }
    }
}

private fun formatCountdown(remainingMillis: Long): String {
    if (remainingMillis <= 0) return "ENDED"
    val totalSeconds = remainingMillis / MILLIS_PER_SECOND
    val hours = totalSeconds / (MINUTES_PER_HOUR * SECONDS_PER_MINUTE)
    val minutes = totalSeconds % (MINUTES_PER_HOUR * SECONDS_PER_MINUTE) / SECONDS_PER_MINUTE
    val seconds = totalSeconds % SECONDS_PER_MINUTE
    return String.format(java.util.Locale.ROOT, "%02d:%02d:%02d", hours, minutes, seconds)
}

@Preview(showBackground = true)
@Composable
private fun XGDailyDealCardPreview() {
    XGTheme {
        XGDailyDealCard(
            title = "Nike Air Zoom Pegasus",
            price = "$89.99",
            originalPrice = "$149.99",
            endTime = System.currentTimeMillis() + 28_800_000L,
            onClick = {},
        )
    }
}
