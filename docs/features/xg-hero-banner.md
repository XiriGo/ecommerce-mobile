# XGHeroBanner

Hero banner card with async image background, gradient overlay, tag badge, headline, and subtitle.
Used in the home screen carousel.

## Component Overview

| Property | Value |
|----------|-------|
| Category | Molecule |
| Token Source | `shared/design-tokens/components/molecules/xg-hero-banner.json` |
| Android | `core/designsystem/component/XGHeroBanner.kt` |
| iOS | `Core/DesignSystem/Component/XGHeroBanner.swift` |

## Visual Behavior

- **Height**: 192dp/pt (fixed)
- **Width**: Full width (`fillMaxWidth` / `maxWidth: .infinity`)
- **Corner radius**: `XGCornerRadius.medium` (10dp/pt)
- **Background**: Async image via `XGImage` (shimmer while loading) or branded fallback gradient
- **Overlay**: Linear gradient from left (brand primary 90% opacity) to right (transparent)
- **Tag badge**: `captionSemiBold` font, brand primary text on brand secondary background
- **Headline**: `headline` font, white text, max 2 lines
- **Subtitle**: `body` font, white text, max 1 line

## Parameters

| Parameter | Type | Required | Default |
|-----------|------|----------|---------|
| `title` | String | Yes | -- |
| `subtitle` | String | Yes | -- |
| `imageUrl` | String/URL | No | `null`/`nil` |
| `tag` | String | No | `null`/`nil` |
| `onClick`/`action` | Callback | No | `null`/`nil` |

## HeroBannerSkeleton

Shimmer loading placeholder that mirrors the banner layout.

- Full-width `SkeletonBox` at 192dp/pt with medium corner radius
- `SkeletonLine` at top-start for tag badge placeholder (80dp/pt)
- `SkeletonLine` at bottom-start for headline placeholder (160dp/pt)
- `SkeletonLine` at bottom-start for subtitle placeholder (120dp/pt)

### Usage

**Android:**
```kotlin
XGSkeleton(
    visible = isLoading,
    placeholder = { HeroBannerSkeleton() },
) {
    XGHeroBanner(title = "...", subtitle = "...")
}
```

**iOS:**
```swift
Text("Real content")
    .skeleton(visible: isLoading) {
        HeroBannerSkeleton()
    }
```

## Auto-Scroll Token

The hero banner carousel auto-scroll interval is centralized in motion tokens:

- **Token**: `XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS` (Android) / `XGMotion.Scroll.autoScrollInterval` (iOS)
- **Value**: 5000ms / 5.0s
- **Source**: `shared/design-tokens/foundations/motion.json` -> `scroll.autoScrollIntervalMs`

## DQ-23 Changes (Upgrade Summary)

1. Added `HeroBannerSkeleton` on both Android and iOS
2. Added `autoScrollInterval` token to `XGMotion.Scroll` on both platforms
3. Replaced hardcoded auto-scroll constants in HomeScreen with motion tokens
4. Updated `xg-hero-banner.json` token file with skeleton and autoScroll references
5. Updated `motion.json` with `autoScrollIntervalMs` in scroll section
6. Verified gradient overlay uses design tokens (no changes needed)
7. Verified image shimmer works via `XGImage` (DQ-07, no changes needed)

## Tests

### Android
- `HeroBannerSkeletonTest.kt` -- rendering, modifier forwarding, XGSkeleton integration
- `XGMotionTest.kt` -- AUTO_SCROLL_INTERVAL_MS token contract tests

### iOS
- `HeroBannerSkeletonTests.swift` -- instantiation, token contract verification
- `XGMotionTests.swift` -- autoScrollInterval token tests

## Accessibility

- `HeroBannerSkeleton`: hidden from accessibility tree (decorative)
- When used with `XGSkeleton`: "Loading content" accessibility label
- `XGHeroBanner`: full accessibility description combining tag, title, subtitle

## File Manifest

| File | Platform |
|------|----------|
| `android/.../component/XGHeroBanner.kt` | Android |
| `android/.../theme/XGMotion.kt` | Android |
| `android/.../screen/HomeScreen.kt` | Android |
| `ios/.../Component/XGHeroBanner.swift` | iOS |
| `ios/.../Theme/XGMotion.swift` | iOS |
| `ios/.../Screen/HomeScreenSections.swift` | iOS |
| `shared/design-tokens/foundations/motion.json` | Shared |
| `shared/design-tokens/components/molecules/xg-hero-banner.json` | Shared |
