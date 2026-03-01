# DQ-03/04: Shimmer Effect Modifier -- Feature Specification

## Overview

The Shimmer Effect Modifier provides an animated gradient sweep overlay for loading placeholders
across the XiriGo design system. It is implemented as a composable `Modifier` extension (Android)
and a `ViewModifier` extension (iOS), drawing a translating linear gradient over any view to
indicate content is loading. All visual parameters -- duration, angle, colors -- are derived from
the `XGMotion.Shimmer` design tokens defined in `shared/design-tokens/foundations/motion.json`.

### User Stories

- As a **user**, I want to see an animated shimmer effect on loading placeholders so I understand content is being fetched.
- As a **developer**, I want a single modifier I can apply to any shape or view to get a consistent shimmer animation without manual setup.
- As a **developer**, I want to conditionally disable the shimmer so I can toggle it based on loading state.
- As a **designer**, I want the shimmer to use centralized motion tokens so any visual change propagates globally.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Animated gradient sweep modifier | Skeleton screen layout composition |
| Token-driven duration, angle, colors | Shimmer color theme switching (dark mode) |
| Conditional enable/disable parameter | Pulsing or fade-based loading animations |
| GPU-accelerated rendering | Content-aware placeholder generation |
| Preview composables for both platforms | Integration tests with real network loading |

### Related Issues

- DQ-03: Shimmer Modifier (Android)
- DQ-04: Shimmer Modifier (iOS)

---

## 1. Design Tokens

All shimmer parameters are sourced from `shared/design-tokens/foundations/motion.json > shimmer`:

| Token | JSON Key | Value | Description |
|-------|----------|-------|-------------|
| Gradient Colors | `shimmer.gradientColors` | `["#E0E0E0", "#F5F5F5", "#E0E0E0"]` | Three-stop gradient: base gray, highlight white, base gray |
| Angle | `shimmer.angleDegrees` | `20` | Rotation angle of gradient in degrees |
| Duration | `shimmer.durationMs` | `1200` | Full sweep cycle in milliseconds (1.2s) |
| Repeat Mode | `shimmer.repeatMode` | `"restart"` | Gradient restarts from left after each cycle (no reverse) |

### Platform Token Mapping

| Token | Android (`XGMotion.Shimmer`) | iOS (`XGMotion.Shimmer`) |
|-------|------------------------------|--------------------------|
| Duration | `DURATION_MS: Int = 1200` | `duration: TimeInterval = 1.2` |
| Angle | `ANGLE_DEGREES: Int = 20` | `angleDegrees: Double = 20` |
| Colors | `GradientColors: List<Color>` | `gradientColors: [Color]` |
| Repeat | `REPEAT_MODE_RESTART: Boolean = true` | Implicit via `.repeatForever(autoreverses: false)` |

---

## 2. API Surface

### Android

```
// File: core/designsystem/component/ShimmerModifier.kt

fun Modifier.shimmerEffect(enabled: Boolean = true): Modifier
```

**Parameters**:
- `enabled` (default `true`): When `false`, the modifier is a no-op and returns the modifier chain unchanged.

**Returns**: The modified `Modifier` chain with a shimmer gradient overlay when enabled.

### iOS

```
// File: Core/DesignSystem/Component/ShimmerModifier.swift

extension View {
    func shimmerEffect(active: Bool = true) -> some View
}
```

**Parameters**:
- `active` (default `true`): When `false`, the modifier is a no-op and renders content as-is.

**Returns**: A view with a shimmer gradient overlay when active.

### Naming Rationale

The parameter is named `enabled` on Android (matching Compose convention for modifier toggles)
and `active` on iOS (matching SwiftUI modifier convention). The function name `shimmerEffect`
is identical on both platforms.

---

## 3. Visual Behavior

### Animation Cycle

