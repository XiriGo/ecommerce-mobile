# DQ-08 XGBadge Audit - Android Dev Handoff

**Agent**: android-dev
**Platform**: Android
**Date**: 2026-03-01
**Status**: Complete

## Summary

Audited and fixed `XGBadge.kt` against the token spec (`components/atoms/xg-badge.json`) and brought it to parity with the iOS implementation.

## Changes Made

### 1. XGStatusBadge: Replaced MaterialTheme references with XGColors

- `MaterialTheme.colorScheme.surfaceVariant` replaced with `XGColors.SurfaceVariant`
- `MaterialTheme.colorScheme.onError` replaced with `XGColors.OnError`
- `MaterialTheme.colorScheme.onSurfaceVariant` replaced with `XGColors.OnSurfaceVariant`

Design system components must never reference `MaterialTheme.colorScheme` directly -- they use XGColors tokens.

### 2. Added XGBadge Composable (primary/secondary variant)

New composable matching iOS `XGBadge` and the token spec:

- **XGBadgeVariant** enum with `Primary` and `Secondary` entries
- **Primary**: `XGColors.BadgeBackground` background, `XGColors.BadgeText` text
- **Secondary**: `XGColors.BadgeSecondaryBackground` background, `XGColors.BadgeSecondaryText` text
- **Font**: `XGCustomTextStyles.CaptionSemiBold` (12sp, SemiBold)
- **Corner radius**: `XGCornerRadius.Medium` (10dp)
- **Padding**: 10dp horizontal, 4dp vertical (component-level constants)

### 3. Fixed XGCountBadge Shape

Changed `CircleShape` to `RoundedCornerShape(XGCornerRadius.Full)` for a capsule/pill shape, matching the token spec `"shape": "capsule"` and the iOS `Capsule()` usage.

### 4. Added XGCustomTextStyles.CaptionSemiBold

The token spec requires `captionSemiBold` (12sp, SemiBold, Poppins) which has no corresponding Material 3 Typography slot. Added a new `XGCustomTextStyles` object in `XGTypography.kt` to host this and any future custom text styles.

### 5. Added Previews

- `XGBadgePrimaryPreview` -- SALE badge
- `XGBadgeSecondaryPreview` -- NEW SEASON and DAILY DEAL badges

## Files Modified

| File | Change |
|------|--------|
| `android/.../component/XGBadge.kt` | Full rewrite: added XGBadgeVariant, XGBadge composable, fixed XGStatusBadge colors, fixed XGCountBadge shape, added previews |
| `android/.../theme/XGTypography.kt` | Added `XGCustomTextStyles.CaptionSemiBold` text style |

## Files NOT Modified (Confirmed Compatible)

| File | Reason |
|------|--------|
| `XGBadgeStatus.kt` | Enum unchanged, no API break |
| `XGBadgeTest.kt` | Existing tests for XGCountBadge/XGStatusBadge still pass (API unchanged) |

## Token Verification

| Token | Spec Value | Implementation |
|-------|-----------|----------------|
| Badge primary bg | `#6000FE` | `XGColors.BadgeBackground` = `Color(0xFF6000FE)` |
| Badge primary text | `#FFFFFF` | `XGColors.BadgeText` = `Color(0xFFFFFFFF)` |
| Badge secondary bg | `#94D63A` | `XGColors.BadgeSecondaryBackground` = `Color(0xFF94D63A)` |
| Badge secondary text | `#6000FE` | `XGColors.BadgeSecondaryText` = `Color(0xFF6000FE)` |
| Corner radius | medium (10dp) | `XGCornerRadius.Medium` = `10.dp` |
| Font | captionSemiBold (12sp SemiBold) | `XGCustomTextStyles.CaptionSemiBold` |
| H-padding | 10dp | `BadgeConstants.HorizontalPadding` = `10.dp` |
| V-padding | 4dp | `BadgeConstants.VerticalPadding` = `4.dp` |
| CountBadge shape | capsule | `RoundedCornerShape(XGCornerRadius.Full)` |
| Neutral bg | `#F9FAFB` | `XGColors.SurfaceVariant` = `Color(0xFFF9FAFB)` |
| OnError text | `#FFFFFF` | `XGColors.OnError` = `Color(0xFFFFFFFF)` |
| OnSurfaceVariant text | `#8E8E93` | `XGColors.OnSurfaceVariant` = `Color(0xFF8E8E93)` |

## iOS Parity

The Android implementation now matches iOS:
- Both have `XGBadge` with `XGBadgeVariant` (Primary/Secondary)
- Both have `XGCountBadge` with capsule shape
- Both have `XGStatusBadge` using platform-specific token references (not raw Material/SwiftUI)

## Next Steps

- Android Tester should add tests for the new `XGBadge` composable
- Reviewer should verify cross-platform parity
