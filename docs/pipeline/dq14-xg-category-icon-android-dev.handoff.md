# DQ-14: XGCategoryIcon Token Audit — Android Dev Handoff

## Component
`XGCategoryIcon.kt` — `core/designsystem/component/`

## Changes

### XGCategoryIcon.kt
1. **Replaced inline font properties with typography token**: Removed `fontFamily = PoppinsFontFamily`, `fontSize = LabelFontSize`, `fontWeight = FontWeight.Medium`, `lineHeight = LabelLineHeight` from the label `Text` composable. Replaced with `style = MaterialTheme.typography.labelMedium` which maps to `XGTypography.labelMedium` (12sp Medium Poppins, 16sp lineHeight).
2. **Removed dead constants**: Deleted `LabelFontSize` (12.sp) and `LabelLineHeight` (16.sp) private vals — now redundant since the typography token carries both values.
3. **Removed unused import**: `PoppinsFontFamily` is no longer directly referenced.
4. **Removed unused imports**: `FontWeight`, `sp` no longer needed.
5. **Added accessibility semantics**: Added `semantics(mergeDescendants = true)` on the outer `Column` so TalkBack treats the icon + label as a single accessible element.
6. **Enhanced doc comment**: Added full token mapping reference in the file header comment linking each visual property to its JSON token path.

### No theme changes
All tokens (`XGCornerRadius.Medium`, `XGColors.IconOnDark`, `XGColors.OnSurface`, `XGColors.Category*`, `XGTypography.labelMedium`) already existed.

## Token Alignment Summary

| Token | JSON Path | Android Value | Status |
|-------|-----------|---------------|--------|
| tileSize | `tokens.tileSize` = 79 | 79.dp | OK |
| cornerRadius | `$foundations/spacing.cornerRadius.medium` | XGCornerRadius.Medium (10dp) | OK |
| iconSize | `tokens.iconSize` = 40 | 40.dp | OK |
| iconColor | `$foundations/colors.light.iconOnDark` | XGColors.IconOnDark | OK |
| labelFont | `$foundations/typography.typeScale.captionMedium` | MaterialTheme.typography.labelMedium | FIXED |
| labelColor | `$foundations/colors.light.textPrimary` | XGColors.OnSurface | OK |
| labelSpacing | `tokens.labelSpacing` = 6 | 6.dp | OK |
