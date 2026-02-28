package com.xirigo.ecommerce.feature.onboarding.presentation.screen

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography
import com.xirigo.ecommerce.feature.onboarding.domain.model.OnboardingPage

private const val DESCRIPTION_ALPHA = 0.8f

@Composable
fun OnboardingPageContent(
    page: OnboardingPage,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = XGSpacing.XL),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(modifier = Modifier.weight(1f))

        Image(
            painter = painterResource(id = page.illustrationResId),
            contentDescription = stringResource(page.titleResId),
            modifier = Modifier.size(200.dp),
        )

        Spacer(modifier = Modifier.height(XGSpacing.XXL))

        Text(
            text = stringResource(page.titleResId),
            style = XGTypography.headlineSmall,
            fontWeight = FontWeight.SemiBold,
            color = Color.White,
            textAlign = TextAlign.Center,
            maxLines = 2,
            modifier = Modifier.semantics { heading() },
        )

        Spacer(modifier = Modifier.height(XGSpacing.MD))

        Text(
            text = stringResource(page.descriptionResId),
            style = XGTypography.bodyLarge,
            color = Color.White.copy(alpha = DESCRIPTION_ALPHA),
            textAlign = TextAlign.Center,
            maxLines = 3,
        )

        Spacer(modifier = Modifier.weight(1f))
    }
}

@Preview(showBackground = true, backgroundColor = 0xFF6000FE)
@Composable
private fun OnboardingPageContentPreview() {
    XGTheme {
        OnboardingPageContent(
            page = OnboardingPage(
                titleResId = R.string.onboarding_page_browse_title,
                descriptionResId = R.string.onboarding_page_browse_description,
                illustrationResId = R.drawable.onboarding_illustration_browse,
            ),
        )
    }
}
