# DQ-10 XGPriceText — Android Dev Handoff

## Status: COMPLETE

## Changes Made

### 1. Renamed XGPriceSize to XGPriceStyle
- Deleted `XGPriceSize.kt` — enum moved into `XGPriceText.kt` as `XGPriceStyle`
- Values: `Default`, `Standard`, `Small`, `Deal`
- Renamed parameter `size` to `style` in `XGPriceText` composable
- Updated all call sites:
  - `XGCard.kt`: `priceSize` → `priceStyle`, `XGPriceSize` → `XGPriceStyle`
  - `XGDailyDealCard.kt`: `size = XGPriceSize.Deal` → `style = XGPriceStyle.Deal`
  - `HomeScreen.kt`: import + call sites updated

### 2. Null Price Fallback
- `price` parameter changed from `String` to `String?`
- When `null`, component returns early (renders nothing)
- Added preview demonstrating null price behavior

### 3. Added StandardStrikethroughFontSize
- Added `StandardStrikethroughFontSize = 14.sp` constant from token spec
- Existing `DefaultStrikethroughFontSize = 15.18.sp` unchanged

### 4. Token Compliance Verified
- All font size constants match `xg-price-text.json` exactly
- All colors use `XGColors` tokens (no hardcoded hex values)
- Strikethrough uses `PoppinsFontFamily`, `FontWeight.Medium`, `XGColors.PriceStrikethrough`
- Deal variant uses `XGColors.BrandSecondary`

## Files Modified
- `android/.../component/XGPriceText.kt` — main refactor
- `android/.../component/XGPriceSize.kt` — DELETED
- `android/.../component/XGCard.kt` — call site updates
- `android/.../component/XGDailyDealCard.kt` — call site update
- `android/.../screen/HomeScreen.kt` — import + call site updates
