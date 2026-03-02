# DQ-30: XGBottomBar / XGTabBar Token Audit

## Summary

Audited and upgraded the bottom navigation bar components on both Android (`XGBottomBar`)
and iOS (`XGTabBar`) to ensure all visual properties derive from XG design tokens.

## Token Source

`shared/design-tokens/components/molecules/xg-bottom-bar.json`

## Changes

### Android (`XGBottomBar.kt`)

| Before | After |
|--------|-------|
| Material 3 `NavigationBar` | Custom `Row`-based composable |
| M3 default colors | `XGColors.BottomNavBackground/IconActive/IconInactive` |
| M3 default label style | Labels hidden (token: `labelVisible: false`) |
| No height control | Explicit 75dp (token: `bottomNavigation.height`) |
| No top border | 0.5dp `XGColors.OutlineVariant` divider |
| M3 elevation | Level0 (no shadow) |
| No icon size control | 24dp (token: `layout.iconSize.medium`) |
| No tint animation | `animateColorAsState` (200ms standard easing) |
| M3 badge | Custom badge with `XGColors.BadgeBackground/BadgeText` |

### iOS (`XGTabBar.swift`)

| Before | After |
|--------|-------|
| `XGColors.surface` background | `XGColors.bottomNavBackground` |
| `XGColors.primary` / `onSurfaceVariant` | `bottomNavIconActive` / `bottomNavIconInactive` |
| `XGElevation.level4` shadow | No elevation (level0) |
| `XGTypography.labelSmall` label | `XGTypography.micro` (10pt Regular) |
| No animation | `withAnimation(.easeInOut(duration: 0.2))` |
| No top border | 0.5pt `XGColors.outlineVariant` divider |
| No explicit height | 75pt (token: `bottomNavigation.height`) |
| `return` in Preview | Removed (ViewBuilder compliance) |

## Test Coverage

- **Android**: 11 instrumented tests (rendering, selection, badge, token contract, accessibility)
- **iOS**: 18 Swift Testing tests (data model, initialization, binding, token contract)

## Files Changed

### Android
- `android/.../designsystem/component/XGBottomBar.kt` (upgraded)
- `android/.../designsystem/component/XGBottomBarTest.kt` (updated)

### iOS
- `ios/.../DesignSystem/Component/XGTabBar.swift` (upgraded)
- `ios/.../DesignSystem/Component/XGTabBarTests.swift` (updated)

## Linked Issue

Closes #74
