# XGPriceLayout

## Overview

`XGPriceLayout` controls the arrangement of sale price and strikethrough in `XGPriceText`.

## Enum Cases

| Case | Description | Container |
|------|-------------|-----------|
| `.inline` | Sale price + strikethrough side-by-side. Default for standard/grid cards. | HStack (iOS) / Row (Android) |
| `.stacked` | Strikethrough above, sale price below. Used for featured/horizontal-scroll cards. | VStack (iOS) / Column (Android) |

## Token Source

`shared/design-tokens/components/atoms/xg-price-text.json` -> `enums.XGPriceLayout`

## Platform Files

| Platform | File |
|----------|------|
| Android | `android/.../core/designsystem/component/XGPriceLayout.kt` |
| iOS | `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGPriceLayout.swift` |

## Usage

### iOS

```swift
// Inline (default) - price and strikethrough side-by-side
XGPriceText(price: "29.99", originalPrice: "49.99")

// Stacked - strikethrough above, price below
XGPriceText(price: "29.99", originalPrice: "49.99", layout: .stacked)
```

### Android

```kotlin
// Inline (default)
XGPriceText(price = "29.99", originalPrice = "49.99")

// Stacked
XGPriceText(price = "29.99", originalPrice = "49.99", layout = XGPriceLayout.Stacked)
```

## Tests

- **iOS**: `XGPriceLayoutTests` in `XGPriceTextTests.swift` (6 tests)
- **Android**: `XGPriceTextTest.kt` (existing tests cover layout parameter)

## History

- **DQ-38** (Issue #82): Extracted `XGPriceLayout` from `XGPriceText.swift` into its own file for platform parity with Android.
