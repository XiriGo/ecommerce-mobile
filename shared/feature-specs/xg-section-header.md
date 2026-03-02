# XGSectionHeader — Token Audit Spec (DQ-13)

## Overview

Audit `XGSectionHeader` on both Android and iOS against the token spec at
`shared/design-tokens/components/atoms/xg-section-header.json`.

## Token Reference

| Token | JSON Value | Resolved |
|-------|-----------|----------|
| titleFont | `$foundations/typography.typeScale.subtitle` | 18sp SemiBold Poppins |
| titleColor | `$foundations/colors.light.textPrimary` | `XGColors.OnSurface` / `.onSurface` |
| subtitleFont | `$foundations/typography.typeScale.bodyMedium` | 14sp Medium Poppins |
| subtitleColor | `$foundations/colors.light.textSecondary` | `XGColors.OnSurfaceVariant` / `.onSurfaceVariant` |
| seeAllFont | `$foundations/typography.typeScale.bodyMedium` | 14sp Medium Poppins |
| seeAllColor | `$foundations/colors.brand.primary` | `XGColors.BrandPrimary` / `.brandPrimary` |
| arrowIconSize | 12 | 12dp / 12pt |
| arrowIcon | Android: `Icons.AutoMirrored.Outlined.ArrowForward`, iOS: `chevron.right` | Platform-specific |
| horizontalPadding | `$foundations/spacing.layout.screenPaddingHorizontal` | 20dp / 20pt |
| subtitleSpacing | `$foundations/spacing.spacing.xxs` | 2dp / 2pt |

## Audit Findings

### Android Issues

1. **Title uses inline font constants** instead of `XGTypography.titleMedium` (which is the
   subtitle typeScale mapped to Material3). Should use `style = XGTypography.titleMedium` and
   `color = XGColors.OnSurface`.
2. **Subtitle uses `FontWeight.Normal`** but spec requires `bodyMedium` which is 14sp Medium.
   Should use `style = XGTypography.labelLarge` (14sp Medium).
3. **Arrow icon size is 16dp** but spec says 12dp. Must change `SeeAllIconSize` to 12.dp.
4. **"See All" text** uses inline font constants. Should use `style = XGTypography.labelLarge`.
5. **No explicit subtitle spacing** — Column has no spacing set; spec requires `XXS` (2dp).
6. **Private constants are redundant** — can be removed once XGTypography styles are used.

### iOS Issues

1. **Subtitle uses `XGTypography.bodyMedium`** which is 14pt Medium — matches token spec. OK.
2. **Title uses `XGTypography.subtitle`** (18pt SemiBold) — matches. OK.
3. **`Constants.titleFontSize` and `Constants.seeAllFontSize` are unused dead code** — remove.
4. **Arrow icon size (12pt)** matches spec. OK.
5. **VStack spacing uses `XGSpacing.xxs`** — matches subtitleSpacing token. OK.
6. **Overall**: iOS is mostly compliant; just dead code cleanup needed.

## Required Changes

### Android

- Replace inline `Text(...)` calls with `style = XGTypography.titleMedium` / `XGTypography.labelLarge`
- Add `color = XGColors.OnSurface` / `XGColors.OnSurfaceVariant` / `XGColors.BrandPrimary` to Text
- Change `SeeAllIconSize` from 16dp to 12dp
- Add `spacing = XGSpacing.XXS` to the Column
- Remove redundant private constants (`TitleFontSize`, `TitleLineHeight`, etc.)

### iOS

- Remove unused `Constants.titleFontSize` and `Constants.seeAllFontSize`
- Verify remaining tokens (all pass)

## Parameters (unchanged)

| Param | Type | Required | Default |
|-------|------|----------|---------|
| title | String | yes | — |
| subtitle | String? | no | null |
| onSeeAllAction | (() -> Void)? | no | null |
