package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/** Full-screen centered loading spinner. */
@Composable
fun XGLoadingView(modifier: Modifier = Modifier) {
    val loadingDescription = stringResource(R.string.common_loading_message)

    Box(
        modifier = modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        CircularProgressIndicator(
            modifier = Modifier.semantics {
                contentDescription = loadingDescription
            },
            color = MaterialTheme.colorScheme.primary,
        )
    }
}

/** Inline loading indicator for list footers and sections. */
@Composable
fun XGLoadingIndicator(modifier: Modifier = Modifier) {
    val loadingDescription = stringResource(R.string.common_loading_message)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(XGSpacing.Base),
        contentAlignment = Alignment.Center,
    ) {
        CircularProgressIndicator(
            modifier = Modifier
                .size(24.dp)
                .semantics { contentDescription = loadingDescription },
            strokeWidth = 2.dp,
            color = MaterialTheme.colorScheme.primary,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGLoadingViewPreview() {
    XGTheme {
        XGLoadingView()
    }
}

@Preview(showBackground = true)
@Composable
private fun XGLoadingIndicatorPreview() {
    XGTheme {
        XGLoadingIndicator()
    }
}
