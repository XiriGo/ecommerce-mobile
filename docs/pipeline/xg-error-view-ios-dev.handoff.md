# iOS Dev Handoff — XGErrorView Crossfade (DQ-27)

## Status: COMPLETE

## Changes Made

### `XGErrorView.swift`
1. Converted to generic `XGErrorView<Content: View>` with `isError: Bool` and `@ViewBuilder content`
2. Added `.animation(.easeInOut(duration: XGMotion.Crossfade.contentSwitch), value: isError)` + `.transition(.opacity)`
3. Extracted `ErrorContent` private struct to share layout between crossfade and static modes
4. Added convenience extension `where Content == EmptyView` for backward compatibility
5. Added previews: Crossfade Error, Crossfade Content, Interactive Toggle (via `XGErrorViewInteractiveDemo`)
6. No `return` statements in `#Preview` closures (ViewBuilder compliance)

## Token Usage
- `XGMotion.Crossfade.contentSwitch` (0.2s) for crossfade duration
- `XGSpacing.IconSize.extraLarge` for icon size
- `XGColors.error` for icon color
- `XGTypography.bodyLarge` for message font
- `XGColors.onSurface` for message color
- `XGSpacing.base` for spacing
- `XGButton` with `.outlined` variant for retry button

## Pattern
Follows exact same `Group { if/else }` + `.animation` pattern as `XGLoadingView`.
