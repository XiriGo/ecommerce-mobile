# XGEmptyView — Token Audit (DQ-28)

## Summary

Audit `XGEmptyView` to ensure all visual properties come from design tokens.
Icon size, message font/color, spacing, and CTA button variant must match
`shared/design-tokens/components/molecules/xg-empty-view.json`.

## Issue

- GitHub Issue: #72
- Feature ID: DQ-28
- Dependencies: None

## Current State

### Android (`XGEmptyView.kt`)
- Icon size: `XGSpacing.XXXL` (48dp) -- CORRECT
- Icon color: `MaterialTheme.colorScheme.onSurfaceVariant` -- CORRECT (maps to textSecondary #8E8E93)
- Message font: `MaterialTheme.typography.bodyLarge` -- CORRECT
- Message color: `MaterialTheme.colorScheme.onSurfaceVariant` -- CORRECT
- Spacing: `XGSpacing.Base` (16dp) -- CORRECT
- CTA button: `XGButtonStyle.Primary` -- INCORRECT (token spec says `outlined`)

### iOS (`XGEmptyView.swift`)
- Icon size: `XGSpacing.xxxl` (48pt) -- CORRECT
- Icon color: `XGColors.onSurfaceVariant` -- CORRECT (#8E8E93)
- Message font: `XGTypography.bodyLarge` -- CORRECT (Poppins 16pt)
- Message color: `XGColors.onSurfaceVariant` -- CORRECT
- Spacing: `XGSpacing.base` (16pt) -- CORRECT
- CTA button: `XGButton` with `.outlined` variant -- CORRECT

## Changes Required

### Android
1. Change CTA button style from `XGButtonStyle.Primary` to `XGButtonStyle.Outlined`

### iOS
1. No changes required -- already compliant with token spec

## Token Reference

From `shared/design-tokens/components/molecules/xg-empty-view.json`:

| Token | JSON Reference | Android | iOS |
|-------|---------------|---------|-----|
| `iconSize` | `$foundations/spacing.spacing.xxxl` (48) | `XGSpacing.XXXL` | `XGSpacing.xxxl` |
| `iconColor` | `$foundations/colors.light.textSecondary` (#8E8E93) | `MaterialTheme.colorScheme.onSurfaceVariant` | `XGColors.onSurfaceVariant` |
| `defaultIcon` | `Icons.Outlined.Inbox` / `tray` | `Icons.Outlined.Inbox` | `"tray"` |
| `messageFont` | `$foundations/typography.typeScale.bodyLarge` (16pt) | `MaterialTheme.typography.bodyLarge` | `XGTypography.bodyLarge` |
| `messageColor` | `$foundations/colors.light.textSecondary` (#8E8E93) | `MaterialTheme.colorScheme.onSurfaceVariant` | `XGColors.onSurfaceVariant` |
| `spacing` | `$foundations/spacing.spacing.base` (16) | `XGSpacing.Base` | `XGSpacing.base` |
| `ctaButton` | `$atoms/xg-button (outlined variant)` | `XGButtonStyle.Outlined` | `.outlined` |

## Backward Compatibility

The existing API signature does not change. Only the visual style of the CTA button
changes from filled/primary to outlined on Android.

## Test Plan

### Android (Compose UI Tests)
1. Verify message text is displayed
2. Verify action button shown when both label and callback provided
3. Verify action button hidden when label is null
4. Verify action button hidden when callback is null
5. Verify action click fires callback
6. Verify custom icon renders without crash
7. Verify default rendering without crash

### iOS (Swift Testing)
1. Verify init with message only
2. Verify default system image is "tray"
3. Verify init with custom system image
4. Verify init with action label and handler
5. Verify default action is nil
6. Verify various system images accepted

## Files Modified

### Android
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGEmptyView.kt`
- `android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGEmptyViewTest.kt`

### iOS
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGEmptyView.swift` (no changes needed)
- `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGEmptyViewTests.swift` (no changes needed)

### Shared
- `shared/feature-specs/xg-empty-view.md` (this file)
- `docs/features/xg-empty-view.md`
- `CHANGELOG.md`
