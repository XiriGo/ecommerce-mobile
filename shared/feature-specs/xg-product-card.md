# DQ-22: Upgrade XGProductCard -- Skeleton + Uniform Height

## Overview

Upgrade the existing `XGProductCard` component on both platforms to add:
1. A `ProductCardSkeleton` variant using skeleton primitives from DQ-05/DQ-06
2. Uniform height behavior via `reserveSpace` strategy for optional content rows
3. Full token compliance from `shared/design-tokens/components/molecules/xg-product-card.json`

This is a **refactor/upgrade** task -- the component already exists on both platforms. No new files
are created; existing files are modified in place.

### Existing Files

| Platform | Source File | Test File |
|----------|-----------|-----------|
| Android | `android/.../core/designsystem/component/XGCard.kt` | (new test file) |
| iOS | `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGProductCard.swift` | (new test file) |

### Dependencies (all complete)

- DQ-05: Skeleton Android (`Skeleton.kt` -- `SkeletonBox`, `SkeletonLine`, `SkeletonCircle`, `XGSkeleton`)
- DQ-06: Skeleton iOS (`Skeleton.swift` -- `SkeletonBox`, `SkeletonLine`, `SkeletonCircle`, `.skeleton(visible:)`)
- DQ-07: XGImage (both platforms)

---

## 1. ProductCardSkeleton

A composable/view that mimics the layout of `XGProductCard` using skeleton primitives. It matches
the card's visual structure so users see a realistic loading placeholder.

### Skeleton Layout (from issue requirements)

| Row | Skeleton Primitive | Width | Height |
|-----|-------------------|-------|--------|
| Image area | `SkeletonBox` | fill width | 1:1 aspect ratio |
| Title line 1 | `SkeletonLine` | 100% of content width | 14 (default) |
| Title line 2 | `SkeletonLine` | 80% of content width | 14 (default) |
| Price | `SkeletonLine` | 60% of content width | 14 (default) |
| Rating | `SkeletonLine` | 40% of content width | 12 |

### API

#### Android

```kotlin
@Composable
fun ProductCardSkeleton(
    modifier: Modifier = Modifier,
)
```

- Lives in `XGCard.kt` (same file as `XGProductCard`)
- Uses `SkeletonBox` for image area with `Modifier.fillMaxWidth().aspectRatio(1f)`
- Content area wrapped in `Column(Modifier.padding(CardPadding))` matching real card layout
- Uses `fillMaxWidth()` with `Modifier.fillMaxWidth(fraction)` for percentage widths

#### iOS

```swift
struct ProductCardSkeleton: View {
    var body: some View { ... }
}
```

- Lives in `XGProductCard.swift` (same file as `XGProductCard`)
- Uses `GeometryReader` or relative sizing for percentage widths
- Card border and corner radius match real card

### Visual Behavior

- Same outer card shape as `XGProductCard` (corner radius, border, background)
- Shimmer animation via existing `shimmerEffect()` on each skeleton primitive
- Accessibility: hidden from accessibility tree (individual shapes are decorative)
- Wrapper should announce "Loading content" when used with `XGSkeleton`/`.skeleton(visible:)`

---

## 2. Uniform Height (reserveSpace)

### Problem

Cards with optional content (rating, delivery label, original price strikethrough) have different
heights when displayed side-by-side in a grid. This creates uneven rows.

### Strategy: reserveSpace

From the design token `heightBehavior.strategy: "reserveSpace"`:

> Always reserve vertical space for ALL optional content rows even when the data is nil/null.
> Use invisible placeholders so every card occupies the same total height.

### Affected Optional Rows

| Row | Condition for Visibility | Reserve Strategy |
|-----|--------------------------|------------------|
| Strikethrough price | `originalPrice != null` | Always reserve line height for stacked layout |
| Rating bar | `rating != null` | Always reserve rating bar height |
| Delivery label | `deliveryLabel != null` | Always reserve delivery line height |
| Add to cart button | `onAddToCartClick != null` | Always reserve button height |

### Implementation

#### Android

Add a `reserveSpace: Boolean = false` parameter to `XGProductCard`. When `true`:
- Each optional section renders an invisible placeholder (same height) when data is absent
- Use `Spacer(Modifier.height(X.dp))` or `Box(Modifier.height(X.dp).alpha(0f))` for absent rows
- The card's total content height is deterministic regardless of data presence

```kotlin
@Composable
fun XGProductCard(
    // ... existing params ...
    reserveSpace: Boolean = false,  // NEW
)
```

#### iOS

Add a `reserveSpace: Bool = false` parameter to `XGProductCard`. When `true`:
- Each optional section renders a hidden placeholder when data is absent
- Use `.hidden()` on dummy views or `Color.clear.frame(height: X)` for absent rows

```swift
struct XGProductCard: View {
    // ... existing properties ...
    let reserveSpace: Bool  // NEW, default false in init
}
```

