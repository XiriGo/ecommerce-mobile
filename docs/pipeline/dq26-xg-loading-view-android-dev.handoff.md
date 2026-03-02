# Android Dev Handoff — DQ-26 XGLoadingView

## Status: COMPLETE

## Changes Made

### `XGLoadingView.kt`
- **Removed** `CircularProgressIndicator` completely
- **Added** skeleton-aware `XGLoadingView(isLoading, modifier, skeleton, content)` overload with `AnimatedContent` crossfade
- **Kept** convenience `XGLoadingView(modifier, skeleton)` overload for existing call sites (backward compatible)
- **Added** skeleton-aware `XGLoadingIndicator(isLoading, modifier, skeleton, content)` overload
- **Kept** convenience `XGLoadingIndicator(modifier, skeleton)` overload
- **Added** `DefaultFullScreenSkeleton()` — shimmer box + lines fallback
- **Added** `DefaultInlineSkeleton()` — shimmer line fallback
- All transitions use `XGMotion.Crossfade.CONTENT_SWITCH` (200ms)
- All colors from `XGColors.Shimmer`, all spacing from `XGSpacing`, all corners from `XGCornerRadius`
- Accessibility: uses `skeleton_loading_placeholder` string resource
- 8 preview variants covering all states

## Backward Compatibility
- `XGLoadingView()` still works (shows default shimmer skeleton)
- `XGLoadingView(modifier = modifier)` still works
- `XGLoadingIndicator()` still works
- No changes needed to `HomeScreen.kt` or other call sites

## Token Usage
| Token | Usage |
|-------|-------|
| `XGMotion.Crossfade.CONTENT_SWITCH` | Crossfade duration (200ms) |
| `XGColors.Shimmer` | Shimmer fill color |
| `XGCornerRadius.Medium` | Box skeleton corners |
| `XGCornerRadius.Small` | Line skeleton corners |
| `XGSpacing.Base` | Container padding |
| `XGSpacing.SM` | Vertical spacing between skeleton items |
| `R.string.skeleton_loading_placeholder` | Accessibility label |
