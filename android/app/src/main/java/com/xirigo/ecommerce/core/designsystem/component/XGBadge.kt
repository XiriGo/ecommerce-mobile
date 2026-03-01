package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGCustomTextStyles
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// ---------------------------------------------------------------------------
// XGBadgeVariant
// ---------------------------------------------------------------------------

/** Style variants for [XGBadge], matching `components/atoms/xg-badge.json`. */
enum class XGBadgeVariant(
    val backgroundColor: Color,
    val textColor: Color,
) {
    /** Primary: brand primary background, white text (e.g. SALE). */
    Primary(
        backgroundColor = XGColors.BadgeBackground,
        textColor = XGColors.BadgeText,
    ),

    /** Secondary: brand secondary background, brand primary text (e.g. NEW SEASON, DAILY DEAL). */
    Secondary(
        backgroundColor = XGColors.BadgeSecondaryBackground,
        textColor = XGColors.BadgeSecondaryText,
    ),
}

// ---------------------------------------------------------------------------
// XGBadge
// ---------------------------------------------------------------------------

/**
 * Inline badge label component.
 *
 * Token source: `components/atoms/xg-badge.json`.
 * - Font: captionSemiBold (12sp SemiBold)
 * - Corner radius: [XGCornerRadius.Medium] (10dp)
 * - Horizontal padding: 10dp
 * - Vertical padding: 4dp
 */
@Composable
fun XGBadge(
    label: String,
    modifier: Modifier = Modifier,
    variant: XGBadgeVariant = XGBadgeVariant.Primary,
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(XGCornerRadius.Medium))
            .background(variant.backgroundColor)
            .padding(
                horizontal = BadgeConstants.HorizontalPadding,
                vertical = BadgeConstants.VerticalPadding,
            ),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = label,
            style = XGCustomTextStyles.CaptionSemiBold,
            color = variant.textColor,
        )
    }
}

// ---------------------------------------------------------------------------
// XGCountBadge
// ---------------------------------------------------------------------------

/** Capsule-shaped count badge that displays a number, capping at "99+". */
@Composable
fun XGCountBadge(count: Int, modifier: Modifier = Modifier) {
    if (count <= 0) return

    val displayText = if (count >= 100) "99+" else count.toString()
    val notificationsDescription = stringResource(R.string.common_notifications_count, count)

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(XGCornerRadius.Full))
            .background(XGColors.BadgeBackground)
            .padding(horizontal = XGSpacing.XS, vertical = XGSpacing.XXS)
            .semantics { contentDescription = notificationsDescription },
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = displayText,
            style = MaterialTheme.typography.labelSmall,
            color = XGColors.BadgeText,
        )
    }
}

// ---------------------------------------------------------------------------
// XGStatusBadge
// ---------------------------------------------------------------------------

/** Pill-shaped status badge with semantic color coding. */
@Composable
fun XGStatusBadge(
    status: XGBadgeStatus,
    label: String,
    modifier: Modifier = Modifier,
) {
    val backgroundColor = when (status) {
        XGBadgeStatus.Success -> XGColors.Success
        XGBadgeStatus.Warning -> XGColors.Warning
        XGBadgeStatus.Error -> XGColors.Error
        XGBadgeStatus.Info -> XGColors.Info
        XGBadgeStatus.Neutral -> XGColors.SurfaceVariant
    }

    val textColor = when (status) {
        XGBadgeStatus.Success -> XGColors.OnSuccess
        XGBadgeStatus.Warning -> XGColors.OnWarning
        XGBadgeStatus.Error -> XGColors.OnError
        XGBadgeStatus.Info -> XGColors.OnInfo
        XGBadgeStatus.Neutral -> XGColors.OnSurfaceVariant
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(XGCornerRadius.Full))
            .background(backgroundColor)
            .padding(horizontal = XGSpacing.SM, vertical = XGSpacing.XS),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = textColor,
        )
    }
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/** Component-level padding constants from xg-badge.json token spec. */
private object BadgeConstants {
    val HorizontalPadding = 10.dp
    val VerticalPadding = 4.dp
}

// ---------------------------------------------------------------------------
// Previews
// ---------------------------------------------------------------------------

@Preview(showBackground = true)
@Composable
private fun XGBadgePrimaryPreview() {
    XGTheme {
        XGBadge(label = "SALE", variant = XGBadgeVariant.Primary)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGBadgeSecondaryPreview() {
    XGTheme {
        Column(verticalArrangement = Arrangement.spacedBy(XGSpacing.SM)) {
            XGBadge(label = "NEW SEASON", variant = XGBadgeVariant.Secondary)
            XGBadge(label = "DAILY DEAL", variant = XGBadgeVariant.Secondary)
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGCountBadgePreview() {
    XGTheme {
        XGCountBadge(count = 5)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGCountBadgeOverflowPreview() {
    XGTheme {
        XGCountBadge(count = 150)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGStatusBadgeSuccessPreview() {
    XGTheme {
        XGStatusBadge(status = XGBadgeStatus.Success, label = "In Stock")
    }
}

@Preview(showBackground = true)
@Composable
private fun XGStatusBadgeErrorPreview() {
    XGTheme {
        XGStatusBadge(status = XGBadgeStatus.Error, label = "Out of Stock")
    }
}

@Preview(showBackground = true)
@Composable
private fun XGStatusBadgeWarningPreview() {
    XGTheme {
        XGStatusBadge(status = XGBadgeStatus.Warning, label = "Low Stock")
    }
}
