# XGErrorView — Crossfade Transition Upgrade (DQ-27)

## Summary

Add a crossfade transition to `XGErrorView` so that when a screen transitions from
loading state to error state, the switch is animated using `XGMotion.Crossfade.contentSwitch`
(200ms). The component already renders an error icon, message, and optional retry button
from design tokens. This upgrade adds an `isError` boolean parameter and a content slot
so that callers can crossfade between loading/content and the error state.

## Issue

- GitHub Issue: #71
- Feature ID: DQ-27
- Dependencies: DQ-01 (XGMotion Android), DQ-02 (XGMotion iOS) — already merged

## Current State

### Android (`XGErrorView.kt`)
- Static full-screen error view with icon, message, and optional retry button
- No animation or transition support
- Uses `Icons.Outlined.ErrorOutline`, `MaterialTheme.colorScheme.error`, `XGSpacing`

### iOS (`XGErrorView.swift`)
- Static full-screen error view with icon, message, and optional retry button
- No animation or transition support
- Uses SF Symbol `exclamationmark.circle`, `XGColors.error`, `XGSpacing`

## Target API

### Android

```kotlin
/**
 * Full-screen error state with crossfade transition.
 *
 * When [isError] is true, crossfades to the error layout (icon + message + retry).
 * When false, shows [content]. Uses XGMotion.Crossfade.CONTENT_SWITCH (200ms).
 *
 * @param message Error message to display.
 * @param isError When true, shows error layout. When false, shows content.
 * @param modifier Modifier for the outer container.
 * @param onRetry Optional retry callback. When non-null, a retry button is shown.
 * @param content Content to show when isError is false.
 */
@Composable
fun XGErrorView(
    message: String,
    isError: Boolean,
    modifier: Modifier = Modifier,
    onRetry: (() -> Unit)? = null,
    content: @Composable () -> Unit,
)

/**
 * Static full-screen error state (backward compatible, no crossfade).
 *
 * @param message Error message to display.
 * @param modifier Modifier for the outer container.
 * @param onRetry Optional retry callback.
 */
@Composable
fun XGErrorView(
    message: String,
    modifier: Modifier = Modifier,
    onRetry: (() -> Unit)? = null,
)
```

### iOS

```swift
struct XGErrorView<Content: View>: View {
    /// Creates an error view with crossfade transition.
    ///
    /// - Parameters:
    ///   - message: Error message to display.
    ///   - isError: When true, shows error layout. When false, shows content.
    ///   - onRetry: Optional retry callback.
    ///   - content: Content to show when isError is false.
    init(
        message: String,
        isError: Bool,
        onRetry: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
    )
}

// Backward compatible convenience (no crossfade)
extension XGErrorView where Content == EmptyView {
    init(
        message: String,
        onRetry: (() -> Void)? = nil,
    )
}
```

## Animation Specification

| Property | Value | Token |
|----------|-------|-------|
| Transition type | Crossfade (fade out old + fade in new) | — |
| Duration | 200ms | `XGMotion.Crossfade.CONTENT_SWITCH` (Android) / `XGMotion.Crossfade.contentSwitch` (iOS) |
| Easing | EaseInOut | `XGMotion.Easing.standard` |
| Trigger | `isError` boolean change | — |

### Android Implementation

Use `AnimatedContent` with `fadeIn(tween(CONTENT_SWITCH)) togetherWith fadeOut(tween(CONTENT_SWITCH))`.
Follow the exact same pattern as `XGLoadingView`.

### iOS Implementation

Use `Group { if isError { ... } else { ... } }` with `.animation(.easeInOut(duration: contentSwitch), value: isError)`
and `.transition(.opacity)` on both branches. Follow the exact same pattern as `XGLoadingView`.

## Token Reference

From `shared/design-tokens/components/molecules/xg-error-view.json`:

| Token | Value |
|-------|-------|
| `iconSize` | `XGSpacing.XXL` (Android) / `XGSpacing.IconSize.extraLarge` (iOS) |
| `iconColor` | `MaterialTheme.colorScheme.error` (Android) / `XGColors.error` (iOS) |
| `icon` | `Icons.Outlined.ErrorOutline` (Android) / `exclamationmark.circle` (iOS) |
| `messageFont` | `MaterialTheme.typography.bodyLarge` (Android) / `XGTypography.bodyLarge` (iOS) |
| `messageColor` | `MaterialTheme.colorScheme.onSurface` (Android) / `XGColors.onSurface` (iOS) |
| `spacing` | `XGSpacing.Base` (Android) / `XGSpacing.base` (iOS) |
| `retryButton` | `XGButton` with `Primary` style (Android) / `outlined` variant (iOS) |

## Backward Compatibility

The existing static `XGErrorView(message:, onRetry:)` signature MUST be preserved.
Callers that do not need crossfade continue to work without changes.

## Test Plan

### Android (Compose UI Tests)
1. Static error view displays message
2. Static error view shows/hides retry button based on callback
3. Retry callback fires on click
4. Crossfade: when `isError=true`, error layout is visible
5. Crossfade: when `isError=false`, content is visible
6. AnimatedContent label exists (for animation identification)

### iOS (Swift Testing)
1. Static error view initialises with message only
2. Static error view initialises with message and retry
3. Crossfade view initialises with all parameters
4. Crossfade view initialises without retry handler
5. isError true shows error layout
6. isError false shows content
7. Retry counter logic works correctly

## Files Modified

### Android
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGErrorView.kt`
- `android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGErrorViewTest.kt`

### iOS
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGErrorView.swift`
- `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGErrorViewTests.swift`

### Shared
- `shared/feature-specs/xg-error-view.md` (this file)
- `docs/features/xg-error-view.md`
- `CHANGELOG.md`
