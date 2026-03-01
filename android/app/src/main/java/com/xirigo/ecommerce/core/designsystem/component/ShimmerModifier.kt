package com.xirigo.ecommerce.core.designsystem.component

import kotlin.math.tan
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGMotion
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/**
 * Applies an animated shimmer gradient sweep effect to any composable.
 *
 * The gradient translates horizontally across the component width on an infinite loop,
 * producing a loading-placeholder animation. Uses [XGMotion.Shimmer] design tokens for
 * duration, angle, and gradient colors — no hardcoded values.
 *
 * GPU-accelerated via [graphicsLayer] to ensure smooth 60 fps during scroll.
 *
 * @param enabled When `false` the modifier is a no-op (returns the chain unchanged).
 */
fun Modifier.shimmerEffect(enabled: Boolean = true): Modifier {
    if (!enabled) return this
    return composed {
        val transition = rememberInfiniteTransition(label = "shimmer")
        val translateAnimation by transition.animateFloat(
            initialValue = 0f,
            targetValue = 1f,
            animationSpec = infiniteRepeatable(
                animation = tween(
                    durationMillis = XGMotion.Shimmer.DURATION_MS,
                    easing = LinearEasing,
                ),
                repeatMode = RepeatMode.Restart,
            ),
            label = "shimmerTranslate",
        )

        val angleRadians = Math.toRadians(XGMotion.Shimmer.ANGLE_DEGREES.toDouble()).toFloat()

        graphicsLayer { }
            .drawWithContent {
                drawContent()

                val gradientWidth = size.width
                val tanAngle = tan(angleRadians)
                val yOffset = tanAngle * gradientWidth

                // Shift the gradient from off-screen left to off-screen right
                val translateX = translateAnimation * (size.width + gradientWidth) - gradientWidth

                val brush = Brush.linearGradient(
                    colors = XGMotion.Shimmer.GradientColors,
                    start = Offset(translateX, -yOffset),
                    end = Offset(translateX + gradientWidth, yOffset),
                )

                drawRect(brush = brush)
            }
    }
}

// region Preview

private val PreviewPlaceholderHeight = 16.dp
private val PreviewBoxHeight = 120.dp
private val PreviewCircleSize = 80.dp
private val PreviewTextWidthShort = 160.dp
private val PreviewTextWidthLong = 220.dp

@Preview(showBackground = true)
@Composable
private fun ShimmerEffectPreview() {
    XGTheme {
        Column(
            modifier = Modifier.padding(XGSpacing.Base),
            verticalArrangement = Arrangement.spacedBy(XGSpacing.Base),
        ) {
            // Shimmer on a rectangular box
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(PreviewBoxHeight)
                    .clip(RoundedCornerShape(XGCornerRadius.Medium))
                    .background(XGMotion.Shimmer.GradientColors.first())
                    .shimmerEffect(),
            )

            // Shimmer on a circle
            Box(
                modifier = Modifier
                    .size(PreviewCircleSize)
                    .clip(CircleShape)
                    .background(XGMotion.Shimmer.GradientColors.first())
                    .shimmerEffect(),
            )

            // Shimmer on text-width placeholders
            Column(verticalArrangement = Arrangement.spacedBy(XGSpacing.SM)) {
                Box(
                    modifier = Modifier
                        .width(PreviewTextWidthLong)
                        .height(PreviewPlaceholderHeight)
                        .clip(RoundedCornerShape(XGCornerRadius.Small))
                        .background(XGMotion.Shimmer.GradientColors.first())
                        .shimmerEffect(),
                )
                Box(
                    modifier = Modifier
                        .width(PreviewTextWidthShort)
                        .height(PreviewPlaceholderHeight)
                        .clip(RoundedCornerShape(XGCornerRadius.Small))
                        .background(XGMotion.Shimmer.GradientColors.first())
                        .shimmerEffect(),
                )
            }

            // Disabled shimmer (static)
            Spacer(modifier = Modifier.height(XGSpacing.SM))
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(PreviewPlaceholderHeight)
                    .clip(RoundedCornerShape(XGCornerRadius.Small))
                    .background(XGMotion.Shimmer.GradientColors.first())
                    .shimmerEffect(enabled = false),
            )
        }
    }
}

// endregion
