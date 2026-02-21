package com.molt.marketplace.core.designsystem.component

import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.molt.marketplace.R
import com.molt.marketplace.core.designsystem.theme.MoltSpacing
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Composable
fun MoltButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    style: MoltButtonStyle = MoltButtonStyle.Primary,
    enabled: Boolean = true,
    loading: Boolean = false,
    leadingIcon: ImageVector? = null,
    fullWidth: Boolean = style == MoltButtonStyle.Primary || style == MoltButtonStyle.Secondary,
) {
    val loadingDescription = stringResource(R.string.common_loading_message)
    val widthModifier = if (fullWidth) Modifier.fillMaxWidth() else Modifier
    val buttonModifier = modifier
        .then(widthModifier)
        .heightIn(min = MoltSpacing.MinTouchTarget)
        .then(
            if (loading) {
                Modifier.semantics { contentDescription = loadingDescription }
            } else {
                Modifier
            },
        )

    val content: @Composable () -> Unit = {
        MoltButtonContent(
            text = text,
            loading = loading,
            isPrimary = style == MoltButtonStyle.Primary,
            leadingIcon = leadingIcon,
        )
    }

    val isEnabled = enabled && !loading
    MoltButtonByStyle(
        style = style,
        onClick = onClick,
        modifier = buttonModifier,
        enabled = isEnabled,
        content = content,
    )
}

@Composable
private fun MoltButtonContent(
    text: String,
    loading: Boolean,
    isPrimary: Boolean,
    leadingIcon: ImageVector?,
) {
    if (loading) {
        CircularProgressIndicator(
            modifier = Modifier.size(20.dp),
            strokeWidth = 2.dp,
            color = if (isPrimary) {
                MaterialTheme.colorScheme.onPrimary
            } else {
                MaterialTheme.colorScheme.primary
            },
        )
        Spacer(modifier = Modifier.width(MoltSpacing.SM))
    }
    if (!loading && leadingIcon != null) {
        Icon(
            imageVector = leadingIcon,
            contentDescription = null,
            modifier = Modifier.size(18.dp),
        )
        Spacer(modifier = Modifier.width(MoltSpacing.SM))
    }
    Text(text = text)
}

@Composable
private fun MoltButtonByStyle(
    style: MoltButtonStyle,
    onClick: () -> Unit,
    modifier: Modifier,
    enabled: Boolean,
    content: @Composable () -> Unit,
) {
    when (style) {
        MoltButtonStyle.Primary -> Button(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            content = { content() },
        )

        MoltButtonStyle.Secondary -> OutlinedButton(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            content = { content() },
        )

        MoltButtonStyle.Outlined -> OutlinedButton(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            colors = ButtonDefaults.outlinedButtonColors(
                contentColor = MaterialTheme.colorScheme.onSurface,
            ),
            content = { content() },
        )

        MoltButtonStyle.Text -> TextButton(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            content = { content() },
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltButtonPrimaryPreview() {
    MoltTheme {
        MoltButton(text = "Add to Cart", onClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltButtonSecondaryPreview() {
    MoltTheme {
        MoltButton(text = "View Details", onClick = {}, style = MoltButtonStyle.Secondary)
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltButtonLoadingPreview() {
    MoltTheme {
        MoltButton(text = "Loading", onClick = {}, loading = true)
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltButtonDisabledPreview() {
    MoltTheme {
        MoltButton(text = "Disabled", onClick = {}, enabled = false)
    }
}
