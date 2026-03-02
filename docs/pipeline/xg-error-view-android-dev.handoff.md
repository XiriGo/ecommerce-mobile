# Android Dev Handoff — XGErrorView Crossfade (DQ-27)

## Status: COMPLETE

## Changes Made

### `XGErrorView.kt`
1. Added crossfade overload: `XGErrorView(message, isError, modifier, onRetry, content)`
   - Uses `AnimatedContent` with `fadeIn(tween(CONTENT_SWITCH)) togetherWith fadeOut(tween(CONTENT_SWITCH))`
   - Label: `"xgErrorViewCrossfade"` for animation identification
2. Extracted `ErrorContent` private composable to share layout between both overloads
3. Preserved backward-compatible static overload: `XGErrorView(message, modifier, onRetry)`
4. Added previews: Crossfade Error, Crossfade Content, Interactive Toggle

## Token Usage
- `XGMotion.Crossfade.CONTENT_SWITCH` (200ms) for crossfade duration
- `XGSpacing.XXL` for icon size
- `MaterialTheme.colorScheme.error` for icon tint
- `MaterialTheme.typography.bodyLarge` for message font
- `MaterialTheme.colorScheme.onSurface` for message color
- `XGSpacing.Base` for spacing
- `XGButtonStyle.Primary` for retry button

## Pattern
Follows exact same `AnimatedContent` pattern as `XGLoadingView`.
