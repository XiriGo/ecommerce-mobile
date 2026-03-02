# XGPriceText — Design System Component

## Overview

`XGPriceText` is a three-part composite price display component that renders a
currency symbol, integer part, and decimal part with separate font sizes. It uses
Source Sans 3 Black font for the price display and Poppins Medium for strikethrough
original prices.

## Token Source

`shared/design-tokens/components/atoms/xg-price-text.json`

## API

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `price` | `String?` | required | Current price. When `null`/`nil`, the component renders nothing. |
| `originalPrice` | `String?` | `null`/`nil` | Original price (shown as strikethrough when set). |
| `currencySymbol` | `String` | `"EUR"` | Currency symbol prefix. |
| `style` | `XGPriceStyle` | `.default`/`Default` | Visual style variant controlling font sizes and color. |
| `strikethroughFontSize` | `Float`/`CGFloat` | `15.18` | Font size for the strikethrough original price. |
| `layout` | `XGPriceLayout` | `.inline`/`Inline` | Arrangement of current price and strikethrough. |

### XGPriceStyle

| Variant | Currency | Integer | Decimal | Color | Usage |
|---------|----------|---------|---------|-------|-------|
| `default` | 22.78 | 27.33 | 18.98 | `priceDiscount` | Popular Products cards |
| `standard` | 20 | 20 | 14 | `priceDiscount` | New Arrivals cards |
| `small` | 14 | 18 | 14 | `priceDiscount` | Compact displays |
| `deal` | 22.78 | 27.33 | 18.98 | `priceDeal` | Daily Deal card |

### XGPriceLayout

| Layout | Description |
|--------|-------------|
| `inline` | Price + strikethrough side-by-side (HStack/Row) |
| `stacked` | Strikethrough above price (VStack/Column) |

### Strikethrough Styling

- Font: Poppins Medium (primary font family)
- Color: `priceStrikethrough` (`#8E8E93`)
- Decoration: line-through
- Default size: 15.18sp/pt
- Standard size: 14sp/pt

## Null Price Fallback (DQ-10)

When `price` is `null`/`nil`, the component renders nothing. This prevents
showing "$0.00" or empty price text for products with no price set.

- **Android**: Early return from composable function
- **iOS**: `if let price { ... }` guard in body

## Platform Implementations

| Platform | File |
|----------|------|
| Android | `android/.../core/designsystem/component/XGPriceText.kt` |
| iOS | `ios/.../Core/DesignSystem/Component/XGPriceText.swift` |

## Usage Examples

### Android (Kotlin + Compose)

```kotlin
// Basic price
XGPriceText(price = "29.99")

// Sale price with strikethrough
XGPriceText(
    price = "19.99",
    originalPrice = "29.99",
    style = XGPriceStyle.Standard,
    strikethroughFontSize = 14f,
)

// Deal variant (green color)
XGPriceText(
    price = "89.99",
    originalPrice = "149.99",
    style = XGPriceStyle.Deal,
    layout = XGPriceLayout.Stacked,
)

// Null price (renders nothing)
XGPriceText(price = null)
```

### iOS (Swift + SwiftUI)

```swift
// Basic price
XGPriceText(price: "29.99")

// Sale price with strikethrough
XGPriceText(
    price: "19.99",
    originalPrice: "29.99",
    style: .standard,
    strikethroughFontSize: 14
)

// Deal variant (green color)
XGPriceText(
    price: "89.99",
    originalPrice: "149.99",
    style: .deal,
    layout: .stacked
)

// Nil price (renders nothing)
XGPriceText(price: nil)
```

## Call Sites

| Component | Platform | Style Used |
|-----------|----------|------------|
| `XGProductCard` | Both | Configurable (default: `.default`) |
| `XGDailyDealCard` | Both | `.deal` |
| `HomeScreen` | Both | `.default` + `.standard` |

## Test Coverage

- **Android**: 14 instrumentation tests (`XGPriceTextTest.kt`)
- **iOS**: 30 Swift Testing tests (`XGPriceTextTests.swift`)

## Changelog

- **DQ-10** (2026-03-02): Token + fallback audit
  - Renamed `XGPriceSize` to `XGPriceStyle` on Android
  - Added null price fallback on both platforms
  - Added `StandardStrikethroughFontSize` (14) from tokens
  - Verified all font sizes and colors match token spec
- **M0-02**: Initial implementation
