package com.xirigo.ecommerce.core.designsystem.component

import kotlin.math.roundToInt
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.PoppinsFontFamily
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Token source: components/atoms/xg-range-slider.json
private val TrackHeight = 4.dp
private val ThumbSize = 24.dp
private val ThumbBorderWidth = 3.dp
private val LabelFontSize = 12.sp
private val LabelLineHeight = 16.sp
private val LabelTopPadding = 8.dp
private val SliderHeight = 48.dp // min touch target

/** Pixel measurements for the slider, resolved from density. */
private data class SliderMetrics(
    val thumbRadiusPx: Float,
    val trackHeightPx: Float,
    val thumbBorderPx: Float,
)

/** Resolved color tokens for the slider track and thumbs. */
private data class SliderColors(
    val trackActive: Color,
    val trackInactive: Color,
    val thumb: Color,
    val thumbBorder: Color,
)

/**
 * Dual-thumb range slider for selecting a numeric range.
 *
 * Token source: `components/atoms/xg-range-slider.json`.
 *
 * @param min Current lower bound of the selected range.
 * @param max Current upper bound of the selected range.
 * @param range Allowed value range.
 * @param onRangeChange Callback when either thumb moves; receives (newMin, newMax).
 * @param modifier Platform layout modifier.
 * @param step Step increment; 0 = continuous.
 * @param showLabels Show min/max value labels below the track.
 * @param labelFormatter Custom label formatting function.
 */
@Composable
fun XGRangeSlider(
    min: Float,
    max: Float,
    range: ClosedFloatingPointRange<Float>,
    onRangeChange: (Float, Float) -> Unit,
    modifier: Modifier = Modifier,
    step: Float = 0f,
    showLabels: Boolean = true,
    labelFormatter: (Float) -> String = { it.roundToInt().toString() },
) {
    val rangeDescription = stringResource(
        R.string.common_range_slider_description,
        labelFormatter(min),
        labelFormatter(max),
    )

    Column(modifier = modifier) {
        RangeSliderTrack(
            min = min,
            max = max,
            range = range,
            step = step,
            onRangeChange = onRangeChange,
            rangeDescription = rangeDescription,
        )

        if (showLabels) {
            RangeSliderLabels(
                min = min,
                max = max,
                labelFormatter = labelFormatter,
            )
        }
    }
}

@Composable
private fun RangeSliderTrack(
    min: Float,
    max: Float,
    range: ClosedFloatingPointRange<Float>,
    step: Float,
    onRangeChange: (Float, Float) -> Unit,
    rangeDescription: String,
) {
    val density = LocalDensity.current
    val metrics = SliderMetrics(
        thumbRadiusPx = with(density) { ThumbSize.toPx() / 2f },
        trackHeightPx = with(density) { TrackHeight.toPx() },
        thumbBorderPx = with(density) { ThumbBorderWidth.toPx() },
    )
    val colors = SliderColors(
        trackActive = XGColors.Primary,
        trackInactive = XGColors.Outline,
        thumb = XGColors.Primary,
        thumbBorder = XGColors.Surface,
    )

    var draggingThumb by remember { mutableFloatStateOf(0f) }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(SliderHeight)
            .semantics { contentDescription = rangeDescription }
            .rangeSliderDragInput(
                min = min,
                max = max,
                range = range,
                step = step,
                metrics = metrics,
                draggingThumb = draggingThumb,
                onDraggingThumbChange = { draggingThumb = it },
                onRangeChange = onRangeChange,
            ),
    ) {
        RangeSliderCanvas(
            min = min,
            max = max,
            range = range,
            metrics = metrics,
            colors = colors,
        )
    }
}

@Suppress("LongParameterList")
private fun Modifier.rangeSliderDragInput(
    min: Float,
    max: Float,
    range: ClosedFloatingPointRange<Float>,
    step: Float,
    metrics: SliderMetrics,
    draggingThumb: Float,
    onDraggingThumbChange: (Float) -> Unit,
    onRangeChange: (Float, Float) -> Unit,
): Modifier = pointerInput(range, step) {
    detectDragGestures(
        onDragStart = { offset ->
            val totalRange = range.endInclusive - range.start
            val trackWidth = size.width - 2 * metrics.thumbRadiusPx
            val lowX = metrics.thumbRadiusPx + (min - range.start) / totalRange * trackWidth
            val highX = metrics.thumbRadiusPx + (max - range.start) / totalRange * trackWidth
            val nearLow = kotlin.math.abs(offset.x - lowX) <= kotlin.math.abs(offset.x - highX)
            onDraggingThumbChange(if (nearLow) -1f else 1f)
        },
        onDrag = { change, _ ->
            change.consume()
            val totalRange = range.endInclusive - range.start
            val trackWidth = size.width - 2 * metrics.thumbRadiusPx
            val rawValue = range.start +
                (change.position.x - metrics.thumbRadiusPx) / trackWidth * totalRange
            val snappedValue = snapToStep(rawValue.coerceIn(range), step, range)
            if (draggingThumb < 0f) {
                onRangeChange(snappedValue.coerceAtMost(max), max)
            } else {
                onRangeChange(min, snappedValue.coerceAtLeast(min))
            }
        },
        onDragEnd = { onDraggingThumbChange(0f) },
        onDragCancel = { onDraggingThumbChange(0f) },
    )
}

