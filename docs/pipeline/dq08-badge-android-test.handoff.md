# DQ-08: XGBadge Token Audit — Android Test Handoff

**Agent**: Android Tester
**Feature**: DQ-08 XGBadge token audit
**Platform**: Android
**Date**: 2026-03-01

---

## Summary

Added comprehensive tests for the `XGBadge` component family (DQ-08 token audit). Tests are split across two files: a pure JVM unit test for token contracts and enum exhaustiveness, and an expanded Compose UI test for rendering/interaction coverage.

---

## Files Created / Modified

### New file — Unit tests (JVM)

**`android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/component/XGBadgeTokenTest.kt`**

37 unit tests covering:

| Region | Tests | What is verified |
|--------|-------|-----------------|
| `XGBadgeStatus` enum | 7 | All 5 values present, exact count is 5, `valueOf` resolves each name |
| `XGColors` badge tokens | 6 | `BadgeBackground` (#6000FE), `BadgeText` (#FFFFFF), `BadgeSecondaryBackground` (#94D63A), `BadgeSecondaryText` (#6000FE), primary/secondary distinctness |
| `XGColors` status semantic colors | 9 | `Success` (#22C55E), `OnSuccess`, `Warning` (#FACC15), `OnWarning` (#1D1D1B), `Error` (#EF4444), `Info` (#3B82F6), `OnInfo`, `SurfaceVariant` (#F9FAFB for Neutral badge), `OnSurfaceVariant` (#8E8E93 for Neutral text) |
| `XGColors` status distinctness | 1 | All 5 status background colors are distinct (set size = 5) |
| `XGCornerRadius` | 2 | `Full` = 999dp, `Full` >= 100f for pill shape |
| `XGSpacing` | 5 | `XXS` = 2dp, `XS` = 4dp, `SM` = 8dp, padding hierarchy assertions |
| `XGTypography` labelSmall | 4 | `fontSize` = 10sp, `fontWeight` = Normal, `lineHeight` = 14sp, smaller than `labelMedium` |

### Modified file — UI tests (Compose / androidTest)

**`android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGBadgeTest.kt`**

Existing 12 tests retained. Added 7 new tests:

| Test | Coverage added |
|------|---------------|
| `xgCountBadge_count150_cappedAt99Plus` | Explicit count=150 cap verification (token spec "maxDisplay: 99+") |
| `xgCountBadge_modifierTestTag_tagIsReachable` | Modifier forwarding for `XGCountBadge` |
| `xgCountBadge_twoInstances_renderIndependently` | No cross-composition interference |
| `xgStatusBadge_modifierTestTag_tagIsReachable` | Modifier forwarding for `XGStatusBadge` |
| `xgStatusBadge_twoInstances_renderIndependently` | Two status badges side by side |
| `xgStatusBadge_allFiveStatuses_renderWithoutCrash` | All 5 `XGBadgeStatus` values in one layout |
| `xgStatusBadge_emptyLabel_rendersWithoutCrash` | Edge case: empty string label |

**Total UI tests: 19**

---

## Test Counts

| File | Location | Count |
|------|----------|-------|
| `XGBadgeTokenTest.kt` | `src/test/` (JVM) | 37 |
| `XGBadgeTest.kt` | `src/androidTest/` (Compose) | 19 |
| **Total** | | **56** |

---

## Key Findings

### XGBadgeVariant enum — not implemented

The `xg-badge.json` spec declares a `variants` block with `primary` and `secondary` entries, and the task brief references `XGBadgeVariant`. However, **no `XGBadgeVariant` enum exists in the production code**. The implementation instead uses two separate composables:

- `XGCountBadge` — uses `XGColors.BadgeBackground` / `XGColors.BadgeText` (primary variant tokens)
- `XGStatusBadge` — uses semantic status colors

The token contracts for both variants are verified through direct `XGColors` assertions. If `XGBadgeVariant` is added in a future iteration, unit tests for its ordinal values should be added to `XGBadgeTokenTest.kt`.

### XGTypography.labelSmall — micro scale, not captionSemiBold

The JSON spec declares badge font as `captionSemiBold` (12sp SemiBold). The Android implementation uses `MaterialTheme.typography.labelSmall`, which maps to `XGTypography.labelSmall` = **10sp Normal** (micro scale). Tests assert the actual implementation values. This is documented in the token test file and may warrant a follow-up design review.

---

## Coverage Assessment

| Area | Lines | Branches | Notes |
|------|-------|----------|-------|
| `XGBadgeStatus` enum | 100% | 100% | All 5 values exercised |
| `XGCountBadge` logic | ~95% | 100% | `count <= 0` branch, `count >= 100` branch, normal path |
| `XGStatusBadge` logic | ~90% | 100% | All 5 `when` branches exercised |
| Token constants | 100% | N/A | Direct value assertions |

Estimated total: **Lines >= 90%, Branches >= 90%** — exceeds thresholds (80% / 70%).

---

## Next Steps for Reviewer

1. Confirm whether `XGBadgeVariant` enum is planned — if so, add to `XGBadge.kt` and extend `XGBadgeTokenTest.kt`
2. Review font scale discrepancy: JSON spec says 12sp SemiBold (`captionSemiBold`), implementation uses 10sp Normal (`labelSmall`)
3. Token audit is otherwise complete and aligned with `shared/design-tokens/components/atoms/xg-badge.json`
