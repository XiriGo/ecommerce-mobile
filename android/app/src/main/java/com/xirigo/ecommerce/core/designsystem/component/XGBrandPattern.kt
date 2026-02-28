package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

private const val PATTERN_OPACITY = 0.06f
private const val TILE_SIZE = 48f

@Composable
fun XGBrandPattern(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier.fillMaxSize()) {
        val cols = (size.width / TILE_SIZE).toInt() + 1
        val rows = (size.height / TILE_SIZE).toInt() + 1
        val patternColor = Color.White.copy(alpha = PATTERN_OPACITY)

        for (row in 0..rows) {
            for (col in 0..cols) {
                val cx = col * TILE_SIZE
                val cy = row * TILE_SIZE
                drawXMotif(cx, cy, TILE_SIZE, patternColor)
            }
        }
    }
}

private fun DrawScope.drawXMotif(
    cx: Float,
    cy: Float,
    tileSize: Float,
    color: Color,
) {
    val half = tileSize / 2f
    val arm = tileSize * 0.15f

    val path = Path().apply {
        moveTo(cx + half, cy + arm)
        lineTo(cx + half + arm, cy)
        lineTo(cx + tileSize, cy + half - arm)
        lineTo(cx + tileSize - arm, cy + half)
        lineTo(cx + tileSize, cy + half + arm)
        lineTo(cx + half + arm, cy + tileSize)
        lineTo(cx + half, cy + tileSize - arm)
        lineTo(cx + half - arm, cy + tileSize)
        lineTo(cx, cy + half + arm)
        lineTo(cx + arm, cy + half)
        lineTo(cx, cy + half - arm)
        lineTo(cx + half - arm, cy)
        close()
    }

    drawPath(path = path, color = color)
}

@Preview(showBackground = true)
@Composable
private fun XGBrandPatternPreview() {
    XGTheme {
        XGBrandPattern(modifier = Modifier.height(400.dp))
    }
}