1. A three-color linear gradient (`#E0E0E0` -> `#F5F5F5` -> `#E0E0E0`) is created.
2. The gradient is rotated by 20 degrees from horizontal.
3. On each animation frame, the gradient translates from off-screen left to off-screen right.
4. The full translation cycle takes 1200ms with linear easing.
5. On completion, the animation restarts immediately (no reverse, no pause).
6. The cycle repeats infinitely until the modifier is removed or disabled.

### Gradient Geometry

```
Off-screen left                     On-screen                     Off-screen right
     |<--- gradient width --->|<--- view width --->|<--- gradient width --->|
     ^                                                                      ^
  start position (t=0)                                          end position (t=1)
```

The gradient width equals the view width. The total travel distance spans from one full
gradient width before the left edge to one full gradient width past the right edge, ensuring
the sweep enters and exits cleanly.

### Angle Calculation

The 20-degree angle creates a subtle diagonal sweep from upper-left to lower-right.

- **Android**: Angle converted to radians; `tan(angle)` computes the vertical offset for gradient start/end points.
- **iOS**: Applied via `.rotationEffect(.degrees(20))` on the gradient view.

---

## 4. Architecture

The shimmer modifier is a design system primitive with no domain or data layer dependencies.
It lives entirely within the design system component layer.

### File Locations

| Platform | File | Layer |
|----------|------|-------|
| Android | `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/ShimmerModifier.kt` | Design System / Component |
| iOS | `ios/XiriGoEcommerce/Core/DesignSystem/Component/ShimmerModifier.swift` | Design System / Component |

### Dependencies

| Dependency | Platform | Purpose |
|------------|----------|---------|
| `XGMotion.Shimmer` | Both | Duration, angle, and color tokens |
| `XGCornerRadius` | Both | Preview clip shapes only |
| `XGSpacing` | Both | Preview layout spacing only |
| `XGColors.shimmer` | iOS only | Fallback color in previews (`#F1F5F9`) |
| `graphicsLayer` | Android only | GPU layer promotion |
| `GeometryReader` | iOS only | View size measurement |

---

## 5. Platform Implementations

### 5.1 Android Implementation

```
fun Modifier.shimmerEffect(enabled: Boolean = true): Modifier {
    if (!enabled) return this
    return composed {
        val transition = rememberInfiniteTransition(label = "shimmer")
        val translateAnimation by transition.animateFloat(
            initialValue = 0f,
            targetValue = 1f,
            animationSpec = infiniteRepeatable(
                animation = tween(
                    durationMillis = XGMotion.Shimmer.DURATION_MS,
                    easing = LinearEasing,
                ),
                repeatMode = RepeatMode.Restart,
            ),
            label = "shimmerTranslate",
        )

        val angleRadians = Math.toRadians(XGMotion.Shimmer.ANGLE_DEGREES.toDouble()).toFloat()

        graphicsLayer { }
            .drawWithContent {
                drawContent()
                val gradientWidth = size.width
                val tanAngle = tan(angleRadians)
                val yOffset = tanAngle * gradientWidth
                val translateX = translateAnimation * (size.width + gradientWidth) - gradientWidth

                val brush = Brush.linearGradient(
                    colors = XGMotion.Shimmer.GradientColors,
                    start = Offset(translateX, -yOffset),
                    end = Offset(translateX + gradientWidth, yOffset),
                )
                drawRect(brush = brush)
            }
    }
}
```

**Key details**:
- `composed { }` ensures each call site gets its own transition state.
- `graphicsLayer { }` promotes the composable to a hardware-accelerated layer for smooth animation.
- `drawWithContent` draws the original content first, then overlays the gradient via `drawRect`.
- `rememberInfiniteTransition` with `animateFloat(0f..1f)` drives the horizontal translation.
- The gradient angle is computed via trigonometry (`tan`) for precise start/end point positioning.

### 5.2 iOS Implementation

