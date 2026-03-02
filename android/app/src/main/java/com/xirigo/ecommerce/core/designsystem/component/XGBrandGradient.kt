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
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Gradient stops sourced from gradients.json > brandHeader.layers[0] (base)
// Stops: #9000FE (edge) -> #6900FE (mid) -> #6900FE (mid) -> #9000FE (edge)
private val BaseGradientStops = arrayOf(
    0.00f to XGColors.BrandPrimaryLight,
    0.27f to XGColors.BrandGradientMid,
    0.66f to XGColors.BrandGradientMid,
    1.00f to XGColors.BrandPrimaryLight,
)

// Gradient stops sourced from gradients.json > brandHeader.layers[1] (darkOverlay)
// Stops: #6000FE@0% -> #5D00FB@6% -> #5800F4@21% -> #4F00E9@46% -> #4200DA@81% -> #3C00D2@100%
private val DarkOverlayStops = arrayOf(
    0.32f to XGColors.BrandPrimary.copy(alpha = 0.00f),
    0.38f to XGColors.BrandOverlayMid1.copy(alpha = 0.06f),
    0.49f to XGColors.BrandOverlayMid2.copy(alpha = 0.21f),
    0.64f to XGColors.BrandOverlayMid3.copy(alpha = 0.46f),
    0.81f to XGColors.BrandOverlayMid4.copy(alpha = 0.81f),
    0.90f to XGColors.BrandPrimaryDark,
)

/** XiriGo brand radial gradient background with dark overlay. */
@Composable
fun XGBrandGradient(modifier: Modifier = Modifier, content: @Composable BoxScope.() -> Unit = {}) {
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
