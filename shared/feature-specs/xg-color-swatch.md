# XGColorSwatch — Platform-Agnostic Spec

## Overview

A circular color swatch component used in product detail and filter screens to
display selectable color options. Each swatch shows a solid fill color with a
thin white border. When selected, a branded ring and checkmark overlay indicate
the active choice.

## Token Reference

Source: `shared/design-tokens/components/atoms/xg-color-swatch.json`

| Token | Value | Description |
|-------|-------|-------------|
| `size` | 40 | Overall diameter of the swatch circle |
| `cornerRadius` | 20 | Half the size (fully circular) |
| `selectedRingColor` | `$brand.primary` (#6000FE) | Outer ring color when selected |
| `selectedRingWidth` | 2 | Stroke width of the selection ring |
| `selectedRingGap` | 3 | Gap between the swatch and the selection ring |
| `whiteBorderColor` | `$light.borderDefault` (#E5E7EB) | Thin border around the swatch (always visible) |
| `whiteBorderWidth` | 1 | Width of the always-visible border |
| `availableColors` | `$colorSwatches` | Map of named colors used in filters |

### Available Swatch Colors (from `colorSwatches`)

| Name | Hex |
|------|-----|
| black | #1D1D1B |
| white | #FFFFFF |
| red | #EF4444 |
| blue | #3B82F6 |
| green | #22C55E |

Note: The "white" swatch has a special `whiteBorder` (#E5E7EB) so it is visible
against white backgrounds.

## Visual States

### Unselected

- Circle of `size` diameter filled with the swatch color
- 1px border of `whiteBorderColor` around the circle
- No ring, no checkmark

### Selected

- Same filled circle
- Outer ring: `selectedRingColor`, `selectedRingWidth` stroke, offset outward by
  `selectedRingGap` from the swatch edge
- Checkmark icon overlaid at center (white with drop shadow, or dark for light
  swatch colors)
- The checkmark should be white for dark colors and dark for light colors (white
  swatch), ensuring visibility

## API Surface

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | Color | required | Fill color of the swatch |
| `isSelected` | Boolean | `false` | Whether this swatch is currently selected |
| `onClick` | () -> Unit | required | Callback when tapped |
| `contentDescription` | String | required | Accessibility label (color name) |

### Accessibility

- `contentDescription` / `accessibilityLabel`: the human-readable color name
- Selected state communicated via `isSelected` trait / semantics
- Minimum touch target: 48dp (Android) / 44pt (iOS) — pad if needed

## Implementation Notes

### Android (Compose)

- File: `core/designsystem/component/XGColorSwatch.kt`
- Use `Canvas` or `Box` with circular clip + border modifiers
- Selection ring via a larger circle stroke behind the swatch
- Checkmark: `Icons.Filled.Check` icon overlay
- Token constants as `private val` at file top
- Colors: use `XGColors.Primary` for ring, `XGColors.Outline` for border
- Animation: animate ring appearance with `XGMotion.Easing.standardTween`
- Previews: show all states (unselected, selected-dark, selected-light)

### iOS (SwiftUI)

- File: `Core/DesignSystem/Component/XGColorSwatch.swift`
- Circle + overlay for border + conditional ring overlay
- Checkmark: `Image(systemName: "checkmark")`
- Private `Constants` enum for token values
- Colors: `XGColors.primary` for ring, `XGColors.outline` for border
- Animation: `.animation(XGMotion.Easing.standard)`
- Previews: show all states with `.xgTheme()`

### Checkmark Contrast Logic

For the checkmark to be visible against both light and dark swatch colors,
use luminance detection:

- If swatch color luminance > 0.6 → dark checkmark (#333333)
- If swatch color luminance <= 0.6 → white checkmark (#FFFFFF)

## Localization

String key: `common_color_swatch_selected_a11y` — "Selected" (accessibility
hint for selected state). The color name comes from the caller.

## Dependencies

No external dependencies. Uses only design system tokens and platform icons.
