# Architect Handoff: DQ-22 XGProductCard Upgrade

## Summary
Spec written at `shared/feature-specs/xg-product-card.md` for upgrading XGProductCard with:
1. `ProductCardSkeleton` composable/view using existing skeleton primitives
2. `reserveSpace` parameter for uniform card height in grids
3. Full token compliance from `xg-product-card.json`

## Key Decisions
- Both `ProductCardSkeleton` and `reserveSpace` logic go into the EXISTING card files (no new files)
- Android: `XGCard.kt`, iOS: `XGProductCard.swift`
- `reserveSpace` defaults to `false` for backward compatibility
- Skeleton uses `fillMaxWidth()` with fractional widths for responsive layout
- Reserved heights derived from design token values (star size, line height, button size)

## Files Created
- `shared/feature-specs/xg-product-card.md`
- `docs/pipeline/xg-product-card-architect.handoff.md`
