# Architect Handoff — DQ-26 XGLoadingView

## Status: COMPLETE

## Spec Location
`shared/feature-specs/xg-loading-view.md`

## Key Decisions

1. **API change**: Both `XGLoadingView` and `XGLoadingIndicator` now accept `isLoading: Boolean`,
   an optional `skeleton` slot, and a `content` slot. This is a breaking API change from the
   old parameterless versions.

2. **Default fallback**: When no skeleton slot is provided, the component shows a default shimmer
   placeholder (full-width box for XGLoadingView, full-width line for XGLoadingIndicator) instead
   of a centered spinner.

3. **Reuse existing primitives**: The implementation should reuse `SkeletonBox`, `SkeletonLine`,
   `shimmerEffect()` from the existing Skeleton and ShimmerModifier components (DQ-03/DQ-04/DQ-05/DQ-06).

4. **Crossfade transition**: Use `AnimatedContent` (Android) / `.animation` + `.transition(.opacity)` (iOS)
   with `XGMotion.Crossfade.CONTENT_SWITCH` duration (200ms).

5. **No spinner**: The `CircularProgressIndicator` (Android) and `ProgressView` (iOS) patterns
   are completely removed.

## Dependencies for Dev Agents
- Read `shared/feature-specs/xg-loading-view.md` for full API spec
- Read existing `Skeleton.kt` / `Skeleton.swift` for reusable primitives
- Read existing `ShimmerModifier.kt` / `ShimmerModifier.swift` for shimmer API
- Read `XGMotion.kt` / `XGMotion.swift` for animation tokens
