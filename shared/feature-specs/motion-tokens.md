# DQ-01 / DQ-02: Motion Tokens -- Feature Specification

## 1. Overview

The Motion Tokens feature establishes a centralized set of animation, transition, scroll,
and performance constants for the XiriGo design system. By exposing every motion-related
value as a named constant through `XGMotion`, the codebase eliminates hardcoded animation
durations, easing curves, shimmer parameters, and performance budgets across both platforms.

This is a **design-system infrastructure** feature. It produces no user-visible screens; instead
it provides the token layer consumed by every component and screen that includes animation or
motion behavior.

### Purpose

- Guarantee cross-platform motion consistency (same durations, easing intent, shimmer appearance).
- Provide a single point of change when motion values are tuned via Figma or performance testing.
- Document performance budgets so that profiling tools can compare against defined thresholds.
- Enforce rules (shimmer-not-static, lazy-rendering, entrance-animation scope) via token-level documentation.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Duration constants (instant, fast, normal, slow, pageTransition) | Shimmer Modifier/ViewModifier implementation (consumed, not defined here) |
| Easing curves (standard, decelerate, accelerate, spring) | Image loading library setup (Coil/Nuke configuration) |
| Shimmer parameters (gradient colors, angle, duration, repeat mode) | Actual scroll restoration implementation |
| Crossfade durations (imageFadeIn, contentSwitch) | Profiling tooling integration |
| Scroll configuration (prefetch distance, scroll restoration flag) | Navigation transition choreography |
| Entrance animation parameters (stagger, fade, slide) | Lottie or Rive animation support |
| Performance budgets (frame time, FPS, startup, FCP) | Runtime performance monitoring |

### Source of Truth

All values originate from `shared/design-tokens/foundations/motion.json`. Platform
implementations mirror these values. Any design-side update to the JSON file must be
propagated to both `XGMotion.kt` (Android) and `XGMotion.swift` (iOS).

---

## 2. Token Categories

### 2.1 Duration

Standard timing values for animations and transitions.

| Token Name | Value (ms) | JSON Key | Usage |
|------------|-----------|----------|-------|
| `instant` | 100 | `duration.instant` | Micro-interactions: toggle, checkbox, ripple |
| `fast` | 200 | `duration.fast` | Button press feedback, icon rotation, chip toggle |
| `normal` | 300 | `duration.normal` | Default animation duration, content crossfade |
| `slow` | 450 | `duration.slow` | Modal entrance/exit, bottom sheet slide |
| `pageTransition` | 350 | `duration.pageTransition` | Screen-to-screen navigation transitions |

**Platform unit note**: Android stores values as `Int` milliseconds. iOS stores values as
`TimeInterval` (seconds), e.g., `0.3` for 300ms.

### 2.2 Easing

Curves and spring specifications for natural-feeling animations.

| Token Name | Android Implementation | iOS Implementation | Usage |
|------------|----------------------|-------------------|-------|
| `standard` | `FastOutSlowInEasing` via `tween()` | `.easeInOut` | General-purpose animation curve |
| `decelerate` | `LinearOutSlowInEasing` via `tween()` | `.easeOut` | Elements entering view |
| `accelerate` | `FastOutLinearInEasing` via `tween()` | `.easeIn` | Elements leaving view |
| `spring` | `spring(dampingRatio=0.7f, stiffness=StiffnessMedium)` | `.spring(response: 0.35, dampingFraction: 0.7)` | Physics-based bounce (bottom sheet, pull-to-refresh) |

**Android-specific**: Easing tokens are exposed as generic factory functions returning
`AnimationSpec<T>`, e.g., `XGMotion.Easing.standardTween<Float>(durationMillis)`.
This allows callers to specify both the animated type and optional duration override.

**iOS-specific**: Easing tokens are exposed as `Animation` values. Duration is applied
separately via `.animation(XGMotion.Easing.standard.speed(...))` or by using
`withAnimation(XGMotion.Easing.standard) { ... }`.

### 2.3 Shimmer

Parameters for loading placeholder animations. All loading placeholders **MUST** use animated
shimmer gradient sweep, never a static color.

| Token Name | Value | JSON Key | Notes |
|------------|-------|----------|-------|
| `durationMs` / `duration` | 1200ms / 1.2s | `shimmer.durationMs` | Full sweep cycle |
| `angleDegrees` | 20 | `shimmer.angleDegrees` | Gradient sweep angle |
| `gradientColors` | `[#E0E0E0, #F5F5F5, #E0E0E0]` | `shimmer.gradientColors` | Three-stop gradient |
| `repeatMode` | restart | `shimmer.repeatMode` | Android: `RepeatMode.Restart` |

**Corner radius**: Shimmer placeholders use the medium corner radius from the spacing tokens
(`$foundations/spacing.cornerRadius.medium`).

