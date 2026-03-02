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
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
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
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Default shimmer placeholder heights
private val DefaultShimmerBoxHeight = 200.dp
private val DefaultShimmerLineHeight = 14.dp
private val InlineShimmerLineHeight = 24.dp

/**
 * Skeleton-aware full-screen loading view.
 *
 * Crossfades between a skeleton placeholder and real content using
 * [XGMotion.Crossfade.CONTENT_SWITCH] (200 ms). When no [skeleton] slot is provided,
 * a default full-width shimmer box is shown.
 *
 * @param isLoading When `true`, shows the skeleton/shimmer. When `false`, shows [content].
 * @param modifier Modifier applied to the outer container.
 * @param skeleton Optional skeleton placeholder slot. When `null`, a default shimmer box is used.
 * @param content The real content to reveal when loading completes.
 */
@Composable
fun XGLoadingView(
    isLoading: Boolean,
    modifier: Modifier = Modifier,
    skeleton: (@Composable () -> Unit)? = null,
    content: @Composable () -> Unit,
) {
    val loadingDescription = stringResource(R.string.skeleton_loading_placeholder)

    AnimatedContent(
        targetState = isLoading,
        modifier = modifier.fillMaxSize(),
        transitionSpec = {
            fadeIn(tween(XGMotion.Crossfade.CONTENT_SWITCH)) togetherWith
                fadeOut(tween(XGMotion.Crossfade.CONTENT_SWITCH))
        },
        label = "xgLoadingViewCrossfade",
    ) { loading ->
        if (loading) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .semantics { contentDescription = loadingDescription },
            ) {
                if (skeleton != null) {
                    skeleton()
                } else {
                    DefaultFullScreenSkeleton()
                }
            }
        } else {
            content()
        }
    }
}

/**
 * Convenience overload that always shows the loading skeleton (no content slot).
 *
 * Use this when the caller only needs a loading placeholder without content transition,
 * for example inside a `when (uiState)` block where content is rendered by a different branch.
 *
 * @param modifier Modifier applied to the outer container.
 * @param skeleton Optional skeleton placeholder slot. When `null`, a default shimmer box is used.
 */
@Composable
fun XGLoadingView(modifier: Modifier = Modifier, skeleton: (@Composable () -> Unit)? = null) {
    val loadingDescription = stringResource(R.string.skeleton_loading_placeholder)

    Box(
        modifier = modifier
            .fillMaxSize()
            .semantics { contentDescription = loadingDescription },
    ) {
        if (skeleton != null) {
            skeleton()
        } else {
            DefaultFullScreenSkeleton()
        }
    }
}

/**
 * Skeleton-aware inline loading indicator for list footers and sections.
 *
 * Crossfades between a skeleton placeholder and real content using
 * [XGMotion.Crossfade.CONTENT_SWITCH] (200 ms). When no [skeleton] slot is provided,
 * a default full-width shimmer line is shown.
 *
 * @param isLoading When `true`, shows the skeleton/shimmer. When `false`, shows [content].
 * @param modifier Modifier applied to the outer container.
 * @param skeleton Optional skeleton placeholder slot. When `null`, a default shimmer line is used.
 * @param content The real content to reveal when loading completes.
 */
@Composable
fun XGLoadingIndicator(
    isLoading: Boolean,
    modifier: Modifier = Modifier,
    skeleton: (@Composable () -> Unit)? = null,
    content: @Composable () -> Unit,
) {
    val loadingDescription = stringResource(R.string.skeleton_loading_placeholder)

    AnimatedContent(
        targetState = isLoading,
        modifier = modifier.fillMaxWidth(),
        transitionSpec = {
            fadeIn(tween(XGMotion.Crossfade.CONTENT_SWITCH)) togetherWith
                fadeOut(tween(XGMotion.Crossfade.CONTENT_SWITCH))
        },
        label = "xgLoadingIndicatorCrossfade",
    ) { loading ->
        if (loading) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(XGSpacing.Base)
                    .semantics { contentDescription = loadingDescription },
            ) {
                if (skeleton != null) {
                    skeleton()
                } else {
                    DefaultInlineSkeleton()
                }
            }
        } else {
            content()
        }
    }
}

/**
 * Convenience overload that always shows the inline loading skeleton (no content slot).
 *
 * @param modifier Modifier applied to the outer container.
 * @param skeleton Optional skeleton placeholder slot. When `null`, a default shimmer line is used.
 */
@Composable
fun XGLoadingIndicator(modifier: Modifier = Modifier, skeleton: (@Composable () -> Unit)? = null) {
    val loadingDescription = stringResource(R.string.skeleton_loading_placeholder)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(XGSpacing.Base)
            .semantics { contentDescription = loadingDescription },
    ) {
        if (skeleton != null) {
            skeleton()
        } else {
            DefaultInlineSkeleton()
        }
    }
}

