package com.xirigo.ecommerce.core.designsystem.theme

import androidx.compose.ui.graphics.Color

object XGColors {
    // Light Theme Colors (from shared/design-tokens/foundations/colors.json)
    val Primary = Color(0xFF6000FE) // brand.primary
    val OnPrimary = Color(0xFFFFFFFF) // brand.onPrimary
    val PrimaryContainer = Color(0xFFF0EBFF) // light tint of brand primary
    val OnPrimaryContainer = Color(0xFF6000FE) // brand.primary

    val Secondary = Color(0xFF94D63A) // brand.secondary
    val OnSecondary = Color(0xFF6000FE) // brand.onSecondary
    val SecondaryContainer = Color(0xFF6200FF) // light.filterPillBackgroundActive
    val OnSecondaryContainer = Color(0xFFFFFFFF)

    val Tertiary = Color(0xFF9000FE) // brand.primaryLight
    val OnTertiary = Color(0xFFFFFFFF)
    val TertiaryContainer = Color(0xFFEDE7FE) // derived light purple
    val OnTertiaryContainer = Color(0xFF3C00D2) // brand.primaryDark

    val Error = Color(0xFFEF4444) // semantic.error
    val OnError = Color(0xFFFFFFFF) // semantic.onError
    val ErrorContainer = Color(0xFFFEE2E2) // derived light red
    val OnErrorContainer = Color(0xFFEF4444)

    val Surface = Color(0xFFFFFFFF) // light.surface
    val OnSurface = Color(0xFF333333) // light.textPrimary
    val SurfaceVariant = Color(0xFFF9FAFB) // light.surfaceSecondary
    val OnSurfaceVariant = Color(0xFF8E8E93) // light.textSecondary

    val Outline = Color(0xFFE5E7EB) // light.borderDefault
    val OutlineVariant = Color(0xFFF0F0F0) // light.borderSubtle

    val Background = Color(0xFFF8F9FC) // light.background
    val OnBackground = Color(0xFF333333) // light.textPrimary

    val InverseSurface = Color(0xFF333333)
    val InverseOnSurface = Color(0xFFF8F9FC)
    val InversePrimary = Color(0xFFA070FF) // dark.textLink

    val Scrim = Color(0xFF000000) // light.shadow

    // Dark Theme Colors (from shared/design-tokens/foundations/colors.json — dark section)
    val DarkPrimary = Color(0xFFA070FF) // dark.textLink
    val DarkOnPrimary = Color(0xFF1A1A24) // dark.surface
    val DarkPrimaryContainer = Color(0xFF3C00D2) // brand.primaryDark
    val DarkOnPrimaryContainer = Color(0xFFF0F0F5) // dark.textPrimary

    val DarkSecondary = Color(0xFF94D63A) // brand.secondary (same in dark)
    val DarkOnSecondary = Color(0xFF6000FE) // brand.onSecondary
    val DarkSecondaryContainer = Color(0xFF6000FE) // brand.primary
    val DarkOnSecondaryContainer = Color(0xFFF0F0F5)

    val DarkTertiary = Color(0xFF9000FE) // brand.primaryLight
    val DarkOnTertiary = Color(0xFFFFFFFF)
    val DarkTertiaryContainer = Color(0xFF3C00D2) // brand.primaryDark
    val DarkOnTertiaryContainer = Color(0xFFF0F0F5)

    val DarkError = Color(0xFFF2B8B5)
    val DarkOnError = Color(0xFF601410)
    val DarkErrorContainer = Color(0xFF8C1D18)
    val DarkOnErrorContainer = Color(0xFFF9DEDC)

    val DarkSurface = Color(0xFF1A1A24) // dark.surface
    val DarkOnSurface = Color(0xFFF0F0F5) // dark.textPrimary
    val DarkSurfaceVariant = Color(0xFF24242E) // dark.surfaceSecondary
    val DarkOnSurfaceVariant = Color(0xFFA0A0B0) // dark.textSecondary

    val DarkOutline = Color(0xFF2E2E3A) // dark.borderDefault
    val DarkOutlineVariant = Color(0xFF24242E) // dark.borderSubtle

    val DarkBackground = Color(0xFF0F0F14) // dark.background
    val DarkOnBackground = Color(0xFFF0F0F5) // dark.textPrimary

    val DarkInverseSurface = Color(0xFFF0F0F5)
    val DarkInverseOnSurface = Color(0xFF1A1A24)
    val DarkInversePrimary = Color(0xFF6000FE)

