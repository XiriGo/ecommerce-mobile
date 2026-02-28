package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

private val LogoGreen = Color(0xFF94D63A)

@Composable
fun XGLogoMark(
    modifier: Modifier = Modifier,
    size: Dp = 120.dp,
) {
    val height = size * 1.03f

    Box(
        modifier = modifier
            .size(width = size, height = height)
            .semantics { contentDescription = "XiriGo logo" },
        contentAlignment = Alignment.Center,
    ) {
        Canvas(modifier = Modifier.size(width = size, height = height)) {
            val w = this.size.width
            val h = this.size.height
            val midX = w / 2f
            val chevronHeight = h * 0.45f
            val gap = h * 0.05f

            val topChevron = Path().apply {
                moveTo(midX, 0f)
                lineTo(w, chevronHeight)
                lineTo(midX, chevronHeight * 0.6f)
                lineTo(0f, chevronHeight)
                close()
            }
            drawPath(path = topChevron, color = LogoGreen)

            val bottomTop = chevronHeight + gap
            val bottomChevron = Path().apply {
                moveTo(0f, bottomTop)
                lineTo(midX, bottomTop + chevronHeight * 0.4f)
                lineTo(w, bottomTop)
                lineTo(midX, bottomTop + chevronHeight)
                close()
            }
            drawPath(path = bottomChevron, color = Color.White)
        }
    }
}

@Preview(showBackground = true, backgroundColor = 0xFF6000FE)
@Composable
private fun XGLogoMarkPreview() {
    XGTheme {
        XGLogoMark()
    }
}

@Preview(showBackground = true, backgroundColor = 0xFF6000FE)
@Composable
private fun XGLogoMarkSmallPreview() {
    XGTheme {
        XGLogoMark(size = 60.dp)
    }
}
