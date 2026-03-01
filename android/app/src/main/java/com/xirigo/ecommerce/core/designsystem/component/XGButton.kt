package com.xirigo.ecommerce.core.designsystem.component

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
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@Composable
fun XGButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    style: XGButtonStyle = XGButtonStyle.Primary,
    enabled: Boolean = true,
    loading: Boolean = false,
    leadingIcon: ImageVector? = null,
    fullWidth: Boolean = style == XGButtonStyle.Primary || style == XGButtonStyle.Secondary,
) {
    val loadingDescription = stringResource(R.string.common_loading_message)
    val widthModifier = if (fullWidth) Modifier.fillMaxWidth() else Modifier
    val buttonModifier = modifier
        .then(widthModifier)
        .heightIn(min = XGSpacing.MinTouchTarget)
        .then(
            if (loading) {
                Modifier.semantics { contentDescription = loadingDescription }
            } else {
                Modifier
            },
        )

    val content: @Composable () -> Unit = {
        XGButtonContent(
            text = text,
            loading = loading,
            isPrimary = style == XGButtonStyle.Primary,
            leadingIcon = leadingIcon,
        )
    }

    val isEnabled = enabled && !loading
    XGButtonByStyle(
        style = style,
        onClick = onClick,
        modifier = buttonModifier,
        enabled = isEnabled,
        content = content,
    )
}

@Composable
private fun XGButtonContent(
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
        Spacer(modifier = Modifier.width(XGSpacing.SM))
    }
    if (!loading && leadingIcon != null) {
        Icon(
            imageVector = leadingIcon,
            contentDescription = null,
            modifier = Modifier.size(18.dp),
        )
        Spacer(modifier = Modifier.width(XGSpacing.SM))
    }
    Text(text = text)
}

@Composable
private fun XGButtonByStyle(
    style: XGButtonStyle,
    onClick: () -> Unit,
    modifier: Modifier,
    enabled: Boolean,
    content: @Composable () -> Unit,
) {
    when (style) {
        XGButtonStyle.Primary -> Button(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            content = { content() },
        )

        XGButtonStyle.Secondary -> OutlinedButton(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            content = { content() },
        )

        XGButtonStyle.Outlined -> OutlinedButton(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            colors = ButtonDefaults.outlinedButtonColors(
                contentColor = MaterialTheme.colorScheme.onSurface,
            ),
            content = { content() },
        )

        XGButtonStyle.Text -> TextButton(
            onClick = onClick,
            modifier = modifier,
            enabled = enabled,
            content = { content() },
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGButtonPrimaryPreview() {
    XGTheme {
        XGButton(text = "Add to Cart", onClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun XGButtonSecondaryPreview() {
    XGTheme {
        XGButton(text = "View Details", onClick = {}, style = XGButtonStyle.Secondary)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGButtonLoadingPreview() {
    XGTheme {
        XGButton(text = "Loading", onClick = {}, loading = true)
    }
}

@Preview(showBackground = true)
@Composable
private fun XGButtonDisabledPreview() {
    XGTheme {
        XGButton(text = "Disabled", onClick = {}, enabled = false)
    }
}
