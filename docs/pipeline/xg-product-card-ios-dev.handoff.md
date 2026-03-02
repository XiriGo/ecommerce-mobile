# iOS Dev Handoff: DQ-22 XGProductCard Upgrade

## Summary
Upgraded `XGProductCard.swift` with:
1. `ProductCardSkeleton` view using `SkeletonBox` + `SkeletonLine` from `Skeleton.swift`
2. `reserveSpace: Bool` parameter on `XGProductCard` for uniform card height in grids
3. All existing behavior preserved when `reserveSpace = false` (default)

## Changes Made
- Added `reserveSpace` parameter to `XGProductCard` init (defaults to `false`)
- Updated `ratingSection`, `deliveryLabelSection`, `priceWithCartRow`, `standaloneCartSection` to support `reserveSpace`
- When `reserveSpace = true` and optional content is nil, `Color.clear.frame(height:)` reserves space
- Added `ProductCardSkeleton` view that mirrors card layout with skeleton primitives
- Skeleton uses `GeometryReader` for responsive percentage-based line widths
- Added 3 new previews: skeleton standalone, skeleton+real side-by-side, uniform height grid
- Added reserved height constants derived from design tokens

## Files Modified
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGProductCard.swift`

## Token Compliance
- Card padding: 8pt from Constants (xg-product-card.json)
- Corner radius: `XGCornerRadius.medium` (10pt)
- Border: 1pt `XGColors.outlineVariant`
- Rating height reserve: 16pt (star size 12 + gap)
- Delivery height reserve: 14pt (delivery line height token)
- Add-to-cart height reserve: 38pt (button size token)
