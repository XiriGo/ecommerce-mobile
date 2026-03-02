# Android Dev Handoff — DQ-24 XGDailyDealCard Upgrade

## Status: COMPLETE

## Changes Made
1. Added `ProductImageSize = 100.dp` token constant (from `productImage.size: 100`)
2. Changed product image from `weight(0.6f).aspectRatio(1f)` to fixed `size(ProductImageSize)` for token compliance
3. Changed countdown font from `PoppinsFontFamily` to `FontFamily.Monospace` (per token: "system monospaced 12pt")
4. Added `TextOverflow.Ellipsis` to title for proper truncation
5. Extracted `TITLE_MAX_LINES = 2` constant from token
6. Added accessibility `semantics { contentDescription }` with full deal info
7. Added KDoc with token source reference and parameter documentation
8. Added expired-state preview (`XGDailyDealCardExpiredPreview`)
9. Image shimmer inherited from XGImage (DQ-07) — no manual shimmer code needed

## Files Modified
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGDailyDealCard.kt`

## Token Mapping Audit
| Token | Value | Constant |
|-------|-------|----------|
| height | 163 | `CardHeight = 163.dp` |
| padding | 16 | `CardPadding = 16.dp` |
| cornerRadius | medium | `XGCornerRadius.Medium` |
| countdown.font | monospaced 12pt | `FontFamily.Monospace`, `CountdownFontSize = 12.sp` |
| productImage.size | 100 | `ProductImageSize = 100.dp` |
| title.maxLines | 2 | `TITLE_MAX_LINES = 2` |
| strikethrough.fontSize | 15.18 | `StrikethroughFontSize = 15.18.sp` |
