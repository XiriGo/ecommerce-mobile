# XGErrorView — Crossfade Transition (DQ-27)

## Overview

`XGErrorView` is a design system molecule component that displays a full-screen error state with an error icon, message text, and an optional retry button. This upgrade adds a crossfade transition so that screens can smoothly animate from content to error state and back.

## Platforms

- **Android**: Kotlin + Jetpack Compose
- **iOS**: Swift + SwiftUI

## API

### Android

```kotlin
// Crossfade overload
@Composable
fun XGErrorView(
    message: String,
    isError: Boolean,
    modifier: Modifier = Modifier,
    onRetry: (() -> Unit)? = null,
    content: @Composable () -> Unit,
)

// Static overload (backward compatible)
@Composable
fun XGErrorView(
    message: String,
    modifier: Modifier = Modifier,
    onRetry: (() -> Unit)? = null,
)
```

### iOS

```swift
// Crossfade init
XGErrorView(
    message: String,
    isError: Bool,
    onRetry: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content,
)

// Static convenience (backward compatible)
XGErrorView(
    message: String,
    onRetry: (() -> Void)? = nil,
)
```

## Animation

| Property | Value | Token |
|----------|-------|-------|
| Type | Crossfade (opacity) | -- |
| Duration | 200ms | `XGMotion.Crossfade.CONTENT_SWITCH` / `contentSwitch` |
| Easing | EaseInOut | `XGMotion.Easing.standard` |
| Trigger | `isError` boolean | -- |

## Token Reference

| Token | Android | iOS |
|-------|---------|-----|
| Icon | `Icons.Outlined.ErrorOutline` | `exclamationmark.circle` |
| Icon size | `XGSpacing.XXL` | `XGSpacing.IconSize.extraLarge` |
| Icon color | `MaterialTheme.colorScheme.error` | `XGColors.error` |
| Message font | `MaterialTheme.typography.bodyLarge` | `XGTypography.bodyLarge` |
| Message color | `MaterialTheme.colorScheme.onSurface` | `XGColors.onSurface` |
| Spacing | `XGSpacing.Base` | `XGSpacing.base` |
| Retry button | `XGButton(style: Primary)` | `XGButton(variant: .outlined)` |

## Files

| File | Platform |
|------|----------|
| `android/.../core/designsystem/component/XGErrorView.kt` | Android |
| `ios/.../Core/DesignSystem/Component/XGErrorView.swift` | iOS |
| `android/.../XGErrorViewTest.kt` | Android Tests |
| `ios/.../XGErrorViewTests.swift` | iOS Tests |
| `shared/design-tokens/components/molecules/xg-error-view.json` | Token spec |

## Test Coverage

- **Android**: 13 instrumented Compose UI tests
- **iOS**: 15 Swift Testing tests

## Dependencies

- DQ-01: XGMotion Android (merged)
- DQ-02: XGMotion iOS (merged)

## GitHub Issue

Closes #71
