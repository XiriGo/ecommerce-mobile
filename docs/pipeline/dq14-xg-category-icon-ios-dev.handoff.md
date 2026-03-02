# DQ-14: XGCategoryIcon Token Audit — iOS Dev Handoff

## Component
`XGCategoryIcon.swift` — `Core/DesignSystem/Component/`

## Changes

### XGColors.swift
1. **Added 5 category color tokens**: `categoryBlue` (#37B4F2), `categoryPink` (#FE75D4), `categoryYellow` (#FDF29C), `categoryMint` (#90D3B1), `categoryLightYellow` (#FEF170). These were present in the Android `XGColors` but missing from iOS.

### XGCategoryIcon.swift
1. **Removed dead constant**: Deleted `Constants.labelFontSize` (12) — unused since the component already uses `XGTypography.captionMedium` for the font.
2. **Added `.buttonStyle(.plain)`**: Prevents SwiftUI's default button styling from tinting the icon and label.
3. **Fixed preview colors**: Replaced hardcoded `Color(hex: "#37B4F2")` etc. with `XGColors.categoryBlue`, `XGColors.categoryPink`, `XGColors.categoryYellow`.
4. **Enhanced doc comment**: Added full token mapping reference linking each visual property to its JSON token path.

## Token Alignment Summary

| Token | JSON Path | iOS Value | Status |
|-------|-----------|-----------|--------|
| tileSize | `tokens.tileSize` = 79 | 79pt | OK |
| cornerRadius | `$foundations/spacing.cornerRadius.medium` | XGCornerRadius.medium (10pt) | OK |
| iconSize | `tokens.iconSize` = 40 | 40pt | OK |
| iconColor | `$foundations/colors.light.iconOnDark` | XGColors.iconOnDark | OK |
| labelFont | `$foundations/typography.typeScale.captionMedium` | XGTypography.captionMedium | OK |
| labelColor | `$foundations/colors.light.textPrimary` | XGColors.onSurface | OK |
| labelSpacing | `tokens.labelSpacing` = 6 | 6pt | OK |
| backgroundColors | `$foundations/colors.category.*` | XGColors.category* | ADDED |
