# DQ-03/04: Shimmer Effect Modifier

## Overview

The Shimmer Effect Modifier applies an animated gradient sweep to any view or composable as a loading placeholder animation. It is implemented as a `Modifier` extension function (Android / Jetpack Compose) and a `ViewModifier` + `View` extension (iOS / SwiftUI).

All visual parameters — duration, sweep angle, gradient colors — are sourced from `XGMotion.Shimmer` design tokens. No hardcoded values exist in the modifier implementations.

**Status**: Complete
**Phase**: M0 (Foundation) — DQ backfill
**Issues**: DQ-03 (Android), DQ-04 (iOS)
**Platforms**: Android (Kotlin + Jetpack Compose) + iOS (Swift + SwiftUI)
**Token dependency**: `XGMotion.Shimmer` (see [motion-tokens.md](./motion-tokens.md))

---

## File Locations

| Platform | File | Layer |
|----------|------|-------|
| Android | `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/ShimmerModifier.kt` | Design System / Component |
| iOS | `ios/XiriGoEcommerce/Core/DesignSystem/Component/ShimmerModifier.swift` | Design System / Component |

---

## API

### Android

```kotlin
// File: core/designsystem/component/ShimmerModifier.kt

fun Modifier.shimmerEffect(enabled: Boolean = true): Modifier
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enabled` | `Boolean` | `true` | When `false`, returns the modifier chain unchanged (no-op) |

**Returns**: The `Modifier` chain with an infinite shimmer gradient overlay when `enabled = true`.

### iOS

