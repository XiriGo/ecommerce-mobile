package com.xirigo.ecommerce.core.designsystem.theme

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import androidx.compose.animation.core.AnimationSpec
import androidx.compose.animation.core.SpringSpec
import androidx.compose.animation.core.TweenSpec
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

class XGMotionTest {

    // region Duration

    @Test
    fun `Duration INSTANT should match motion json instant value`() {
        assertThat(XGMotion.Duration.INSTANT).isEqualTo(100)
    }

    @Test
    fun `Duration FAST should match motion json fast value`() {
        assertThat(XGMotion.Duration.FAST).isEqualTo(200)
    }

    @Test
    fun `Duration NORMAL should match motion json normal value`() {
        assertThat(XGMotion.Duration.NORMAL).isEqualTo(300)
    }

    @Test
    fun `Duration SLOW should match motion json slow value`() {
        assertThat(XGMotion.Duration.SLOW).isEqualTo(450)
    }

    @Test
    fun `Duration PAGE_TRANSITION should match motion json pageTransition value`() {
        assertThat(XGMotion.Duration.PAGE_TRANSITION).isEqualTo(350)
    }

    @Test
    fun `Duration values should increase from instant to slow`() {
        assertThat(XGMotion.Duration.INSTANT).isLessThan(XGMotion.Duration.FAST)
        assertThat(XGMotion.Duration.FAST).isLessThan(XGMotion.Duration.NORMAL)
        assertThat(XGMotion.Duration.NORMAL).isLessThan(XGMotion.Duration.SLOW)
    }

    @Test
    fun `Duration PAGE_TRANSITION should be between NORMAL and SLOW`() {
        assertThat(XGMotion.Duration.PAGE_TRANSITION).isGreaterThan(XGMotion.Duration.NORMAL)
        assertThat(XGMotion.Duration.PAGE_TRANSITION).isLessThan(XGMotion.Duration.SLOW)
    }

    // endregion

    // region Shimmer

    @Test
    fun `Shimmer DURATION_MS should be 1200ms`() {
        assertThat(XGMotion.Shimmer.DURATION_MS).isEqualTo(1200)
    }

    @Test
    fun `Shimmer ANGLE_DEGREES should be 20`() {
        assertThat(XGMotion.Shimmer.ANGLE_DEGREES).isEqualTo(20)
    }

    @Test
    fun `Shimmer REPEAT_MODE_RESTART should be true`() {
        assertThat(XGMotion.Shimmer.REPEAT_MODE_RESTART).isTrue()
    }

    @Test
    fun `Shimmer GradientColors should have exactly 3 colors`() {
        assertThat(XGMotion.Shimmer.GradientColors).hasSize(3)
    }

    @Test
    fun `Shimmer GradientColors first and last should be the same base color`() {
        assertThat(XGMotion.Shimmer.GradientColors.first())
            .isEqualTo(XGMotion.Shimmer.GradientColors.last())
    }

    @Test
    fun `Shimmer GradientColors should match design token hex values`() {
        assertThat(XGMotion.Shimmer.GradientColors[0]).isEqualTo(Color(0xFFE0E0E0))
        assertThat(XGMotion.Shimmer.GradientColors[1]).isEqualTo(Color(0xFFF5F5F5))
        assertThat(XGMotion.Shimmer.GradientColors[2]).isEqualTo(Color(0xFFE0E0E0))
    }

    // endregion

    // region Crossfade

    @Test
    fun `Crossfade IMAGE_FADE_IN should be 300ms`() {
        assertThat(XGMotion.Crossfade.IMAGE_FADE_IN).isEqualTo(300)
    }

    @Test
    fun `Crossfade CONTENT_SWITCH should be 200ms`() {
        assertThat(XGMotion.Crossfade.CONTENT_SWITCH).isEqualTo(200)
    }