### Height Reservation Values

Calculated from design tokens and typography:

| Row | Height to Reserve | Source |
|-----|-------------------|--------|
| Rating bar | ~16dp/pt (star size 12 + spacing) | `spacing.json > starRating.starSize` |
| Delivery label | 14dp/pt (line height from token) | `xg-product-card.json > deliveryLabelSubComponent.lineHeight` |
| Strikethrough price | ~18dp/pt (strikethrough font + spacing) | Typography scale |
| Add to cart button | 38dp/pt (button diameter) | `xg-product-card.json > addToCartSubComponent.size` |

---

## 3. Token Compliance

All existing hardcoded values must map to design tokens:

| Property | Token Source | Value |
|----------|------------|-------|
| Card corner radius | `spacing.json > cornerRadius.medium` | 10 |
| Card padding | `xg-product-card.json > sharedTokens.padding` | 8 |
| Card border width | `xg-product-card.json > sharedTokens.borderWidth` | 1 |
| Card background | `xg-product-card.json > sharedTokens.background` | `XGColors.Surface` |
| Card border color | `xg-product-card.json > sharedTokens.borderColor` | `XGColors.OutlineVariant` |
| Image aspect ratio | `xg-product-card.json > sharedTokens.imageAspectRatio` | 1:1 |
| Title font | `xg-product-card.json > sharedTokens.titleFont` | captionSemiBold |
| Title font size | `xg-product-card.json > sharedTokens.titleFontSize` | 12 |
| Title max lines | `xg-product-card.json > sharedTokens.titleMaxLines` | 2 |
| Title color | `xg-product-card.json > sharedTokens.titleColor` | `XGColors.OnSurface` |
| Featured card width | `spacing.json > layout.productGrid.featuredCard.width` | 160 |
| Standard card width | `spacing.json > layout.productGrid.standardCard.width` | 170 |
| Add to cart size | `xg-product-card.json > addToCartSubComponent.size` | 38 |
| Add to cart corner radius | `xg-product-card.json > addToCartSubComponent.cornerRadius` | 19 |
| Add to cart icon size | `xg-product-card.json > addToCartSubComponent.iconSize` | 16 |
| Delivery font size | `xg-product-card.json > deliveryLabelSubComponent.fontSize` | 10 |
| Delivery line height | `xg-product-card.json > deliveryLabelSubComponent.lineHeight` | 14 |

---

## 4. Previews

Each platform must have a preview showing skeleton and real card side by side:

### Required Previews

1. **ProductCardSkeleton** -- standalone skeleton card
2. **Side-by-side** -- skeleton next to real card in a horizontal row
3. **Grid uniform height** -- 2x2 grid showing cards with different optional content but uniform height

---

## 5. File Manifest

### Android

| File | Action | Changes |
|------|--------|---------|
| `core/designsystem/component/XGCard.kt` | MODIFY | Add `ProductCardSkeleton`, add `reserveSpace` param to `XGProductCard`, add new previews |

### iOS

| File | Action | Changes |
|------|--------|---------|
| `Core/DesignSystem/Component/XGProductCard.swift` | MODIFY | Add `ProductCardSkeleton`, add `reserveSpace` param, add new previews |

### No New Files

This is a modification to existing files only. No new Kotlin or Swift files are created.

---

## 6. Verification Criteria

| # | Criterion | Platform |
|---|-----------|----------|
| 1 | `ProductCardSkeleton` renders with image box, 2 title lines, price line, rating line | Both |
| 2 | Skeleton has same outer shape as real card (corner radius, border) | Both |
| 3 | Skeleton primitives animate with shimmer | Both |
| 4 | `reserveSpace=true` produces uniform height for cards with different content | Both |
| 5 | Cards in a 2-column grid have equal height when `reserveSpace=true` | Both |
| 6 | All dimensions come from design tokens (no magic numbers) | Both |
| 7 | Preview shows skeleton + real card side by side | Both |
| 8 | No force unwrap (`!!`/`!`) in implementation | Both |
| 9 | Existing card behavior unchanged when `reserveSpace=false` (default) | Both |
| 10 | Accessibility: skeleton card hidden from accessibility tree | Both |

---

## 7. Platform-Specific Notes

### Android

- `ProductCardSkeleton` uses `fillMaxWidth()` for responsive skeleton widths
- Use `BoxWithConstraints` or `Modifier.fillMaxWidth(fraction)` for percentage-based line widths
- `reserveSpace` logic uses `Spacer(Modifier.height(X.dp))` for absent optional rows
- Constants for reserved heights should be private `val` at file level

### iOS

- `ProductCardSkeleton` uses `GeometryReader` for responsive skeleton line widths
- `reserveSpace` logic uses `Color.clear.frame(height: X)` or `.opacity(0)` for absent rows
- Follow existing MARK section pattern in the file
- `#Preview` blocks must NOT use `return` keyword
