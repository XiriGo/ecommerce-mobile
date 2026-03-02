# DQ-11 XGRatingBar -- Android Test Handoff

## Summary
Updated existing Android tests and added new test cases for the DQ-11 XGRatingBar refactor.

## Changes Made

### XGRatingBarTest.kt
1. **Added `useUnmergedTree = true`** to all `onNodeWithText` calls. Since `mergeDescendants = true`
   was added to the semantics block, text nodes within the merged subtree require `useUnmergedTree = true`
   to be found individually.
2. **Added test: `xgRatingBar_accessibilityDescription_withReviewCount`** -- verifies accessibility
   description includes rating when review count is also present.
3. **Added test: `xgRatingBar_customMaxRating_rendersWithoutCrash`** -- verifies custom maxRating
   (e.g. 10 stars) works correctly.

## Test Count
- Previous: 9 tests
- Current: 11 tests

## Test Coverage Areas
- Rating value display (show/hide)
- Review count display (with/without)
- Full, zero, and half ratings
- Accessibility content description (with and without review count)
- Both value and review count displayed together
- Custom max rating