```swift
// File: Core/DesignSystem/Component/ShimmerModifier.swift

extension View {
    func shimmerEffect(active: Bool = true) -> some View
}
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `active` | `Bool` | `true` | When `false`, returns the view unchanged (no-op) |

**Returns**: A view with a shimmer gradient overlay when `active = true`.

**Naming note**: The parameter is `enabled` on Android (Compose modifier convention) and `active` on iOS (SwiftUI modifier convention). The function name `shimmerEffect` is identical on both platforms.

---

## Design Tokens Used

All values come from `shared/design-tokens/foundations/motion.json > shimmer` via `XGMotion.Shimmer`:

| Token | Android | iOS | Value |
|-------|---------|-----|-------|
| Duration | `XGMotion.Shimmer.DURATION_MS` | `XGMotion.Shimmer.duration` | 1200ms / 1.2s |
| Angle | `XGMotion.Shimmer.ANGLE_DEGREES` | `XGMotion.Shimmer.angleDegrees` | 20 degrees |
| Gradient colors | `XGMotion.Shimmer.GradientColors` | `XGMotion.Shimmer.gradientColors` | `[#E0E0E0, #F5F5F5, #E0E0E0]` |
| Repeat mode | `RepeatMode.Restart` | `.repeatForever(autoreverses: false)` | No reverse |

---

## Visual Behavior

1. A three-color linear gradient (`#E0E0E0` → `#F5F5F5` → `#E0E0E0`) is created.
2. The gradient is rotated 20 degrees from horizontal (subtle diagonal sweep).
3. The gradient translates from off-screen left to off-screen right each frame.
4. One full sweep cycle takes 1200ms with linear easing.
5. The animation restarts immediately on completion — no reverse, no pause.
6. The shimmer repeats infinitely until the modifier is removed or disabled.

### Gradient travel geometry

```
[off-screen left] | [view width] | [off-screen right]
^-- start (t=0)                   end (t=1) --^
```

The gradient width equals the view width. Total travel = 2× view width (enters and exits cleanly).

---

## Implementation Details

### Android

```kotlin
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

Key points:
- `composed { }` gives each call site its own transition state instance.
- `graphicsLayer { }` promotes to a hardware-accelerated RenderNode layer.
- `drawWithContent` draws original content first, then overlays the gradient — no content replacement.
- Angle converted via `Math.toRadians` + `tan()` for correct start/end point geometry.

### iOS

```swift
struct ShimmerModifier: ViewModifier {
    let active: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if active {
            content.overlay(shimmerOverlay).mask(content)
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
                ) { phase = 1 }
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

Key points:
- `.overlay` + `.mask(content)` ensures shimmer respects the shape of any underlying view (rounded rect, circle, custom shape).
- `GeometryReader` measures view width to compute gradient travel distance.
- `@State phase` animates 0→1 with `.linear.repeatForever(autoreverses: false)`.
- `.rotationEffect` applies the 20-degree diagonal to the gradient overlay.
- `.clipped()` prevents gradient from rendering outside view bounds.

---

## Performance

### GPU Acceleration

| Platform | Technique | Effect |
|----------|-----------|--------|
| Android | `graphicsLayer { }` | Promotes composable to hardware-accelerated RenderNode; avoids CPU-bound redraws |
| iOS | Implicit layer | `.offset` animation on a `LinearGradient` is GPU-composited by SwiftUI by default |

### Frame Budget

Per `XGMotion.Performance`, the frame time budget is 16ms (60 fps target). The shimmer does not cause jank because:

- Android: `drawWithContent` redraws only the draw scope, not the full composition tree.
- iOS: Only `offset` changes per frame — no layout recalculation.
- Both: `LinearEasing` uses a simple lerp per frame (no expensive curve interpolation).
- No bitmap allocations — the gradient is rendered procedurally with three color stops.

---

## Usage

### When to Apply

- Placeholder shapes representing content being loaded (product cards, text lines, images, avatars).
- Apply **after** `.clip()` and `.background()` so the shimmer overlays the base color.
- Combine with skeleton layouts: the skeleton provides shape; the shimmer modifier provides animation.

### When NOT to Apply

- Interactive elements (buttons, text fields) — use `XGLoadingView` or a disabled state instead.
- Already-loaded content (not a decorative effect).
- Nested views — apply once to the outermost container only.

### Composition Pattern

**Android**:
```kotlin
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
```swift
RoundedRectangle(cornerRadius: XGCornerRadius.medium)
    .fill(XGMotion.Shimmer.gradientColors.first ?? XGColors.shimmer)
    .frame(height: 120)
    .shimmerEffect(active: isLoading)
```

### Base Color

Use `XGMotion.Shimmer.GradientColors.first()` (Android) or `XGMotion.Shimmer.gradientColors.first` (iOS), which is `#E0E0E0`. This matches the gradient's outer stops for a seamless blend. On iOS, `XGColors.shimmer` (`#F1F5F9`) serves as a defensive fallback only — it cannot happen in practice since the token array is never empty.

---

## Previews

Both platforms ship preview composables demonstrating shimmer on multiple shapes.

| Shape | Dimensions | Corner Radius |
|-------|------------|---------------|
| Rectangle | Full width × 120pt | `XGCornerRadius.Medium` / `.medium` |
| Circle | 80 × 80pt | `CircleShape` / `Circle()` |
| Text placeholder (long) | 220pt × 16pt | `XGCornerRadius.Small` / `.small` |
| Text placeholder (short) | 160pt × 16pt | `XGCornerRadius.Small` / `.small` |
| Disabled shimmer | Full width × 16pt | `XGCornerRadius.Small` / `.small` |

All preview dimensions are extracted to named constants (Android: `private val` top-level; iOS: `private enum PreviewConstants`). No magic numbers.

**Android preview**: `ShimmerEffectPreview` (`@Preview(showBackground = true)`)

**iOS previews**:
- `#Preview("Shimmer on Shapes")` — rectangle, circle, text placeholders
- `#Preview("Shimmer Disabled")` — static rectangle with `active: false`

---

## Cross-Platform Parity

| Aspect | Android | iOS |
|--------|---------|-----|
| Function name | `shimmerEffect` | `shimmerEffect` |
| Toggle param name | `enabled` | `active` |
| Default value | `true` | `true` |
| Duration | 1200ms | 1.2s |
| Angle | 20 degrees | 20 degrees |
| Gradient colors | `#E0E0E0, #F5F5F5, #E0E0E0` | `#E0E0E0, #F5F5F5, #E0E0E0` |
| Repeat | Restart (no reverse) | `repeatForever(autoreverses: false)` |
| Easing | `LinearEasing` | `.linear` |
| Rendering | `drawWithContent` + `drawRect` | `.overlay` + `.mask` |
| Shape masking | Parent clip (`.clip`) | `.mask(content)` |
| GPU | `graphicsLayer { }` | Implicit layer |
| No-op when disabled | Returns `this` | Returns `content` unchanged |

---

## Tests

### Android — `ShimmerModifierTest.kt`

**Location**: `android/app/src/androidTest/java/com/xirigo/ecommerce/core/designsystem/component/ShimmerModifierTest.kt`

**Runner**: AndroidJUnit4 + `createComposeRule`
**Total tests**: 12 (instrumented UI tests)

| Test | Covers |
|------|--------|
| `shimmerEffect_enabled_rectangularBox_isDisplayed` | Enabled shimmer on rounded-rect box renders |
| `shimmerEffect_enabled_circleBox_isDisplayed` | Enabled shimmer on circle shape renders |
| `shimmerEffect_enabled_textPlaceholder_isDisplayed` | Enabled shimmer on text-width placeholder renders |
| `shimmerEffect_disabled_boxIsStillDisplayed` | `enabled=false` — box still visible (no-op) |
| `shimmerEffect_disabled_defaultParameter_boxIsDisplayed` | Default `enabled=true` renders correctly |
| `xgMotionShimmer_durationMs_matchesDesignSpec` | `DURATION_MS == 1200` |
| `xgMotionShimmer_angleDegrees_matchesDesignSpec` | `ANGLE_DEGREES == 20` |
| `xgMotionShimmer_repeatModeRestart_isTrue` | `REPEAT_MODE_RESTART == true` |
| `xgMotionShimmer_gradientColors_hasThreeStops` | Gradient list has 3 colors |
| `xgMotionShimmer_gradientColors_firstAndLastAreEqual` | Symmetrical gradient |
| `xgMotionShimmer_gradientColors_firstColor_matchesDesignSpec` | Base color == `#E0E0E0` |
| `xgMotionShimmer_gradientColors_highlightColor_matchesDesignSpec` | Highlight == `#F5F5F5` |
| `shimmerEffect_multipleBoxes_allDisplayed` | Two shimmer boxes coexist without interference |

**Note**: The animated gradient draw overlay itself (`drawRect`) cannot be asserted via Compose semantics — this is a limitation of draw-layer testing. Visual correctness is validated via the preview composable and profiler.

### iOS — `ShimmerModifierTests.swift`

**Location**: `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/ShimmerModifierTests.swift`

**Total tests**: 17 (15 active, 2 disabled for SwiftUI runtime dependency)

| Test | Covers |
|------|--------|
| `init_activeTrue_initialises` | `ShimmerModifier(active: true)` stores `active = true` |
| `init_activeFalse_initialises` | `ShimmerModifier(active: false)` stores `active = false` |
| `shimmerEffect_defaultActive_isTrue` | Extension default param is `active: true` |
| `shimmerEffect_activeFalse_modifierIsInactive` | Extension with `active: false` produces inactive modifier |
| `shimmerToken_duration_is1point2Seconds` | `XGMotion.Shimmer.duration == 1.2` |
| `shimmerToken_angleDegrees_is20` | `XGMotion.Shimmer.angleDegrees == 20` |
| `shimmerToken_gradientColors_hasThreeStops` | Gradient has 3 color stops |
| `shimmerToken_gradientColors_isNonEmpty` | Gradient array is non-empty |
| `shimmerToken_gradientColors_firstAndLastAreEqual` | Outer colors are identical |
| `shimmerToken_gradientColors_middleIsDifferentFromOuter` | Middle (highlight) differs from outer |
| `offsetForPhase_phaseZero_isNegativeViewWidth` | phase=0 → offset = -viewWidth (off-screen left) |
| `offsetForPhase_phaseOne_isPositiveViewWidth` | phase=1 → offset = +viewWidth (off-screen right) |
| `offsetForPhase_phaseHalf_isZero` | phase=0.5 → offset = 0 (centered) |
| `offsetForPhase_totalTravel_isTwiceViewWidth` | Total sweep = 2× view width |
| `offsetForPhase_linearProgress_isMonotonicallyIncreasing` | Offset increases linearly with phase |
