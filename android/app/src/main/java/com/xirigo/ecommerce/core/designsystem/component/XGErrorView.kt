package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ErrorOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * Full-screen error state with crossfade transition.
 *
 * Crossfades between [content] and the error layout (icon + message + retry button)
 * using [XGMotion.Crossfade.CONTENT_SWITCH] (200 ms). When [isError] is `true`,
 * the error layout is shown. When `false`, the [content] slot is shown.
 *
 * @param message Error message to display.
 * @param isError When `true`, crossfades to the error layout. When `false`, shows [content].
 * @param modifier Modifier applied to the outer container.
 * @param onRetry Optional retry callback. When non-null, a retry button is shown.
 * @param content The content to show when [isError] is `false`.
 */
@Composable
fun XGErrorView(
    message: String,
    isError: Boolean,
    modifier: Modifier = Modifier,
    onRetry: (() -> Unit)? = null,
    content: @Composable () -> Unit,
) {
    AnimatedContent(
        targetState = isError,
        modifier = modifier.fillMaxSize(),
        transitionSpec = {
            fadeIn(tween(XGMotion.Crossfade.CONTENT_SWITCH)) togetherWith
                fadeOut(tween(XGMotion.Crossfade.CONTENT_SWITCH))
        },
        label = "xgErrorViewCrossfade",
    ) { showError ->
        if (showError) {
            ErrorContent(
                message = message,
                onRetry = onRetry,
            )
        } else {
            content()
        }
    }
}

/** Full-screen error state with message and optional retry button (no crossfade). */
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
        ErrorContent(
            message = message,
            onRetry = onRetry,
        )
    }
}

/** Internal error content layout: icon + message + optional retry button. */
@Composable
private fun ErrorContent(message: String, onRetry: (() -> Unit)?) {
    Box(
        modifier = Modifier.fillMaxSize(),
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

// region Preview

private const val PREVIEW_ERROR_MESSAGE = "Something went wrong"
private const val PREVIEW_CONTENT_TEXT = "Content loaded!"

@Preview(showBackground = true)
@Composable
private fun XGErrorViewPreview() {
    XGTheme {
        XGErrorView(
            message = PREVIEW_ERROR_MESSAGE,
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

@Preview(showBackground = true, name = "XGErrorView — Crossfade Error")
@Composable
private fun XGErrorViewCrossfadeErrorPreview() {
    XGTheme {
        XGErrorView(
            message = PREVIEW_ERROR_MESSAGE,
            isError = true,
            onRetry = {},
        ) {
            Text(
                text = PREVIEW_CONTENT_TEXT,
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.padding(XGSpacing.Base),
            )
        }
    }
}

@Preview(showBackground = true, name = "XGErrorView — Crossfade Content")
@Composable
private fun XGErrorViewCrossfadeContentPreview() {
    XGTheme {
        XGErrorView(
            message = PREVIEW_ERROR_MESSAGE,
            isError = false,
            onRetry = {},
        ) {
            Text(
                text = PREVIEW_CONTENT_TEXT,
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.padding(XGSpacing.Base),
            )
        }
    }
}

@Preview(showBackground = true, name = "XGErrorView — Interactive Toggle")
@Composable
private fun XGErrorViewInteractivePreview() {
    XGTheme {
        var isError by remember { mutableStateOf(false) }

        Column {
            XGErrorView(
                message = PREVIEW_ERROR_MESSAGE,
                isError = isError,
                modifier = Modifier.weight(1f),
                onRetry = { isError = false },
            ) {
                Text(
                    text = "Real content loaded!",
                    style = MaterialTheme.typography.bodyLarge,
                    modifier = Modifier.padding(XGSpacing.Base),
                )
            }

            androidx.compose.material3.Button(
                onClick = { isError = !isError },
                modifier = Modifier.padding(XGSpacing.Base),
            ) {
                Text(text = if (isError) "Show Content" else "Show Error")
            }
        }
    }
}

// endregion
