# DQ-05: Skeleton Base Components -- Feature Specification

## Overview

The Skeleton Base Components feature provides three reusable loading-placeholder primitives
(`SkeletonBox`, `SkeletonLine`, `SkeletonCircle`) and a content-wrapping modifier
(`Modifier.skeleton` / `.skeleton(visible:)`) for the XiriGo design system. These are
**infrastructure-level design system atoms** -- not a user-facing screen. Every screen that
displays loading states composes its skeleton layout from these primitives.

All skeleton shapes render a solid `XGColors.skeleton` (#F1F5F9) background with an animated
shimmer gradient sweep via the existing `shimmerEffect` modifier. The content-wrapping modifier
crossfades between skeleton placeholders and real content using `XGMotion.Crossfade.contentSwitch`.

### User Stories

- As a **developer**, I want pre-built skeleton shapes (box, line, circle) so I can quickly compose loading-state layouts without reimplementing shimmer plumbing.
- As a **developer**, I want a `skeleton(visible:)` modifier that crossfades between a placeholder and real content so loading-to-loaded transitions are smooth and consistent.
- As a **user**, I want to see animated placeholder shapes while content loads so I understand the app is working and know what layout to expect.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| `SkeletonBox` composable / view | Screen-specific skeleton layouts (e.g., `HomeSkeletonScreen`) |
| `SkeletonLine` composable / view | Skeleton versions of existing components (e.g., `XGCard.skeleton`) |
| `SkeletonCircle` composable / view | Dark mode skeleton colors (future token addition) |
| `Modifier.skeleton(visible:)` / `.skeleton(visible:)` | Lottie or custom animation effects |
| Design token file for skeleton components | Changes to existing `ShimmerModifier` internals |
| Previews for all components | |
| Accessibility annotations | |

---

## 1. API Mapping

These components are **design-system-only** and do not call any backend API. They consume design
tokens from `shared/design-tokens/` and existing theme objects.

### Token Dependencies

| Token | Source | Platform Reference |
|-------|--------|--------------------|
| Background color | `colors.json > semantic.shimmer` (#F1F5F9) | `XGColors.Shimmer` (Android) / `XGColors.shimmer` (iOS) |
| Shimmer gradient | `motion.json > shimmer.gradientColors` | `XGMotion.Shimmer.GradientColors` / `.gradientColors` |
| Shimmer duration | `motion.json > shimmer.durationMs` (1200ms) | `XGMotion.Shimmer.DURATION_MS` / `.duration` |
| Shimmer angle | `motion.json > shimmer.angleDegrees` (20) | `XGMotion.Shimmer.ANGLE_DEGREES` / `.angleDegrees` |
| Crossfade duration | `motion.json > crossfade.contentSwitch` (200ms) | `XGMotion.Crossfade.CONTENT_SWITCH` / `.contentSwitch` |
| Corner radius (small) | `spacing.json > cornerRadius.small` (6dp) | `XGCornerRadius.Small` / `.small` |
| Corner radius (medium) | `spacing.json > cornerRadius.medium` (10dp) | `XGCornerRadius.Medium` / `.medium` |
| Corner radius (full) | `spacing.json > cornerRadius.circle` (999dp) | `XGCornerRadius.Full` / `.full` |

---

## 2. Data Models

No domain models are needed. These are stateless UI components.

---

## 3. Architecture

These components live in the **design system layer** (`core/designsystem/component/`), not in any
feature module. They have zero domain or data layer dependencies.

### Dependency Graph

```
SkeletonBox / SkeletonLine / SkeletonCircle
    |
    +-- XGColors.skeleton (background color)
    +-- XGCornerRadius.* (shape)
    +-- Modifier.shimmerEffect() (animation)
    |       |
    |       +-- XGMotion.Shimmer.* (tokens)
    |
Modifier.skeleton(visible:)
    |
    +-- XGMotion.Crossfade.CONTENT_SWITCH (transition duration)
    +-- Any skeleton composable/view (placeholder content)
```

---

## 4. New Design System Components

### 4.1 SkeletonBox

A rectangular shimmer placeholder with configurable dimensions and corner radius.

#### API

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `Dp` / `CGFloat` | **required** | Width of the placeholder rectangle |
| `height` | `Dp` / `CGFloat` | **required** | Height of the placeholder rectangle |
| `cornerRadius` | `Dp` / `CGFloat` | `XGCornerRadius.Medium` (10) | Corner radius of the rectangle |
| `modifier` / -- | `Modifier` / -- | `Modifier` / -- | Additional modifiers (Android only param) |

#### Visual Behavior

- Fill: `XGColors.skeleton` (#F1F5F9)
- Shape: `RoundedRectangleShape` with `cornerRadius`
- Animation: `shimmerEffect(enabled: true)` applied as an overlay
- The shimmer gradient sweeps left-to-right at 20 degrees, 1200ms loop, restart repeat

#### Pseudocode -- Android

```
@Composable
fun SkeletonBox(
    width: Dp,
    height: Dp,
    modifier: Modifier = Modifier,
    cornerRadius: Dp = XGCornerRadius.Medium,
)
    val shape = RoundedCornerShape(cornerRadius)
    Box(
        modifier = modifier
            .size(width, height)
            .clip(shape)
            .background(XGColors.Shimmer)
            .shimmerEffect()
    )
```

#### Pseudocode -- iOS

```
struct SkeletonBox: View
    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = XGCornerRadius.medium

    var body: some View
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(XGColors.shimmer)
            .frame(width: width, height: height)
            .shimmerEffect()
```

---

### 4.2 SkeletonLine

A text-line shimmer placeholder. Functionally identical to `SkeletonBox` but with a hardcoded
small corner radius (`XGCornerRadius.Small` = 6dp), signaling its text-line intent.

#### API

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `Dp` / `CGFloat` | **required** | Width of the text-line placeholder |
| `height` | `Dp` / `CGFloat` | `14.dp` / `14` | Height (typical single-line text height) |
| `modifier` / -- | `Modifier` / -- | `Modifier` / -- | Additional modifiers (Android only param) |

The corner radius is fixed at `XGCornerRadius.Small` (6dp) -- not configurable. This
distinguishes `SkeletonLine` from `SkeletonBox` and ensures all text-line skeletons look
consistent across the app.

#### Default Height Rationale

The default height of 14dp approximates `bodyMedium` line height from the typography scale,
making `SkeletonLine()` immediately usable for most text placeholders without specifying height.

#### Visual Behavior

- Fill: `XGColors.skeleton` (#F1F5F9)
- Shape: `RoundedRectangleShape` with `XGCornerRadius.Small` (6dp)
- Animation: `shimmerEffect(enabled: true)`

#### Pseudocode -- Android

```
private val SkeletonLineDefaultHeight = 14.dp

@Composable
fun SkeletonLine(
    width: Dp,
    modifier: Modifier = Modifier,
    height: Dp = SkeletonLineDefaultHeight,
)
    val shape = RoundedCornerShape(XGCornerRadius.Small)
    Box(
        modifier = modifier
            .size(width, height)
            .clip(shape)
            .background(XGColors.Shimmer)
            .shimmerEffect()
    )
```

#### Pseudocode -- iOS

```
struct SkeletonLine: View
    let width: CGFloat
    var height: CGFloat = SkeletonConstants.lineDefaultHeight  // 14

    var body: some View
        RoundedRectangle(cornerRadius: XGCornerRadius.small)
            .fill(XGColors.shimmer)
            .frame(width: width, height: height)
            .shimmerEffect()
```

---

### 4.3 SkeletonCircle

A circular shimmer placeholder (avatars, icons, thumbnails).

#### API

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `size` | `Dp` / `CGFloat` | **required** | Diameter of the circle |
| `modifier` / -- | `Modifier` / -- | `Modifier` / -- | Additional modifiers (Android only param) |

#### Visual Behavior

- Fill: `XGColors.skeleton` (#F1F5F9)
- Shape: `CircleShape` / `Circle()`
- Animation: `shimmerEffect(enabled: true)`

#### Pseudocode -- Android

```
@Composable
fun SkeletonCircle(
    size: Dp,
    modifier: Modifier = Modifier,
)
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(XGColors.Shimmer)
            .shimmerEffect()
    )
```

#### Pseudocode -- iOS

```
struct SkeletonCircle: View
    let size: CGFloat

    var body: some View
        Circle()
            .fill(XGColors.shimmer)
            .frame(width: size, height: size)
            .shimmerEffect()
```

---

### 4.4 Modifier.skeleton(visible:) / .skeleton(visible:content:)

A content-wrapping modifier that crossfades between a skeleton placeholder (when `visible = true`)
and the real content (when `visible = false`). This enables a single composable/view to declare
both its loaded and loading states in one place.

#### API -- Android

```
fun Modifier.skeleton(
    visible: Boolean,
    placeholder: @Composable () -> Unit,
): Modifier
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `visible` | `Boolean` | When `true`, shows the placeholder with crossfade. When `false`, shows content. |
| `placeholder` | `@Composable () -> Unit` | The skeleton layout to show during loading. |

#### API -- iOS

```
func skeleton<Placeholder: View>(
    visible: Bool,
    @ViewBuilder placeholder: () -> Placeholder
) -> some View
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `visible` | `Bool` | When `true`, shows the placeholder with crossfade. When `false`, shows content. |
| `placeholder` | `() -> Placeholder` | The skeleton layout to show during loading. |

#### Visual Behavior

- Transition: Crossfade animation using `XGMotion.Crossfade.CONTENT_SWITCH` (200ms)
- Android: `AnimatedContent` with `fadeIn + fadeOut` using `tween(XGMotion.Crossfade.CONTENT_SWITCH)`
- iOS: `.transition(.opacity)` with `.animation(.easeInOut(duration: XGMotion.Crossfade.contentSwitch))`
- The crossfade is keyed on the `visible` boolean, not on content changes

#### Pseudocode -- Android

```
@Composable
fun Modifier.skeleton(
    visible: Boolean,
    placeholder: @Composable () -> Unit,
): Modifier
    // Implementation uses AnimatedContent at the call site level.
    // This is provided as a composable wrapper, not a true Modifier.
    // See XGSkeleton composable below.
```

Because Compose modifiers cannot host `@Composable` content, the actual implementation is a
**wrapper composable** named `XGSkeleton`:

```
@Composable
fun XGSkeleton(
    visible: Boolean,
    placeholder: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
)
    AnimatedContent(
        targetState = visible,
        modifier = modifier,
        transitionSpec = {
            fadeIn(tween(XGMotion.Crossfade.CONTENT_SWITCH)) togetherWith
                fadeOut(tween(XGMotion.Crossfade.CONTENT_SWITCH))
        },
        label = "skeletonCrossfade",
    ) { isLoading ->
        if (isLoading) placeholder() else content()
    }
```

#### Pseudocode -- iOS

On iOS, this is implemented as a `View` extension using a `ViewModifier`:

```
struct SkeletonModifier<Placeholder: View>: ViewModifier
    let visible: Bool
    let placeholder: Placeholder

    func body(content: Content) -> some View
        if visible
            placeholder
                .transition(.opacity)
        else
            content
                .transition(.opacity)
        // .animation(.easeInOut(duration: XGMotion.Crossfade.contentSwitch), value: visible)

extension View
    func skeleton<Placeholder: View>(
        visible: Bool,
        @ViewBuilder placeholder: () -> Placeholder
    ) -> some View
        modifier(SkeletonModifier(visible: visible, placeholder: placeholder()))
            .animation(.easeInOut(duration: XGMotion.Crossfade.contentSwitch), value: visible)
```

---

## 5. Existing Component Updates

No existing components need modification. The skeleton primitives are new additions that
complement the existing `ShimmerModifier` (which remains unchanged).

---

## 6. Screen Layout

Not applicable -- these are design system atoms, not screens. However, here is a **usage example**
showing how a screen would compose skeleton primitives into a loading layout.

### Example: Product Card Skeleton

```
-- Android --
@Composable
fun ProductCardSkeleton(modifier: Modifier = Modifier)
    Column(modifier = modifier, verticalArrangement = spacedBy(XGSpacing.SM))
        SkeletonBox(width = 170.dp, height = 170.dp)           // product image
        SkeletonLine(width = 140.dp)                             // product name
        SkeletonLine(width = 80.dp, height = 12.dp)             // price
        Row(horizontalArrangement = spacedBy(XGSpacing.XS))
            SkeletonCircle(size = 12.dp)                         // rating star
            SkeletonLine(width = 30.dp, height = 12.dp)         // rating text

-- iOS --
struct ProductCardSkeleton: View
    var body: some View
        VStack(alignment: .leading, spacing: XGSpacing.sm)
            SkeletonBox(width: 170, height: 170)
            SkeletonLine(width: 140)
            SkeletonLine(width: 80, height: 12)
            HStack(spacing: XGSpacing.xs)
                SkeletonCircle(size: 12)
                SkeletonLine(width: 30, height: 12)
```

### Example: Using XGSkeleton Wrapper

```
-- Android --
XGSkeleton(
    visible = uiState is Loading,
    placeholder = { ProductCardSkeleton() },
) {
    XGProductCard(product = uiState.product)
}

-- iOS --
XGProductCard(product: product)
    .skeleton(visible: isLoading) {
        ProductCardSkeleton()
    }
```

---

## 7. Screen States

Not applicable -- design system atoms do not have screen-level states.

---

## 8. Navigation

Not applicable -- no navigation involved.

---

## 9. Localization

### Accessibility Labels

| Key | English | Maltese | Turkish |
|-----|---------|---------|---------|
| `skeleton_loading_placeholder` | "Loading content" | "Qed jitghabba l-kontenut" | "Icerik yukleniyor" |

The accessibility label is applied to the skeleton container. Individual skeleton shapes are
marked as decorative (no semantics) since they are purely visual placeholders.

#### Android

```
// On each SkeletonBox/Line/Circle:
Modifier.semantics { /* no contentDescription -- decorative */ }

// On XGSkeleton wrapper when visible=true:
Modifier.semantics {
    contentDescription = stringResource(R.string.skeleton_loading_placeholder)
}
```

#### iOS

```
// On each SkeletonBox/Line/Circle:
.accessibilityHidden(true)

// On XGSkeleton wrapper when visible=true:
.accessibilityLabel(Text("skeleton_loading_placeholder", bundle: .main))
```

---

## 10. Accessibility

- All individual skeleton shapes (`SkeletonBox`, `SkeletonLine`, `SkeletonCircle`) are **decorative**
  and hidden from the accessibility tree.
- The `XGSkeleton` wrapper (or `.skeleton(visible:)` modifier) announces a single
  "Loading content" label to screen readers when `visible = true`.
- When `visible` transitions to `false`, the screen reader focus moves to the loaded content
  naturally via the crossfade -- no programmatic focus management needed.
- Shimmer animation respects `reduceMotion` / `UIAccessibility.isReduceMotionEnabled`:
  - The existing `ShimmerModifier` should check for reduced motion and disable animation if enabled.
  - When reduced motion is on, the skeleton shapes display a static `XGColors.skeleton` fill
    without the shimmer sweep. This is handled at the `shimmerEffect` modifier level, not in
    the skeleton components themselves.

---

## 11. File Manifest

### 11.1 Android

| # | File Path | Type | Description |
|---|-----------|------|-------------|
| 1 | `core/designsystem/component/Skeleton.kt` | NEW | `SkeletonBox`, `SkeletonLine`, `SkeletonCircle`, `XGSkeleton` composables + previews |

All four components live in a single file since they are small, closely related atoms.

**String Resources:**

| # | File | Key | Value |
|---|------|-----|-------|
| 1 | `res/values/strings.xml` | `skeleton_loading_placeholder` | `Loading content` |
| 2 | `res/values-mt/strings.xml` | `skeleton_loading_placeholder` | `Qed jitghabba l-kontenut` |
| 3 | `res/values-tr/strings.xml` | `skeleton_loading_placeholder` | `Icerik yukleniyor` |

### 11.2 iOS

| # | File Path | Type | Description |
|---|-----------|------|-------------|
| 1 | `Core/DesignSystem/Component/Skeleton.swift` | NEW | `SkeletonBox`, `SkeletonLine`, `SkeletonCircle`, `SkeletonModifier` (content wrapper) + previews |

All four components live in a single file since they are small, closely related atoms.

**Localization:**

| # | Key | English | Maltese | Turkish |
|---|-----|---------|---------|---------|
| 1 | `skeleton_loading_placeholder` | `Loading content` | `Qed jitghabba l-kontenut` | `Icerik yukleniyor` |

---

## 12. Platform-Specific Notes

### 12.1 Android

- **File location**: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/Skeleton.kt`
- **Package**: `com.xirigo.ecommerce.core.designsystem.component`
- Use `Box` with `Modifier.size().clip().background().shimmerEffect()` for all shapes.
- `SkeletonBox` corner radius uses `RoundedCornerShape(cornerRadius)`.
- `SkeletonCircle` uses `CircleShape`.
- `XGSkeleton` uses `AnimatedContent` with `fadeIn`/`fadeOut` transition spec.
- All `Dp` literal defaults must be extracted to `private val` constants at file top (per detekt rules).
- Each composable must have a `@Preview` annotation.
- The `XGSkeleton` composable must have the `label` parameter on `AnimatedContent` for tooling.
- No `@HiltViewModel` or DI needed -- these are pure UI components.

### 12.2 iOS

- **File location**: `ios/XiriGoEcommerce/Core/DesignSystem/Component/Skeleton.swift`
- Use SwiftUI shape views (`RoundedRectangle`, `Circle`) with `.fill()` and `.frame()`.
- `SkeletonModifier` is a `ViewModifier` struct. The `.skeleton(visible:placeholder:)` extension
  applies it and chains `.animation()` for the crossfade.
- Use `PreviewConstants` private enum pattern for preview magic numbers (matching existing conventions).
- All structs are implicitly `Sendable` since they contain only value types.
- Use `#Preview` macro for previews (not the deprecated `PreviewProvider` protocol).
- Mark `SkeletonModifier` with `// MARK: -` section headers per SwiftLint conventions.

---

## 13. Verification Criteria

### Functional

| # | Criterion | How to Verify |
|---|-----------|---------------|
| 1 | `SkeletonBox` renders with correct dimensions | Preview with various width/height values |
| 2 | `SkeletonBox` corner radius defaults to `XGCornerRadius.Medium` (10dp) | Preview -- visually inspect rounded corners |
| 3 | `SkeletonBox` corner radius is configurable | Pass `XGCornerRadius.Large` and verify corners |
| 4 | `SkeletonLine` renders with correct width and default height (14dp) | Preview -- measure rendered output |
| 5 | `SkeletonLine` always uses `XGCornerRadius.Small` (6dp) | Preview -- visually inspect small corner radius |
| 6 | `SkeletonCircle` renders as a perfect circle | Preview with equal width/height |
| 7 | All shapes use `XGColors.skeleton` (#F1F5F9) background | Preview -- verify color matches token |
| 8 | All shapes display animated shimmer gradient sweep | Run on device/simulator -- verify animation plays |
| 9 | Shimmer animation uses correct tokens (1200ms, 20 deg, gradient colors) | Code review against `XGMotion.Shimmer` |
| 10 | `XGSkeleton`/`.skeleton(visible:)` shows placeholder when `visible = true` | Toggle state in preview/test |
| 11 | `XGSkeleton`/`.skeleton(visible:)` shows content when `visible = false` | Toggle state in preview/test |
| 12 | Crossfade uses `XGMotion.Crossfade.CONTENT_SWITCH` (200ms) duration | Code review |

### Accessibility

| # | Criterion | How to Verify |
|---|-----------|---------------|
| 13 | Individual shapes are hidden from accessibility tree | TalkBack/VoiceOver does not announce them |
| 14 | `XGSkeleton` wrapper announces "Loading content" when visible | TalkBack/VoiceOver reads the label |

### Code Quality

| # | Criterion | How to Verify |
|---|-----------|---------------|
| 15 | No hardcoded color values -- all from `XGColors` | Code review |
| 16 | No hardcoded dimensions in component body -- all from tokens or params | Code review |
| 17 | No hardcoded animation values -- all from `XGMotion` | Code review |
| 18 | All composables/views have `@Preview` / `#Preview` | Code review |
| 19 | No raw Material 3 / SwiftUI usage beyond the design system file | Code review |
| 20 | Android: detekt passes with zero violations | `./gradlew detekt` |
| 21 | iOS: SwiftLint passes with zero violations | `swiftlint lint` |
| 22 | Android: builds successfully | `./gradlew assembleDebug` |
| 23 | iOS: builds successfully | Xcode build |

---

## 14. Design Token File

A new component token file should be created for documentation and tooling purposes:

**Path**: `shared/design-tokens/components/atoms/xg-skeleton.json`

```json
{
  "component": "XGSkeleton",
  "category": "atoms",
  "description": "Skeleton loading placeholder primitives",
  "variants": {
    "SkeletonBox": {
      "params": {
        "width": { "type": "dimension", "required": true },
        "height": { "type": "dimension", "required": true },
        "cornerRadius": { "type": "dimension", "default": "$foundations/spacing.cornerRadius.medium" }
      },
      "fill": "$foundations/colors.semantic.shimmer",
      "animation": "$foundations/motion.shimmer"
    },
    "SkeletonLine": {
      "params": {
        "width": { "type": "dimension", "required": true },
        "height": { "type": "dimension", "default": 14 }
      },
      "cornerRadius": "$foundations/spacing.cornerRadius.small",
      "fill": "$foundations/colors.semantic.shimmer",
      "animation": "$foundations/motion.shimmer"
    },
    "SkeletonCircle": {
      "params": {
        "size": { "type": "dimension", "required": true }
      },
      "shape": "circle",
      "fill": "$foundations/colors.semantic.shimmer",
      "animation": "$foundations/motion.shimmer"
    }
  },
  "wrapper": {
    "XGSkeleton": {
      "description": "Crossfade wrapper between skeleton placeholder and real content",
      "params": {
        "visible": { "type": "boolean", "required": true },
        "placeholder": { "type": "slot", "required": true }
      },
      "transition": {
        "type": "crossfade",
        "duration": "$foundations/motion.crossfade.contentSwitch"
      }
    }
  },
  "accessibility": {
    "shapes": "decorative, hidden from accessibility tree",
    "wrapper": {
      "loadingLabel": "skeleton_loading_placeholder"
    }
  }
}
```
