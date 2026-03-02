package com.xirigo.ecommerce.core.designsystem.theme

import androidx.compose.animation.core.FastOutLinearInEasing
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

/**
 * Motion, animation, and performance tokens for the XiriGo design system.
 *
 * All values are sourced from `shared/design-tokens/foundations/motion.json`.
 * Components and feature screens reference these constants instead of hardcoding
 * animation durations, easing curves, or performance thresholds.
 */
object XGMotion {

    /**
     * Standard duration values for animations and transitions.
     * All values are in milliseconds.
     */
    object Duration {
        const val INSTANT = 100 // duration.instant
        const val FAST = 200 // duration.fast
        const val NORMAL = 300 // duration.normal
        const val SLOW = 450 // duration.slow
        const val PAGE_TRANSITION = 350 // duration.pageTransition
    }

    /**
     * Easing curves and spring specifications for natural-feeling animations.
     *
     * - `standard`: general-purpose ease-in-out (FastOutSlowIn)
     * - `decelerate`: elements entering view (LinearOutSlowIn)
     * - `accelerate`: elements leaving view (FastOutLinearIn)
     * - `spring`: physics-based spring with moderate bounce
     */
    object Easing {
        /** Physics-based spring damping ratio for moderate bounce. */
        private const val SPRING_DAMPING_RATIO = 0.7f

        /** General-purpose ease-in-out curve. */
        fun <T> standardTween(durationMillis: Int = Duration.NORMAL) =
            tween<T>(durationMillis = durationMillis, easing = FastOutSlowInEasing)

        /** Deceleration curve for elements entering the viewport. */
        fun <T> decelerateTween(durationMillis: Int = Duration.NORMAL) =
            tween<T>(durationMillis = durationMillis, easing = LinearOutSlowInEasing)

        /** Acceleration curve for elements leaving the viewport. */
        fun <T> accelerateTween(durationMillis: Int = Duration.FAST) =
            tween<T>(durationMillis = durationMillis, easing = FastOutLinearInEasing)

        /** Physics-based spring with moderate bounce. */
        fun <T> springSpec() = spring<T>(
            dampingRatio = SPRING_DAMPING_RATIO,
            stiffness = Spring.StiffnessMedium,
        )
    }

    /**
     * Shimmer animation parameters for loading placeholders.
     *
     * All loading placeholders MUST use an animated shimmer gradient sweep,
     * never a static color.
     */
    object Shimmer {
        const val DURATION_MS = 1200 // shimmer.durationMs
        const val ANGLE_DEGREES = 20 // shimmer.angleDegrees
        const val REPEAT_MODE_RESTART = true // shimmer.repeatMode = "restart"

        /** Gradient colors for the shimmer sweep effect (from shimmer.gradientColors). */
        val GradientColors: List<Color> = listOf(
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
        )
    }

    /**
     * Crossfade animation durations for image loading and content switching.
     * All values are in milliseconds.
     */
    object Crossfade {
        const val IMAGE_FADE_IN = 300 // crossfade.imageFadeIn
        const val CONTENT_SWITCH = 200 // crossfade.contentSwitch
    }

    /**
     * Scroll behavior configuration for lazy lists and grids.
     *
     * All scrollable lists MUST use lazy rendering (LazyColumn/LazyRow/LazyVGrid).
     * Never use Column+verticalScroll for lists with more than 4 items.
     */
    object Scroll {
        const val PREFETCH_DISTANCE = 5 // scroll.prefetchDistance
        const val SCROLL_RESTORATION_ENABLED = true // scroll.scrollRestorationEnabled
        const val AUTO_SCROLL_INTERVAL_MS = 5000L // scroll.autoScrollIntervalMs
    }

    /**
     * Entrance animation parameters for staggered list-item reveals.
     *
     * Used only on first screen load, not for paginated items.
     * Keep animations subtle to avoid distracting the user.
     */
    object EntranceAnimation {
        const val STAGGER_DELAY_MS = 50 // entranceAnimation.staggerDelayMs
        const val MAX_STAGGER_ITEMS = 8 // entranceAnimation.maxStaggerItems
        const val FADE_FROM = 0f // entranceAnimation.fadeFromOpacity
        const val FADE_TO = 1f // entranceAnimation.fadeToOpacity
        val SlideOffsetY = 20.dp // entranceAnimation.slideOffsetY
    }

    /**
     * Performance budget thresholds used for profiling and monitoring.
     *
     * Profile with Android Studio Profiler. Target zero jank frames during scroll.
     */
    object Performance {
        const val FRAME_TIME_MS = 16 // performanceBudgets.frameTimeMs
        const val STARTUP_COLD_MS = 2000 // performanceBudgets.startupColdMs
        const val SCREEN_TRANSITION_MS = 300 // performanceBudgets.screenTransitionMs
        const val LIST_SCROLL_FPS = 60 // performanceBudgets.listScrollFps
        const val FIRST_CONTENTFUL_PAINT_MS = 1000 // performanceBudgets.firstContentfulPaintMs
    }
}

// region Preview

@Preview(showBackground = true)
@Composable
private fun XGMotionTokenPreview() {
    XGTheme {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(XGSpacing.Base),
            verticalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            Text(
                text = "XGMotion Tokens",
                style = MaterialTheme.typography.headlineSmall,
            )

            Spacer(modifier = Modifier.height(XGSpacing.SM))

            Text(
                text = "Duration: instant=${XGMotion.Duration.INSTANT}ms, " +
                    "fast=${XGMotion.Duration.FAST}ms, " +
                    "normal=${XGMotion.Duration.NORMAL}ms, " +
                    "slow=${XGMotion.Duration.SLOW}ms",
                style = MaterialTheme.typography.bodySmall,
            )

            Text(
                text = "Shimmer: duration=${XGMotion.Shimmer.DURATION_MS}ms, " +
                    "angle=${XGMotion.Shimmer.ANGLE_DEGREES} deg",
                style = MaterialTheme.typography.bodySmall,
            )

            Text(
                text = "Crossfade: imageFadeIn=${XGMotion.Crossfade.IMAGE_FADE_IN}ms, " +
                    "contentSwitch=${XGMotion.Crossfade.CONTENT_SWITCH}ms",
                style = MaterialTheme.typography.bodySmall,
            )

            Text(
                text = "Scroll: prefetch=${XGMotion.Scroll.PREFETCH_DISTANCE}, " +
                    "restoration=${XGMotion.Scroll.SCROLL_RESTORATION_ENABLED}",
                style = MaterialTheme.typography.bodySmall,
            )

            Text(
                text = "Entrance: stagger=${XGMotion.EntranceAnimation.STAGGER_DELAY_MS}ms, " +
                    "maxItems=${XGMotion.EntranceAnimation.MAX_STAGGER_ITEMS}, " +
                    "slideY=${XGMotion.EntranceAnimation.SlideOffsetY}",
                style = MaterialTheme.typography.bodySmall,
            )

            Text(
                text = "Performance: frame=${XGMotion.Performance.FRAME_TIME_MS}ms, " +
                    "fps=${XGMotion.Performance.LIST_SCROLL_FPS}",
                style = MaterialTheme.typography.bodySmall,
            )

            Spacer(modifier = Modifier.height(XGSpacing.SM))

            Text(
                text = "Shimmer Gradient Colors:",
                style = MaterialTheme.typography.labelMedium,
            )

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(XGSpacing.XXL)
                    .background(XGMotion.Shimmer.GradientColors[0]),
            )

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(XGSpacing.XXL)
                    .background(XGMotion.Shimmer.GradientColors[1]),
            )
        }
    }
}

// endregion
