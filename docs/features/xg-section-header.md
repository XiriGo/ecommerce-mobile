# XGSectionHeader

## Overview

Section header component displaying a title, optional subtitle, and optional "See All" action link with arrow icon. Used across feature screens to introduce content sections (e.g., "Popular Products", "Categories", "New Arrivals").

## Token Source

`shared/design-tokens/components/atoms/xg-section-header.json`

## API

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `title` | String | Yes | — | Section title text |
| `subtitle` | String? | No | nil | Optional subtitle below title |
| `onSeeAllClick` (Android) / `onSeeAllAction` (iOS) | (() -> Unit)? | No | nil | If non-null, shows "See All" link with arrow |

## Token Mapping

| Token | Value | Android | iOS |
|-------|-------|---------|-----|
| titleFont | 18sp SemiBold Poppins | `MaterialTheme.typography.titleMedium` | `XGTypography.subtitle` |
| titleColor | #333333 | `XGColors.OnSurface` | `XGColors.onSurface` |
| subtitleFont | 14sp Medium Poppins | `MaterialTheme.typography.labelLarge` | `XGTypography.bodyMedium` |
| subtitleColor | #8E8E93 | `XGColors.OnSurfaceVariant` | `XGColors.onSurfaceVariant` |
| seeAllFont | 14sp Medium Poppins | `MaterialTheme.typography.labelLarge` | `XGTypography.bodyMedium` |
| seeAllColor | #6000FE | `XGColors.BrandPrimary` | `XGColors.brandPrimary` |
| arrowIconSize | 12 | `ArrowIconSize = 12.dp` | `Constants.arrowIconSize = 12` |
| arrowIcon | Platform-specific | `Icons.AutoMirrored.Outlined.ArrowForward` | `chevron.right` (SF Symbol) |
| horizontalPadding | 20 | `XGSpacing.ScreenPaddingHorizontal` | `XGSpacing.screenPaddingHorizontal` |
| subtitleSpacing | 2 | `XGSpacing.XXS` | `XGSpacing.xxs` |

## Files

### Android
- Component: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGSectionHeader.kt`
- Tests: `android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/component/XGSectionHeaderTokenTest.kt`

### iOS
- Component: `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGSectionHeader.swift`
- Tests: `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGSectionHeaderTests.swift`

## DQ-13 Audit Changes

### Android
- Replaced 6 inline font constants with `MaterialTheme.typography` references
- Fixed subtitle font weight: Normal -> Medium (via `labelLarge`)
- Fixed arrow icon size: 16dp -> 12dp
- Added explicit subtitle spacing (`XGSpacing.XXS`)
- Removed `PoppinsFontFamily` direct import (centralised via `XGTypography`)

### iOS
- Removed unused `Constants.titleFontSize` and `Constants.seeAllFontSize`
- Enhanced doc comment with full token mapping

### Tests
- 15 Android JUnit token contract tests
- 19 iOS Swift Testing tests (init + token contract + cross-token consistency)
