# iOS Dev Handoff — DQ-26 XGLoadingView

## Status: COMPLETE

## Changes Made

### `XGLoadingView.swift`
- **Removed** `ProgressView` completely from both components
- **Rewrote** `XGLoadingView` as generic `XGLoadingView<Skeleton, Content>` with crossfade
- **Added** convenience inits:
  - `init(isLoading:skeleton:content:)` — full crossfade with custom skeleton
  - `init(isLoading:content:)` — crossfade with default shimmer
  - `init()` — backward compatible loading-only (no content slot)
  - `init(skeleton:)` — custom skeleton, no content slot
- **Rewrote** `XGLoadingIndicator` as generic `XGLoadingIndicator<Skeleton, Content>`
- **Added** `DefaultFullScreenSkeleton` — shimmer box + lines
- **Added** `DefaultInlineSkeleton` — full-width shimmer line
- All transitions use `.easeInOut(duration: XGMotion.Crossfade.contentSwitch)`
- All colors from `XGColors.shimmer`, spacing from `XGSpacing`, corners from `XGCornerRadius`
- Accessibility: uses `skeleton_loading_placeholder` localized string
- 7 preview variants + interactive demo

## Backward Compatibility
- `XGLoadingView()` still works (shows default shimmer skeleton)
- `XGLoadingIndicator()` still works
- No changes needed to `HomeScreen.swift` or other call sites

## Token Usage
| Token | Usage |
|-------|-------|
| `XGMotion.Crossfade.contentSwitch` | Crossfade duration (0.2s) |
| `XGColors.shimmer` | Shimmer fill color |
| `XGCornerRadius.medium` | Box skeleton corners |
| `XGCornerRadius.small` | Line skeleton corners |
| `XGSpacing.base` | Container padding |
| `XGSpacing.sm` | Vertical spacing between skeleton items |
| `skeleton_loading_placeholder` | Accessibility label |
