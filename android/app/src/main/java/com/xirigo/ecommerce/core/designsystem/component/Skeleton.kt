package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Token source: components/atoms/xg-skeleton.json

private val SkeletonLineDefaultHeight = 14.dp

// Preview constants
private val PreviewBoxWidth = 170.dp
private val PreviewBoxHeight = 170.dp
private val PreviewLineWidthLong = 140.dp
private val PreviewLineWidthShort = 80.dp
private val PreviewLineSmallHeight = 12.dp
private val PreviewCircleSize = 48.dp
private val PreviewRatingCircleSize = 12.dp
private val PreviewRatingLineWidth = 30.dp

/**
 * Rectangular shimmer placeholder with configurable dimensions and corner radius.
 *
 * Individual skeleton shapes are decorative and hidden from the accessibility tree.
 * Use [XGSkeleton] to wrap skeleton layouts with an accessible "Loading content" label.
 */
@Composable
fun SkeletonBox(
    width: Dp,
    height: Dp,
    modifier: Modifier = Modifier,
    cornerRadius: Dp = XGCornerRadius.Medium,
) {
    val shape = RoundedCornerShape(cornerRadius)
    Box(
        modifier = modifier
            .size(width, height)
            .clip(shape)
            .background(XGColors.Shimmer)
            .shimmerEffect(),
    )
}

/**
 * Text-line shimmer placeholder with a fixed small corner radius.
 *
 * The default height of 14dp approximates `bodyMedium` line height from the typography scale,
 * making [SkeletonLine] immediately usable for most text placeholders without specifying height.
 *
 * Individual skeleton shapes are decorative and hidden from the accessibility tree.
 */
@Composable
fun SkeletonLine(
    width: Dp,
    modifier: Modifier = Modifier,
    height: Dp = SkeletonLineDefaultHeight,
) {
    val shape = RoundedCornerShape(XGCornerRadius.Small)
    Box(
        modifier = modifier
            .size(width, height)
            .clip(shape)
            .background(XGColors.Shimmer)
            .shimmerEffect(),
    )
}

/**
 * Circular shimmer placeholder for avatars, icons, and thumbnails.
 *
 * Individual skeleton shapes are decorative and hidden from the accessibility tree.
 */
@Composable
fun SkeletonCircle(size: Dp, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(XGColors.Shimmer)
            .shimmerEffect(),
    )
}

/**
 * Content-wrapping composable that crossfades between a skeleton [placeholder] and real [content].
 *
 * When [visible] is `true`, the [placeholder] is shown with an accessible "Loading content" label.
 * When [visible] transitions to `false`, a crossfade animation reveals the real [content].
 *
 * The crossfade duration is [XGMotion.Crossfade.CONTENT_SWITCH] (200ms).
 *
 * @param visible When `true`, shows the placeholder. When `false`, shows content.
 * @param placeholder The skeleton layout to show during loading.
 * @param modifier Modifier applied to the [AnimatedContent] container.
 * @param content The real content to show when loading completes.
 */
@Composable
fun XGSkeleton(
    visible: Boolean,
    placeholder: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    val loadingDescription = stringResource(R.string.skeleton_loading_placeholder)

    AnimatedContent(
        targetState = visible,
        modifier = modifier.semantics {
            if (visible) {
                contentDescription = loadingDescription
            }
        },
        transitionSpec = {
            fadeIn(tween(XGMotion.Crossfade.CONTENT_SWITCH)) togetherWith
                fadeOut(tween(XGMotion.Crossfade.CONTENT_SWITCH))
        },
        label = "skeletonCrossfade",
    ) { isLoading ->
        if (isLoading) placeholder() else content()
    }
}

// region Preview

@Preview(showBackground = true)
@Composable
private fun SkeletonBoxPreview() {
    XGTheme {
        Column(
            modifier = Modifier.padding(XGSpacing.Base),
            verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            SkeletonBox(width = PreviewBoxWidth, height = PreviewBoxHeight)
            SkeletonBox(
                width = PreviewBoxWidth,
                height = PreviewBoxHeight,
                cornerRadius = XGCornerRadius.Large,
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun SkeletonLinePreview() {
    XGTheme {
        Column(
            modifier = Modifier.padding(XGSpacing.Base),
            verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            SkeletonLine(width = PreviewLineWidthLong)
            SkeletonLine(width = PreviewLineWidthShort, height = PreviewLineSmallHeight)
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun SkeletonCirclePreview() {
    XGTheme {
        Column(
            modifier = Modifier.padding(XGSpacing.Base),
            verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            SkeletonCircle(size = PreviewCircleSize)
            SkeletonCircle(size = PreviewRatingCircleSize)
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun ProductCardSkeletonPreview() {
    XGTheme {
        Column(
            modifier = Modifier.padding(XGSpacing.Base),
            verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            SkeletonBox(width = PreviewBoxWidth, height = PreviewBoxHeight)
            SkeletonLine(width = PreviewLineWidthLong)
            SkeletonLine(width = PreviewLineWidthShort, height = PreviewLineSmallHeight)
            Row(horizontalArrangement = Arrangement.spacedBy(XGSpacing.XS)) {
                SkeletonCircle(size = PreviewRatingCircleSize)
                SkeletonLine(width = PreviewRatingLineWidth, height = PreviewLineSmallHeight)
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGSkeletonCrossfadePreview() {
    XGTheme {
        var isLoading by remember { mutableStateOf(true) }

        Column(
            modifier = Modifier.padding(XGSpacing.Base),
            verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            Text(
                text = "Crossfade Demo (isLoading=$isLoading)",
                style = MaterialTheme.typography.labelMedium,
            )

            XGSkeleton(
                visible = isLoading,
                placeholder = {
                    Column(verticalArrangement = Arrangement.spacedBy(XGSpacing.SM)) {
                        SkeletonBox(width = PreviewBoxWidth, height = PreviewBoxHeight)
                        SkeletonLine(width = PreviewLineWidthLong)
                    }
                },
            ) {
                Text(
                    text = "Real content loaded!",
                    style = MaterialTheme.typography.bodyLarge,
                )
            }

            Spacer(modifier = Modifier.height(XGSpacing.SM))

            // Toggle button for interactive preview testing
            androidx.compose.material3.Button(onClick = { isLoading = !isLoading }) {
                Text(text = if (isLoading) "Show Content" else "Show Skeleton")
            }
        }
    }
}

// endregion
