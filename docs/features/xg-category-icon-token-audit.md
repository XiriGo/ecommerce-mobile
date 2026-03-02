# XGCategoryIcon Token Audit (DQ-14)

## Overview

Audited `XGCategoryIcon` on both Android and iOS platforms against the token specification at `shared/design-tokens/components/atoms/xg-category-icon.json`. Replaced inline font properties with typography tokens, removed dead code, added missing iOS category color tokens, and added token contract tests.

## Token Specification

| Token | JSON Path | Value |
|-------|-----------|-------|
| tileSize | `tokens.tileSize` | 79 |
| cornerRadius | `$foundations/spacing.cornerRadius.medium` | 10 |
| iconSize | `tokens.iconSize` | 40 |
| iconColor | `$foundations/colors.light.iconOnDark` | #FFFFFF |
| labelFont | `$foundations/typography.typeScale.captionMedium` | 12pt Medium |
| labelColor | `$foundations/colors.light.textPrimary` | #333333 |
| labelSpacing | `tokens.labelSpacing` | 6 |
| backgroundColors | `$foundations/colors.category.*` | blue, pink, yellow, mint, lightYellow |

## Changes

### Android
- Replaced inline `fontFamily/fontSize/fontWeight/lineHeight` on label `Text` with `MaterialTheme.typography.labelMedium`
- Removed dead constants `LabelFontSize` and `LabelLineHeight`
- Removed unused `PoppinsFontFamily` import
- Added `semantics(mergeDescendants = true)` for TalkBack accessibility
- Added full token mapping doc comment

### iOS
- Added 5 missing category color tokens to `XGColors.swift` (categoryBlue, categoryPink, categoryYellow, categoryMint, categoryLightYellow)
- Removed dead `Constants.labelFontSize` constant
- Added `.buttonStyle(.plain)` to prevent system button styling
- Fixed preview to use `XGColors.category*` instead of hardcoded hex colors
- Added full token mapping doc comment

### Tests
- **Android**: 22 JUnit tests in `XGCategoryIconTokenTest.kt`
- **iOS**: 24 Swift Testing tests in `XGCategoryIconTests.swift`

## Files Modified

| File | Platform | Change |
|------|----------|--------|
| `android/.../component/XGCategoryIcon.kt` | Android | Token alignment |
| `ios/.../Component/XGCategoryIcon.swift` | iOS | Token alignment, dead code removal |
| `ios/.../Theme/XGColors.swift` | iOS | Added category colors |
| `android/.../component/XGCategoryIconTokenTest.kt` | Android | New test file |
| `ios/.../Component/XGCategoryIconTests.swift` | iOS | New test file |
