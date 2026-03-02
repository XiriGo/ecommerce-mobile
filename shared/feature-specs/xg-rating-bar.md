# DQ-11: XGRatingBar Token Audit -- Feature Specification

## 1. Overview

This specification describes the audit and upgrade of the `XGRatingBar` atom component
to ensure all visual properties (star size, spacing, colors) come from centralized design
tokens, and to improve accessibility on both platforms.

### Purpose

- Verify star size, star gap, and review count spacing match token spec values
- Ensure filled/empty star colors use `XGColors.ratingStarFilled` / `XGColors.ratingStarEmpty`
- Verify review count text uses `XGTypography.caption` and `XGColors.onSurfaceVariant`
- Improve accessibility: announce "X out of Y stars" properly on both platforms
- Ensure token file references use `$foundations/` token references (not hardcoded values)

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Android: Audit token usage in XGRatingBar.kt | New star animation features |
| iOS: Audit token usage in XGRatingBar.swift | Interactive star selection |
| Update xg-rating-bar.json token references | Color changes (tokens are correct) |
| Improve accessibility descriptions | New component features |
| Ensure cross-platform consistency | Layout restructuring |

### Dependencies

- **DQ-01** (XGMotion Android) -- MERGED
- **DQ-02** (XGMotion iOS) -- MERGED

---

## 2. Current State Analysis

### 2.1 Token Specification (`xg-rating-bar.json`)

```json
{
  "tokens": {
    "starSize": 12,
    "starGap": 2,
    "starCount": 5,
    "activeColor": "$foundations/colors.semantic.ratingStarActive",
    "inactiveColor": "$foundations/colors.semantic.ratingStarInactive",
    "reviewCountFontSize": 12,
    "reviewCountFont": "$foundations/typography.typeScale.caption",
    "reviewCountColor": "$foundations/colors.light.textSecondary",
    "reviewCountSpacing": 4
  }
}
```

### 2.2 Android (`XGRatingBar.kt`) -- Current Status

| Token | Expected | Actual | Status |
|-------|----------|--------|--------|
| starSize | 12.dp | 12.dp (private val StarSize) | CORRECT |
| starGap | 2.dp | 2.dp (private val StarGap) | CORRECT |
| starCount | 5 | 5 (private const STAR_COUNT) | CORRECT |
| activeColor | XGColors.RatingStarFilled | XGColors.RatingStarFilled | CORRECT |
| inactiveColor | XGColors.RatingStarEmpty | XGColors.RatingStarEmpty | CORRECT |
| reviewCountFont | PoppinsFontFamily, 12sp | PoppinsFontFamily, 12sp | CORRECT |
| reviewCountColor | XGColors.OnSurfaceVariant | XGColors.OnSurfaceVariant | CORRECT |
| reviewCountSpacing | 4.dp | 4.dp (ReviewCountSpacing) | CORRECT |
| Accessibility | Content description | Uses stringResource | NEEDS IMPROVEMENT |

**Issues found**:
1. The outer `Row` uses `Arrangement.spacedBy(StarGap)` which applies the 2dp gap to ALL children including text elements. The star gap should only apply between stars, not between the stars row and the value/review text. This is a layout bug.
2. No `mergeDescendants` semantics -- individual icons may be traversed separately by TalkBack.

### 2.3 iOS (`XGRatingBar.swift`) -- Current Status

| Token | Expected | Actual | Status |
|-------|----------|--------|--------|
| starSize | 12 | 12 (Constants.starSize) | CORRECT |
| starGap | 2 | 2 (Constants.starGap) | CORRECT |
| starCount | 5 | 5 (Constants.starCount) | CORRECT |
| activeColor | XGColors.ratingStarFilled | XGColors.ratingStarFilled | CORRECT |
| inactiveColor | XGColors.ratingStarEmpty | XGColors.ratingStarEmpty | CORRECT |
| reviewCountFont | XGTypography.caption | XGTypography.caption | CORRECT |
| reviewCountColor | XGColors.onSurfaceVariant | XGColors.onSurfaceVariant | CORRECT |
| reviewCountSpacing | 4 | Constants.reviewCountSpacing=4 | CORRECT |
| Accessibility | accessibilityLabel | Uses String(localized:) | NEEDS IMPROVEMENT |

**Issues found**:
1. The outer `HStack` uses `spacing: Constants.reviewCountSpacing` (4pt) for all children. Stars have their own inner `HStack` with `starGap` (2pt). This is structurally correct for the outer spacing but the outer spacing between the stars group and text should be `reviewCountSpacing` (4pt).
2. Accessibility: currently uses plain string interpolation `\(rating) \(maxRating)` -- should use formatted number to avoid precision issues (e.g. "4.5 out of 5 stars").

---

## 3. Required Changes

### 3.1 Android (`XGRatingBar.kt`)

1. **Fix layout structure**: Move the `for` loop generating stars into a nested `Row` with `spacedBy(StarGap)`, and use the outer `Row` with `spacedBy(ReviewCountSpacing)` for spacing between star group, value text, and review count.
2. **Add mergeDescendants**: The outer Row already has `semantics { contentDescription = ... }` but should also use `mergeDescendants = true` to prevent TalkBack from traversing individual icons.
3. **Remove redundant Spacers**: The `RatingValueText` and `ReviewCountText` composables add their own `Spacer(width = ReviewCountSpacing)` which doubles the spacing when used with `Arrangement.spacedBy`. Remove the spacers since the outer Row will handle spacing.

### 3.2 iOS (`XGRatingBar.swift`)

1. **Layout is structurally correct**: The stars are already in their own inner `HStack` with `starGap`, and the outer `HStack` uses `reviewCountSpacing`. No layout changes needed.
2. **Accessibility improvement**: Format the rating value to one decimal place in the accessibility description to avoid floating-point display issues.

### 3.3 Token File Update (`xg-rating-bar.json`)

No changes needed -- the token file already has proper `$foundations/` references.

---

## 4. Cross-Platform Consistency

Both platforms should produce identical visual output and accessibility behavior:

- 5 stars at 12pt/dp size with 2pt/dp gap between stars
- 4pt/dp gap between star group and optional value/review text
- Review text in caption font, onSurfaceVariant color
- Accessibility: "Rating: X.X out of Y" plus optional "(N reviews)"

---

## 5. Test Strategy

### Android Tests (existing XGRatingBarTest.kt)
- All 9 existing tests should continue to pass
- No new tests needed -- the refactor is internal layout restructuring

### iOS Tests (existing XGRatingBarTests.swift)
- All existing tests should continue to pass
- Star fill logic tests are purely algorithmic and unaffected
