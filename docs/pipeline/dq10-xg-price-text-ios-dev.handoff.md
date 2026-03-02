# DQ-10 XGPriceText — iOS Dev Handoff

## Status: COMPLETE

## Changes Made

### 1. Null Price Fallback
- `price` parameter changed from `String` to `String?`
- When `nil`, body renders nothing (implicit `EmptyView` via `if let` guard)
- Updated `priceParts` and `accessibilityDescription` to handle optional safely
- Added preview demonstrating nil price behavior

### 2. Added StandardStrikethroughFontSize
- Added `Constants.standardStrikethroughFontSize = 14` from token spec
- Existing `Constants.defaultStrikethroughFontSize = 15.18` unchanged

### 3. Token Compliance Verified
- All font size constants in `XGPriceStyle.Constants` match `xg-price-text.json`
- `XGPriceStyle` enum already existed with correct values (no rename needed)
- Colors use `XGColors` semantic tokens
- Strikethrough uses `XGTypography.strikethroughFont()` (Poppins Medium)
- Deal variant uses `XGColors.brandSecondary`

### 4. Call Sites Verified
- `XGProductCard.swift` — already passes `price: String`, no change needed (null handled by caller)
- `XGDailyDealCard.swift` — already uses `style: .deal`, no change needed

## Files Modified
- `ios/.../Component/XGPriceText.swift` — null price support, standardStrikethroughFontSize
