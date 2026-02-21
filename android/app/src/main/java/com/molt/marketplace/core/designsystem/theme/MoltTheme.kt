package com.molt.marketplace.core.designsystem.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val MoltLightColorScheme = lightColorScheme(
    primary = MoltColors.Primary,
    onPrimary = MoltColors.OnPrimary,
    primaryContainer = MoltColors.PrimaryContainer,
    onPrimaryContainer = MoltColors.OnPrimaryContainer,
    secondary = MoltColors.Secondary,
    onSecondary = MoltColors.OnSecondary,
    secondaryContainer = MoltColors.SecondaryContainer,
    onSecondaryContainer = MoltColors.OnSecondaryContainer,
    tertiary = MoltColors.Tertiary,
    onTertiary = MoltColors.OnTertiary,
    tertiaryContainer = MoltColors.TertiaryContainer,
    onTertiaryContainer = MoltColors.OnTertiaryContainer,
    error = MoltColors.Error,
    onError = MoltColors.OnError,
    errorContainer = MoltColors.ErrorContainer,
    onErrorContainer = MoltColors.OnErrorContainer,
    surface = MoltColors.Surface,
    onSurface = MoltColors.OnSurface,
    surfaceVariant = MoltColors.SurfaceVariant,
    onSurfaceVariant = MoltColors.OnSurfaceVariant,
    outline = MoltColors.Outline,
    outlineVariant = MoltColors.OutlineVariant,
    background = MoltColors.Background,
    onBackground = MoltColors.OnBackground,
    inverseSurface = MoltColors.InverseSurface,
    inverseOnSurface = MoltColors.InverseOnSurface,
    inversePrimary = MoltColors.InversePrimary,
    scrim = MoltColors.Scrim,
)

private val MoltDarkColorScheme = darkColorScheme(
    primary = MoltColors.DarkPrimary,
    onPrimary = MoltColors.DarkOnPrimary,
    primaryContainer = MoltColors.DarkPrimaryContainer,
    onPrimaryContainer = MoltColors.DarkOnPrimaryContainer,
    secondary = MoltColors.DarkSecondary,
    onSecondary = MoltColors.DarkOnSecondary,
    secondaryContainer = MoltColors.DarkSecondaryContainer,
    onSecondaryContainer = MoltColors.DarkOnSecondaryContainer,
    tertiary = MoltColors.DarkTertiary,
    onTertiary = MoltColors.DarkOnTertiary,
    tertiaryContainer = MoltColors.DarkTertiaryContainer,
    onTertiaryContainer = MoltColors.DarkOnTertiaryContainer,
    error = MoltColors.DarkError,
    onError = MoltColors.DarkOnError,
    errorContainer = MoltColors.DarkErrorContainer,
    onErrorContainer = MoltColors.DarkOnErrorContainer,
    surface = MoltColors.DarkSurface,
    onSurface = MoltColors.DarkOnSurface,
    surfaceVariant = MoltColors.DarkSurfaceVariant,
    onSurfaceVariant = MoltColors.DarkOnSurfaceVariant,
    outline = MoltColors.DarkOutline,
    outlineVariant = MoltColors.DarkOutlineVariant,
    background = MoltColors.DarkBackground,
    onBackground = MoltColors.DarkOnBackground,
    inverseSurface = MoltColors.DarkInverseSurface,
    inverseOnSurface = MoltColors.DarkInverseOnSurface,
    inversePrimary = MoltColors.DarkInversePrimary,
    scrim = MoltColors.DarkScrim,
)

@Composable
fun MoltTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
    val colorScheme = if (darkTheme) {
        MoltDarkColorScheme
    } else {
        MoltLightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = MoltTypography,
        content = content,
    )
}
