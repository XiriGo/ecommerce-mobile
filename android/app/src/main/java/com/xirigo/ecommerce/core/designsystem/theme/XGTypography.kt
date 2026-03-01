package com.xirigo.ecommerce.core.designsystem.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

/**
 * Font families from design tokens (typography.json).
 * When actual font files are embedded in res/font/, replace these with:
 *   FontFamily(Font(R.font.poppins_regular, FontWeight.Normal), ...)
 */
val PoppinsFontFamily: FontFamily = FontFamily.Default
val SourceSans3FontFamily: FontFamily = FontFamily.SansSerif

val XGTypography = Typography(
    // display (28sp bold) — from typeScale.display
    displayLarge = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 28.sp,
        lineHeight = 36.sp,
        fontWeight = FontWeight.Bold,
    ),
    displayMedium = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 28.sp,
        lineHeight = 36.sp,
        fontWeight = FontWeight.Bold,
    ),
    displaySmall = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 28.sp,
        lineHeight = 36.sp,
        fontWeight = FontWeight.Bold,
    ),
    // headline (24sp semiBold) — from typeScale.headline
    headlineLarge = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        fontWeight = FontWeight.SemiBold,
    ),
    headlineMedium = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        fontWeight = FontWeight.SemiBold,
    ),
    headlineSmall = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        fontWeight = FontWeight.SemiBold,
    ),
    // title (20sp semiBold) — from typeScale.title
    titleLarge = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 20.sp,
        lineHeight = 28.sp,
        fontWeight = FontWeight.SemiBold,
    ),
    // subtitle (18sp semiBold) — from typeScale.subtitle
    titleMedium = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 18.sp,
        lineHeight = 26.sp,
        fontWeight = FontWeight.SemiBold,
    ),
    // bodySemiBold (14sp semiBold) — from typeScale.bodySemiBold
    titleSmall = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        fontWeight = FontWeight.SemiBold,
    ),
    // bodyLarge (16sp regular) — from typeScale.bodyLarge
    bodyLarge = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 16.sp,
        lineHeight = 22.sp,
        fontWeight = FontWeight.Normal,
    ),
    // body (14sp regular) — from typeScale.body
    bodyMedium = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        fontWeight = FontWeight.Normal,
    ),
    // caption (12sp regular) — from typeScale.caption
    bodySmall = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        fontWeight = FontWeight.Normal,
    ),
    // bodyMedium weight (14sp medium) — from typeScale.bodyMedium
    labelLarge = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        fontWeight = FontWeight.Medium,
    ),
    // captionMedium (12sp medium) — from typeScale.captionMedium
    labelMedium = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        fontWeight = FontWeight.Medium,
    ),
    // micro (10sp regular) — from typeScale.micro
    labelSmall = TextStyle(
        fontFamily = PoppinsFontFamily,
        fontSize = 10.sp,
        lineHeight = 14.sp,
        fontWeight = FontWeight.Normal,
    ),
)
