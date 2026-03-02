# XGRatingBar -- Design System Atom Component

## Overview

`XGRatingBar` is a star rating display component that shows a visual rating using filled,
half-filled, and empty star icons, with optional numeric value and review count text.

## Token Reference

Source: `shared/design-tokens/components/atoms/xg-rating-bar.json`

| Token | Value | Usage |
|-------|-------|-------|
| `starSize` | 12dp/pt | Size of each star icon |
| `starGap` | 2dp/pt | Spacing between individual stars |
| `starCount` | 5 | Default number of stars |
| `activeColor` | `XGColors.ratingStarFilled` (#6000FE) | Filled and half-filled star tint |
| `inactiveColor` | `XGColors.ratingStarEmpty` (#8E8E93) | Empty star tint |
| `reviewCountFontSize` | 12sp/pt | Font size for value and review count text |
| `reviewCountFont` | Caption (Poppins Regular 12) | Font for value and review count text |
| `reviewCountColor` | `XGColors.onSurfaceVariant` (#8E8E93) | Color for value and review count text |
| `reviewCountSpacing` | 4dp/pt | Spacing between star group and text elements |

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `rating` | Float/Double | required | Current rating value |
| `maxRating` | Int | 5 | Maximum number of stars |
| `starSize` | Dp/CGFloat | 12 | Size of each star icon |
| `showValue` | Boolean/Bool | false | Whether to display the numeric rating value |
| `reviewCount` | Int? | null/nil | Optional review count to display |

## Star Fill Logic

For each star position (1 to maxRating):
- **Full star**: `rating >= position`
- **Half star**: `rating >= position - 0.5`
- **Empty star**: otherwise

## Layout Structure

```
[Stars Row (starGap spacing)] [reviewCountSpacing] [Rating Value] [reviewCountSpacing] [Review Count]
```

- Stars are in their own group with `starGap` (2dp/pt) between them
- The outer container uses `reviewCountSpacing` (4dp/pt) between the star group, value text, and review count

## Accessibility

- **Android**: `semantics(mergeDescendants = true)` with `contentDescription` announcing
  "Rating: X.X out of Y" plus optional "(N reviews)". Individual star icons have no content description.
- **iOS**: `accessibilityElement(children: .ignore)` with `accessibilityLabel` announcing
  the same format. Individual star images are marked `accessibilityHidden(true)`.

## Platform Files

| Platform | Source | Tests |
|----------|--------|-------|
| Android | `android/.../core/designsystem/component/XGRatingBar.kt` | `android/.../component/XGRatingBarTest.kt` |
| iOS | `ios/.../Core/DesignSystem/Component/XGRatingBar.swift` | `ios/.../Component/XGRatingBarTests.swift` |

## Usage Examples

### Android (Kotlin)
```kotlin
XGRatingBar(rating = 4.5f, showValue = true, reviewCount = 123)
XGRatingBar(rating = 3.0f)
XGRatingBar(rating = 5.0f, starSize = 24.dp, showValue = true)
```

### iOS (Swift)
```swift
XGRatingBar(rating: 4.5, showValue: true, reviewCount: 123)
XGRatingBar(rating: 3.0)
XGRatingBar(rating: 5.0, starSize: 24, showValue: true)
```

## DQ-11 Audit Changes

- Android: Fixed layout structure (stars in inner Row with starGap, outer Row with reviewCountSpacing)
- Android: Added `mergeDescendants = true` for TalkBack accessibility
- Android: Removed redundant Spacers from value/review text composables
- iOS: Formatted rating to one decimal place in accessibility description
- Both: All token values verified against spec -- no color/size/spacing changes needed
