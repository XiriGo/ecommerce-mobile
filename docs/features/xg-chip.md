# XGChip Component

## Overview

`XGChip` provides two selectable chip variants for the XiriGo design system:
**XGFilterChip** (active/inactive filter selection) and **XGCategoryChip**
(category browsing). Both variants are token-driven and serve as the base
for `XGFilterPill` (DQ-31).

## Variants

### XGFilterChip

Selectable chip with active/inactive states and optional leading icon. When
selected, a checkmark icon replaces any leading icon.

| Property | Value | Token |
|----------|-------|-------|
| Height | 36 dp/pt | `variants.filter.height` |
| Corner Radius | 18 dp/pt | `variants.filter.cornerRadius` |
| Horizontal Padding | 16 dp/pt | `variants.filter.horizontalPadding` |
| Font | bodyMedium (14pt Medium) | `typography.typeScale.bodyMedium` |
| Icon-to-text gap | 8 dp/pt | `variants.filter.gap` |
| Selected Icon Size | 16 dp/pt | `spacing.layout.iconSize.small` |
| Active Background | `#6200FF` | `colors.light.filterPillBackgroundActive` |
| Active Text | `#FFFFFF` | `colors.light.filterPillTextActive` |
| Inactive Background | `#F1F5F9` | `colors.light.filterPillBackground` |
| Inactive Text | `#333333` | `colors.light.filterPillText` |
| Inactive Border | `#E5E7EB` (1dp) | `colors.light.borderDefault` |

### XGCategoryChip

Non-selectable chip for category navigation with optional leading icon (loaded
from URL).

| Property | Value | Token |
|----------|-------|-------|
| Shape | Capsule | `variants.category.shape` |
| Background | `#F1F5F9` | `colors.light.surfaceTertiary` |
| Text Color | `#333333` | `colors.light.textPrimary` |
| Font | labelLarge (14pt Medium) | `variants.category.font` |
| Icon Size | 24 dp/pt | `spacing.layout.iconSize.medium` |

## Usage

### Android

```kotlin
XGFilterChip(
    label = "Electronics",
    selected = isSelected,
    onClick = { onFilterToggle() },
)

XGCategoryChip(
    label = "Shoes",
    onClick = { onCategoryTap() },
    iconUrl = category.iconUrl,
)
```

### iOS

```swift
XGFilterChip(label: "Electronics", isSelected: isSelected) {
    onFilterToggle()
}

XGCategoryChip(label: "Shoes", iconUrl: category.iconUrl) {
    onCategoryTap()
}
```

## Files

| Platform | Source | Tests |
|----------|--------|-------|
| Android | `android/.../component/XGChip.kt` | `android/.../component/XGChipTest.kt` |
| iOS | `ios/.../Component/XGChip.swift` | `ios/.../Component/XGChipTests.swift` |
| Tokens | `shared/design-tokens/components/atoms/xg-chip.json` | -- |

## Token Source

`shared/design-tokens/components/atoms/xg-chip.json`

## Related

- DQ-31: XGFilterPill (built on top of XGFilterChip)
- DQ-18: This token audit issue (#62)
