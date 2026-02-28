package com.xirigo.ecommerce.core.designsystem.component

import android.graphics.BitmapFactory
import android.graphics.Shader
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.ShaderBrush
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

private const val PATTERN_OPACITY = 0.06f

@Composable
fun XGBrandPattern(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val tiledBrush = remember {
        val bitmap = BitmapFactory.decodeResource(context.resources, R.drawable.xg_brand_pattern)
        val shader = android.graphics.BitmapShader(
            bitmap,
            Shader.TileMode.REPEAT,
            Shader.TileMode.REPEAT,
        )
        ShaderBrush(shader)
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .drawBehind {
                drawRect(
                    brush = tiledBrush,
                    alpha = PATTERN_OPACITY,
                )
            },
    )
}

@Preview(showBackground = true)
@Composable
private fun XGBrandPatternPreview() {
    XGTheme {
        XGBrandPattern(modifier = Modifier.height(400.dp))
    }
}
