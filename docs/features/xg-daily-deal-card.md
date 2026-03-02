# XGDailyDealCard

## Overview

`XGDailyDealCard` is a gradient promotional card that displays a daily deal with a live countdown timer, product title, pricing (deal + strikethrough), and product image. It lives in the design system layer and is consumed by the Home screen.

## Platforms

| Platform | File |
|----------|------|
| Android | `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGDailyDealCard.kt` |
| iOS | `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGDailyDealCard.swift` |

## Design Tokens

Source: `shared/design-tokens/components/molecules/xg-daily-deal-card.json`

| Token | Value |
|-------|-------|
| Height | 163dp/pt |
| Padding | 16dp/pt |
| Corner Radius | XGCornerRadius.Medium (10) |
| Background | Linear gradient: textDark -> brandPrimary |
| Product Image Size | 100x100dp/pt |
| Title Font | Poppins SemiBold 20sp/pt, textOnDark, max 2 lines |
| Countdown Font | System monospaced 12sp/pt, textOnDark |
| Countdown Tick | 1 second |
| Price Style | XGPriceText deal style |
| Strikethrough Font Size | 15.18sp/pt |

## Layout

```
HStack {
  VStack(spacing: SM) {
    Badge("DAILY DEAL", secondary)
    Title(maxLines: 2)
    Countdown(HH:MM:SS)
    HStack(spacing: SM) {
      DealPrice
      StrikethroughOriginalPrice
    }
  }
  Spacer
  ProductImage(100x100, cornerRadius: medium)
}
```

## Countdown Timer

- **Android**: `LaunchedEffect(endTime)` + `delay(1000L)` loop. Uses `mutableLongStateOf` for remaining millis.
- **iOS**: `TimelineView(.periodic(from: .now, by: 1))` for declarative 1-second ticks.
- **Format**: `HH:MM:SS` using `String.format("%02d:%02d:%02d", h, m, s)`.
- **Expired**: Shows localized `home_daily_deal_ended` string.

## Image Loading

Product image uses `XGImage` which provides:
- Animated shimmer placeholder while loading (inherited from DQ-07)
- Crossfade transition (300ms) on success
- Branded fallback on error

No manual shimmer code is needed in the card component.

## Accessibility

- **Android**: `semantics { contentDescription }` with badge, title, price, and countdown text.
- **iOS**: `.accessibilityElement(children: .ignore)` + `.accessibilityLabel()` with full deal description.

## Parameters

| Parameter | Android Type | iOS Type | Required | Description |
|-----------|-------------|----------|----------|-------------|
| title | String | String | Yes | Product title |
| price | String | String | Yes | Formatted deal price |
| originalPrice | String | String | Yes | Original price (strikethrough) |
| endTime | Long (epoch ms) | Date | Yes | When the deal expires |
| imageUrl | String? | URL? | No | Product image URL |
| onClick/action | (() -> Unit)? | (() -> Void)? | No | Tap handler |

## Tests

| Platform | File | Count |
|----------|------|-------|
| Android | `XGDailyDealCardTokenTest.kt` | 25 |
| iOS | `XGDailyDealCardTests.swift` | 31 |

## Dependencies

- DQ-07: XGImage upgrade (shimmer + crossfade)
- XGPriceText (deal style)
- XGColors, XGSpacing, XGCornerRadius, XGTypography tokens

## Changelog

- **DQ-24** (2026-03-02): Token audit, monospaced countdown font, fixed image sizing to 100dp/pt, accessibility improvements, shimmer inheritance documentation.
