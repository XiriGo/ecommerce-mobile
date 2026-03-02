# XGTopBar — Token Audit Spec (DQ-29)

## Overview

Audit `XGTopBar` on both Android and iOS against the token spec at
`shared/design-tokens/components/molecules/xg-top-bar.json`.

## Token Reference

| Token | JSON Value | Resolved |
|-------|-----------|----------|
| height | `56` | 56dp / 56pt |
| titleFont | `$foundations/typography.typeScale.titleLarge` | 20sp/pt SemiBold Poppins |
| backIcon (Android) | `Icons.AutoMirrored.Filled.ArrowBack` | Material ArrowBack |
| backIcon (iOS) | `chevron.left` | SF Symbol |
| iconSize | `$foundations/spacing.layout.iconSize.medium` | 24dp / 24pt |
| horizontalPadding | `$foundations/spacing.spacing.base` | 16dp / 16pt |
| minTouchTarget | `$foundations/spacing.layout.minTouchTarget` | 48dp / 48pt |

### Variant: transparent

| Token | JSON Value | Resolved |
|-------|-----------|----------|
| background | `transparent` | Color.Transparent / Color.clear |
| textColor | `$foundations/colors.light.textOnDark` | #FFFFFF — `XGColors.TextOnDark` / `.textOnDark` |
| iconColor | `$foundations/colors.light.textOnDark` | #FFFFFF — `XGColors.IconOnDark` / `.iconOnDark` |

Usage: Splash, Login (over gradient backgrounds)

### Variant: surface

| Token | JSON Value | Resolved |
|-------|-----------|----------|
| background | `$foundations/colors.light.surface` | #FFFFFF — `XGColors.Surface` / `.surface` |
| textColor | `$foundations/colors.light.textPrimary` | #333333 — `XGColors.OnSurface` / `.onSurface` |
| iconColor | `$foundations/colors.light.textPrimary` | #333333 — `XGColors.OnSurface` / `.onSurface` |

Usage: Filter screen, product list

### Sub-components

| Sub-component | Token | Resolved |
|---------------|-------|----------|
| backButton.icon (Android) | `Icons.AutoMirrored.Filled.ArrowBack` | Material icon |
| backButton.icon (iOS) | `chevron.left` | SF Symbol |
| backButton.minSize | `48` | 48dp / 48pt |
| actionButton.iconSize | `24` | 24dp / 24pt |
| actionButton.minSize | `48` | 48dp / 48pt |
| actionButton.badgeOverlay | `$atoms/xg-badge.XGCountBadge` | XGCountBadge |

## Audit Findings

### Android Issues

1. **Title uses `MaterialTheme.typography.titleLarge`** instead of direct `XGTypography.titleLarge`
   reference. While they resolve to the same style (the theme feeds XGTypography), direct token
   usage is preferred for consistency with all DQ-audited components.
2. **Colors use `MaterialTheme.colorScheme.*`** instead of `XGColors.*` directly. Same value
   resolution issue, but direct token usage is the standard.
3. **No variant support** — component only supports the surface variant. The `transparent` variant
   is needed for splash/login screens.
4. **No explicit height** — relies on `TopAppBar` default. Should set height to 56.dp per spec.
5. **No explicit icon size** — relies on IconButton defaults. Should use `XGSpacing.IconSize.Medium`
   (24.dp) but Android does not have an IconSize object. Icon size is controlled by Material
   defaults which happen to be 24dp, so this is acceptable, but adding an explicit size
   reference via Modifier would be ideal.
6. **Action icon color uses `onSurfaceVariant`** but spec says `textPrimary` (same as title).
   Should use same color as title for consistency.

### iOS Issues

1. **Title uses `XGTypography.titleLarge`** — matches token spec. OK.
2. **Colors use `XGColors.onSurface`** — matches surface variant. OK.
3. **No variant support** — only surface variant. Needs `transparent` variant for splash/login.
4. **Height uses `minTouchTarget` (48pt)** but spec says height should be 56pt.
   Should change to explicit 56pt frame height.
5. **Icon size uses `XGSpacing.IconSize.medium`** (24pt) — matches spec. OK.
6. **Horizontal padding uses `XGSpacing.base`** (16pt) — matches spec. OK.

## Required Changes

### Android

- Add `XGTopBarVariant` enum with `Surface` and `Transparent` cases
- Replace `MaterialTheme.typography.titleLarge` with `XGTypography.titleLarge` directly
- Replace `MaterialTheme.colorScheme.*` with `XGColors.*` via variant-based color resolution
- Set action icon color to match title/nav icon color per variant
- Add explicit top bar height modifier (56.dp) via `TopAppBarDefaults` expandedHeight
- Add preview for transparent variant
- Add explicit icon size (24.dp) via `Modifier.size()` on the icon

### iOS

- Add `XGTopBarVariant` enum with `surface` and `transparent` cases
- Wire variant colors through background/text/icon styling
- Change frame height from `minTouchTarget` (48) to 56pt per spec
- Add preview for transparent variant

## Parameters

| Param | Type | Required | Default |
|-------|------|----------|---------|
| title | String | yes | -- |
| variant | XGTopBarVariant | no | surface |
| onBackClick/onBackTap | (() -> Unit/Void)? | no | null/nil |
| actions | composable slot / [XGTopBarAction] | no | empty |