@Composable
private fun RangeSliderCanvas(
    min: Float,
    max: Float,
    range: ClosedFloatingPointRange<Float>,
    metrics: SliderMetrics,
    colors: SliderColors,
) {
    Canvas(
        modifier = Modifier
            .fillMaxWidth()
            .height(SliderHeight),
    ) {
        val centerY = size.height / 2f
        val trackWidth = size.width - 2 * metrics.thumbRadiusPx
        val totalRange = range.endInclusive - range.start

        val lowFraction = if (totalRange > 0f) (min - range.start) / totalRange else 0f
        val highFraction = if (totalRange > 0f) (max - range.start) / totalRange else 1f
        val lowX = metrics.thumbRadiusPx + lowFraction * trackWidth
        val highX = metrics.thumbRadiusPx + highFraction * trackWidth
        val cornerRadius = CornerRadius(metrics.trackHeightPx / 2f)
        val trackTop = centerY - metrics.trackHeightPx / 2f

        drawTrackSegments(
            metrics.thumbRadiusPx,
            trackTop,
            metrics.trackHeightPx,
            trackWidth,
            lowX,
            highX,
            cornerRadius,
            colors,
        )
        drawThumb(colors, metrics, lowX, centerY)
        drawThumb(colors, metrics, highX, centerY)
    }
}

@Suppress("LongParameterList")
private fun DrawScope.drawTrackSegments(
    thumbRadiusPx: Float,
    trackTop: Float,
    trackHeightPx: Float,
    trackWidth: Float,
    lowX: Float,
    highX: Float,
    cornerRadius: CornerRadius,
    colors: SliderColors,
) {
    drawRoundRect(
        color = colors.trackInactive,
        topLeft = Offset(thumbRadiusPx, trackTop),
        size = Size(lowX - thumbRadiusPx, trackHeightPx),
        cornerRadius = cornerRadius,
    )
    drawRoundRect(
        color = colors.trackActive,
        topLeft = Offset(lowX, trackTop),
        size = Size(highX - lowX, trackHeightPx),
        cornerRadius = cornerRadius,
    )
    drawRoundRect(
        color = colors.trackInactive,
        topLeft = Offset(highX, trackTop),
        size = Size(thumbRadiusPx + trackWidth - highX, trackHeightPx),
        cornerRadius = cornerRadius,
    )
}

private fun DrawScope.drawThumb(
    colors: SliderColors,
    metrics: SliderMetrics,
    x: Float,
    y: Float,
) {
    val center = Offset(x, y)
    drawCircle(color = colors.thumb, radius = metrics.thumbRadiusPx, center = center)
    drawCircle(
        color = colors.thumbBorder,
        radius = metrics.thumbRadiusPx,
        center = center,
        style = Stroke(width = metrics.thumbBorderPx),
    )
}

@Composable
private fun RangeSliderLabels(
    min: Float,
    max: Float,
    labelFormatter: (Float) -> String,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = LabelTopPadding),
        horizontalArrangement = Arrangement.SpaceBetween,
    ) {
        Text(
            text = labelFormatter(min),
            fontFamily = PoppinsFontFamily,
            fontSize = LabelFontSize,
            fontWeight = FontWeight.Normal,
            color = XGColors.OnSurfaceVariant,
            lineHeight = LabelLineHeight,
        )
        Text(
            text = labelFormatter(max),
            fontFamily = PoppinsFontFamily,
            fontSize = LabelFontSize,
            fontWeight = FontWeight.Normal,
            color = XGColors.OnSurfaceVariant,
            lineHeight = LabelLineHeight,
        )
    }
}

private fun snapToStep(
    value: Float,
    step: Float,
    range: ClosedFloatingPointRange<Float>,
): Float {
    if (step <= 0f) return value
    val steps = ((value - range.start) / step).roundToInt()
    return (range.start + steps * step).coerceIn(range)
}

@Preview(showBackground = true)
@Composable
private fun XGRangeSliderPreview() {
    XGTheme {
        var min by remember { mutableFloatStateOf(25f) }
        var max by remember { mutableFloatStateOf(75f) }
        XGRangeSlider(
            min = min,
            max = max,
            range = 0f..100f,
            onRangeChange = { newMin, newMax ->
                min = newMin
                max = newMax
            },
            modifier = Modifier.padding(XGSpacing.Base),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGRangeSliderNoLabelsPreview() {
    XGTheme {
        XGRangeSlider(
            min = 200f,
            max = 800f,
            range = 0f..1000f,
            onRangeChange = { _, _ -> },
            showLabels = false,
            modifier = Modifier.padding(XGSpacing.Base),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGRangeSliderSteppedPreview() {
    XGTheme {
        XGRangeSlider(
            min = 20f,
            max = 80f,
            range = 0f..100f,
            onRangeChange = { _, _ -> },
            step = 10f,
            labelFormatter = { "$${it.roundToInt()}" },
            modifier = Modifier.padding(XGSpacing.Base),
        )
    }
}
