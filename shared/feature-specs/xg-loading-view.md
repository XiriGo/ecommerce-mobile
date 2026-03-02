# XGLoadingView — Skeleton-Aware Rewrite (DQ-26)

## Summary

Replace the centered spinner pattern in `XGLoadingView` and `XGLoadingIndicator` with a
skeleton-aware loading component that accepts an optional skeleton content slot. When a
slot is provided, the skeleton content is shown with shimmer animation. When no slot is
provided, the component falls back to a simple shimmer box. A crossfade transition
smoothly reveals real content when loading completes.

## Issue

- GitHub Issue: #70
- Feature ID: DQ-26
- Dependencies: DQ-03 (Shimmer Android), DQ-04 (Shimmer iOS) — already merged

## Current State

### Android (`XGLoadingView.kt`)
- `XGLoadingView`: Full-screen centered `CircularProgressIndicator`
- `XGLoadingIndicator`: Inline centered `CircularProgressIndicator` (24dp, 2dp stroke)

### iOS (`XGLoadingView.swift`)
- `XGLoadingView`: Full-screen centered `ProgressView` with "Loading" text
- `XGLoadingIndicator`: Inline centered `ProgressView`

## Target API

### Android

```kotlin
/**
 * Skeleton-aware full-screen loading view.
 *
 * @param isLoading When true, shows skeleton/shimmer. When false, shows content.
 * @param modifier Modifier for the container.
 * @param skeleton Optional skeleton placeholder slot. When null, shows default shimmer box.
 * @param content The real content to show when loading completes.
 */
@Composable
fun XGLoadingView(
    isLoading: Boolean,
    modifier: Modifier = Modifier,
    skeleton: (@Composable () -> Unit)? = null,
    content: @Composable () -> Unit,
)

/**
 * Skeleton-aware inline loading indicator.
 *
 * @param isLoading When true, shows skeleton/shimmer. When false, shows content.
 * @param modifier Modifier for the container.
 * @param skeleton Optional skeleton placeholder slot. When null, shows default shimmer line.
 * @param content The real content to show when loading completes.
 */
@Composable
fun XGLoadingIndicator(
    isLoading: Boolean,
    modifier: Modifier = Modifier,
    skeleton: (@Composable () -> Unit)? = null,
    content: @Composable () -> Unit,
)
```

### iOS

```swift
/// Skeleton-aware full-screen loading view.
struct XGLoadingView<Skeleton: View, Content: View>: View {
    let isLoading: Bool
    let skeleton: Skeleton?
    let content: Content

    init(
        isLoading: Bool,
        @ViewBuilder skeleton: () -> Skeleton,
        @ViewBuilder content: () -> Content
    )

    /// Convenience initializer with no skeleton (uses default shimmer).
    init(
        isLoading: Bool,
        @ViewBuilder content: () -> Content
    ) where Skeleton == EmptyView
}

/// Skeleton-aware inline loading indicator.
struct XGLoadingIndicator<Skeleton: View, Content: View>: View {
    let isLoading: Bool
    let skeleton: Skeleton?
    let content: Content

    // Same init patterns as XGLoadingView
}
```

## Behavior

### Loading State (`isLoading = true`)

1. **With skeleton slot**: Show the provided skeleton content. The slot should contain
   `SkeletonBox`, `SkeletonLine`, `SkeletonCircle` primitives (which already have shimmer applied).
2. **Without skeleton slot (default)**: Show a default shimmer placeholder:
   - `XGLoadingView`: Full-width shimmer box filling available space
   - `XGLoadingIndicator`: Full-width shimmer line

### Content State (`isLoading = false`)

Show the real content provided in the `content` slot.

### Transition

- **Android**: Use `AnimatedContent` with `fadeIn`/`fadeOut` using `XGMotion.Crossfade.CONTENT_SWITCH` (200ms)
- **iOS**: Use `.animation(.easeInOut(duration: XGMotion.Crossfade.contentSwitch), value: isLoading)` with `.transition(.opacity)`

### Accessibility

- When loading: announce "Loading content" (use `skeleton_loading_placeholder` string resource)
- When content shown: normal content accessibility applies
- Individual skeleton shapes remain decorative (hidden from accessibility tree)

## Design Tokens

| Token | Source | Value |
|-------|--------|-------|
| Crossfade duration | `XGMotion.Crossfade.CONTENT_SWITCH` | 200ms |
| Shimmer fill | `XGColors.Shimmer` | #E0E0E0 |
| Shimmer gradient | `XGMotion.Shimmer.GradientColors` | [#E0E0E0, #F5F5F5, #E0E0E0] |
| Default corner radius | `XGCornerRadius.Medium` | from spacing tokens |
| Loading text | `skeleton_loading_placeholder` | localized string |
| Container spacing | `XGSpacing.Base` | from spacing tokens |

## Constraints

- No `CircularProgressIndicator` (Android) or `ProgressView` (iOS) in the final implementation
- No hardcoded colors, dimensions, or strings
- All animations use design tokens from `XGMotion`
- Backward-compatible: existing call sites that just want a loading state can pass `isLoading = true` with empty content
- Must have `@Preview` (Android) / `#Preview` (iOS) showing:
  1. Loading with custom skeleton
  2. Loading with default shimmer
  3. Content shown after loading
  4. Interactive toggle demo

## Files Modified

### Android
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGLoadingView.kt`

### iOS
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGLoadingView.swift`

### Tests
- `android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGLoadingViewTest.kt`
- `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGLoadingViewTests.swift`
