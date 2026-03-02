package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

/** Default logo size from xg-logo-mark.json > tokens.defaultSize. */
private val DEFAULT_LOGO_SIZE = 120.dp

/** XiriGo logo mark image at a configurable size. */
@Composable
fun XGLogoMark(modifier: Modifier = Modifier, size: Dp = DEFAULT_LOGO_SIZE) {
    Image(
        painter = painterResource(R.drawable.splash_logo),
        contentDescription = stringResource(R.string.onboarding_logo_a11y),
        modifier = modifier.size(size),
    )
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