### 2.4 Crossfade

Durations for smooth content transitions.

| Token Name | Value (ms) | JSON Key | Usage |
|------------|-----------|----------|-------|
| `imageFadeIn` | 300 | `crossfade.imageFadeIn` | Image loading completion transition |
| `contentSwitch` | 200 | `crossfade.contentSwitch` | State-based content swap (loading to loaded) |

### 2.5 Scroll

Configuration for lazy list/grid scroll behavior.

| Token Name | Value | JSON Key | Usage |
|------------|-------|----------|-------|
| `prefetchDistance` | 5 | `scroll.prefetchDistance` | Items to prefetch beyond visible area |
| `scrollRestorationEnabled` | true | `scroll.scrollRestorationEnabled` | Restore scroll position on back-navigation |

**Rule**: All scrollable lists MUST use lazy rendering:
- Android: `LazyColumn`, `LazyRow`, `LazyVerticalGrid`
- iOS: `LazyVStack`, `LazyHStack`, `LazyVGrid`

Never use `Column` + `verticalScroll` (Android) or `ScrollView` + `VStack` (iOS) for lists
with more than 4 items.

### 2.6 EntranceAnimation

Parameters for staggered list-item reveal animations on first screen load.

| Token Name | Value | JSON Key | Usage |
|------------|-------|----------|-------|
| `staggerDelay` | 50ms / 0.05s | `entranceAnimation.staggerDelayMs` | Delay between consecutive item animations |
| `maxStaggerItems` | 8 | `entranceAnimation.maxStaggerItems` | Cap on animated items (avoid long waits) |
| `fadeFrom` | 0.0 | `entranceAnimation.fadeFromOpacity` | Initial opacity |
| `fadeTo` | 1.0 | `entranceAnimation.fadeToOpacity` | Final opacity |
| `slideOffsetY` | 20dp / 20pt | `entranceAnimation.slideOffsetY` | Vertical slide distance |

**Rule**: Entrance animations apply only on first screen load. Items loaded via pagination
or infinite scroll must NOT animate in with stagger.

### 2.7 Performance

Budget thresholds for profiling and monitoring. These are reference constants, not enforced
at runtime.

| Token Name | Value | JSON Key | Target |
|------------|-------|----------|--------|
| `frameTime` | 16ms | `performanceBudgets.frameTimeMs` | Max frame render time (60 FPS) |
| `startupCold` | 2000ms | `performanceBudgets.startupColdMs` | Cold start budget |
| `screenTransition` | 300ms | `performanceBudgets.screenTransitionMs` | Screen transition budget |
| `listScrollFps` | 60 | `performanceBudgets.listScrollFps` | Target scroll frame rate |
| `firstContentfulPaint` | 1000ms | `performanceBudgets.firstContentfulPaintMs` | Time to first meaningful content |

**Profiling tools**: Android Studio Profiler (Android), Xcode Instruments (iOS).
Target: zero jank frames during scroll.

---

## 3. Data Models

### 3.1 Android (`XGMotion.kt`)

```
object XGMotion {

    object Duration {
        const val INSTANT = 100          // Int (milliseconds)
        const val FAST = 200
        const val NORMAL = 300
        const val SLOW = 450
        const val PAGE_TRANSITION = 350
    }

    object Easing {
        fun <T> standardTween(durationMillis: Int = Duration.NORMAL): TweenSpec<T>
        fun <T> decelerateTween(durationMillis: Int = Duration.NORMAL): TweenSpec<T>
        fun <T> accelerateTween(durationMillis: Int = Duration.FAST): TweenSpec<T>
        fun <T> springSpec(): SpringSpec<T>
    }

    object Shimmer {
        const val DURATION_MS = 1200
        const val ANGLE_DEGREES = 20
        const val REPEAT_MODE_RESTART = true
        val GradientColors: List<Color>   // [#E0E0E0, #F5F5F5, #E0E0E0]
    }

    object Crossfade {
        const val IMAGE_FADE_IN = 300
        const val CONTENT_SWITCH = 200
    }

    object Scroll {
        const val PREFETCH_DISTANCE = 5
        const val SCROLL_RESTORATION_ENABLED = true
    }

    object EntranceAnimation {
        const val STAGGER_DELAY_MS = 50
        const val MAX_STAGGER_ITEMS = 8
        const val FADE_FROM = 0f
        const val FADE_TO = 1f
        val SlideOffsetY = 20.dp
    }

    object Performance {
        const val FRAME_TIME_MS = 16
        const val STARTUP_COLD_MS = 2000
        const val SCREEN_TRANSITION_MS = 300
        const val LIST_SCROLL_FPS = 60
        const val FIRST_CONTENTFUL_PAINT_MS = 1000
    }
}
```

### 3.2 iOS (`XGMotion.swift`)

