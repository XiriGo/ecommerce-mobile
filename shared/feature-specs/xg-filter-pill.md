# XGFilterPill Component Specification (DQ-31)

## Overview

`XGFilterPill` is a molecule component that wraps `XGFilterChip` (DQ-18) with
filter-specific behavior: a dismiss button (X) when selected, and a horizontal
scrollable list variant (`XGFilterPillRow`). Used by Product List (M1-06) and
Filter screens.

## Token Reference

Source: `shared/design-tokens/components/molecules/xg-filter-pill.json`

| Property | Token Value | Token Source |
|----------|-------------|-------------|
| Height | 36 dp/pt | `tokens.height` |
| Corner Radius | 18 dp/pt | `tokens.cornerRadius` |
| Horizontal Padding | 16 dp/pt | `tokens.horizontalPadding` |
| Font | bodyMedium (14pt Medium) | `$foundations/typography.typeScale.bodyMedium` |
| Active Background | `#6200FF` | `$foundations/colors.light.filterPillBackgroundActive` |
| Active Text Color | `#FFFFFF` | `$foundations/colors.light.filterPillTextActive` |
| Inactive Background | `#F1F5F9` | `$foundations/colors.light.filterPillBackground` |
| Inactive Text Color | `#333333` | `$foundations/colors.light.filterPillText` |
| Gap (between pills) | 8 dp/pt | `tokens.gap` |

All tokens map directly to XGFilterChip tokens since XGFilterPill wraps XGFilterChip.

## Component API

### XGFilterPill

A single filter pill with dismiss (X) functionality when selected.

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | String | required | Display text |
| `isSelected` / `selected` | Boolean | `false` | Selected state |
| `onSelect` / `onClick` | () -> Void | required | Tap callback (toggle selection) |
| `onDismiss` | (() -> Void)? | `null` | Dismiss callback; shows X icon when non-null AND selected |

**States:**

1. **Unselected**: Outlined border, inactive colors. No trailing icon.
2. **Selected (no dismiss)**: Filled background, active colors, leading checkmark icon.
3. **Selected (with dismiss)**: Filled background, active colors, leading checkmark icon, trailing X dismiss icon.

The trailing dismiss (X) icon is only visible when:
- `isSelected == true` AND `onDismiss != null`

### XGFilterPillRow

A horizontally scrollable row of `XGFilterPill` items.

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `items` | List of pill data | required | Labels + selection states |
| `onSelect` | (index: Int) -> Void | required | Pill tap callback with index |
| `onDismiss` | ((index: Int) -> Void)? | `null` | Dismiss callback with index |

**Layout:**
- Horizontal scroll (LazyRow on Android, ScrollView+HStack on iOS)
- Gap between pills: 8 dp/pt (from `tokens.gap`)
- Content padding: 16 dp/pt horizontal (matches screen edge padding)

## Data Model

```
XGFilterPillItem:
  - label: String
  - isSelected: Boolean
```

## Accessibility

- Each pill has `accessibilityLabel` = label text
- Selected state announced via `.isSelected` trait
- Dismiss button has `accessibilityLabel` = "Remove {label} filter"
- Row uses horizontal scroll semantics

## File Locations

### Android
- Component: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGFilterPill.kt`
- Tests: `android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGFilterPillTest.kt`

### iOS
- Component: `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGFilterPill.swift`
- Tests: `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGFilterPillTests.swift`

## Dependencies

- XGFilterChip (DQ-18) -- base component, already complete
- XGColors.filterPill* tokens -- already defined
- XGSpacing tokens -- already defined

## Acceptance Criteria

- [ ] XGFilterPill renders on Android with all three states
- [ ] XGFilterPill renders on iOS with all three states
- [ ] Dismiss (X) button only shows when selected AND onDismiss is provided
- [ ] XGFilterPillRow horizontally scrollable with correct gap spacing
- [ ] Uses XGFilterChip as base (wraps, not duplicates)
- [ ] All visual tokens from XG* token objects
- [ ] Previews show all variants on both platforms
- [ ] Unit tests cover all states and callbacks
