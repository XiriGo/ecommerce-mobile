# XGSearchBar -- Design Token Audit (DQ-12)

## Overview

`XGSearchBar` is a tappable search bar placeholder component that navigates users to the search screen. This document describes the DQ-12 token audit that aligned both Android and iOS implementations with the centralized design token specification.

## Token Source

`shared/design-tokens/components/atoms/xg-search-bar.json`

## Token Mapping

| Token | JSON Reference | Value | Android | iOS |
|-------|---------------|-------|---------|-----|
| background | `colors.light.inputBackground` | #F9FAFB | `XGColors.InputBackground` | `XGColors.inputBackground` |
| borderColor | `colors.light.borderSubtle` | #F0F0F0 | `XGColors.OutlineVariant` | `XGColors.outlineVariant` |
| borderWidth | literal | 1 dp/pt | `1.dp` | `1` |
| cornerRadius | `cornerRadius.pill` | 28 dp/pt | `XGCornerRadius.Pill` | `XGCornerRadius.pill` |
| iconSize | `layout.iconSize.medium` | 24 dp/pt | `24.dp` | `XGSpacing.IconSize.medium` |
| iconColor | `colors.light.textSecondary` | #8E8E93 | `XGColors.OnSurfaceVariant` | `XGColors.onSurfaceVariant` |
| placeholderFont | `typeScale.bodyLarge` | 16 sp/pt | `XGTypography.bodyLarge` | `XGTypography.bodyLarge` |
| placeholderColor | `colors.light.textSecondary` | #8E8E93 | `XGColors.OnSurfaceVariant` | `XGColors.onSurfaceVariant` |
| horizontalPadding | `spacing.md` | 12 dp/pt | `XGSpacing.MD` | `XGSpacing.md` |
| verticalPadding | `spacing.md` | 12 dp/pt | `XGSpacing.MD` | `XGSpacing.md` |
| leadingIcon | platform | -- | `Icons.Outlined.Search` | `magnifyingglass` |

## Changes Made

### Android

- Replaced `Card` wrapper with `Row` + `background` + `border` + `clip` modifiers
- Changed background from `XGColors.SurfaceVariant` to `XGColors.InputBackground`
- Changed corner radius from `XGCornerRadius.Medium` (10dp) to `XGCornerRadius.Pill` (28dp)
- Removed `CardDefaults.cardElevation` (no elevation per spec)
- Added `border(1.dp, XGColors.OutlineVariant)` per spec
- Changed horizontal padding from `XGSpacing.Base` (16dp) to `XGSpacing.MD` (12dp)
- Added explicit icon `Modifier.size(24.dp)` per `layout.iconSize.medium`
- Removed redundant `fontFamily = PoppinsFontFamily` override (already in `XGTypography.bodyLarge`)
- Added `role = Role.Button` to `clickable` for accessibility

### iOS

- Changed corner radius from `XGCornerRadius.full` (999pt) to `XGCornerRadius.pill` (28pt)
- Updated documentation comment to list all token references

## Component API

### Android

```kotlin
@Composable
fun XGSearchBar(
    hint: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
)
```

### iOS

```swift
struct XGSearchBar: View {
    init(placeholder: String, action: @escaping () -> Void)
}
```

## Test Coverage

- **Android**: 15 JUnit tests in `XGSearchBarTokenTest.kt` covering all token contracts
- **iOS**: 19 Swift Testing tests in `XGSearchBarTests.swift` covering initialisation and token contracts

## Files

| File | Platform |
|------|----------|
| `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGSearchBar.kt` | Android |
| `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGSearchBar.swift` | iOS |
| `android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/component/XGSearchBarTokenTest.kt` | Android |
| `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGSearchBarTests.swift` | iOS |
| `shared/feature-specs/xg-search-bar.md` | Shared |
