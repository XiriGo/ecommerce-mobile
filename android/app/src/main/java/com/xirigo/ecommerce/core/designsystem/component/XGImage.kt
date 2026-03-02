package com.xirigo.ecommerce.core.designsystem.component

import coil3.compose.SubcomposeAsyncImage
import coil3.request.ImageRequest
import coil3.request.crossfade
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Image
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/** Icon size for the placeholder and error fallback states. */
private val PlaceholderIconSize = 27.dp

/** Preview-only square size for demonstration. */
private val PreviewImageSize = 200.dp

/**
 * Async image loader with animated shimmer placeholder and branded error fallback.
 *
 * Uses [SubcomposeAsyncImage] to support composable loading/error slots with
 * [shimmerEffect] animation. Crossfade duration is driven by
 * [XGMotion.Crossfade.IMAGE_FADE_IN].
 *
 * @param url Image URL to load. When `null`, renders the branded error fallback.
 * @param contentDescription Accessibility label for the image.
 * @param modifier Modifier applied to the root composable.
 * @param contentScale How the image content is scaled within the bounds.
 */
@Composable
fun XGImage(
    url: String?,
    contentDescription: String?,
    modifier: Modifier = Modifier,
    contentScale: ContentScale = ContentScale.Crop,
) {
    if (url != null) {
        SubcomposeAsyncImage(
            model = ImageRequest.Builder(LocalContext.current)
                .data(url)
                .crossfade(XGMotion.Crossfade.IMAGE_FADE_IN)
                .build(),
            contentDescription = contentDescription,
            modifier = modifier,
            contentScale = contentScale,
            loading = {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(XGColors.Shimmer)
                        .shimmerEffect(),
                )
            },
            error = {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(XGColors.SurfaceVariant),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Image,
                        contentDescription = null,
                        tint = XGColors.OnSurfaceVariant,
                        modifier = Modifier.size(PlaceholderIconSize),
                    )
                }
            },
        )
    } else {
        Box(
            modifier = modifier.background(XGColors.SurfaceVariant),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = Icons.Outlined.Image,
                contentDescription = contentDescription,
                tint = XGColors.OnSurfaceVariant,
                modifier = Modifier.size(PlaceholderIconSize),
            )
        }
    }
}

// region Preview

@Preview(showBackground = true)
@Composable
private fun XGImagePlaceholderPreview() {
    XGTheme {
        XGImage(
            url = null,
            contentDescription = "Product image",
            modifier = Modifier.size(PreviewImageSize),
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
            modifier = Modifier.size(PreviewImageSize),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGImageErrorPreview() {
    XGTheme {
        // Simulates an error state by using a broken URL.
        // SubcomposeAsyncImage will render the error slot.
        XGImage(
            url = "https://invalid.test/broken-image",
            contentDescription = "Product image error",
            modifier = Modifier.size(PreviewImageSize),
        )
    }
}

// endregion