    @Test
    fun `Crossfade IMAGE_FADE_IN should be longer than CONTENT_SWITCH`() {
        assertThat(XGMotion.Crossfade.IMAGE_FADE_IN).isGreaterThan(XGMotion.Crossfade.CONTENT_SWITCH)
    }

    // endregion

    // region Scroll

    @Test
    fun `Scroll PREFETCH_DISTANCE should be 5`() {
        assertThat(XGMotion.Scroll.PREFETCH_DISTANCE).isEqualTo(5)
    }

    @Test
    fun `Scroll SCROLL_RESTORATION_ENABLED should be true`() {
        assertThat(XGMotion.Scroll.SCROLL_RESTORATION_ENABLED).isTrue()
    }

    @Test
    fun `Scroll AUTO_SCROLL_INTERVAL_MS should be 5000`() {
        assertThat(XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS).isEqualTo(5000L)
    }

    @Test
    fun `Scroll AUTO_SCROLL_INTERVAL_MS should be positive`() {
        assertThat(XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS).isGreaterThan(0L)
    }

    // endregion

    // region EntranceAnimation

    @Test
    fun `EntranceAnimation STAGGER_DELAY_MS should be 50ms`() {
        assertThat(XGMotion.EntranceAnimation.STAGGER_DELAY_MS).isEqualTo(50)
    }

    @Test
    fun `EntranceAnimation MAX_STAGGER_ITEMS should be 8`() {
        assertThat(XGMotion.EntranceAnimation.MAX_STAGGER_ITEMS).isEqualTo(8)
    }

    @Test
    fun `EntranceAnimation FADE_FROM should be 0f`() {
        assertThat(XGMotion.EntranceAnimation.FADE_FROM).isEqualTo(0f)
    }

    @Test
    fun `EntranceAnimation FADE_TO should be 1f`() {
        assertThat(XGMotion.EntranceAnimation.FADE_TO).isEqualTo(1f)
    }

    @Test
    fun `EntranceAnimation SlideOffsetY should be 20dp`() {
        assertThat(XGMotion.EntranceAnimation.SlideOffsetY).isEqualTo(20.dp)
    }

    @Test
    fun `EntranceAnimation fade range should span from transparent to opaque`() {
        assertThat(XGMotion.EntranceAnimation.FADE_FROM).isLessThan(XGMotion.EntranceAnimation.FADE_TO)
    }

    // endregion

    // region Performance

    @Test
    fun `Performance FRAME_TIME_MS should be 16ms`() {
        assertThat(XGMotion.Performance.FRAME_TIME_MS).isEqualTo(16)
    }

    @Test
    fun `Performance STARTUP_COLD_MS should be 2000ms`() {
        assertThat(XGMotion.Performance.STARTUP_COLD_MS).isEqualTo(2000)
    }

    @Test
    fun `Performance SCREEN_TRANSITION_MS should be 300ms`() {
        assertThat(XGMotion.Performance.SCREEN_TRANSITION_MS).isEqualTo(300)
    }

    @Test
    fun `Performance LIST_SCROLL_FPS should be 60`() {
        assertThat(XGMotion.Performance.LIST_SCROLL_FPS).isEqualTo(60)
    }

    @Test
    fun `Performance FIRST_CONTENTFUL_PAINT_MS should be 1000ms`() {
        assertThat(XGMotion.Performance.FIRST_CONTENTFUL_PAINT_MS).isEqualTo(1000)
    }

    @Test
    fun `Performance FRAME_TIME_MS should equal 1000ms divided by LIST_SCROLL_FPS`() {
        val expectedFrameTime = 1000 / XGMotion.Performance.LIST_SCROLL_FPS
        assertThat(XGMotion.Performance.FRAME_TIME_MS).isEqualTo(expectedFrameTime)
    }

    // endregion

    // region Easing

    @Test
    fun `Easing standardTween with default duration returns AnimationSpec`() {
        val spec: AnimationSpec<Float> = XGMotion.Easing.standardTween()
        assertThat(spec).isNotNull()
    }

