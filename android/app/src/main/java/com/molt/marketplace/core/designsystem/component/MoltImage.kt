package com.molt.marketplace.core.designsystem.component

import coil3.compose.AsyncImage
import coil3.request.ImageRequest
import coil3.request.crossfade
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.painter.ColorPainter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.molt.marketplace.core.designsystem.theme.MoltColors
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Composable
@Suppress("ktlint:standard:function-naming")
fun MoltImage(
    url: String?,
    contentDescription: String?,
    modifier: Modifier = Modifier,
    contentScale: ContentScale = ContentScale.Crop,
) {
    if (url != null) {
        AsyncImage(
            model = ImageRequest.Builder(LocalContext.current)
                .data(url)
                .crossfade(true)
                .crossfade(250)
                .build(),
            contentDescription = contentDescription,
            modifier = modifier,
            contentScale = contentScale,
            placeholder = ColorPainter(MoltColors.Shimmer),
            error = ColorPainter(MoltColors.Shimmer),
        )
    } else {
        Box(
            modifier = modifier.background(MoltColors.Shimmer),
        )
    }
}

@Preview(showBackground = true)
@Composable
@Suppress("ktlint:standard:function-naming")
private fun MoltImagePlaceholderPreview() {
    MoltTheme {
        MoltImage(
            url = null,
            contentDescription = "Product image",
            modifier = Modifier.size(200.dp),
        )
    }
}

@Preview(showBackground = true)
@Composable
@Suppress("ktlint:standard:function-naming")
private fun MoltImageWithUrlPreview() {
    MoltTheme {
        MoltImage(
            url = "https://example.com/image.jpg",
            contentDescription = "Product image",
            modifier = Modifier.size(200.dp),
        )
    }
}
