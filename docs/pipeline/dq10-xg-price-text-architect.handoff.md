# DQ-10 XGPriceText — Architect Handoff

## Status: COMPLETE

## Summary

Designed platform-agnostic spec for the XGPriceText token + fallback audit (DQ-10).

## Key Decisions

1. **Null price fallback**: `price` parameter becomes `String?`. When null, component renders nothing.
2. **Rename XGPriceSize → XGPriceStyle** on Android for cross-platform consistency (iOS already correct).
3. **Add StandardStrikethroughFontSize** (14sp/pt) — missing on both platforms.
4. **All existing font size constants verified correct** against xg-price-text.json.
5. **All color tokens verified correct** — using XGColors semantic tokens, not hardcoded.
6. **Strikethrough styling verified correct** — Poppins Medium + priceStrikethrough color.

## Spec Location

`shared/feature-specs/xg-price-text.md`

## Next Steps

- Android Dev: Rename XGPriceSize → XGPriceStyle, add null price support, add StandardStrikethroughFontSize
- iOS Dev: Add null price support, add standardStrikethroughFontSize constant
