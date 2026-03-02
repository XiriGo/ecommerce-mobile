# DQ-25: XGFlashSaleBanner Upgrade

## Overview

Token audit and upgrade of the `XGFlashSaleBanner` design system component on both Android and iOS. Part of the Design Quality (DQ) initiative to ensure all components use design tokens consistently.

## Changes

### Android (`XGFlashSaleBanner.kt`)
- Replaced inline font properties (`fontFamily`, `fontSize`, `fontWeight`) with `MaterialTheme.typography.titleSmall` (badge) and `MaterialTheme.typography.titleLarge` (title).
- Added `textAlign = TextAlign.Center` and `maxLines = 2` to title per token spec.
- Removed unused constants: `BadgeFontSize`, `TitleFontSize`, `TitleLineHeight`.
- Removed unused imports: `PoppinsFontFamily`, `FontWeight`, `sp`.
- Enhanced KDoc with `@param` documentation.
- Added second preview variant showing the banner with an `imageUrl`.

### iOS (`XGFlashSaleBanner.swift`)
- Added `XGImage` rendering when `imageUrl` is provided, inheriting shimmer from DQ-07.
- Removed unused constants: `badgeFontSize`, `titleFontSize`.
- Added `titleMaxLines` constant to `Constants` enum (replaces magic number `2`).
- Updated doc comment to reference token names instead of hardcoded hex values.
- Typography tokens were already correct: `XGTypography.bodySemiBold` and `XGTypography.title`.
- Added preview variant showing the banner with an `imageUrl`.

## Token Reference

Source: `shared/design-tokens/components/molecules/xg-flash-sale-banner.json`

| Property | Token | Android | iOS |
|----------|-------|---------|-----|
| Height | `tokens.height` | `133.dp` | `133` pt |
| Corner radius | `cornerRadius.medium` | `XGCornerRadius.Medium` | `XGCornerRadius.medium` |
| Background | `colors.flashSale.background` | `XGColors.FlashSaleBackground` | `XGColors.flashSaleBackground` |
| Text color | `colors.flashSale.text` | `XGColors.FlashSaleText` | `XGColors.flashSaleText` |
| Left stripe | `colors.flashSale.accentBlue` | `XGColors.FlashSaleAccentBlue` | `XGColors.flashSaleAccentBlue` |
| Right stripe | `colors.flashSale.accentPink` | `XGColors.FlashSaleAccentPink` | `XGColors.flashSaleAccentPink` |
| Badge font | `typography.bodySemiBold` | `MaterialTheme.typography.titleSmall` | `XGTypography.bodySemiBold` |
| Title font | `typography.title` | `MaterialTheme.typography.titleLarge` | `XGTypography.title` |

## Test Coverage

- **Android**: 11 JVM unit tests (`XGFlashSaleBannerTokenTest.kt`)
- **iOS**: 24 Swift Testing tests (`XGFlashSaleBannerTests.swift`)

## Dependencies

- DQ-07 (XGImage upgrade) -- closed/done. XGImage provides shimmer via `.shimmerEffect()`.
