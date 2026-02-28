package com.xirigo.ecommerce.core.designsystem.component

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
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@Composable
fun XGImage(
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
            placeholder = ColorPainter(XGColors.Shimmer),
            error = ColorPainter(XGColors.Shimmer),
        )
    } else {
        Box(
            modifier = modifier.background(XGColors.Shimmer),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGImagePlaceholderPreview() {
    XGTheme {
        XGImage(
            url = null,
            contentDescription = "Product image",
            modifier = Modifier.size(200.dp),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGImageWithUrlPreview() {
    XGTheme {
        XGImage(
            url = "https://example.com/image.jpg",
            contentDescription = "Product image",
            modifier = Modifier.size(200.dp),
        )
    }
}
