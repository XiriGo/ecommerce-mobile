# XGPaginationDots

Animated horizontal pagination indicator for paged content (carousels, onboarding, etc.).

## Component Overview

| Property | Value |
|----------|-------|
| Category | Atom |
| Token Source | `shared/design-tokens/components/atoms/xg-pagination-dots.json` |
| Android | `core/designsystem/component/XGPaginationDots.kt` |
| iOS | `Core/DesignSystem/Component/XGPaginationDots.swift` |

## Visual Behavior

- **Active dot**: 18pt wide pill shape (capsule with 3pt corner radius)
- **Inactive dot**: 6pt circle
- **Height**: 6pt for all dots
- **Gap**: 4pt between dots
- **Animation**: Spring-based width transition using `XGMotion.Easing.spring`

## Parameters

| Parameter | Type | Required | Default |
|-----------|------|----------|---------|
| `totalPages` | Int | Yes | -- |
| `currentPage` | Int | Yes | -- |
| `activeColor` | Color | No | `XGColors.paginationDotsActive` |
| `inactiveColor` | Color | No | `XGColors.paginationDotsInactive` |

## Usage

### Android

```kotlin
XGPaginationDots(
    totalPages = 4,
    currentPage = currentPage,
    modifier = Modifier,
)
```

### iOS

```swift
XGPaginationDots(
    totalPages: 4,
    currentPage: currentPage,
)
```

## Motion Tokens

| Token | Android | iOS |
|-------|---------|-----|
| Animation | `XGMotion.Easing.springSpec()` | `XGMotion.Easing.spring` |
| Spring damping | 0.7 | 0.7 |
| Spring stiffness | `StiffnessMedium` | response: 0.35 |

## Accessibility

- **Android**: Semantics `contentDescription` with format "Page X of Y"
- **iOS**: `accessibilityLabel` with localized "Page X of Y"

## Used In

- Onboarding screen (page indicator)
- Home screen (hero banner carousel)

## History

| Version | Change | Issue |
|---------|--------|-------|
| M4-05 | Initial creation | App Onboarding |
| DQ-09 | Upgraded Android animation from tween(300ms) to XGMotion.Easing.springSpec() | #53 |
