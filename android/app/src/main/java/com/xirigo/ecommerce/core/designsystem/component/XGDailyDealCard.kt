package com.xirigo.ecommerce.core.designsystem.component

import kotlinx.coroutines.delay
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.PoppinsFontFamily
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Token source: components/molecules/xg-daily-deal-card.json
private val CardHeight = 163.dp
private val CardPadding = 16.dp
private val BadgeFontSize = 12.sp
private val BadgePaddingHorizontal = 10.dp
private val BadgePaddingVertical = 4.dp
private val TitleFontSize = 20.sp
private val TitleLineHeight = 28.sp
private val CountdownFontSize = 12.sp
private val BadgeLineHeight = 16.sp
private val CountdownLineHeight = 16.sp
private val StrikethroughFontSize = 15.18.sp
private val ProductImageSize = 100.dp
private const val TITLE_MAX_LINES = 2
private const val COUNTDOWN_DELAY_MS = 1000L
private const val MILLIS_PER_SECOND = 1000L
private const val SECONDS_PER_MINUTE = 60L
private const val MINUTES_PER_HOUR = 60L

// gradients.json: dailyDealCard (linear leftToRight TextDark -> BrandPrimary)
private val DailyDealGradient = Brush.horizontalGradient(
    colorStops = arrayOf(
        0.0f to XGColors.TextDark,
        1.0f to XGColors.BrandPrimary,
    ),
)

/**
 * Daily deal promotional card with countdown timer, gradient background, and pricing.
 *
 * Image loading delegates to [XGImage] which provides animated shimmer while loading
 * and a branded fallback on error (inherited from DQ-07). Countdown ticks every second
 * via [LaunchedEffect] + [delay] and displays HH:MM:SS or the localized expired text.
 *
 * Token source: `components/molecules/xg-daily-deal-card.json`
 *
 * @param title Product title, truncated to 2 lines.
 * @param price Formatted deal price string.
 * @param originalPrice Formatted original price string (shown with strikethrough).
 * @param endTime Epoch millis when the deal ends.
 * @param modifier Modifier applied to the root container.
 * @param imageUrl Optional product image URL. Shimmer is shown while loading.
 * @param onClick Optional click handler; card is non-interactive when `null`.
 */
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
    val endedText = stringResource(R.string.home_daily_deal_ended)
    val badgeText = stringResource(R.string.home_daily_deal_badge)
    var remainingMillis by remember { mutableLongStateOf(endTime - System.currentTimeMillis()) }

    LaunchedEffect(endTime) {
        while (remainingMillis > 0) {
            delay(COUNTDOWN_DELAY_MS)
            remainingMillis = endTime - System.currentTimeMillis()
        }
    }

    val countdownText = formatCountdown(remainingMillis, endedText)
    val clickModifier = if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier
    val a11yLabel = "$badgeText: $title, $price, $countdownText"

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(CardHeight)
            .clip(RoundedCornerShape(XGCornerRadius.Medium))
            .background(DailyDealGradient)
            .then(clickModifier)
            .padding(CardPadding)
            .semantics { contentDescription = a11yLabel },
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
            ) {
                // DAILY DEAL badge (secondary style)
                Box(
                    modifier = Modifier
                        .background(
                            color = XGColors.BadgeSecondaryBackground,
                            shape = RoundedCornerShape(XGCornerRadius.Medium),
                        )
                        .padding(horizontal = BadgePaddingHorizontal, vertical = BadgePaddingVertical),
                ) {
                    Text(
                        text = badgeText,
                        fontFamily = PoppinsFontFamily,
                        fontSize = BadgeFontSize,
                        fontWeight = FontWeight.SemiBold,
                        color = XGColors.BadgeSecondaryText,
                        lineHeight = BadgeLineHeight,
                    )
                }

                // Product title
                Text(
                    text = title,
                    fontFamily = PoppinsFontFamily,
                    fontSize = TitleFontSize,
                    fontWeight = FontWeight.SemiBold,
                    color = XGColors.TextOnDark,
                    maxLines = TITLE_MAX_LINES,
                    overflow = TextOverflow.Ellipsis,
                    lineHeight = TitleLineHeight,
                )

                // Countdown timer (monospaced per token spec)
                Text(
                    text = countdownText,
                    fontFamily = FontFamily.Monospace,
                    fontSize = CountdownFontSize,
                    fontWeight = FontWeight.Normal,
                    color = XGColors.TextOnDark,
                    lineHeight = CountdownLineHeight,
                )

                // Price row
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
                ) {
                    XGPriceText(
                        price = price,
                        size = XGPriceSize.Deal,
                    )
                    Text(
                        text = originalPrice,
                        fontFamily = PoppinsFontFamily,
                        fontSize = StrikethroughFontSize,
                        fontWeight = FontWeight.Medium,
                        color = XGColors.PriceStrikethrough,
                        textDecoration = TextDecoration.LineThrough,
                    )
                }
            }

            Spacer(modifier = Modifier.width(XGSpacing.MD))

            // Product image — shimmer + crossfade inherited from XGImage (DQ-07)
            XGImage(
                url = imageUrl,
                contentDescription = title,
                modifier = Modifier
                    .size(ProductImageSize)
                    .clip(RoundedCornerShape(XGCornerRadius.Medium)),
            )
        }
    }
}

private fun formatCountdown(remainingMillis: Long, endedText: String): String {
    if (remainingMillis <= 0) return endedText
    val totalSeconds = remainingMillis / MILLIS_PER_SECOND
    val hours = totalSeconds / (MINUTES_PER_HOUR * SECONDS_PER_MINUTE)
    val minutes = totalSeconds % (MINUTES_PER_HOUR * SECONDS_PER_MINUTE) / SECONDS_PER_MINUTE
    val seconds = totalSeconds % SECONDS_PER_MINUTE
    return String.format(java.util.Locale.ROOT, "%02d:%02d:%02d", hours, minutes, seconds)
}

@Preview(showBackground = true, name = "XGDailyDealCard Active")
@Composable
private fun XGDailyDealCardPreview() {
    XGTheme {
        XGDailyDealCard(
            title = "Nike Air Zoom Pegasus",
            price = "89.99",
            originalPrice = "\u20AC149,99",
            endTime = System.currentTimeMillis() + 28_800_000L,
            onClick = {},
        )
    }
}

@Preview(showBackground = true, name = "XGDailyDealCard Expired")
@Composable
private fun XGDailyDealCardExpiredPreview() {
    XGTheme {
        XGDailyDealCard(
            title = "Expired Deal Product",
            price = "49.99",
            originalPrice = "\u20AC99,99",
            endTime = System.currentTimeMillis() - 60_000L,
        )
    }
}
