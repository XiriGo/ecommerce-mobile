# XGColorSwatch

## Overview

Circular color swatch component for product detail and filter screens. Displays
selectable color options with a branded selection ring and adaptive checkmark.

## Token Source

`shared/design-tokens/components/atoms/xg-color-swatch.json`

## Visual States

| State | Description |
|-------|-------------|
| Unselected | Filled circle with 1px border |
| Selected | Filled circle + branded ring + checkmark overlay |

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | Color | required | Fill color of the swatch |
| `isSelected` | Boolean | `false` | Whether swatch is selected |
| `onClick` / `action` | Callback | required | Tap handler |
| `colorName` | String | required | Accessibility label |

## Token Values

| Token | Value |
|-------|-------|
| Size | 40dp / 40pt |
| Corner radius | 20 (circle) |
| Selected ring color | Brand primary (#6000FE) |
| Selected ring width | 2 |
| Selected ring gap | 3 |
| Border color | #E5E7EB |
| Border width | 1 |

## Platform Files

| Platform | Component | Tests |
|----------|-----------|-------|
| Android | `core/designsystem/component/XGColorSwatch.kt` | `core/designsystem/component/XGColorSwatchTokenTest.kt` |
| iOS | `Core/DesignSystem/Component/XGColorSwatch.swift` | `Core/DesignSystem/Component/XGColorSwatchTests.swift` |

## Accessibility

- Color name as content description / accessibility label
- Selected state communicated via semantics
- Touch target meets minimum size (48dp Android / 44pt iOS)

## Checkmark Contrast

The checkmark color adapts based on swatch luminance:
- Dark swatches (luminance <= 0.6): white checkmark
- Light swatches (luminance > 0.6): dark checkmark (#333333)
