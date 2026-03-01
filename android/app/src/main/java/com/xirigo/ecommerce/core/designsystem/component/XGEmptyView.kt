package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Inbox
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/** Full-screen empty state with icon, message, and optional action button. */
@Composable
fun XGEmptyView(
    message: String,
    modifier: Modifier = Modifier,
    icon: ImageVector = Icons.Outlined.Inbox,
    actionLabel: String? = null,
    onAction: (() -> Unit)? = null,
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
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(XGSpacing.XXXL),
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )

            Spacer(modifier = Modifier.height(XGSpacing.Base))

            Text(
                text = message,
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )

            if (actionLabel != null && onAction != null) {
                Spacer(modifier = Modifier.height(XGSpacing.Base))
                XGButton(
                    text = actionLabel,
                    onClick = onAction,
                    style = XGButtonStyle.Primary,
                    fullWidth = false,
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGEmptyViewPreview() {
    XGTheme {
        XGEmptyView(message = "Nothing to show")
    }
}

@Preview(showBackground = true)
@Composable
private fun XGEmptyViewWithActionPreview() {
    XGTheme {
        XGEmptyView(
            message = "Your cart is empty",
            actionLabel = "Start Shopping",
            onAction = {},
        )
    }
}
