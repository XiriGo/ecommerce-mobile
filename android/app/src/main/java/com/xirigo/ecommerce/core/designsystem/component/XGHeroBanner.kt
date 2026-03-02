package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.core.designsystem.theme.PoppinsFontFamily
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Token source: components/molecules/xg-hero-banner.json
private val BannerHeight = 192.dp
private val TagFontSize = 12.sp
private val TagLineHeight = 16.sp
private val HeadlineFontSize = 24.sp
private val HeadlineLineHeight = 32.sp
private val SubtitleFontSize = 14.sp
private val SubtitleLineHeight = 20.sp
private val BadgePaddingHorizontal = 10.dp
private val BadgePaddingVertical = 4.dp

// gradients.json: heroBannerOverlay (linear leftToRight, derived from BrandPrimary)
private const val OVERLAY_START_ALPHA = 0xE6
private const val OVERLAY_END_ALPHA = 0x00
private val HeroBannerOverlay = Brush.horizontalGradient(
    colorStops = arrayOf(
        0.0f to XGColors.BrandPrimary.copy(alpha = OVERLAY_START_ALPHA / 255f),
        1.0f to XGColors.BrandPrimary.copy(alpha = OVERLAY_END_ALPHA / 255f),
    ),
)

/** Hero banner with optional background image, gradient overlay, tag badge, and text. */
@Composable
fun XGHeroBanner(
    title: String,
    subtitle: String,
    modifier: Modifier = Modifier,
    imageUrl: String? = null,
    tag: String? = null,
    onClick: (() -> Unit)? = null,
) {
    val clickModifier = if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(BannerHeight)
            .clip(RoundedCornerShape(XGCornerRadius.Medium))
            .then(clickModifier),
    ) {
        if (imageUrl != null) {
            XGImage(
                url = imageUrl,
                contentDescription = null,
                modifier = Modifier.fillMaxSize(),
            )
        } else {
            XGBrandGradient(modifier = Modifier.fillMaxSize())
        }

        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(HeroBannerOverlay),
        )

        if (tag != null) {
            Box(
                modifier = Modifier
                    .align(Alignment.TopStart)
                    .padding(XGSpacing.MD)
                    .background(
                        color = XGColors.BadgeSecondaryBackground,
                        shape = RoundedCornerShape(XGCornerRadius.Medium),
                    )
                    .padding(horizontal = BadgePaddingHorizontal, vertical = BadgePaddingVertical),
            ) {
                Text(
                    text = tag,
                    fontFamily = PoppinsFontFamily,
                    fontSize = TagFontSize,
                    fontWeight = FontWeight.SemiBold,
                    color = XGColors.BadgeSecondaryText,
                    lineHeight = TagLineHeight,
                )
            }
        }

        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(XGSpacing.Base),
        ) {
            Text(
                text = title,
                fontFamily = PoppinsFontFamily,
                fontSize = HeadlineFontSize,
                fontWeight = FontWeight.SemiBold,
                color = XGColors.TextOnDark,
                lineHeight = HeadlineLineHeight,
            )
            Spacer(modifier = Modifier.height(XGSpacing.XS))
            Text(
                text = subtitle,
                fontFamily = PoppinsFontFamily,
                fontSize = SubtitleFontSize,
                fontWeight = FontWeight.Normal,
                color = XGColors.TextOnDark,
                lineHeight = SubtitleLineHeight,
            )
        }
    }
}

// Skeleton placeholder dimensions — approximate the text content area
private val SkeletonTagWidth = 80.dp
private val SkeletonHeadlineWidth = 160.dp
private val SkeletonSubtitleWidth = 120.dp

/**
 * Shimmer skeleton placeholder that mirrors the [XGHeroBanner] layout.
 *
 * Displays a full-size shimmer box with overlaid skeleton lines matching
 * the tag badge, headline, and subtitle positions. Use this as the
 * placeholder in a [XGSkeleton] wrapper or loading state.
 *
 * Token source: `components/molecules/xg-hero-banner.json` (skeleton section).
 */
@Composable
fun HeroBannerSkeleton(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(BannerHeight)
            .clip(RoundedCornerShape(XGCornerRadius.Medium)),
    ) {
        // Full background shimmer — width ignored because fillMaxSize overrides
        SkeletonBox(
            width = 0.dp,
            height = BannerHeight,
            modifier = Modifier.fillMaxSize(),
        )

        // Overlaid text skeleton lines matching content layout
        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(XGSpacing.Base),
            verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            SkeletonLine(width = SkeletonHeadlineWidth, height = HeadlineFontSize.value.dp)
            SkeletonLine(width = SkeletonSubtitleWidth, height = SubtitleFontSize.value.dp)
        }

        // Tag badge skeleton at top-start
        SkeletonLine(
            width = SkeletonTagWidth,
            height = TagFontSize.value.dp,
            modifier = Modifier
                .align(Alignment.TopStart)
                .padding(XGSpacing.MD),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun HeroBannerSkeletonPreview() {
    XGTheme {
        HeroBannerSkeleton(
            modifier = Modifier.padding(XGSpacing.Base),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGHeroBannerPreview() {
    XGTheme {
        XGHeroBanner(
            title = "Summer Sale",
            subtitle = "Up to 50% off selected items",
            tag = "NEW SEASON",
            onClick = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGHeroBannerWithImagePreview() {
    XGTheme {
        XGHeroBanner(
            title = "New Collection",
            subtitle = "Explore the latest arrivals",
            imageUrl = null,
            onClick = {},
        )
    }
}
