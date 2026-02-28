package com.xirigo.ecommerce.feature.onboarding.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.xirigo.ecommerce.core.designsystem.component.XGBrandGradient
import com.xirigo.ecommerce.core.designsystem.component.XGBrandPattern
import com.xirigo.ecommerce.core.designsystem.component.XGLogoMark
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

@Composable
fun SplashScreen(modifier: Modifier = Modifier) {
    Box(modifier = modifier.fillMaxSize()) {
        XGBrandGradient()

        XGBrandPattern()

        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center,
        ) {
            XGLogoMark()
        }

        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    brush = Brush.verticalGradient(
                        colorStops = arrayOf(
                            0.0f to Color.Transparent,
                            0.7f to Color.Transparent,
                            1.0f to Color.Black.copy(alpha = 0.3f),
                        ),
                    ),
                ),
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun SplashScreenPreview() {
    XGTheme {
        SplashScreen()
    }
}
