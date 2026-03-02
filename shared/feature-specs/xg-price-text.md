# XGPriceText — Token + Fallback Audit Spec (DQ-10)

## Overview

Audit and upgrade the `XGPriceText` component on both Android and iOS to ensure
full compliance with `shared/design-tokens/components/atoms/xg-price-text.json`.
This is a refactor — no new screens or features, only design-system-layer changes.

## Token Reference

Source: `shared/design-tokens/components/atoms/xg-price-text.json`

### Enums

| Enum | Values | Platform Status |
|------|--------|-----------------|
| `XGPriceStyle` | `default`, `standard`, `small`, `deal` | iOS: EXISTS as `XGPriceStyle`. Android: EXISTS as `XGPriceSize` — **RENAME** to `XGPriceStyle` |
| `XGPriceLayout` | `inline`, `stacked` | iOS: EXISTS. Android: EXISTS as `XGPriceLayout` |

### Variant Font Sizes (from token spec)

| Variant | Currency | Integer | Decimal | Color Token |
|---------|----------|---------|---------|-------------|
| `default` | 22.78 | 27.33 | 18.98 | `semantic.priceDiscount` → `XGColors.PriceSale` / `.priceSale` |
| `standard` | 20 | 20 | 14 | `semantic.priceDiscount` → `XGColors.PriceSale` / `.priceSale` |
| `small` | 14 | 18 | 14 | `semantic.priceDiscount` → `XGColors.PriceSale` / `.priceSale` |
| `deal` | 22.78 | 27.33 | 18.98 | `semantic.priceDeal` → `XGColors.BrandSecondary` / `.brandSecondary` |

### Strikethrough (from token spec)

| Property | Value | Token Reference |
|----------|-------|-----------------|
| Font family | Poppins (primary) | `$foundations/typography.fontFamily.primary` |
| Font weight | Medium (500) | via token |
| Color | `#8E8E93` | `semantic.priceStrikethrough` → `XGColors.PriceStrikethrough` / `.priceStrikethrough` |
| Text decoration | `line-through` | via token |
| Default font size | 15.18 | `strikethrough.defaultFontSize` |
| Standard font size | 14 | `strikethrough.standardFontSize` |

### Parameters (from token spec)

| Parameter | Type | Required | Default |
|-----------|------|----------|---------|
| `price` | `String?` | Yes (but nullable) | N/A |
| `originalPrice` | `String?` | No | `null`/`nil` |
| `style` | `XGPriceStyle` | No | `.default` / `Default` |
| `layout` | `XGPriceLayout` | No | `.inline` / `Inline` |
| `strikethroughFontSize` | `Float`/`CGFloat` | No | `15.18` |

## Changes Required

### 1. Null Price Fallback (BOTH PLATFORMS)

**Current behavior**: `price` is a non-null `String`. If empty or invalid, component renders with "0,00".

**Required behavior**: `price` becomes `String?`. When `null`:
- Android: Render nothing (return early, emit no composable content)
- iOS: Return `EmptyView()`
- Call sites that pass `null` will see the price area disappear entirely

This prevents showing "$0.00" or empty price text for products with no price.

### 2. Rename XGPriceSize to XGPriceStyle (ANDROID ONLY)

- Rename enum `XGPriceSize` → `XGPriceStyle` in `XGPriceText.kt`
- Delete `XGPriceSize.kt` file
- Rename parameter `size` → `style` in `XGPriceText` composable
- Update all call sites: `XGCard.kt`, `XGDailyDealCard.kt`
- iOS already uses `XGPriceStyle` — no changes needed

### 3. Token Compliance Audit

Verify all named constants match the token JSON exactly:

| Constant | Expected | Android Status | iOS Status |
|----------|----------|---------------|------------|
| DefaultCurrencyFontSize | 22.78 | CORRECT | CORRECT |
| DefaultIntegerFontSize | 27.33 | CORRECT | CORRECT |
| DefaultDecimalFontSize | 18.98 | CORRECT | CORRECT |
| StandardCurrencyFontSize | 20 | CORRECT | CORRECT |
| StandardIntegerFontSize | 20 | CORRECT | CORRECT |
| StandardDecimalFontSize | 14 | CORRECT | CORRECT |
| SmallCurrencyFontSize | 14 | CORRECT | CORRECT |
| SmallIntegerFontSize | 18 | CORRECT | CORRECT |
| SmallDecimalFontSize | 14 | CORRECT | CORRECT |
| DefaultStrikethroughFontSize | 15.18 | CORRECT | CORRECT |
| StandardStrikethroughFontSize | 14 | MISSING — **ADD** | MISSING — **ADD** |

### 4. Strikethrough Token Compliance

| Property | Token Value | Android | iOS |
|----------|-------------|---------|-----|
| Font family | Poppins (primary) | `PoppinsFontFamily` — CORRECT | `XGTypography.strikethroughFont()` — CORRECT |
| Font weight | Medium | `FontWeight.Medium` — CORRECT | via `Poppins-Medium` — CORRECT |
| Color | `priceStrikethrough` | `XGColors.PriceStrikethrough` — CORRECT | `XGColors.priceStrikethrough` — CORRECT |
| Decoration | line-through | `TextDecoration.LineThrough` — CORRECT | `.strikethrough()` — CORRECT |

### 5. Price Color Token Compliance

| Style | Token Color | Android | iOS |
|-------|-------------|---------|-----|
| default | `priceDiscount` | `XGColors.PriceSale` — CORRECT | `XGColors.priceSale` — CORRECT |
| standard | `priceDiscount` | `XGColors.PriceSale` — CORRECT | `XGColors.priceSale` — CORRECT |
| small | `priceDiscount` | `XGColors.PriceSale` — CORRECT | `XGColors.priceSale` — CORRECT |
| deal | `priceDeal` | `XGColors.BrandSecondary` — CORRECT | `XGColors.brandSecondary` — CORRECT |

## Files Affected

### Android
- `android/.../component/XGPriceText.kt` — UPDATE (rename param, nullable price, add constant)
- `android/.../component/XGPriceSize.kt` — DELETE (merged into XGPriceText.kt as XGPriceStyle)
- `android/.../component/XGPriceLayout.kt` — no change (already correct)
- `android/.../component/XGCard.kt` — UPDATE call sites
- `android/.../component/XGDailyDealCard.kt` — UPDATE call sites

### iOS
- `ios/.../Component/XGPriceText.swift` — UPDATE (nullable price, add constant)
- `ios/.../Component/XGProductCard.swift` — VERIFY call sites
- `ios/.../Component/XGDailyDealCard.swift` — VERIFY call sites

### Tests
- `android/app/src/androidTest/.../XGPriceTextTest.kt` — UPDATE
- `ios/XiriGoEcommerceTests/.../XGPriceTextTests.swift` — UPDATE

## Non-Goals

- No new components
- No new screens
- No API changes
- No navigation changes
- No new string resources needed (existing accessibility strings remain)