```
enum XGMotion {

    enum Duration {
        static let instant: TimeInterval = 0.1
        static let fast: TimeInterval = 0.2
        static let normal: TimeInterval = 0.3
        static let slow: TimeInterval = 0.45
        static let pageTransition: TimeInterval = 0.35
    }

    enum Easing {
        static let standard: Animation = .easeInOut
        static let decelerate: Animation = .easeOut
        static let accelerate: Animation = .easeIn
        static let spring: Animation = .spring(response: 0.35, dampingFraction: 0.7)
        static let springResponse: Double = 0.35
        static let springDampingFraction: Double = 0.7
    }

    enum Shimmer {
        static let duration: TimeInterval = 1.2
        static let angleDegrees: Double = 20
        static let gradientColors: [Color]    // [#E0E0E0, #F5F5F5, #E0E0E0]
    }

    enum Crossfade {
        static let imageFadeIn: TimeInterval = 0.3
        static let contentSwitch: TimeInterval = 0.2
    }

    enum Scroll {
        static let prefetchDistance: Int = 5
        static let scrollRestorationEnabled = true
    }

    enum EntranceAnimation {
        static let staggerDelay: TimeInterval = 0.05
        static let maxStaggerItems: Int = 8
        static let fadeFrom: Double = 0
        static let fadeTo: Double = 1
        static let slideOffsetY: CGFloat = 20
    }

    enum Performance {
        static let frameTime: TimeInterval = 0.016
        static let startupCold: TimeInterval = 2.0
        static let screenTransition: TimeInterval = 0.3
        static let listScrollFps: Int = 60
        static let firstContentfulPaint: TimeInterval = 1.0
    }
}
```

---

## 4. Architecture

### 4.1 Layer

Motion tokens are a **theme-level** concern, sitting alongside `XGColors`, `XGTypography`,
and `XGSpacing` in the design system's theme layer:

```
core/designsystem/theme/
  XGColors.kt / XGColors.swift
  XGTypography.kt / XGTypography.swift
  XGSpacing.kt / XGSpacing.swift
  XGMotion.kt / XGMotion.swift          <-- this feature
```

### 4.2 Dependency Direction

- `XGMotion` has **no dependencies** on other design system types (zero imports from
  feature modules or domain layer).
- Design system components (`XGLoadingView`, `XGImage`, `XGCard`, etc.) import `XGMotion`
  for animation parameters.
- Feature screens import `XGMotion` only when applying screen-level animations
  (entrance stagger, page transitions). Component-level motion is encapsulated in
  `XG*` wrappers.

### 4.3 No Repository / Use Case / ViewModel

This feature is a pure constant definition. It does not involve network calls, persistence,
or state management. There is no repository, use case, or ViewModel associated with
motion tokens.

---

## 5. Usage Guidelines

### 5.1 Selecting the Right Duration

| Scenario | Token |
|----------|-------|
| Toggle, checkbox, small icon change | `Duration.instant` (100ms) |
| Button feedback, chip selection, icon rotation | `Duration.fast` (200ms) |
| Default for most animations, content crossfade | `Duration.normal` (300ms) |
| Modal/sheet entrance or exit | `Duration.slow` (450ms) |
| Screen-to-screen navigation | `Duration.pageTransition` (350ms) |

### 5.2 Selecting the Right Easing

| Scenario | Token |
|----------|-------|
| General-purpose symmetric animation | `Easing.standard` (ease-in-out) |
| Element sliding into viewport, appearing | `Easing.decelerate` (ease-out) |
| Element sliding out of viewport, dismissing | `Easing.accelerate` (ease-in) |
| Bounce effect, pull-to-refresh, bottom sheet snap | `Easing.spring` |

### 5.3 Shimmer Rules

1. Every loading placeholder MUST use animated shimmer with `Shimmer.GradientColors`.
2. Never show a static gray rectangle for loading state.
3. Shimmer sweep angle is fixed at 20 degrees.
4. Cycle duration is 1200ms with restart repeat mode.
5. Use `cornerRadius.medium` from spacing tokens for shimmer shape rounding.

### 5.4 Crossfade Rules

1. When an image finishes loading, fade it in over `Crossfade.imageFadeIn` (300ms).
2. When switching between content states (e.g., loading to loaded), use
   `Crossfade.contentSwitch` (200ms).

### 5.5 Scroll Rules

1. All lists with more than 4 items MUST use lazy rendering.
2. Set prefetch distance to `Scroll.prefetchDistance` (5) for optimal preloading.
3. Enable scroll position restoration on back-navigation.

### 5.6 Entrance Animation Rules

1. Stagger entrance animations only on first screen load.
2. Do NOT animate items loaded via pagination or infinite scroll.
3. Cap staggered items at `EntranceAnimation.maxStaggerItems` (8).
4. Each item fades from 0 to 1 opacity and slides up by `slideOffsetY` (20dp/pt).
5. Keep animations subtle -- they should not delay perceived content availability.

