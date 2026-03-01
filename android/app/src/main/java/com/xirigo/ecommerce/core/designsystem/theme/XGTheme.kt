package com.xirigo.ecommerce.core.designsystem.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val XGLightColorScheme = lightColorScheme(
    primary = XGColors.Primary,
    onPrimary = XGColors.OnPrimary,
    primaryContainer = XGColors.PrimaryContainer,
    onPrimaryContainer = XGColors.OnPrimaryContainer,
    secondary = XGColors.Secondary,
    onSecondary = XGColors.OnSecondary,
    secondaryContainer = XGColors.SecondaryContainer,
    onSecondaryContainer = XGColors.OnSecondaryContainer,
    tertiary = XGColors.Tertiary,
    onTertiary = XGColors.OnTertiary,
    tertiaryContainer = XGColors.TertiaryContainer,
    onTertiaryContainer = XGColors.OnTertiaryContainer,
    error = XGColors.Error,
    onError = XGColors.OnError,
    errorContainer = XGColors.ErrorContainer,
    onErrorContainer = XGColors.OnErrorContainer,
    surface = XGColors.Surface,
    onSurface = XGColors.OnSurface,
    surfaceVariant = XGColors.SurfaceVariant,
    onSurfaceVariant = XGColors.OnSurfaceVariant,
    outline = XGColors.Outline,
    outlineVariant = XGColors.OutlineVariant,
    background = XGColors.Background,
    onBackground = XGColors.OnBackground,
    inverseSurface = XGColors.InverseSurface,
    inverseOnSurface = XGColors.InverseOnSurface,
    inversePrimary = XGColors.InversePrimary,
    scrim = XGColors.Scrim,
)

private val XGDarkColorScheme = darkColorScheme(
    primary = XGColors.DarkPrimary,
    onPrimary = XGColors.DarkOnPrimary,
    primaryContainer = XGColors.DarkPrimaryContainer,
    onPrimaryContainer = XGColors.DarkOnPrimaryContainer,
    secondary = XGColors.DarkSecondary,
    onSecondary = XGColors.DarkOnSecondary,
    secondaryContainer = XGColors.DarkSecondaryContainer,
    onSecondaryContainer = XGColors.DarkOnSecondaryContainer,
    tertiary = XGColors.DarkTertiary,
    onTertiary = XGColors.DarkOnTertiary,
    tertiaryContainer = XGColors.DarkTertiaryContainer,
    onTertiaryContainer = XGColors.DarkOnTertiaryContainer,
    error = XGColors.DarkError,
    onError = XGColors.DarkOnError,
    errorContainer = XGColors.DarkErrorContainer,
    onErrorContainer = XGColors.DarkOnErrorContainer,
    surface = XGColors.DarkSurface,
    onSurface = XGColors.DarkOnSurface,
    surfaceVariant = XGColors.DarkSurfaceVariant,
    onSurfaceVariant = XGColors.DarkOnSurfaceVariant,
    outline = XGColors.DarkOutline,
    outlineVariant = XGColors.DarkOutlineVariant,
    background = XGColors.DarkBackground,
    onBackground = XGColors.DarkOnBackground,
    inverseSurface = XGColors.DarkInverseSurface,
    inverseOnSurface = XGColors.DarkInverseOnSurface,
    inversePrimary = XGColors.DarkInversePrimary,
    scrim = XGColors.DarkScrim,
)

@Composable
fun XGTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
    val colorScheme = if (darkTheme) {
        XGDarkColorScheme
    } else {
        XGLightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = XGTypography,
        content = content,
    )
}
