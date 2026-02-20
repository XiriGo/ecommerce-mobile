@file:Suppress("MatchingDeclarationName")

package com.molt.marketplace.core.designsystem.component

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
import com.molt.marketplace.R
import com.molt.marketplace.core.designsystem.theme.MoltColors
import com.molt.marketplace.core.designsystem.theme.MoltCornerRadius
import com.molt.marketplace.core.designsystem.theme.MoltSpacing
import com.molt.marketplace.core.designsystem.theme.MoltTheme

enum class MoltBadgeStatus {
    Success,
    Warning,
    Error,
    Info,
    Neutral,
}

@Composable
@Suppress("ktlint:standard:function-naming")
fun MoltCountBadge(count: Int, modifier: Modifier = Modifier) {
    if (count <= 0) return

    val displayText = if (count >= 100) "99+" else count.toString()
    val notificationsDescription = stringResource(R.string.common_notifications_count, count)

    Box(
        modifier = modifier
            .clip(CircleShape)
            .background(MoltColors.BadgeBackground)
            .padding(horizontal = MoltSpacing.XS, vertical = MoltSpacing.XXS)
            .semantics { contentDescription = notificationsDescription },
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = displayText,
            style = MaterialTheme.typography.labelSmall,
            color = MoltColors.BadgeText,
        )
    }
}

@Composable
@Suppress("ktlint:standard:function-naming")
fun MoltStatusBadge(
    status: MoltBadgeStatus,
    label: String,
    modifier: Modifier = Modifier,
) {
    val backgroundColor = when (status) {
        MoltBadgeStatus.Success -> MoltColors.Success
        MoltBadgeStatus.Warning -> MoltColors.Warning
        MoltBadgeStatus.Error -> MoltColors.Error
        MoltBadgeStatus.Info -> MoltColors.Info
        MoltBadgeStatus.Neutral -> MaterialTheme.colorScheme.surfaceVariant
    }

    val textColor = when (status) {
        MoltBadgeStatus.Success -> MoltColors.OnSuccess
        MoltBadgeStatus.Warning -> MoltColors.OnWarning
        MoltBadgeStatus.Error -> MaterialTheme.colorScheme.onError
        MoltBadgeStatus.Info -> MoltColors.OnInfo
        MoltBadgeStatus.Neutral -> MaterialTheme.colorScheme.onSurfaceVariant
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(MoltCornerRadius.Full))
            .background(backgroundColor)
            .padding(horizontal = MoltSpacing.SM, vertical = MoltSpacing.XS),
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
@Suppress("ktlint:standard:function-naming")
private fun MoltCountBadgePreview() {
    MoltTheme {
        MoltCountBadge(count = 5)
    }
}

@Preview(showBackground = true)
@Composable
@Suppress("ktlint:standard:function-naming")
private fun MoltCountBadgeOverflowPreview() {
    MoltTheme {
        MoltCountBadge(count = 150)
    }
}

@Preview(showBackground = true)
@Composable
@Suppress("ktlint:standard:function-naming")
private fun MoltStatusBadgeSuccessPreview() {
    MoltTheme {
        MoltStatusBadge(status = MoltBadgeStatus.Success, label = "In Stock")
    }
}

@Preview(showBackground = true)
@Composable
@Suppress("ktlint:standard:function-naming")
private fun MoltStatusBadgeErrorPreview() {
    MoltTheme {
        MoltStatusBadge(status = MoltBadgeStatus.Error, label = "Out of Stock")
    }
}

@Preview(showBackground = true)
@Composable
@Suppress("ktlint:standard:function-naming")
private fun MoltStatusBadgeWarningPreview() {
    MoltTheme {
        MoltStatusBadge(status = MoltBadgeStatus.Warning, label = "Low Stock")
    }
}
