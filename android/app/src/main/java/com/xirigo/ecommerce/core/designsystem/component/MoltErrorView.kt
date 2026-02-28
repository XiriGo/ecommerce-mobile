package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ErrorOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.MoltSpacing
import com.xirigo.ecommerce.core.designsystem.theme.MoltTheme

@Composable
fun MoltErrorView(
    message: String,
    modifier: Modifier = Modifier,
    onRetry: (() -> Unit)? = null,
) {
    Box(
        modifier = modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Icon(
                imageVector = Icons.Outlined.ErrorOutline,
                contentDescription = null,
                modifier = Modifier.size(MoltSpacing.XXL),
                tint = MaterialTheme.colorScheme.error,
            )

            Spacer(modifier = Modifier.height(MoltSpacing.Base))

            Text(
                text = message,
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurface,
            )

            if (onRetry != null) {
                Spacer(modifier = Modifier.height(MoltSpacing.Base))
                MoltButton(
                    text = stringResource(R.string.common_retry_button),
                    onClick = onRetry,
                    style = MoltButtonStyle.Primary,
                    fullWidth = false,
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltErrorViewPreview() {
    MoltTheme {
        MoltErrorView(
            message = "Something went wrong",
            onRetry = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun MoltErrorViewNoRetryPreview() {
    MoltTheme {
        MoltErrorView(message = "No internet connection")
    }
}
