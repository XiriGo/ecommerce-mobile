# DQ-30: XGBottomBar / XGTabBar — Token Audit Specification

## Overview

Audit and upgrade the bottom navigation bar components on both platforms to ensure
all visual properties derive from design tokens rather than hardcoded values or
Material 3 defaults.

| Platform | Component | File |
|----------|-----------|------|
| Android  | `XGBottomBar` | `android/.../designsystem/component/XGBottomBar.kt` |
| iOS      | `XGTabBar` | `ios/.../DesignSystem/Component/XGTabBar.swift` |

## Token Mapping

### Colors (from `colors.json` — `bottomNav` section)

| Property | Token | Value |
|----------|-------|-------|
| Background | `bottomNav.background` | `#FFFFFF` |
| Active icon/label | `bottomNav.iconActive` | `#6000FE` |
| Inactive icon/label | `bottomNav.iconInactive` | `#8E8E93` |
| Top border (Android) | `light.borderSubtle` | `#F0F0F0` |

### Android Token References

| Property | Token Constant |
|----------|---------------|
| Background | `XGColors.BottomNavBackground` |
| Active icon tint | `XGColors.BottomNavIconActive` |
| Inactive icon tint | `XGColors.BottomNavIconInactive` |
| Top border color | `XGColors.OutlineVariant` |

### iOS Token References

| Property | Token Constant |
|----------|---------------|
| Background | `XGColors.bottomNavBackground` |
| Active icon/label | `XGColors.bottomNavIconActive` |
| Inactive icon/label | `XGColors.bottomNavIconInactive` |

### Spacing / Layout (from `spacing.json` — `bottomNavigation` + `layout.iconSize`)

| Property | Token | Value |
|----------|-------|-------|
| Bar height | `bottomNavigation.height` | 75 dp/pt |
| Icon size | `layout.iconSize.medium` | 24 dp/pt |
| Min touch target | `layout.minTouchTarget` | 48 dp/pt |

### Android Spacing References

| Property | Token Constant |
|----------|---------------|
| Icon size | 24.dp (from `layout.iconSize.medium`) |
| Bar height | 75.dp (from `bottomNavigation.height`) |
| Top border width | 0.5.dp (from component spec) |
| Elevation | `XGElevation.Level0` (0.dp) |

### iOS Spacing References

| Property | Token Constant |
|----------|---------------|
| Icon size | `XGSpacing.IconSize.medium` (24pt) |
| Min touch target | `XGSpacing.minTouchTarget` (48pt) |

### Typography (from `typography.json`)

| Property | Token | Value |
|----------|-------|-------|
| Tab label (if visible) | `typeScale.micro` | 10sp/pt Regular |

### Android Typography

| Property | Token Constant |
|----------|---------------|
| Label font | `XGTypography.labelSmall` (10sp Regular — micro) |

### iOS Typography

| Property | Token Constant |
|----------|---------------|
| Label font | `XGTypography.micro` (10pt Regular) |

### Motion (from `motion.json`)

| Property | Token | Value |
|----------|-------|-------|
| Tab switch crossfade | `crossfade.contentSwitch` | 200ms |
| Icon tint transition | `duration.fast` | 200ms |
| Easing | `easing.standard` | ease-in-out |

## Current Issues (Pre-Audit)

### Android (`XGBottomBar.kt`)

1. **Uses Material 3 `NavigationBar`** — colors come from M3 theme, not XG tokens
2. **Uses Material 3 `NavigationBarItem`** — selected/unselected states from M3
3. **Badge uses `MaterialTheme.typography`** — should use `XGTypography`
4. **No explicit height** — should be 75dp per token spec
5. **No top border** — spec requires 0.5dp `borderSubtle` top divider
6. **No elevation control** — should be level0 (0dp)
7. **Label visibility** — token says `labelVisible: false` but current code always shows labels

### iOS (`XGTabBar.swift`)

1. **Uses `XGColors.primary` / `XGColors.onSurfaceVariant`** — should use `bottomNavIconActive` / `bottomNavIconInactive`
2. **Uses `XGColors.surface` for background** — should use `bottomNavBackground`
3. **Uses `XGElevation.level4`** — should use level0 per spec (no elevation)
4. **Label font uses `XGTypography.labelSmall`** — should use `XGTypography.micro` (10pt)
5. **No animation on tab switch** — should have 200ms crossfade
6. **`return` in `#Preview`** — must remove explicit return from @ViewBuilder

## Required Changes

### Android

1. Replace `NavigationBar` + `NavigationBarItem` with custom `Row`-based composable
2. Set explicit background to `XGColors.BottomNavBackground`
3. Set icon tint: selected = `XGColors.BottomNavIconActive`, unselected = `XGColors.BottomNavIconInactive`
4. Set label tint to match icon tint
5. Set icon size to 24.dp (layout.iconSize.medium)
6. Set bar height to 75.dp (bottomNavigation.height)
7. Add 0.5dp top border with `XGColors.OutlineVariant`
8. Set elevation to 0dp (XGElevation.Level0)
9. Hide labels by default (token `labelVisible: false`)
10. Add `animateColorAsState` for icon tint transitions (200ms, standard easing)
11. Badge uses `XGColors.BadgeBackground` / `XGColors.BadgeText` + `XGTypography.labelSmall`
12. Maintain `@Preview` with `XGTheme`

### iOS

1. Use `XGColors.bottomNavBackground` for background
2. Use `XGColors.bottomNavIconActive` for selected tab foreground
3. Use `XGColors.bottomNavIconInactive` for unselected tab foreground
4. Remove elevation (use `XGElevation.level0` or remove `.xgElevation`)
5. Set icon size explicitly via `.font(.system(size: XGSpacing.IconSize.medium))`
6. Use `XGTypography.micro` for label font (10pt)
7. Add `withAnimation(.easeInOut(duration: XGMotion.Duration.fast))` on tab selection
8. Remove explicit `return` from `#Preview` closure
9. Keep `XGCountBadge` for badge display (already token-compliant)
10. Maintain `#Preview` block

## Test Coverage Requirements

### Token Contract Tests

- Verify `XGColors.BottomNavBackground` / `bottomNavBackground` equals `#FFFFFF`
- Verify `XGColors.BottomNavIconActive` / `bottomNavIconActive` equals `#6000FE`
- Verify `XGColors.BottomNavIconInactive` / `bottomNavIconInactive` equals `#8E8E93`
- Verify icon size constant equals 24
- Verify bar height equals 75

### Behavioral Tests

- All tabs render with labels
- Selected tab fires callback with correct index
- Badge displays correct count (including 99+ overflow)
- Zero badge count hides badge
- Accessibility labels present

## API Impact

None. This is a UI-only refactor with no data layer changes.
