package com.xirigo.ecommerce.core.designsystem.component

import androidx.annotation.StringRes
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
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
        colors = ButtonDefaults.outlinedButtonColors(
            containerColor = XGColors.Surface,
            contentColor = XGColors.OnSurface,
            disabledContainerColor = XGColors.Surface.copy(alpha = alpha),
            disabledContentColor = XGColors.OnSurface.copy(alpha = alpha),
        ),
        border = BorderStroke(
            width = 1.dp,
            color = if (enabled) XGColors.Outline else XGColors.Outline.copy(alpha = alpha),
        ),
    ) {
        if (loading) {
            CircularProgressIndicator(
                modifier = Modifier.size(SocialIconSize),
                strokeWidth = SpinnerStrokeWidth,
                color = XGColors.OnSurface,
            )
        } else {
            when (provider) {
                SocialLoginProvider.Google -> GoogleIcon(
                    modifier = Modifier.size(SocialIconSize),
                )
                SocialLoginProvider.Apple -> AppleIcon(
                    modifier = Modifier.size(SocialIconSize),
                    color = XGColors.SocialAppleBlack,
                )
            }
        }
        Spacer(modifier = Modifier.width(XGSpacing.SM))
        Text(
            text = label,
            // Token: bodyMedium (14pt Medium) -> Material3 labelLarge slot
            style = XGTypography.labelLarge,
            color = if (enabled) XGColors.OnSurface else XGColors.OnSurface.copy(alpha = alpha),
        )
    }
}

// region Icon composables

/**
 * Multi-color Google "G" icon drawn via [Canvas].
 *
 * Colors from `socialAuth` tokens via [XGColors]:
 * googleBlue, googleGreen, googleYellow, googleRed.
 */
@Composable
private fun GoogleIcon(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height
        val cx = w / 2f
        val cy = h / 2f
        val r = w * 0.45f
        val strokeW = w * 0.18f

        val arcStyle = Stroke(width = strokeW)
        val arcTopLeft = Offset(cx - r, cy - r)
        val arcSize = Size(r * 2, r * 2)

        // Blue arc (right side)
        drawArc(
            color = XGColors.SocialGoogleBlue,
            startAngle = -45f,
            sweepAngle = 90f,
            useCenter = false,
            topLeft = arcTopLeft,
            size = arcSize,
            style = arcStyle,
        )
        // Green arc (bottom)
        drawArc(
            color = XGColors.SocialGoogleGreen,
            startAngle = 45f,
            sweepAngle = 90f,
            useCenter = false,
            topLeft = arcTopLeft,
            size = arcSize,
            style = arcStyle,
        )
        // Yellow arc (left-bottom)
        drawArc(
            color = XGColors.SocialGoogleYellow,
            startAngle = 135f,
            sweepAngle = 90f,
            useCenter = false,
            topLeft = arcTopLeft,
            size = arcSize,
            style = arcStyle,
        )
        // Red arc (top)
        drawArc(
            color = XGColors.SocialGoogleRed,
            startAngle = 225f,
            sweepAngle = 90f,
            useCenter = false,
            topLeft = arcTopLeft,
            size = arcSize,
            style = arcStyle,
        )

        // Horizontal bar of the "G" (blue)
        drawLine(
            color = XGColors.SocialGoogleBlue,
            start = Offset(cx, cy),
            end = Offset(cx + r + strokeW / 2f, cy),
            strokeWidth = strokeW,
        )
    }
}

/**
 * Apple logo drawn via [Canvas].
 *
 * Renders a simplified Apple logo shape using the provided [color].
 * Color from `socialAuth.appleBlack` via [XGColors.SocialAppleBlack].
 */
@Composable
private fun AppleIcon(modifier: Modifier = Modifier, color: Color = XGColors.SocialAppleBlack) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height

        val path = Path().apply {
            // Apple body (simplified teardrop shape)
            moveTo(w * 0.50f, h * 0.22f)
            cubicTo(w * 0.65f, h * 0.22f, w * 0.82f, h * 0.32f, w * 0.82f, h * 0.52f)
            cubicTo(w * 0.82f, h * 0.72f, w * 0.70f, h * 0.92f, w * 0.58f, h * 0.98f)
            cubicTo(w * 0.52f, h * 1.00f, w * 0.50f, h * 0.96f, w * 0.50f, h * 0.96f)
            cubicTo(w * 0.50f, h * 0.96f, w * 0.48f, h * 1.00f, w * 0.42f, h * 0.98f)
            cubicTo(w * 0.30f, h * 0.92f, w * 0.18f, h * 0.72f, w * 0.18f, h * 0.52f)
            cubicTo(w * 0.18f, h * 0.32f, w * 0.35f, h * 0.22f, w * 0.50f, h * 0.22f)
            close()

            // Leaf
            moveTo(w * 0.50f, h * 0.20f)
            cubicTo(w * 0.50f, h * 0.10f, w * 0.58f, h * 0.02f, w * 0.66f, h * 0.00f)
            cubicTo(w * 0.64f, h * 0.08f, w * 0.58f, h * 0.16f, w * 0.50f, h * 0.20f)
            close()
        }

        drawPath(path = path, color = color)
    }
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
