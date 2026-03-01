# DQ-01/02: Motion Tokens (XGMotion)

## Overview

`XGMotion` is the centralized animation and motion token namespace for the XiriGo design system. It lives in the theme layer alongside `XGColors`, `XGTypography`, and `XGSpacing`, exposing every motion-related constant — durations, easing curves, shimmer parameters, crossfade timings, scroll configuration, entrance animation parameters, and performance budgets — as named constants on both Android and iOS.

**Status**: Complete
**Phase**: M0 (Foundation) — DQ backfill
**Issues**: DQ-01 (Android), DQ-02 (iOS)
**Platforms**: Android (Kotlin + Jetpack Compose) + iOS (Swift + SwiftUI)
**Token source**: `shared/design-tokens/foundations/motion.json`

### Purpose

- Eliminate hardcoded animation durations, easing curves, and shimmer parameters across the codebase.
- Guarantee cross-platform motion consistency (same values, same intent).
- Provide a single update point when motion values are tuned via Figma or performance testing.
- Document performance budgets for profiling comparisons.

### What This Is Not

`XGMotion` is a pure constant definition. It has no repository, use case, ViewModel, or network dependency. It produces no user-visible screens. Components and feature screens consume its values — it does not consume other design system types.

---

## Architecture

### Layer Position

```
core/designsystem/theme/
  XGColors.kt / XGColors.swift
  XGTypography.kt / XGTypography.swift
  XGSpacing.kt / XGSpacing.swift
  XGMotion.kt / XGMotion.swift          <-- this feature
```

### File Locations

| Platform | File |
|----------|------|
| Android | `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGMotion.kt` |
| iOS | `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGMotion.swift` |
| Token source | `shared/design-tokens/foundations/motion.json` |

### Declaration Style

| Aspect | Android | iOS |
|--------|---------|-----|
| Top-level | `object XGMotion` | `enum XGMotion` (caseless, prevents instantiation) |
| Sub-namespaces | Nested `object` | Nested caseless `enum` |
| Constants | `const val` for primitives | `static let` |
| Non-primitive values | `val` (`List<Color>`, `Dp`) | `static let` |

---

## Token Reference

### Duration

All timing constants for animations and transitions.

| Android Constant | iOS Constant | Value | Usage |
|-----------------|-------------|-------|-------|
| `Duration.INSTANT` | `Duration.instant` | 100ms / 0.1s | Toggle, checkbox, ripple, micro-interactions |
| `Duration.FAST` | `Duration.fast` | 200ms / 0.2s | Button press feedback, icon rotation, chip toggle |
| `Duration.NORMAL` | `Duration.normal` | 300ms / 0.3s | Default animation duration, content crossfade |
| `Duration.SLOW` | `Duration.slow` | 450ms / 0.45s | Modal entrance/exit, bottom sheet slide |
| `Duration.PAGE_TRANSITION` | `Duration.pageTransition` | 350ms / 0.35s | Screen-to-screen navigation transitions |

**Unit note**: Android stores values as `Int` milliseconds. iOS stores values as `TimeInterval` (seconds).

### Easing

Curves and spring specifications for natural-feeling animations.

| Name | Android | iOS | Usage |
|------|---------|-----|-------|
| standard | `Easing.standardTween<T>(durationMillis)` → `TweenSpec<T>` with `FastOutSlowInEasing` | `Easing.standard: Animation = .easeInOut` | General-purpose symmetric animation |
| decelerate | `Easing.decelerateTween<T>(durationMillis)` → `TweenSpec<T>` with `LinearOutSlowInEasing` | `Easing.decelerate: Animation = .easeOut` | Elements entering view |
| accelerate | `Easing.accelerateTween<T>(durationMillis)` → `TweenSpec<T>` with `FastOutLinearInEasing` | `Easing.accelerate: Animation = .easeIn` | Elements leaving view |
| spring | `Easing.springSpec<T>()` → `SpringSpec<T>` (dampingRatio=0.7, StiffnessMedium) | `Easing.spring: Animation = .spring(response: 0.35, dampingFraction: 0.7)` | Bounce — bottom sheet, pull-to-refresh |

**API difference**: Android exposes generic factory functions returning `AnimationSpec<T>` (easing + duration bundled). iOS exposes `Animation` values where duration is composed separately via `.animation(XGMotion.Easing.standard)` or `withAnimation(XGMotion.Easing.standard) { }`.

