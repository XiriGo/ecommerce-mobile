# XGRangeSlider — Feature Specification

## Overview

A dual-thumb range slider component for selecting a numeric range (e.g., price
filter). Part of the XiriGo design system atom layer. Used by Product Search
(M1-08) and any future filter screens.

## Token Source

`shared/design-tokens/components/atoms/xg-range-slider.json`

| Token | Value | Maps To |
|-------|-------|---------|
| `trackHeight` | 4 | Track bar height (dp/pt) |
| `trackActiveColor` | `$foundations/colors.brand.primary` | `XGColors.Primary` / `XGColors.primary` |
| `trackInactiveColor` | `$foundations/colors.light.borderStrong` | `XGColors.Outline` / `XGColors.borderStrong` |
| `thumbSize` | 24 | Thumb diameter (dp/pt) |
| `thumbColor` | `$foundations/colors.brand.primary` | `XGColors.Primary` / `XGColors.primary` |
| `thumbBorderColor` | `$foundations/colors.light.surface` | `XGColors.Surface` / `XGColors.surface` |
| `thumbBorderWidth` | 3 | Thumb border stroke width (dp/pt) |

## API Contract

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `min` | Float/Double | (required) | Current lower bound of the selected range |
| `max` | Float/Double | (required) | Current upper bound of the selected range |
| `range` | ClosedRange | (required) | Allowed value range (e.g., 0..1000) |
| `onRangeChange` | (Float, Float) -> Unit | (required) | Callback when either thumb moves; receives (newMin, newMax) |
| `modifier` | Modifier/ViewModifier | default | Platform layout modifier |
| `step` | Float/Double | 0 (continuous) | Step increment; 0 = continuous |
| `showLabels` | Boolean | true | Show min/max value labels below the track |
| `labelFormatter` | (Float) -> String | default | Custom label formatting (e.g., currency) |

### Behavioral Rules

1. The low thumb can never exceed the high thumb.
2. The high thumb can never go below the low thumb.
3. When `step > 0`, values snap to the nearest step.
4. Both thumbs respect `range` bounds.
5. The active track segment lies between the two thumbs.
6. The inactive track extends from `range.start` to `lowThumb` and from `highThumb` to `range.end`.
7. Minimum touch target: 48dp (Android) / 44pt (iOS).

### Accessibility

- **Android**: Each thumb has `contentDescription` with current value. Whole slider
  has semantic description of the selected range.
- **iOS**: Each thumb has `accessibilityLabel` + `accessibilityValue` with current value.
  Supports VoiceOver adjustable actions for increment/decrement.

### Visual Layout

```
  [lowThumb]--------active track--------[highThumb]
inactive |                                | inactive
         $25                             $200
```

## Platform Mapping

### Android (Kotlin + Jetpack Compose)

- File: `core/designsystem/component/XGRangeSlider.kt`
- Uses Canvas for custom track drawing
- Custom drag gesture for dual thumbs
- Token constants as private top-level vals
- `@Preview` with `XGTheme` wrapper

### iOS (Swift + SwiftUI)

- File: `Core/DesignSystem/Component/XGRangeSlider.swift`
- Uses GeometryReader + Canvas/Shape for track
- DragGesture for each thumb
- Private Constants enum
- `#Preview` with `.xgTheme()` modifier

## Test Requirements

- Token contract tests (colors, dimensions match spec)
- Initialization tests (default and custom parameters)
- Coverage target: >= 80%

## Dependencies

None. Pure UI component with no data/domain layer.
