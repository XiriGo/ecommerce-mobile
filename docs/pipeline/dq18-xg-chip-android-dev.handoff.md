# DQ-18 XGChip Token Audit -- Android Dev Handoff

## Changes Made

### `XGColors.kt`
- Added `FilterPillBackground` = `Color(0xFFF1F5F9)` from `light.filterPillBackground`
- Added `FilterPillBackgroundActive` = `Color(0xFF6200FF)` from `light.filterPillBackgroundActive`
- Added `FilterPillText` = `Color(0xFF333333)` from `light.filterPillText`
- Added `FilterPillTextActive` = `Color(0xFFFFFFFF)` from `light.filterPillTextActive`
- Added `SurfaceTertiary` = `Color(0xFFF1F5F9)` from `light.surfaceTertiary`

### `XGChip.kt` — XGFilterChip
- Added explicit height: `FilterChipHeight = 36.dp` (token: `variants.filter.height`)
- Added explicit shape: `RoundedCornerShape(18.dp)` (token: `variants.filter.cornerRadius`)
- Set font to `MaterialTheme.typography.bodyMedium` (token: `variants.filter.font`)
- Set active colors: `FilterPillBackgroundActive` / `FilterPillTextActive`
- Set inactive colors: `FilterPillBackground` / `FilterPillText`
- Set icon size to `SelectedIconSize = 16.dp` (token: `iconSize.small`)
- Set inactive border to `XGColors.Outline` with 1dp width
- Removed dependency on `FilterChipDefaults.IconSize`

### `XGChip.kt` — XGCategoryChip
- Set font to `MaterialTheme.typography.labelLarge` (token: `labelLarge`)
- Set background to `XGColors.SurfaceTertiary` (token: `surfaceTertiary`)
- Set text color to `XGColors.OnSurface` (token: `textPrimary`)
- Fixed icon size from hardcoded `18.dp` to `CategoryIconSize = 24.dp` (token: `iconSize.medium`)
- Set shape to `RoundedCornerShape(18.dp)` — capsule-like for chip height
- Removed default border (transparent)

## Status
COMPLETE
