# XGLoadingView — Skeleton-Aware Loading Component

## Overview

`XGLoadingView` and `XGLoadingIndicator` are skeleton-aware loading components that replace the traditional centered spinner pattern with shimmer-based skeleton placeholders. They support an optional skeleton content slot for custom placeholders and crossfade transitions between loading and content states.

**Issue**: [DQ-26](https://github.com/XiriGo/ecommerce-mobile/issues/70)
**Phase**: 2C — Molecule Component Upgrades
**Dependencies**: DQ-03 (Shimmer Android), DQ-04 (Shimmer iOS)

## Components

### XGLoadingView

Full-screen skeleton-aware loading view. Two usage patterns:

1. **Loading-only** (backward compatible) — used in `when (uiState)` blocks where content is rendered by a different branch
2. **Crossfade** — wraps both skeleton and content, animates between them

### XGLoadingIndicator

Inline skeleton-aware loading indicator for list footers and sections. Same two usage patterns as `XGLoadingView`.

## API

### Android (Kotlin + Jetpack Compose)

```kotlin
// Loading-only (backward compatible)
XGLoadingView()
XGLoadingView(modifier = modifier)
XGLoadingView(skeleton = { SkeletonBox(width = 170.dp, height = 170.dp) })

// Crossfade
XGLoadingView(isLoading = isLoading) { Text("Content") }
XGLoadingView(
    isLoading = isLoading,
    skeleton = { SkeletonBox(width = 170.dp, height = 170.dp) },
) { Text("Content") }

// Inline
XGLoadingIndicator()
XGLoadingIndicator(isLoading = isLoading) { Text("More items") }
```

### iOS (Swift + SwiftUI)

```swift
// Loading-only (backward compatible)
XGLoadingView()
XGLoadingView { SkeletonBox(width: 170, height: 170) }

// Crossfade
XGLoadingView(isLoading: isLoading) { Text("Content") }
XGLoadingView(isLoading: isLoading) {
    SkeletonBox(width: 170, height: 170)
} content: {
    Text("Content")
}

// Inline
XGLoadingIndicator()
XGLoadingIndicator(isLoading: isLoading) { Text("More items") }
```

## Design Tokens

| Token | Android | iOS | Value |
|-------|---------|-----|-------|
| Crossfade duration | `XGMotion.Crossfade.CONTENT_SWITCH` | `XGMotion.Crossfade.contentSwitch` | 200ms |
| Shimmer fill | `XGColors.Shimmer` | `XGColors.shimmer` | Semantic shimmer color |
| Box corner radius | `XGCornerRadius.Medium` | `XGCornerRadius.medium` | Medium radius |
| Line corner radius | `XGCornerRadius.Small` | `XGCornerRadius.small` | Small radius |
| Container padding | `XGSpacing.Base` | `XGSpacing.base` | Base spacing |
| Item spacing | `XGSpacing.SM` | `XGSpacing.sm` | Small spacing |

## Accessibility

- Loading state announces "Loading content" via `skeleton_loading_placeholder` localized string
- Individual skeleton shapes are decorative (hidden from accessibility tree)
- Content state uses normal content accessibility

## Files

### Source
- Android: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGLoadingView.kt`
- iOS: `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGLoadingView.swift`

### Tests
- Android: `android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/XGLoadingViewTest.kt`
- iOS: `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/XGLoadingViewTests.swift`

### Design Tokens
- `shared/design-tokens/components/molecules/xg-loading-view.json`
- `shared/design-tokens/components/atoms/xg-skeleton.json`
- `shared/design-tokens/foundations/motion.json`

## Migration Guide

### Before (centered spinner)
```kotlin
// Android
XGLoadingView(modifier = modifier) // centered CircularProgressIndicator
```
```swift
// iOS
XGLoadingView() // centered ProgressView
```

### After (skeleton-aware)
```kotlin
// Android — drop-in replacement (same call site, now shows shimmer)
XGLoadingView(modifier = modifier)

// Android — with custom skeleton
XGLoadingView(
    modifier = modifier,
    skeleton = { ProductCardSkeleton() },
)

// Android — with crossfade
XGLoadingView(
    isLoading = uiState.isLoading,
    skeleton = { ProductCardSkeleton() },
) {
    ProductContent(uiState.data)
}
```
```swift
// iOS — drop-in replacement
XGLoadingView()

// iOS — with crossfade
XGLoadingView(isLoading: viewModel.isLoading) {
    ProductCardSkeleton()
} content: {
    ProductContent(data: viewModel.data)
}
```
