package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

private val BaseGradientStops = arrayOf(
    0.00f to Color(0xFF9000FE),
    0.27f to Color(0xFF6900FE),
    0.66f to Color(0xFF6900FE),
    1.00f to Color(0xFF9000FE),
)

private val DarkOverlayStops = arrayOf(
    0.32f to Color(0x006000FE),
    0.38f to Color(0x0F5D00FB),
    0.49f to Color(0x365800F4),
    0.64f to Color(0x754F00E9),
    0.81f to Color(0xCF4200DA),
    0.90f to Color(0xFF3C00D2),
)

@Composable
fun XGBrandGradient(
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit = {},
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .drawBehind {
                val center = Offset(size.width * 0.5f, size.height * 0.3f)
                val radius = maxOf(size.width, size.height)

                drawRect(
                    brush = Brush.radialGradient(
                        colorStops = BaseGradientStops,
                        center = center,
                        radius = radius,
                    ),
                )
                drawRect(
                    brush = Brush.radialGradient(
                        colorStops = DarkOverlayStops,
                        center = center,
                        radius = radius,
                    ),
                )
            },
        content = content,
    )
}

@Preview(showBackground = true)
@Composable
private fun XGBrandGradientPreview() {
    XGTheme {
        XGBrandGradient(modifier = Modifier.height(400.dp))
    }
}
