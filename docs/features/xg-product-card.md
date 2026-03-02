# XGProductCard Component

## Overview

`XGProductCard` is a molecule-level design system component that renders product cards in grid and scroll layouts. It composes several atom components (`XGImage`, `XGWishlistButton`, `XGRatingBar`, `XGPriceText`, delivery label) into a unified card.

## Variants

| Variant | Layout | Width | Key Features |
|---------|--------|-------|-------------|
| `productFeatured` | Horizontal scroll | 160dp/pt | Image, title, rating, price |
| `productStandard` | 2-column grid | Flexible | Image, title, rating, delivery, price + cart |

## DQ-22 Upgrade

### ProductCardSkeleton

A loading placeholder that mirrors the card layout using skeleton primitives.

| Row | Primitive | Width |
|-----|-----------|-------|
| Image | SkeletonBox | 1:1 aspect, fill width |
| Title 1 | SkeletonLine | 100% |
| Title 2 | SkeletonLine | 80% |
| Price | SkeletonLine | 60% |
| Rating | SkeletonLine | 40% |

### Uniform Height (reserveSpace)

`reserveSpace: Boolean/Bool` parameter ensures cards have equal height regardless of content.

When `reserveSpace = true` and optional data is absent, invisible spacers reserve the height of:
- Rating bar: 16dp/pt
- Delivery label: 14dp/pt
- Add-to-cart button: 38dp/pt

### Token Source

`shared/design-tokens/components/molecules/xg-product-card.json`

## Files

| Platform | Source | Tests |
|----------|--------|-------|
| Android | `core/designsystem/component/XGCard.kt` | `XGProductCardTokenTest.kt` |
| iOS | `Core/DesignSystem/Component/XGProductCard.swift` | `XGProductCardTests.swift` |
| iOS | `Core/DesignSystem/Component/ProductCardSkeleton.swift` | (included above) |

## Dependencies

- DQ-05: Skeleton Android
- DQ-06: Skeleton iOS
- DQ-07: XGImage