    val DarkScrim = Color(0xFF000000)

    // Semantic Colors (from shared/design-tokens/foundations/colors.json — semantic section)
    val Success = Color(0xFF22C55E) // semantic.success
    val OnSuccess = Color(0xFFFFFFFF) // semantic.onSuccess
    val Warning = Color(0xFFFACC15) // semantic.warning
    val OnWarning = Color(0xFF1D1D1B) // semantic.onWarning
    val Info = Color(0xFF3B82F6) // semantic.info
    val OnInfo = Color(0xFFFFFFFF) // semantic.onInfo

    val PriceRegular = Color(0xFF333333) // semantic.priceDefault
    val PriceSale = Color(0xFF6000FE) // semantic.priceDiscount
    val PriceOriginal = Color(0xFF8E8E93) // semantic.priceOriginal
    val PriceStrikethrough = Color(0xFF8E8E93) // semantic.priceStrikethrough

    val RatingStarFilled = Color(0xFF6000FE) // semantic.ratingStarActive
    val RatingStarEmpty = Color(0xFF8E8E93) // semantic.ratingStarInactive

    val BadgeBackground = Color(0xFF6000FE) // semantic.badgeBackground
    val BadgeText = Color(0xFFFFFFFF) // semantic.badgeText
    val BadgeSecondaryBackground = Color(0xFF94D63A) // semantic.badgeSecondaryBackground
    val BadgeSecondaryText = Color(0xFF6000FE) // semantic.badgeSecondaryText

    val Divider = Color(0xFFE5E7EB) // semantic.divider
    val Shimmer = Color(0xFFF1F5F9) // semantic.shimmer

    // Brand Colors
    val BrandPrimary = Color(0xFF6000FE) // brand.primary
    val BrandOnPrimary = Color(0xFFFFFFFF) // brand.onPrimary
    val BrandPrimaryLight = Color(0xFF9000FE) // brand.primaryLight
    val BrandPrimaryDark = Color(0xFF3C00D2) // brand.primaryDark
    val BrandSecondary = Color(0xFF94D63A) // brand.secondary
    val BrandOnSecondary = Color(0xFF6000FE) // brand.onSecondary

    // Text Colors (from light theme)
    val TextDark = Color(0xFF111827) // light.textDark
    val TextOnDark = Color(0xFFFFFFFF) // text on dark backgrounds
    val TextTertiary = Color(0xFF9CA3AF) // light.textTertiary
    val TextPlaceholder = Color(0xFF9CA3AF) // light.textPlaceholder

    // Icon Colors
    val IconOnDark = Color(0xFFFFFFFF) // icon on dark/colored backgrounds

    // Flash Sale Colors
    val FlashSaleBackground = Color(0xFFFFD814) // flashSale.background
    val FlashSaleAccentPink = Color(0xFFF60186) // flashSale.accentPink
    val FlashSaleAccentBlue = Color(0xFF9EBDF4) // flashSale.accentBlue
    val FlashSaleText = Color(0xFF1D1D1B) // flashSale.text

    // Category Colors
    val CategoryBlue = Color(0xFF37B4F2) // category.blue
    val CategoryPink = Color(0xFFFE75D4) // category.pink
    val CategoryYellow = Color(0xFFFDF29C) // category.yellow
    val CategoryMint = Color(0xFF90D3B1) // category.mint
    val CategoryLightYellow = Color(0xFFFEF170) // category.lightYellow

    // Pagination Dots
    val PaginationDotsActive = Color(0xFF6000FE) // paginationDots.active
    val PaginationDotsInactive = Color(0xFFD1D5DB) // paginationDots.inactive

    // Bottom Navigation
    val BottomNavBackground = Color(0xFFFFFFFF) // bottomNav.background
    val BottomNavIconActive = Color(0xFF6000FE) // bottomNav.iconActive
    val BottomNavIconInactive = Color(0xFF8E8E93) // bottomNav.iconInactive

    // Input/Form Colors
    val InputBackground = Color(0xFFF9FAFB) // light.inputBackground
    val InputBorder = Color(0xFFE5E7EB) // light.inputBorder
    val InputPlaceholder = Color(0xFF9CA3AF) // light.inputPlaceholder

    // Delivery
    val DeliveryText = Color(0xFF94D63A) // semantic.deliveryText
    val AddToCart = Color(0xFF94D63A) // semantic.addToCart
}