    @Test
    fun `Easing standardTween with custom duration returns TweenSpec`() {
        val spec: AnimationSpec<Float> = XGMotion.Easing.standardTween(durationMillis = 500)
        assertThat(spec).isInstanceOf(TweenSpec::class.java)
    }

    @Test
    fun `Easing standardTween default duration uses Duration NORMAL`() {
        val specDefault: TweenSpec<Float> = XGMotion.Easing.standardTween()
        val specExplicit: TweenSpec<Float> = XGMotion.Easing.standardTween(
            durationMillis = XGMotion.Duration.NORMAL,
        )
        assertThat(specDefault.durationMillis).isEqualTo(specExplicit.durationMillis)
    }

    @Test
    fun `Easing decelerateTween with default duration returns AnimationSpec`() {
        val spec: AnimationSpec<Float> = XGMotion.Easing.decelerateTween()
        assertThat(spec).isNotNull()
    }

    @Test
    fun `Easing decelerateTween with custom duration returns TweenSpec`() {
        val spec: AnimationSpec<Float> = XGMotion.Easing.decelerateTween(durationMillis = 400)
        assertThat(spec).isInstanceOf(TweenSpec::class.java)
    }

    @Test
    fun `Easing decelerateTween default duration uses Duration NORMAL`() {
        val specDefault: TweenSpec<Float> = XGMotion.Easing.decelerateTween()
        val specExplicit: TweenSpec<Float> = XGMotion.Easing.decelerateTween(
            durationMillis = XGMotion.Duration.NORMAL,
        )
        assertThat(specDefault.durationMillis).isEqualTo(specExplicit.durationMillis)
    }

    @Test
    fun `Easing accelerateTween with default duration returns AnimationSpec`() {
        val spec: AnimationSpec<Float> = XGMotion.Easing.accelerateTween()
        assertThat(spec).isNotNull()
    }

    @Test
    fun `Easing accelerateTween with custom duration returns TweenSpec`() {
        val spec: AnimationSpec<Float> = XGMotion.Easing.accelerateTween(durationMillis = 150)
        assertThat(spec).isInstanceOf(TweenSpec::class.java)
    }

    @Test
    fun `Easing accelerateTween default duration uses Duration FAST`() {
        val specDefault: TweenSpec<Float> = XGMotion.Easing.accelerateTween()
        val specExplicit: TweenSpec<Float> = XGMotion.Easing.accelerateTween(
            durationMillis = XGMotion.Duration.FAST,
        )
        assertThat(specDefault.durationMillis).isEqualTo(specExplicit.durationMillis)
    }

    @Test
    fun `Easing springSpec returns AnimationSpec`() {
        val spec: AnimationSpec<Float> = XGMotion.Easing.springSpec()
        assertThat(spec).isNotNull()
    }

    @Test
    fun `Easing springSpec returns SpringSpec`() {
        val spec: AnimationSpec<Float> = XGMotion.Easing.springSpec<Float>()
        assertThat(spec).isInstanceOf(SpringSpec::class.java)
    }

    @Test
    fun `Easing tween specs are distinct instances`() {
        val standard: AnimationSpec<Float> = XGMotion.Easing.standardTween()
        val decelerate: AnimationSpec<Float> = XGMotion.Easing.decelerateTween()
        val accelerate: AnimationSpec<Float> = XGMotion.Easing.accelerateTween()
        // Each factory call produces a new spec instance
        assertThat(standard).isNotSameInstanceAs(decelerate)
        assertThat(decelerate).isNotSameInstanceAs(accelerate)
    }

    @Test
    fun `Easing springSpec produces distinct instances on each call`() {
        val spec1: AnimationSpec<Float> = XGMotion.Easing.springSpec()
        val spec2: AnimationSpec<Float> = XGMotion.Easing.springSpec()
        assertThat(spec1).isNotSameInstanceAs(spec2)
    }

    // endregion
}