### Shimmer

Parameters for loading placeholder animations. See also: [shimmer-modifier.md](./shimmer-modifier.md) for the modifier that consumes these tokens.

| Android Constant | iOS Constant | Value | Notes |
|-----------------|-------------|-------|-------|
| `Shimmer.DURATION_MS` | `Shimmer.duration` | 1200ms / 1.2s | Full sweep cycle |
| `Shimmer.ANGLE_DEGREES` | `Shimmer.angleDegrees` | 20 | Gradient sweep angle in degrees |
| `Shimmer.GradientColors` | `Shimmer.gradientColors` | `[#E0E0E0, #F5F5F5, #E0E0E0]` | Three-stop `List<Color>` / `[Color]` |
| `Shimmer.REPEAT_MODE_RESTART` | _(implicit)_ | `true` / `autoreverses: false` | Restart repeat, no reverse |

**Rule**: All loading placeholders MUST use animated shimmer, never a static color.

### Crossfade

| Android Constant | iOS Constant | Value | Usage |
|-----------------|-------------|-------|-------|
| `Crossfade.IMAGE_FADE_IN` | `Crossfade.imageFadeIn` | 300ms / 0.3s | Image loading completion fade-in |
| `Crossfade.CONTENT_SWITCH` | `Crossfade.contentSwitch` | 200ms / 0.2s | State transition (loading → loaded) |

### Scroll

| Android Constant | iOS Constant | Value | Usage |
|-----------------|-------------|-------|-------|
| `Scroll.PREFETCH_DISTANCE` | `Scroll.prefetchDistance` | 5 | Items to prefetch beyond visible area |
| `Scroll.SCROLL_RESTORATION_ENABLED` | `Scroll.scrollRestorationEnabled` | `true` | Restore position on back-navigation |

**Rule**: All lists with more than 4 items MUST use lazy rendering (`LazyColumn`/`LazyRow`/`LazyVerticalGrid` on Android; `LazyVStack`/`LazyHStack`/`LazyVGrid` on iOS).

### EntranceAnimation

Parameters for staggered list-item reveal on first screen load only.

| Android Constant | iOS Constant | Value | Notes |
|-----------------|-------------|-------|-------|
| `EntranceAnimation.STAGGER_DELAY_MS` | `EntranceAnimation.staggerDelay` | 50ms / 0.05s | Delay between consecutive item animations |
| `EntranceAnimation.MAX_STAGGER_ITEMS` | `EntranceAnimation.maxStaggerItems` | 8 | Cap on animated items |
| `EntranceAnimation.FADE_FROM` | `EntranceAnimation.fadeFrom` | 0f / 0.0 | Initial opacity |
| `EntranceAnimation.FADE_TO` | `EntranceAnimation.fadeTo` | 1f / 1.0 | Final opacity |
| `EntranceAnimation.SlideOffsetY` | `EntranceAnimation.slideOffsetY` | 20.dp / 20pt | Vertical slide distance |

**Rule**: Apply entrance animation on first screen load only. Items loaded via pagination or infinite scroll must NOT stagger-animate in.

### Performance

Reference thresholds for profiling — not enforced at runtime.

| Android Constant | iOS Constant | Value | Target |
|-----------------|-------------|-------|--------|
| `Performance.FRAME_TIME_MS` | `Performance.frameTime` | 16ms / 0.016s | Max frame render time (60 FPS) |
| `Performance.STARTUP_COLD_MS` | `Performance.startupCold` | 2000ms / 2.0s | Cold start budget |
| `Performance.SCREEN_TRANSITION_MS` | `Performance.screenTransition` | 300ms / 0.3s | Screen transition budget |
| `Performance.LIST_SCROLL_FPS` | `Performance.listScrollFps` | 60 | Target scroll frame rate |
| `Performance.FIRST_CONTENTFUL_PAINT_MS` | `Performance.firstContentfulPaint` | 1000ms / 1.0s | Time to first meaningful content |

**Profiling tools**: Android Studio Profiler (Android), Xcode Instruments (iOS). Target: zero jank frames during scroll.

---

## Usage Guide

### Selecting a Duration

