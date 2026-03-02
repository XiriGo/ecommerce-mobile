# XGEmptyView

## Overview

Full-screen empty state component with icon, message, and optional CTA action button.
Used across the app when a list or screen has no content to display (e.g., empty cart,
empty wishlist, no search results).

## Component API

### Android (Kotlin + Jetpack Compose)

```kotlin
@Composable
fun XGEmptyView(
    message: String,
    modifier: Modifier = Modifier,
    icon: ImageVector = Icons.Outlined.Inbox,
    actionLabel: String? = null,
    onAction: (() -> Unit)? = null,
)
```

### iOS (Swift + SwiftUI)

```swift
struct XGEmptyView: View {
    init(
        message: String,
        systemImage: String = "tray",
        actionLabel: String? = nil,
        onAction: (() -> Void)? = nil,
    )
}
```

## Design Tokens

Source: `shared/design-tokens/components/molecules/xg-empty-view.json`

| Token | Value | Android | iOS |
|-------|-------|---------|-----|
| Icon size | 48dp/pt | `XGSpacing.XXXL` | `XGSpacing.xxxl` |
| Icon color | #8E8E93 | `onSurfaceVariant` | `XGColors.onSurfaceVariant` |
| Default icon | inbox/tray | `Icons.Outlined.Inbox` | `"tray"` |
| Message font | 16pt Regular | `bodyLarge` | `XGTypography.bodyLarge` |
| Message color | #8E8E93 | `onSurfaceVariant` | `XGColors.onSurfaceVariant` |
| Spacing | 16dp/pt | `XGSpacing.Base` | `XGSpacing.base` |
| CTA button | outlined | `XGButtonStyle.Outlined` | `.outlined` |

## Behavior

1. Icon and message are always displayed, centered vertically and horizontally
2. CTA button appears only when both `actionLabel` and `onAction` are provided
3. Button uses the `outlined` variant from the design system

## Usage Example

### Android
```kotlin
XGEmptyView(
    message = "Your cart is empty",
    icon = Icons.Outlined.ShoppingCart,
    actionLabel = "Start Shopping",
    onAction = { navigateToHome() },
)
```

### iOS
```swift
XGEmptyView(
    message: "Your cart is empty",
    systemImage: "cart",
    actionLabel: "Start Shopping",
    onAction: { navigateToHome() },
)
```

## Files

- **Android**: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/XGEmptyView.kt`
- **iOS**: `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGEmptyView.swift`
- **Token spec**: `shared/design-tokens/components/molecules/xg-empty-view.json`
- **Feature spec**: `shared/feature-specs/xg-empty-view.md`