```
struct ShimmerModifier: ViewModifier {
    let active: Bool

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if active {
            content
                .overlay(shimmerOverlay)
                .mask(content)
        } else {
            content
        }
    }

    private var shimmerOverlay: some View {
        GeometryReader { geometry in
            let gradientWidth = geometry.size.width
            LinearGradient(
                colors: XGMotion.Shimmer.gradientColors,
                startPoint: .leading,
                endPoint: .trailing,
            )
            .frame(width: gradientWidth)
            .rotationEffect(.degrees(XGMotion.Shimmer.angleDegrees))
            .offset(x: offsetForPhase(viewWidth: gradientWidth))
            .onAppear {
                withAnimation(
                    .linear(duration: XGMotion.Shimmer.duration)
                        .repeatForever(autoreverses: false),
                ) {
                    phase = 1
                }
            }
        }
        .clipped()
    }

    private func offsetForPhase(viewWidth: CGFloat) -> CGFloat {
        let totalTravel = viewWidth * 2
        return -viewWidth + (phase * totalTravel)
    }
}
```

**Key details**:
- `.overlay` + `.mask(content)` ensures shimmer respects the shape of any underlying view (rounded rect, circle, etc.).
- `GeometryReader` measures the view width to calculate gradient travel distance.
- `@State phase` animated from 0 to 1 with `.linear.repeatForever(autoreverses: false)`.
- `.rotationEffect` applies the 20-degree angle to the gradient view.
- `.clipped()` prevents gradient overflow outside the view bounds.

---

## 6. Performance Considerations

### GPU Acceleration

| Platform | Technique | Purpose |
|----------|-----------|---------|
| Android | `graphicsLayer { }` | Promotes to hardware-accelerated RenderNode; avoids CPU-bound redraws |
| iOS | SwiftUI implicit layer | `.offset` animation on a gradient view is GPU-composited by default |

### Frame Budget

Per `XGMotion.Performance`, the frame time budget is 16ms (60 fps). The shimmer animation
must not cause jank during scroll. Verified techniques:

1. **No recomposition on every frame** (Android): `drawWithContent` only redraws the draw scope, not the entire composition tree.
2. **No expensive layout passes** (iOS): Only the `offset` property changes; no layout recalculation per frame.
3. **Linear easing**: Avoids expensive curve interpolation; simple lerp per frame.

### Memory

- The gradient brush is recreated per draw call (lightweight; three color stops).
- No bitmap allocations -- the gradient is rendered procedurally.
- The infinite transition is scoped to the composable/view lifecycle and cleaned up on removal.

---

## 7. Usage Guidelines

### When to Apply

- Apply to **placeholder shapes** that represent content being loaded (product cards, text lines, images, avatars).
- Apply **after** `.clip()` and `.background()` so the shimmer overlays the base color.
- Combine with skeleton layouts: a skeleton component provides the shape; the shimmer modifier provides the animation.

### When NOT to Apply

- Do not apply to interactive elements (buttons, text fields) -- these should use `XGLoadingView` or disable state.
- Do not apply to already-loaded content as a decorative effect.
- Do not stack multiple shimmer modifiers on nested views -- apply once to the outermost container.

### Composition Pattern

**Android**:
```
Box(
    modifier = Modifier
        .fillMaxWidth()
        .height(120.dp)
        .clip(RoundedCornerShape(XGCornerRadius.Medium))
        .background(XGMotion.Shimmer.GradientColors.first())
        .shimmerEffect(enabled = isLoading),
)
```

**iOS**:
```
RoundedRectangle(cornerRadius: XGCornerRadius.medium)
    .fill(XGMotion.Shimmer.gradientColors.first ?? XGColors.shimmer)
    .frame(height: 120)
    .shimmerEffect(active: isLoading)
```

### Base Color

The placeholder base color should be `XGMotion.Shimmer.GradientColors.first()` (Android) or
`XGMotion.Shimmer.gradientColors.first` (iOS), which is `#E0E0E0`. This ensures a seamless
visual blend with the gradient sweep. The iOS side uses `XGColors.shimmer` (`#F1F5F9`) as a
fallback if the array is empty (defensive, will not happen in practice).

