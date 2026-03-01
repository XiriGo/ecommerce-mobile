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
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/** Full-screen error state with message and optional retry button. */
@Composable
fun XGErrorView(
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
                modifier = Modifier.size(XGSpacing.XXL),
                tint = MaterialTheme.colorScheme.error,
            )

            Spacer(modifier = Modifier.height(XGSpacing.Base))

            Text(
                text = message,
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurface,
            )

            if (onRetry != null) {
                Spacer(modifier = Modifier.height(XGSpacing.Base))
                XGButton(
                    text = stringResource(R.string.common_retry_button),
                    onClick = onRetry,
                    style = XGButtonStyle.Primary,
                    fullWidth = false,
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGErrorViewPreview() {
    XGTheme {
        XGErrorView(
            message = "Something went wrong",
            onRetry = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGErrorViewNoRetryPreview() {
    XGTheme {
        XGErrorView(message = "No internet connection")
    }
}
