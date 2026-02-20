package com.molt.marketplace.core.designsystem.component

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
import com.molt.marketplace.R
import com.molt.marketplace.core.designsystem.theme.MoltSpacing
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Composable
@Suppress("ktlint:standard:function-naming")
fun MoltLoadingView(modifier: Modifier = Modifier) {
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

@Composable
@Suppress("ktlint:standard:function-naming")
fun MoltLoadingIndicator(modifier: Modifier = Modifier) {
    val loadingDescription = stringResource(R.string.common_loading_message)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(MoltSpacing.Base),
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
@Suppress("ktlint:standard:function-naming")
private fun MoltLoadingViewPreview() {
    MoltTheme {
        MoltLoadingView()
    }
}

@Preview(showBackground = true)
@Composable
@Suppress("ktlint:standard:function-naming")
private fun MoltLoadingIndicatorPreview() {
    MoltTheme {
        MoltLoadingIndicator()
    }
}