---

## 6. Cross-Platform Parity Notes

### 6.1 Unit Conventions

| Dimension | Android | iOS |
|-----------|---------|-----|
| Duration | `Int` milliseconds | `TimeInterval` seconds |
| Offset | `Dp` (e.g., `20.dp`) | `CGFloat` (e.g., `20`) |
| Opacity | `Float` (0f..1f) | `Double` (0..1) |
| Color | `Color(0xFFE0E0E0)` | `Color(hex: "#E0E0E0")` |

### 6.2 Easing API Differences

Android exposes easing as generic factory functions that return `AnimationSpec<T>`,
bundling easing curve and duration together. iOS exposes easing as `Animation` values;
duration is composed separately using SwiftUI animation modifiers.

### 6.3 Spring Parameters

Both platforms use the same conceptual spring (dampingFraction/dampingRatio = 0.7). iOS
additionally exposes a `response` parameter (0.35s) that controls the spring's natural
period. Android uses `Spring.StiffnessMedium` as the stiffness equivalent.

### 6.4 Token Coverage Gap: imageLoading

The JSON source file defines an `imageLoading` section with memory cache budget (100 MB),
disk cache budget (250 MB), thumbnail size multiplier, progressive loading, WebP, and
downsampling flags. Neither platform implementation surfaces these as `XGMotion` constants.
These are considered **image-library configuration** values rather than motion tokens and are
expected to be consumed directly by the Coil (Android) and Nuke (iOS) setup code rather
than through the `XGMotion` namespace.

---

## 7. File Manifest

### 7.1 Shared

| File | Purpose |
|------|---------|
| `shared/design-tokens/foundations/motion.json` | Source of truth token definitions |

### 7.2 Android

| File | Purpose |
|------|---------|
| `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGMotion.kt` | Token constants + preview |

### 7.3 iOS

| File | Purpose |
|------|---------|
| `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGMotion.swift` | Token constants |

---

## 8. Platform-Specific Notes

### 8.1 Android

- `XGMotion` is declared as a top-level `object` with nested `object` sub-namespaces.
- Numeric constants use `const val` for compile-time inlining.
- `Shimmer.GradientColors` is a `List<Color>` (not `const` since `Color` is not primitive).
- `EntranceAnimation.SlideOffsetY` is a `Dp` value (not `const` since `Dp` is inline class).
- Includes a `@Preview` composable (`XGMotionTokenPreview`) that renders all token values
  for visual inspection in Android Studio.

### 8.2 iOS

- `XGMotion` is declared as a caseless `enum` (prevents instantiation) with nested
  caseless `enum` sub-namespaces.
- All values are `static let` properties.
- Duration values use `TimeInterval` (seconds) to align with SwiftUI and Foundation APIs.
- `Easing.spring` is a computed pre-built `Animation` value ready for use with
  `withAnimation()` or `.animation()`.
- `Shimmer.gradientColors` uses the `Color(hex:)` extension (defined elsewhere in the
  design system).
- `Performance.frameTime` is stored as `0.016` seconds (not 16ms) to match `TimeInterval`
  convention.

---

## 9. Verification Criteria

### 9.1 Token Completeness

- [ ] Every value in `motion.json` sections `duration`, `easing`, `shimmer`, `crossfade`,
      `scroll`, `entranceAnimation`, and `performanceBudgets` has a corresponding constant
      in both `XGMotion.kt` and `XGMotion.swift`.
- [ ] The `imageLoading` section is intentionally excluded from `XGMotion` (documented in
      cross-platform parity notes).

### 9.2 Value Accuracy

- [ ] All duration values match between JSON (milliseconds), Android (Int ms), and
      iOS (TimeInterval seconds, i.e., JSON value / 1000).
- [ ] Shimmer gradient colors match the hex values in JSON.
- [ ] Spring damping values match: Android `dampingRatio = 0.7f`, iOS `dampingFraction: 0.7`.
- [ ] Entrance animation `slideOffsetY` is 20 on both platforms (dp on Android, pt on iOS).

### 9.3 API Usability

- [ ] Android easing functions are generic (`<T>`) and return `AnimationSpec<T>`.
- [ ] iOS easing properties are typed as `Animation` and can be used directly with
      `withAnimation()` or `.animation()`.
- [ ] No force-unwrap (`!!` / `!`) anywhere in either implementation.
- [ ] No hardcoded animation values remain in design system components that should
      reference `XGMotion`.

### 9.4 Code Quality

- [ ] Android: `@Preview` composable renders all token categories without crash.
- [ ] Android: Passes detekt and ktlint checks.
- [ ] iOS: Passes SwiftLint checks.
- [ ] Both: KDoc/doc comments on every public constant and nested object/enum.
