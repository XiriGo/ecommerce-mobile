# XGChip Token Audit Specification (DQ-18)

## Overview

Audit `XGFilterChip` and `XGCategoryChip` against the component token spec at
`shared/design-tokens/components/atoms/xg-chip.json`. Replace all hardcoded
values and Material 3 defaults with explicit design-system tokens. This
component serves as the base for `XGFilterPill` (DQ-31).

## Token Reference

Source: `shared/design-tokens/components/atoms/xg-chip.json`

### Filter Variant

| Property | Token Value | Token Source |
|----------|-------------|-------------|
| Height | 36 dp/pt | `variants.filter.height` |
| Corner Radius | 18 dp/pt | `variants.filter.cornerRadius` |
| Horizontal Padding | 16 dp/pt | `variants.filter.horizontalPadding` |
| Font | bodyMedium (14pt Medium) | `$foundations/typography.typeScale.bodyMedium` |
| Active Background | `#6200FF` | `$foundations/colors.light.filterPillBackgroundActive` |
| Active Text Color | `#FFFFFF` | `$foundations/colors.light.filterPillTextActive` |
| Inactive Background | `#F1F5F9` | `$foundations/colors.light.filterPillBackground` |
| Inactive Text Color | `#333333` | `$foundations/colors.light.filterPillText` |
| Gap (icon to text) | 8 dp/pt | `variants.filter.gap` |
| Selected Icon | checkmark / Icons.Filled.Check | `variants.filter.selectedIcon` |
| Selected Icon Size | 16 dp/pt | `$foundations/spacing.layout.iconSize.small` |

### Category Variant

| Property | Token Value | Token Source |
|----------|-------------|-------------|
| Shape | Capsule | `variants.category.shape` |
| Background | surfaceTertiary (`#F1F5F9`) | `$foundations/colors.light.surfaceTertiary` |
| Text Color | textPrimary (`#333333`) | `$foundations/colors.light.textPrimary` |
| Font | labelLarge (14pt Medium) | `variants.category.font` |
| Icon Size | 24 dp/pt | `$foundations/spacing.layout.iconSize.medium` |

## Current State Analysis

### Android (`XGChip.kt`)

**XGFilterChip**:
- Uses `FilterChip` composable with Material 3 defaults for height and padding
- Uses `FilterChipDefaults.IconSize` instead of token `iconSize.small` (16dp)
- Colors use `MaterialTheme.colorScheme.secondaryContainer` — correct mapping but
  should use explicit `XGColors` tokens for clarity
- Missing: explicit height (36dp), corner radius (18dp), horizontal padding (16dp),
  font (bodyMedium), gap (8dp), inactive colors

**XGCategoryChip**:
- Uses `FilterChip(selected = false)` — picks up Material 3 defaults
- Icon size hardcoded to `18.dp` — should be `XGSpacing.IconSize.Medium` (24dp)
- Missing: explicit capsule shape, surfaceTertiary background, textPrimary color,
  labelLarge font

### iOS (`XGChip.swift`)

**XGFilterChip**:
- Uses `XGSpacing.xs` (4pt) for gap — should be `XGSpacing.sm` (8pt) per token
- Uses `XGSpacing.md` (12pt) for horizontal padding — should be `XGSpacing.base` (16pt)
- Uses `XGSpacing.sm` (8pt) for vertical padding — not explicit height
- Uses `XGTypography.labelLarge` — correct (14pt Medium = bodyMedium)
- Colors use `XGColors.secondaryContainer`/`XGColors.onSecondaryContainer` for active
  and `XGColors.surfaceVariant`/`XGColors.onSurfaceVariant` for inactive — should use
  dedicated filterPill tokens
- Missing: explicit height (36pt), corner radius (18pt) instead of Capsule()

**XGCategoryChip**:
- Uses `XGSpacing.sm` (8pt) for gap — token doesn't specify gap for category
- Uses `XGSpacing.md` (12pt) for horizontal padding — should match category spec
- Icon size correct at `XGSpacing.IconSize.medium` (24pt)
- Background `XGColors.surfaceVariant` — should be `surfaceTertiary`
- Text color `XGColors.onSurface` — matches textPrimary
- Missing: explicit capsule shape is present, good

## Required Changes

### Theme Token Additions

**Android `XGColors.kt`**: Add dedicated filterPill tokens:
- `FilterPillBackground = Color(0xFFF1F5F9)`
- `FilterPillBackgroundActive = Color(0xFF6200FF)`
- `FilterPillText = Color(0xFF333333)`
- `FilterPillTextActive = Color(0xFFFFFFFF)`
- `SurfaceTertiary = Color(0xFFF1F5F9)`

**iOS `XGColors.swift`**: Add dedicated filterPill tokens:
- `filterPillBackground = Color(hex: "#F1F5F9")`
- `filterPillBackgroundActive = Color(hex: "#6200FF")`
- `filterPillText = Color(hex: "#333333")`
- `filterPillTextActive = Color.white`
- `surfaceTertiary = Color(hex: "#F1F5F9")` (if not already present)

### Android Implementation Changes

1. Replace `FilterChip` with custom `Surface` + `Row` to control height/radius/padding
   OR use `FilterChip` with explicit `shape`, `border`, and `colors` overrides
2. Set height to `36.dp`
3. Set shape to `RoundedCornerShape(18.dp)` — note: 18dp = half of 36dp height (pill)
4. Set horizontal padding to `XGSpacing.Base` (16dp)
5. Set font to `MaterialTheme.typography.bodyMedium` (maps to bodyMedium token)
6. Set active colors: bg = `XGColors.FilterPillBackgroundActive`, text = `XGColors.FilterPillTextActive`
7. Set inactive colors: bg = `XGColors.FilterPillBackground`, text = `XGColors.FilterPillText`
8. Set gap to `XGSpacing.SM` (8dp)
9. Set icon size to `16.dp` (XGSpacing layout iconSize.small — define constant if needed)
10. Set inactive border to `XGColors.Outline`
11. Category chip: fix icon size to `24.dp` via `IconSize` constant, set bg to `SurfaceTertiary`

### iOS Implementation Changes

1. Set explicit `.frame(height: 36)` on the chip container
2. Replace `Capsule()` with `RoundedRectangle(cornerRadius: 18)` for filter variant
3. Set horizontal padding to `XGSpacing.base` (16pt)
4. Set gap to `XGSpacing.sm` (8pt) — already correct
5. Use `XGTypography.bodyMedium` for filter variant label (already labelLarge = 14pt Medium)
6. Set active colors: bg = `XGColors.filterPillBackgroundActive`, text = `XGColors.filterPillTextActive`
7. Set inactive colors: bg = `XGColors.filterPillBackground`, text = `XGColors.filterPillText`
8. Set inactive border to `XGColors.outline`
9. Category chip: change background from `surfaceVariant` to `surfaceTertiary`

## Acceptance Criteria

- [ ] All filter variant dimensions match token spec (height 36, radius 18, hPadding 16)
- [ ] Filter chip active state uses filterPillBackgroundActive + filterPillTextActive
- [ ] Filter chip inactive state uses filterPillBackground + filterPillText
- [ ] Filter chip inactive state has outline border
- [ ] Selected icon is checkmark at iconSize.small (16)
- [ ] Category chip uses surfaceTertiary background
- [ ] Category chip uses textPrimary (onSurface) text color
- [ ] Category chip icon size is iconSize.medium (24)
- [ ] All values come from XG* token objects, zero magic numbers
- [ ] Both platforms produce visually identical chips
- [ ] Previews show all variants
- [ ] Existing tests updated to verify token values
