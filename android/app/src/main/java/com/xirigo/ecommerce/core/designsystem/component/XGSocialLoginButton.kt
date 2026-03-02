package com.xirigo.ecommerce.core.designsystem.component

import androidx.annotation.StringRes
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.theme.XGColors
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme
import com.xirigo.ecommerce.core.designsystem.theme.XGTypography

// Token source: components/molecules/xg-social-login-button.json
// Height from buttonSize.social.height (44dp)
private val SocialButtonHeight = 44.dp
private val SocialIconSize = 20.dp
private val SpinnerStrokeWidth = 2.dp
private const val DISABLED_ALPHA = 0.38f

/**
 * Social authentication provider identifiers.
 *
 * Each variant holds its own localized label resource and icon color information
 * sourced from `foundations/colors.json > socialAuth`.
 */
enum class SocialLoginProvider(
    @StringRes val labelRes: Int,
) {
    Google(labelRes = R.string.auth_social_continue_google),
    Apple(labelRes = R.string.auth_social_continue_apple),
}

/**
 * Social login button for the authentication screen.
 *
 * Renders a provider icon and localized label inside an outlined surface button.
 * Width is intentionally *not* fixed: callers are expected to pass
 * `Modifier.weight(1f)` when the buttons sit side by side in a [Row].
 *
 * Token reference: `components/molecules/xg-social-login-button.json`
 *
 * @param provider  The social login provider (Google or Apple).
 * @param onClick   Called when the button is tapped (ignored while [loading]).
 * @param modifier  Optional [Modifier] (apply `.weight(1f)` for equal sizing).
 * @param loading   When `true`, the icon is replaced by a progress spinner.
 * @param enabled   When `false`, the button is rendered at reduced opacity.
 */
@Composable
fun XGSocialLoginButton(
    provider: SocialLoginProvider,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    loading: Boolean = false,
    enabled: Boolean = true,
) {
    val label = stringResource(provider.labelRes)
    val loadingText = stringResource(R.string.common_loading_message)
    val isInteractive = enabled && !loading
    val alpha = if (enabled) 1f else DISABLED_ALPHA

    OutlinedButton(
        onClick = onClick,
        modifier = modifier
            .height(SocialButtonHeight)
            .semantics {
                contentDescription = if (loading) loadingText else label
            },
        enabled = isInteractive,
        shape = RoundedCornerShape(XGCornerRadius.Medium),
        colors = socialButtonColors(alpha),
        border = socialButtonBorder(enabled, alpha),
    ) {
        SocialButtonContent(provider = provider, loading = loading, enabled = enabled, label = label, alpha = alpha)
    }
}

@Composable
private fun SocialButtonContent(
    provider: SocialLoginProvider,
    loading: Boolean,
    enabled: Boolean,
    label: String,
    alpha: Float,
) {
    SocialButtonIcon(provider = provider, loading = loading)
    Spacer(modifier = Modifier.width(XGSpacing.SM))
    Text(
        text = label,
        style = XGTypography.labelLarge,
        color = if (enabled) XGColors.OnSurface else XGColors.OnSurface.copy(alpha = alpha),
    )
}

@Composable
private fun SocialButtonIcon(provider: SocialLoginProvider, loading: Boolean) {
    if (loading) {
        CircularProgressIndicator(
            modifier = Modifier.size(SocialIconSize),
            strokeWidth = SpinnerStrokeWidth,
            color = XGColors.OnSurface,
        )
    } else {
        ProviderIcon(provider = provider)
    }
}

@Composable
private fun ProviderIcon(provider: SocialLoginProvider) {
    when (provider) {
        SocialLoginProvider.Google -> GoogleIcon(modifier = Modifier.size(SocialIconSize))
        SocialLoginProvider.Apple -> AppleIcon(modifier = Modifier.size(SocialIconSize))
    }
}

@Composable
private fun socialButtonColors(alpha: Float) = ButtonDefaults.outlinedButtonColors(
    containerColor = XGColors.Surface,
    contentColor = XGColors.OnSurface,
    disabledContainerColor = XGColors.Surface.copy(alpha = alpha),
    disabledContentColor = XGColors.OnSurface.copy(alpha = alpha),
)

private fun socialButtonBorder(enabled: Boolean, alpha: Float) = BorderStroke(
    width = 1.dp,
    color = if (enabled) XGColors.Outline else XGColors.Outline.copy(alpha = alpha),
)

// region Icon composables

/** Google "G" icon rendered as styled text with brand blue color. */
@Composable
private fun GoogleIcon(modifier: Modifier = Modifier) {
    Text(
        text = "G",
        modifier = modifier,
        color = XGColors.SocialGoogleBlue,
        style = XGTypography.labelLarge,
    )
}

/** Apple logo rendered via Unicode character (U+F8FF) with brand black color. */
@Composable
private fun AppleIcon(modifier: Modifier = Modifier) {
    Text(
        text = "\uF8FF",
        modifier = modifier,
        color = XGColors.SocialAppleBlack,
        style = XGTypography.labelLarge,
    )
}

// endregion

// region Previews

@Preview(showBackground = true)
@Composable
private fun XGSocialLoginButtonGooglePreview() {
    XGTheme {
        XGSocialLoginButton(
            provider = SocialLoginProvider.Google,
            onClick = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGSocialLoginButtonApplePreview() {
    XGTheme {
        XGSocialLoginButton(
            provider = SocialLoginProvider.Apple,
            onClick = {},
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun XGSocialLoginButtonRowPreview() {
    XGTheme {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            XGSocialLoginButton(
                provider = SocialLoginProvider.Google,
                onClick = {},
                modifier = Modifier.weight(1f),
            )
            XGSocialLoginButton(
                provider = SocialLoginProvider.Apple,
                onClick = {},
                modifier = Modifier.weight(1f),
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGSocialLoginButtonLoadingPreview() {
    XGTheme {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            XGSocialLoginButton(
                provider = SocialLoginProvider.Google,
                onClick = {},
                modifier = Modifier.weight(1f),
                loading = true,
            )
            XGSocialLoginButton(
                provider = SocialLoginProvider.Apple,
                onClick = {},
                modifier = Modifier.weight(1f),
                loading = true,
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun XGSocialLoginButtonDisabledPreview() {
    XGTheme {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM),
        ) {
            XGSocialLoginButton(
                provider = SocialLoginProvider.Google,
                onClick = {},
                modifier = Modifier.weight(1f),
                enabled = false,
            )
            XGSocialLoginButton(
                provider = SocialLoginProvider.Apple,
                onClick = {},
                modifier = Modifier.weight(1f),
                enabled = false,
            )
        }
    }
}

// endregion
