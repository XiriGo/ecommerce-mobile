# DQ-07 XGImage Shimmer Upgrade - Android Test Handoff

## Status: COMPLETE

## Task
Update and extend `XGImageTest.kt` to cover the DQ-07 changes to `XGImage.kt`:
- `SubcomposeAsyncImage` replaces `AsyncImage`
- Animated shimmer loading slot via `shimmerEffect()`
- Branded error fallback (SurfaceVariant background + outlined Image icon)
- Crossfade uses `XGMotion.Crossfade.IMAGE_FADE_IN` (300ms) instead of hardcoded 250ms
- Null URL renders shimmer placeholder Box

## Files Modified

| File | Change |
|------|--------|
| `android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGImageTest.kt` | Rewrote and expanded test suite for DQ-07 changes |

## Files Created

| File | Purpose |
|------|---------|
| `docs/pipeline/dq07-xgimage-android-test.handoff.md` | This handoff |

## Test Coverage Summary

### Test Regions

| Region | Tests | Description |
|--------|-------|-------------|
| Null URL (shimmer branch) | 4 | No-crash, no semantic node, testTag forwarding, PlaceholderIconSize rendering |
| Valid URL (SubcomposeAsyncImage branch) | 5 | No-crash, null contentDesc, testTag forwarding, broken URL, PreviewImageSize rendering |
| XGMotion.Crossfade token contract | 3 | IMAGE_FADE_IN == 300, greater than CONTENT_SWITCH, positive |
| XGColors token contract | 4 | Shimmer, SurfaceVariant, OnSurfaceVariant values; Shimmer != SurfaceVariant |
| Multiple instances | 2 | Two images (null + URL), two null images — no cross-composition interference |

**Total: 18 tests**

### Coverage Notes

- **Null URL state**: Verified that the shimmer Box renders without crash, the contentDescription semantic node is absent (the Box has no label), testTag is forwarded, and the component handles PlaceholderIconSize (27.dp) dimensions.
- **Valid URL state**: Verified that `SubcomposeAsyncImage` renders with the correct semantic label, handles null contentDescription, forwards testTag, and handles broken URLs without crash (error slot renders).
- **Motion token**: `XGMotion.Crossfade.IMAGE_FADE_IN == 300` asserted directly. The old hardcoded 250ms constant (`CROSSFADE_DURATION_MS`) was removed in DQ-07 — this test documents the new contract.
- **Color tokens**: `XGColors.Shimmer`, `XGColors.SurfaceVariant`, and `XGColors.OnSurfaceVariant` are asserted against their design-token hex values. The Shimmer ≠ SurfaceVariant assertion ensures the two states remain visually distinct.
- **Private constants**: `PlaceholderIconSize` (27.dp) and `PreviewImageSize` (200.dp) are `private val` inside `XGImage.kt` and cannot be referenced externally. They are verified indirectly — the component renders correctly when sized at those values.

## What Was Removed from the Old Test File

| Old Test | Reason Removed/Replaced |
|----------|--------------------------|
| `xgImage_withUrl_rendersAsyncImage` (old comment referenced `AsyncImage`) | Replaced: comment updated; `SubcomposeAsyncImage` semantics are the same |

All four original tests are preserved with updated comments. Fourteen new tests were added.

## Key Design Decisions

1. **testTag on modifier** — Used `Modifier.testTag(...)` chained after `Modifier.size(...)` on the `modifier` parameter. This verifies that `XGImage` correctly forwards the modifier to its root composable in both branches (null URL = Box, valid URL = SubcomposeAsyncImage).

2. **Token assertions in androidTest** — Color and motion token assertions (`assertThat(...).isEqualTo(...)`) live in the UI test class rather than a separate unit test, keeping all XGImage-related contracts in one file. The XGMotionTest and XGColorsTest already test these values in full; the assertions here document the *dependency* from XGImage's perspective.

3. **No mock of Coil/network** — Per testing standards, network layer is the only mock target. Coil's async loading is not mocked; tests verify composable presence (the `SubcomposeAsyncImage` root node) rather than the loaded image bitmap.

4. **Broken URL test** — Uses `https://invalid.test/broken-image` (matching the `XGImageErrorPreview` preview URL). The error slot renders the branded fallback but the `SubcomposeAsyncImage` root node retains the contentDescription, so `assertIsDisplayed()` still passes.

## Quality Checks

- [x] All tests are independent (no shared mutable state)
- [x] Test naming follows `camelCase_condition_expected` convention
- [x] No hardcoded hex values in tests — Truth assertions compare against XGColors constants where semantically correct; raw hex only used to verify the token value itself
- [x] No mocks of DI container or navigation
- [x] `@RunWith(AndroidJUnit4::class)` and `createComposeRule()` present
- [x] All tests wrapped in `XGTheme { ... }` for correct token resolution
- [x] No force unwrap (`!!`) in test code
- [x] KDoc at class level describing DQ-07 context

## Next Steps

- Doc Writer: document DQ-07 in `docs/features/design-system.md` (XGImage section)
- Reviewer: verify test coverage satisfies >= 80% line / >= 70% branch thresholds
