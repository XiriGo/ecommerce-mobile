# DQ-11 XGRatingBar -- Architect Handoff

## Summary
Audited XGRatingBar against `shared/design-tokens/components/atoms/xg-rating-bar.json`.
Token values (sizes, colors, fonts) are all correct on both platforms. Found one layout
bug on Android (star gap applied to all children instead of just stars) and minor
accessibility improvements needed on both platforms.

## Spec Location
`shared/feature-specs/xg-rating-bar.md`

## Changes Required

### Android
1. Fix layout: nest stars in inner Row with starGap, outer Row uses reviewCountSpacing
2. Remove redundant Spacers from RatingValueText and ReviewCountText
3. Add `mergeDescendants = true` to semantics block

### iOS
1. Format rating to one decimal in accessibility description
2. No layout changes needed (structure is already correct)

### Token File
No changes needed.

## Risks
- LOW: Layout change on Android is internal restructuring, visual output unchanged
- LOW: Accessibility change is additive

## Dependencies
- DQ-01 (XGMotion Android) -- MERGED
- DQ-02 (XGMotion iOS) -- MERGED