---

## 8. Cross-Platform Parity

| Aspect | Android | iOS | Parity |
|--------|---------|-----|--------|
| Function name | `shimmerEffect` | `shimmerEffect` | Identical |
| Toggle param | `enabled: Boolean` | `active: Bool` | Name differs (platform convention) |
| Default | `true` | `true` | Identical |
| Duration | 1200ms | 1.2s | Identical |
| Angle | 20 degrees | 20 degrees | Identical |
| Gradient colors | `#E0E0E0, #F5F5F5, #E0E0E0` | `#E0E0E0, #F5F5F5, #E0E0E0` | Identical |
| Repeat mode | Restart (no reverse) | Repeat forever (no autoreverse) | Identical |
| Easing | LinearEasing | .linear | Identical |
| Rendering | `drawWithContent` + `drawRect` | `.overlay` + `.mask` | Different technique, same result |
| Shape masking | Inherits parent clip | `.mask(content)` | Same visual result |
| GPU acceleration | `graphicsLayer { }` | Implicit layer | Same performance goal |
| No-op when disabled | Returns `this` | Returns `content` | Identical behavior |

---

## 9. Previews

Both platforms include preview composables demonstrating shimmer on multiple shapes:

| Preview Shape | Dimensions | Corner Radius |
|---------------|------------|---------------|
| Rectangle | Full width x 120pt | `XGCornerRadius.Medium` |
| Circle | 80pt x 80pt | `CircleShape` / `Circle()` |
| Text placeholder (long) | 220pt x 16pt | `XGCornerRadius.Small` |
| Text placeholder (short) | 160pt x 16pt | `XGCornerRadius.Small` |
| Disabled shimmer | Full width x 16pt | `XGCornerRadius.Small` |

All preview dimension values are extracted to named constants:
- **Android**: `private val` top-level constants
- **iOS**: `private enum PreviewConstants` with static properties

---

## 10. File Manifest

### 10.1 Android

| File | Status | Layer |
|------|--------|-------|
| `android/.../core/designsystem/component/ShimmerModifier.kt` | Existing | Design System |
| `android/.../core/designsystem/theme/XGMotion.kt` | Existing (provides tokens) | Design System |

### 10.2 iOS

| File | Status | Layer |
|------|--------|-------|
| `ios/XiriGoEcommerce/Core/DesignSystem/Component/ShimmerModifier.swift` | Existing | Design System |
| `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGMotion.swift` | Existing (provides tokens) | Design System |

---

## 11. Verification Criteria

### Functional

- [ ] Shimmer gradient animates left-to-right across the view continuously.
- [ ] Animation uses `XGMotion.Shimmer` tokens for duration (1200ms), angle (20 degrees), and colors.
- [ ] No hardcoded color, duration, or angle values in the modifier implementation.
- [ ] When `enabled`/`active` is `false`, no animation runs and content renders normally.
- [ ] Shimmer respects the clip shape of the underlying view (rectangle, circle, rounded rect).

### Performance

- [ ] No dropped frames during shimmer animation while scrolling (verified via profiler).
- [ ] GPU-accelerated rendering on Android (`graphicsLayer` present).
- [ ] No unnecessary recomposition/layout passes per animation frame.

### Code Quality

- [ ] Android: ktlint and detekt pass with zero violations.
- [ ] iOS: SwiftLint passes with zero violations.
- [ ] No `!!` (Kotlin) or force unwrap `!` (Swift).
- [ ] No `Any` type usage.
- [ ] All string literals are design token references, not hardcoded.
- [ ] Preview composables/views present and rendering correctly.
- [ ] All multi-line parameter lists use trailing commas.

### Cross-Platform

- [ ] Visual output is indistinguishable between Android and iOS at 60 fps.
- [ ] Same gradient colors, angle, and duration on both platforms.
- [ ] Same no-op behavior when disabled on both platforms.