| Scenario | Token |
|----------|-------|
| Toggle, checkbox, small icon change | `Duration.INSTANT` / `Duration.instant` |
| Button feedback, chip selection | `Duration.FAST` / `Duration.fast` |
| Most animations, content crossfade | `Duration.NORMAL` / `Duration.normal` |
| Modal entrance/exit, bottom sheet | `Duration.SLOW` / `Duration.slow` |
| Screen navigation | `Duration.PAGE_TRANSITION` / `Duration.pageTransition` |

### Selecting an Easing

| Scenario | Token |
|----------|-------|
| General-purpose animation | `Easing.standard` |
| Element entering view | `Easing.decelerate` |
| Element leaving view | `Easing.accelerate` |
| Spring / bounce | `Easing.spring` |

### Android Usage Example

```kotlin
// Duration + easing tween
animate(
    animationSpec = XGMotion.Easing.standardTween<Float>(XGMotion.Duration.NORMAL),
)

// Spring
animate(animationSpec = XGMotion.Easing.springSpec<Dp>())

// Crossfade on image load
crossfade(durationMillis = XGMotion.Crossfade.IMAGE_FADE_IN)
```

### iOS Usage Example

```swift
// Easing + duration
withAnimation(.easeInOut(duration: XGMotion.Duration.normal)) { ... }

// Pre-built animation value
withAnimation(XGMotion.Easing.spring) { ... }

// Crossfade on image load
withAnimation(.linear(duration: XGMotion.Crossfade.imageFadeIn)) { ... }
```

---

## Cross-Platform Parity Notes

| Dimension | Android | iOS |
|-----------|---------|-----|
| Duration unit | `Int` milliseconds | `TimeInterval` (seconds) |
| Offset unit | `Dp` (e.g., `20.dp`) | `CGFloat` (e.g., `20`) |
| Opacity unit | `Float` (0f..1f) | `Double` (0..1) |
| Color | `Color(0xFFE0E0E0)` | `Color(hex: "#E0E0E0")` |
| Easing API | Generic factory functions → `AnimationSpec<T>` | `Animation` values |
| Spring params | `dampingRatio = 0.7f`, `StiffnessMedium` | `response: 0.35, dampingFraction: 0.7` |
| Preview | `XGMotionTokenPreview` `@Preview` composable | None (pure constants, no SwiftUI view) |

### imageLoading Exclusion

`motion.json` defines an `imageLoading` section (memory/disk cache budgets, WebP, downsampling). These are image-library configuration values consumed by Coil (Android) and Nuke (iOS) setup code directly — they are intentionally excluded from `XGMotion`.

---

## Tests

### Android — `XGMotionTest.kt`

**Location**: `android/app/src/test/java/com/xirigo/ecommerce/core/designsystem/theme/XGMotionTest.kt`

**Total tests**: 36 (pure unit tests, no Robolectric needed)

| Category | Count | What is verified |
|----------|-------|-----------------|
| Duration | 7 | All 5 constants match JSON values; ordering invariants |
| Shimmer | 6 | `DURATION_MS`, `ANGLE_DEGREES`, `REPEAT_MODE_RESTART`, gradient size/symmetry/hex values |
| Crossfade | 3 | `IMAGE_FADE_IN`, `CONTENT_SWITCH`, relative ordering |
| Scroll | 2 | `PREFETCH_DISTANCE`, `SCROLL_RESTORATION_ENABLED` |
| EntranceAnimation | 6 | All 5 constants, fade range invariant |
| Performance | 6 | All 5 constants, frame/fps math correctness |
| Easing | 10 | Return types (`TweenSpec<T>`, `SpringSpec<T>`), default durations, distinct instances |

### iOS — `XGMotionTests.swift`

**Location**: `ios/XiriGoEcommerceTests/Core/DesignSystem/Theme/XGMotionTests.swift`

**Total tests**: 48, all passing (7 suites × average 7 tests each — see breakdown below)

| Suite | Count |
|-------|-------|
| `XGMotion.Duration Tests` | 8 |
| `XGMotion.Easing Tests` | 7 |
| `XGMotion.Shimmer Tests` | 8 |
| `XGMotion.Crossfade Tests` | 5 |
| `XGMotion.Scroll Tests` | 3 |
| `XGMotion.EntranceAnimation Tests` | 8 |
| `XGMotion.Performance Tests` | 9 |

All 26 JSON token paths are covered with exact-value assertions.