/** Default full-screen shimmer placeholder: a set of shimmer boxes and lines. */
@Composable
private fun DefaultFullScreenSkeleton() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(XGSpacing.Base),
        verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(DefaultShimmerBoxHeight)
                .clip(RoundedCornerShape(XGCornerRadius.Medium))
                .background(XGColors.Shimmer)
                .shimmerEffect(),
        )
        Box(
            modifier = Modifier
                .fillMaxWidth(fraction = 0.7f)
                .height(DefaultShimmerLineHeight)
                .clip(RoundedCornerShape(XGCornerRadius.Small))
                .background(XGColors.Shimmer)
                .shimmerEffect(),
        )
        Box(
            modifier = Modifier
                .fillMaxWidth(fraction = 0.5f)
                .height(DefaultShimmerLineHeight)
                .clip(RoundedCornerShape(XGCornerRadius.Small))
                .background(XGColors.Shimmer)
                .shimmerEffect(),
        )
    }
}

/** Default inline shimmer placeholder: a full-width shimmer line. */
@Composable
private fun DefaultInlineSkeleton() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(InlineShimmerLineHeight)
            .clip(RoundedCornerShape(XGCornerRadius.Small))
            .background(XGColors.Shimmer)
            .shimmerEffect(),
    )
}

// region Preview

@Preview(showBackground = true, name = "XGLoadingView — Default Skeleton")
@Composable
private fun XGLoadingViewDefaultSkeletonPreview() {
    XGTheme {
        XGLoadingView()
    }
}

@Preview(showBackground = true, name = "XGLoadingView — Custom Skeleton")
@Composable
private fun XGLoadingViewCustomSkeletonPreview() {
    XGTheme {
        XGLoadingView(
            skeleton = {
                Column(
                    modifier = Modifier.padding(XGSpacing.Base),
                    verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
                ) {
                    SkeletonBox(width = 170.dp, height = 170.dp)
                    SkeletonLine(width = 140.dp)
                    SkeletonLine(width = 80.dp)
                }
            },
        )
    }
}

@Preview(showBackground = true, name = "XGLoadingView — Crossfade Loading")
@Composable
private fun XGLoadingViewCrossfadeLoadingPreview() {
    XGTheme {
        XGLoadingView(
            isLoading = true,
            skeleton = {
                Column(
                    modifier = Modifier.padding(XGSpacing.Base),
                    verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
                ) {
                    SkeletonBox(width = 170.dp, height = 170.dp)
                    SkeletonLine(width = 140.dp)
                }
            },
        ) {
            Text(
                text = "Content loaded!",
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.padding(XGSpacing.Base),
            )
        }
    }
}

@Preview(showBackground = true, name = "XGLoadingView — Crossfade Content")
@Composable
private fun XGLoadingViewCrossfadeContentPreview() {
    XGTheme {
        XGLoadingView(
            isLoading = false,
        ) {
            Text(
                text = "Content loaded!",
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.padding(XGSpacing.Base),
            )
        }
    }
}

@Preview(showBackground = true, name = "XGLoadingView — Interactive Toggle")
@Composable
private fun XGLoadingViewInteractivePreview() {
    XGTheme {
        var isLoading by remember { mutableStateOf(true) }

        Column {
            XGLoadingView(
                isLoading = isLoading,
                modifier = Modifier.weight(1f),
                skeleton = {
                    Column(
                        modifier = Modifier.padding(XGSpacing.Base),
                        verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
                    ) {
                        SkeletonBox(width = 170.dp, height = 170.dp)
                        SkeletonLine(width = 140.dp)
                        SkeletonLine(width = 80.dp)
                    }
                },
            ) {
                Text(
                    text = "Real content loaded!",
                    style = MaterialTheme.typography.bodyLarge,
                    modifier = Modifier.padding(XGSpacing.Base),
                )
            }

            androidx.compose.material3.Button(
                onClick = { isLoading = !isLoading },
                modifier = Modifier.padding(XGSpacing.Base),
            ) {
                Text(text = if (isLoading) "Show Content" else "Show Skeleton")
            }
        }
    }
}

@Preview(showBackground = true, name = "XGLoadingIndicator — Default Skeleton")
@Composable
private fun XGLoadingIndicatorDefaultSkeletonPreview() {
    XGTheme {
        XGLoadingIndicator()
    }
}

@Preview(showBackground = true, name = "XGLoadingIndicator — Custom Skeleton")
@Composable
private fun XGLoadingIndicatorCustomSkeletonPreview() {
    XGTheme {
        XGLoadingIndicator(
            skeleton = {
                SkeletonLine(width = 200.dp)
            },
        )
    }
}

@Preview(showBackground = true, name = "XGLoadingIndicator — Crossfade")
@Composable
private fun XGLoadingIndicatorCrossfadePreview() {
    XGTheme {
        var isLoading by remember { mutableStateOf(true) }

        Column {
            Text(text = "List content above", modifier = Modifier.padding(XGSpacing.Base))

            XGLoadingIndicator(
                isLoading = isLoading,
                skeleton = { SkeletonLine(width = 200.dp) },
            ) {
                Text(
                    text = "More items loaded",
                    modifier = Modifier.padding(XGSpacing.Base),
                )
            }

            Spacer(modifier = Modifier.height(XGSpacing.SM))

            androidx.compose.material3.Button(
                onClick = { isLoading = !isLoading },
                modifier = Modifier.padding(XGSpacing.Base),
            ) {
                Text(text = if (isLoading) "Show Content" else "Show Skeleton")
            }
        }
    }
}

// endregion
