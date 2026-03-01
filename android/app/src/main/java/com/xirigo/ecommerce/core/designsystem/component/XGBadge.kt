package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/** Circular count badge that displays a number, capping at "99+". */
@Composable
fun XGCountBadge(count: Int, modifier: Modifier = Modifier) {
    if (count <= 0) return

    val displayText = if (count >= 100) "99+" else count.toString()
    val notificationsDescription = stringResource(R.string.common_notifications_count, count)

    Box(
        modifier = modifier
            .clip(CircleShape)
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
        XGBadgeStatus.Neutral -> MaterialTheme.colorScheme.surfaceVariant
    }

    val textColor = when (status) {
        XGBadgeStatus.Success -> XGColors.OnSuccess
        XGBadgeStatus.Warning -> XGColors.OnWarning
        XGBadgeStatus.Error -> MaterialTheme.colorScheme.onError
        XGBadgeStatus.Info -> XGColors.OnInfo
        XGBadgeStatus.Neutral -> MaterialTheme.colorScheme.onSurfaceVariant
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
