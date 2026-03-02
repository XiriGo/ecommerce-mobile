# DQ-18 XGChip Token Audit -- iOS Dev Handoff

## Changes Made

### `XGColors.swift`
- Added `filterPillBackground` = `Color(hex: "#F1F5F9")` from `light.filterPillBackground`
- Added `filterPillBackgroundActive` = `Color(hex: "#6200FF")` from `light.filterPillBackgroundActive`
- Added `filterPillText` = `Color(hex: "#333333")` from `light.filterPillText`
- Added `filterPillTextActive` = `Color.white` from `light.filterPillTextActive`
- Added `surfaceTertiary` = `Color(hex: "#F1F5F9")` from `light.surfaceTertiary`

### `XGChip.swift` — XGFilterChip
- Added `FilterChipTokens` private enum with height (36), cornerRadius (18),
  horizontalPadding (XGSpacing.base = 16), gap (XGSpacing.sm = 8)
- Set explicit `.frame(height: 36)` instead of vertical padding
- Changed shape from `Capsule()` to `RoundedRectangle(cornerRadius: 18)`
- Changed font from `XGTypography.labelLarge` to `XGTypography.bodyMedium` (same 14pt Medium)
- Changed active colors from `secondaryContainer`/`onSecondaryContainer` to
  `filterPillBackgroundActive`/`filterPillTextActive`
- Changed inactive colors from `surfaceVariant`/`onSurfaceVariant` to
  `filterPillBackground`/`filterPillText`
- Changed border shape from `Capsule()` to `RoundedRectangle(cornerRadius: 18)`
- Changed border color to `XGColors.outline`

### `XGChip.swift` — XGCategoryChip
- Changed background from `XGColors.surfaceVariant` to `XGColors.surfaceTertiary`

### Pre-staged Fix (included in branch)
- `XGWishlistButtonTests.swift`: minTouchTarget assertion changed from 44 to 48

## Status
COMPLETE
