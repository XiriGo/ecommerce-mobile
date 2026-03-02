# DQ-13 XGSectionHeader Audit - Android Dev Handoff

**Agent**: android-dev
**Platform**: Android
**Date**: 2026-03-02
**Status**: Complete

## Summary

Audited and fixed `XGSectionHeader.kt` against the token spec (`components/atoms/xg-section-header.json`).

## Changes Made

### 1. Title Text: Inline font constants replaced with XGTypography.titleMedium

**Before**: `fontFamily = PoppinsFontFamily, fontSize = TitleFontSize, fontWeight = FontWeight.SemiBold`
**After**: `style = MaterialTheme.typography.titleMedium, color = XGColors.OnSurface`

`XGTypography.titleMedium` maps to typeScale.subtitle (18sp SemiBold Poppins) which is set in `XGTheme`.

### 2. Subtitle Text: Fixed font weight from Normal to Medium

**Before**: `fontFamily = PoppinsFontFamily, fontSize = SubtitleFontSize, fontWeight = FontWeight.Normal`
**After**: `style = MaterialTheme.typography.labelLarge, color = XGColors.OnSurfaceVariant`

Token spec requires `bodyMedium` = 14sp Medium. `XGTypography.labelLarge` maps to this (14sp Medium Poppins).

### 3. Arrow icon size corrected from 16dp to 12dp

**Before**: `SeeAllIconSize = 16.dp`
**After**: `ArrowIconSize = 12.dp`

Matches token spec `arrowIconSize: 12`.

### 4. "See All" text: Inline font constants replaced with XGTypography.labelLarge

**Before**: `fontFamily = PoppinsFontFamily, fontSize = SeeAllFontSize, fontWeight = FontWeight.Medium`
**After**: `style = MaterialTheme.typography.labelLarge, color = XGColors.BrandPrimary`

### 5. Subtitle spacing added

**Before**: `Column(modifier = Modifier.weight(1f))` (no spacing)
**After**: `Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(XGSpacing.XXS))`

Matches token spec `subtitleSpacing: $foundations/spacing.spacing.xxs` (2dp).

### 6. Removed redundant private constants

Removed: `TitleFontSize`, `TitleLineHeight`, `SubtitleFontSize`, `SubtitleLineHeight`, `SeeAllFontSize`, `SeeAllLineHeight`, `SeeAllIconSize`.
Kept (renamed): `ArrowIconSize = 12.dp` (no typography token for icon size).

### 7. Removed unused import

Removed: `import com.xirigo.ecommerce.core.designsystem.theme.PoppinsFontFamily` (no longer needed).
Removed: `import androidx.compose.ui.text.font.FontWeight` (no longer needed).
Removed: `import androidx.compose.ui.unit.sp` (no longer needed).

## Files Modified

| File | Change |
|------|--------|
| `android/.../component/XGSectionHeader.kt` | Replace inline fonts with XGTypography, fix icon size 16dp->12dp, add subtitle spacing, remove dead constants |

## Token Verification

| Token | Spec Value | Implementation |
|-------|-----------|----------------|
| titleFont | typeScale.subtitle (18sp SemiBold) | `MaterialTheme.typography.titleMedium` via `XGTypography.titleMedium` |
| titleColor | light.textPrimary (#333333) | `XGColors.OnSurface` = `Color(0xFF333333)` |
| subtitleFont | typeScale.bodyMedium (14sp Medium) | `MaterialTheme.typography.labelLarge` via `XGTypography.labelLarge` |
| subtitleColor | light.textSecondary (#8E8E93) | `XGColors.OnSurfaceVariant` = `Color(0xFF8E8E93)` |
| seeAllFont | typeScale.bodyMedium (14sp Medium) | `MaterialTheme.typography.labelLarge` |
| seeAllColor | brand.primary (#6000FE) | `XGColors.BrandPrimary` = `Color(0xFF6000FE)` |
| arrowIconSize | 12 | `ArrowIconSize = 12.dp` |
| horizontalPadding | screenPaddingHorizontal (20dp) | `XGSpacing.ScreenPaddingHorizontal` = `20.dp` |
| subtitleSpacing | spacing.xxs (2dp) | `XGSpacing.XXS` = `2.dp` |

## Next Steps

- Android Tester should verify the token tests
- Reviewer should verify cross-platform parity
