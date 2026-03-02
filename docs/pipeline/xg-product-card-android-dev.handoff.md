# Android Dev Handoff: DQ-22 XGProductCard Upgrade

## Summary
Upgraded `XGCard.kt` with:
1. `ProductCardSkeleton` composable using `SkeletonBox` + `SkeletonLine` from `Skeleton.kt`
2. `reserveSpace: Boolean` parameter on `XGProductCard` for uniform card height in grids
3. All existing behavior preserved when `reserveSpace = false` (default)

## Changes Made
- Added `reserveSpace` parameter to `XGProductCard` (defaults to `false`)
- Updated `ProductCardDetailsSection`, `RatingSection`, `DeliverySection`, `PriceWithCartRow`, `StandaloneCartSection` to support `reserveSpace`
- When `reserveSpace = true` and optional content is null, invisible spacers reserve the same height
- Added `ProductCardSkeleton` composable that mirrors card layout with skeleton primitives
- Skeleton uses `fillMaxWidth(fraction)` for responsive percentage-based line widths
- Added 3 new previews: skeleton standalone, skeleton+real side-by-side, uniform height comparison
- Added reserved height constants derived from design tokens

## Files Modified
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGCard.kt`

## Token Compliance
- Card padding: 8dp from `CardPadding` constant (xg-product-card.json)
- Corner radius: `XGCornerRadius.Medium` (10dp)
- Border: 1dp `XGColors.OutlineVariant`
- Rating height reserve: 16dp (star size 12 + gap)
- Delivery height reserve: 14dp (delivery line height token)
- Add-to-cart height reserve: 38dp (button size token)
