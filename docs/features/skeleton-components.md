# Skeleton Components

## Overview

Skeleton components are design-system-level loading placeholder primitives for the XiriGo Ecommerce app. They provide three reusable shapes — `SkeletonBox`, `SkeletonLine`, `SkeletonCircle` — and a content-wrapping crossfade mechanism (`XGSkeleton` on Android, `.skeleton(visible:placeholder:)` on iOS) that transitions between a placeholder layout and real content.

These are infrastructure atoms, not user-facing screens. Every loading state in the app composes skeleton layouts from these primitives instead of reimplementing shimmer plumbing.

**Status**: Complete
**Phase**: M0 (Foundation) — DQ backfill
**Issues**: DQ-05 (Android), DQ-06 (iOS)
**Platforms**: Android (Kotlin + Jetpack Compose) + iOS (Swift + SwiftUI)
**Design token source**: `shared/design-tokens/components/atoms/xg-skeleton.json`

---

## File Locations

| Platform | File | Layer |
|----------|------|-------|
| Android | `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/Skeleton.kt` | Design System / Component |
| iOS | `ios/XiriGoEcommerce/Core/DesignSystem/Component/Skeleton.swift` | Design System / Component |
| Token file | `shared/design-tokens/components/atoms/xg-skeleton.json` | Shared |

### Modified Files

| Platform | File | Change |
|----------|------|--------|
| Android | `android/app/src/main/res/values/strings.xml` | Added `skeleton_loading_placeholder` |
| Android | `android/app/src/main/res/values-mt/strings.xml` | Maltese translation |
| Android | `android/app/src/main/res/values-tr/strings.xml` | Turkish translation |
| iOS | `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` | Added `skeleton_loading_placeholder` (EN, MT, TR) |
| iOS | `ios/XiriGoEcommerce.xcodeproj/project.pbxproj` | File references for `Skeleton.swift` |

---

## Architecture

These components live exclusively in the design system layer (`core/designsystem/component/`). They have no domain or data layer dependencies.

```
SkeletonBox / SkeletonLine / SkeletonCircle
    |
    +-- XGColors.Shimmer / XGColors.shimmer   (fill color: #F1F5F9)
    +-- XGCornerRadius.*                       (shape)
    +-- shimmerEffect()                        (animation)
            |
            +-- XGMotion.Shimmer.*             (duration, angle, gradient colors)

XGSkeleton (Android) / .skeleton(visible:) (iOS)
    |
    +-- XGMotion.Crossfade.CONTENT_SWITCH / .contentSwitch   (200ms / 0.2s)
    +-- Any skeleton composable/view (placeholder slot)
```

---

## Components

### SkeletonBox

Rectangular shimmer placeholder with configurable dimensions and corner radius.

#### Android API

```kotlin
@Composable
fun SkeletonBox(
    width: Dp,
    height: Dp,
    modifier: Modifier = Modifier,
    cornerRadius: Dp = XGCornerRadius.Medium,  // 10dp
)
```

#### iOS API

```swift
struct SkeletonBox: View {
    init(
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat = XGCornerRadius.medium,  // 10pt
    )
}
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `Dp` / `CGFloat` | required | Width of the placeholder rectangle |
| `height` | `Dp` / `CGFloat` | required | Height of the placeholder rectangle |
| `cornerRadius` | `Dp` / `CGFloat` | `XGCornerRadius.Medium` / `.medium` (10) | Corner radius; pass any `XGCornerRadius` value to override |

**Visual behavior**: Fills with `XGColors.Shimmer` (#F1F5F9), clips to `RoundedCornerShape` / `RoundedRectangle`, applies `shimmerEffect()`.

---

### SkeletonLine

Text-line shimmer placeholder. Corner radius is fixed at `XGCornerRadius.Small` (6pt) — not configurable — enforcing visual consistency for text-line placeholders app-wide.

#### Android API

```kotlin
@Composable
fun SkeletonLine(
    width: Dp,
    modifier: Modifier = Modifier,
    height: Dp = 14.dp,  // approximates bodyMedium line height
)
```

#### iOS API

```swift
struct SkeletonLine: View {
    init(
        width: CGFloat,
        height: CGFloat = SkeletonConstants.lineDefaultHeight,  // 14pt
    )
}
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `Dp` / `CGFloat` | required | Width of the text-line placeholder |
| `height` | `Dp` / `CGFloat` | 14 | Height; defaults to approximate `bodyMedium` line height |

**Visual behavior**: Fills with `XGColors.Shimmer` (#F1F5F9), clips to `RoundedCornerShape(XGCornerRadius.Small)` / `RoundedRectangle(cornerRadius: XGCornerRadius.small)`, applies `shimmerEffect()`.

**Note**: Corner radius is hardcoded to `XGCornerRadius.Small` / `.small` (6pt). Use `SkeletonBox` if a different radius is needed.

---

### SkeletonCircle

Circular shimmer placeholder for avatars, icons, and thumbnails.

#### Android API

```kotlin
@Composable
fun SkeletonCircle(
    size: Dp,
    modifier: Modifier = Modifier,
)
```

#### iOS API

```swift
struct SkeletonCircle: View {
    let size: CGFloat
}
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `size` | `Dp` / `CGFloat` | required | Diameter of the circle |

**Visual behavior**: Fills with `XGColors.Shimmer` (#F1F5F9), clips to `CircleShape` / `Circle()`, applies `shimmerEffect()`.

---

### XGSkeleton (Android) / .skeleton(visible:placeholder:) (iOS)

Content-wrapping mechanism that crossfades between a skeleton placeholder layout and real content.

#### Android API

```kotlin
@Composable
fun XGSkeleton(
    visible: Boolean,
    placeholder: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
)
```

Android uses `AnimatedContent` with `fadeIn` / `fadeOut` transition spec. Cannot be a true `Modifier` because Compose modifiers cannot host `@Composable` content.

#### iOS API

```swift
extension View {
    func skeleton(
        visible: Bool,
        @ViewBuilder placeholder: () -> some View,
    ) -> some View
}
```

iOS uses `SkeletonModifier` (a `ViewModifier` struct) with `.transition(.opacity)` and `.animation(.easeInOut(duration:), value: visible)`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `visible` | `Boolean` / `Bool` | When `true`, shows placeholder. When `false`, shows real content with crossfade. |
| `placeholder` | composable / `@ViewBuilder` closure | The skeleton layout to display during loading. |

**Crossfade duration**: `XGMotion.Crossfade.CONTENT_SWITCH` / `.contentSwitch` — 200ms / 0.2s.

---

## Design Tokens

| Token | Android | iOS | Value | Used By |
|-------|---------|-----|-------|---------|
| Skeleton fill color | `XGColors.Shimmer` | `XGColors.shimmer` | #F1F5F9 | All three shapes |
| Box default corner radius | `XGCornerRadius.Medium` | `XGCornerRadius.medium` | 10dp / 10pt | SkeletonBox default |
| Line fixed corner radius | `XGCornerRadius.Small` | `XGCornerRadius.small` | 6dp / 6pt | SkeletonLine (non-configurable) |
| Line default height | `SkeletonLineDefaultHeight` | `SkeletonConstants.lineDefaultHeight` | 14dp / 14pt | SkeletonLine default height |
| Shimmer duration | `XGMotion.Shimmer.DURATION_MS` | `XGMotion.Shimmer.duration` | 1200ms / 1.2s | shimmerEffect() |
| Shimmer angle | `XGMotion.Shimmer.ANGLE_DEGREES` | `XGMotion.Shimmer.angleDegrees` | 20 degrees | shimmerEffect() |
| Crossfade duration | `XGMotion.Crossfade.CONTENT_SWITCH` | `XGMotion.Crossfade.contentSwitch` | 200ms / 0.2s | XGSkeleton / .skeleton() |

---

## Usage Examples

### Composing a product card skeleton

**Android**:

```kotlin
Column(verticalArrangement = Arrangement.spacedBy(XGSpacing.SM)) {
    SkeletonBox(width = 170.dp, height = 170.dp)           // product image
    SkeletonLine(width = 140.dp)                            // product name (default 14dp height)
    SkeletonLine(width = 80.dp, height = 12.dp)            // price
    Row(horizontalArrangement = Arrangement.spacedBy(XGSpacing.XS)) {
        SkeletonCircle(size = 12.dp)                        // rating star
        SkeletonLine(width = 30.dp, height = 12.dp)        // rating text
    }
}
```

**iOS**:

```swift
VStack(alignment: .leading, spacing: XGSpacing.sm) {
    SkeletonBox(width: 170, height: 170)
    SkeletonLine(width: 140)
    SkeletonLine(width: 80, height: 12)
    HStack(spacing: XGSpacing.xs) {
        SkeletonCircle(size: 12)
        SkeletonLine(width: 30, height: 12)
    }
}
```

### Crossfade between skeleton and content

**Android**:

```kotlin
XGSkeleton(
    visible = uiState is HomeUiState.Loading,
    placeholder = { ProductCardSkeleton() },
) {
    XGProductCard(product = uiState.product)
}
```

**iOS**:

```swift
XGProductCard(product: product)
    .skeleton(visible: isLoading) {
        ProductCardSkeleton()
    }
```

---

## Accessibility

Individual skeleton shapes (`SkeletonBox`, `SkeletonLine`, `SkeletonCircle`) are decorative and hidden from the accessibility tree.

| Platform | Shape annotation | Wrapper annotation |
|----------|-----------------|-------------------|
| Android | No `contentDescription` (omitted from semantics) | `Modifier.semantics { contentDescription = "Loading content" }` when `visible = true` |
| iOS | `.accessibilityHidden(true)` | `.accessibilityLabel(Text("skeleton_loading_placeholder"))` when `visible = true` |

**Localized string**: `skeleton_loading_placeholder`

| Language | Value |
|----------|-------|
| English (en) | "Loading content" |
| Maltese (mt) | "Qed jitghabba l-kontenut" |
| Turkish (tr) | "Icerik yukleniyor" |

**Reduced motion**: The shimmer animation is disabled when the system reduced motion setting is active. This is handled by the existing `shimmerEffect()` modifier — skeleton components do not duplicate that logic.

---

## Previews

Both platforms ship 5 preview scenes:

| Preview | Content |
|---------|---------|
| SkeletonBox | Box with default corner radius + box with `XGCornerRadius.Large` |
| SkeletonLine | Line with default height + line with 12dp/pt height |
| SkeletonCircle | Circle at 48dp/pt + circle at 12dp/pt |
| Product Card Skeleton | Composed layout (box + two lines + circle + line) |
| Skeleton Crossfade | Interactive toggle demo (`XGSkeleton` / `.skeleton()`) |

Android previews use `@Preview(showBackground = true)` wrapped in `XGTheme { }`.
iOS previews use the `#Preview` macro with `.xgTheme()`.

---

## Tests

### Android

No dedicated unit test file for skeleton components — behavior is validated via Android instrumented previews and the design token contract tests in `XGMotionTest.kt`. The `XGMotion.Crossfade.CONTENT_SWITCH` value used by `XGSkeleton` is covered by existing motion token tests.

### iOS

**Test file**: `ios/XiriGoEcommerceTests/Core/DesignSystem/Component/SkeletonTests.swift`

**Framework**: Swift Testing (`@Test` macro, `@Suite`, `#expect`)

**Total test methods**: 37 across 7 suites

| Suite | Test count | What is verified |
|-------|-----------|-----------------|
| `SkeletonBoxTests` | 9 | `width`, `height`, `cornerRadius` init storage; default equals `XGCornerRadius.medium` (10); custom radii (`large` 16, `small` 6, zero); fractional dimensions; instance independence |
| `SkeletonLineTests` | 6 | `width` storage; default `height` equals 14; custom height; both stored when explicit; instance independence |
| `SkeletonCircleTests` | 4 | `size` storage for avatar (48), small (12), and independence |
| `SkeletonModifierTests` | 7 | `visible = true/false` init; distinct values; crossfade duration equals `XGMotion.Crossfade.contentSwitch` (0.2s) and `XGMotion.Duration.fast` |
| `SkeletonViewExtensionTests` | 3 | `.skeleton(visible:)` produces modifier with correct `visible` flag; crossfade uses 0.2s |
| `SkeletonDesignTokenContractTests` | 6 | `XGCornerRadius.medium == 10`, `.small == 6`, `.large == 16`, `contentSwitch == 0.2`; ordering invariants |
| `SkeletonCompositionTests` | 2 | Product card skeleton layout matches handoff spec dimensions; avatar and rating circle sizes |

SwiftUI body tests are disabled (require runtime environment) — these are covered by UI tests.

**Run tests**:

```bash
xcodebuild test \
  -project ios/XiriGoEcommerce.xcodeproj \
  -scheme XiriGoEcommerce \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:XiriGoEcommerceTests/SkeletonBoxTests \
  -only-testing:XiriGoEcommerceTests/SkeletonLineTests \
  -only-testing:XiriGoEcommerceTests/SkeletonCircleTests \
  -only-testing:XiriGoEcommerceTests/SkeletonModifierTests \
  -only-testing:XiriGoEcommerceTests/SkeletonViewExtensionTests \
  -only-testing:XiriGoEcommerceTests/SkeletonDesignTokenContractTests \
  -only-testing:XiriGoEcommerceTests/SkeletonCompositionTests
```

---

## Cross-Platform Parity

| Aspect | Android | iOS |
|--------|---------|-----|
| SkeletonBox type | `@Composable` function | `struct` conforming to `View` |
| SkeletonLine type | `@Composable` function | `struct` conforming to `View` |
| SkeletonCircle type | `@Composable` function | `struct` conforming to `View` |
| Crossfade wrapper | `XGSkeleton { }` composable | `.skeleton(visible:placeholder:)` ViewModifier extension |
| Crossfade mechanism | `AnimatedContent` with `fadeIn`/`fadeOut` | `SkeletonModifier` with `.transition(.opacity)` + `.animation()` |
| Crossfade duration | `XGMotion.Crossfade.CONTENT_SWITCH` (200ms) | `XGMotion.Crossfade.contentSwitch` (0.2s) |
| Fill color token | `XGColors.Shimmer` | `XGColors.shimmer` |
| Box default radius token | `XGCornerRadius.Medium` | `XGCornerRadius.medium` |
| Line fixed radius token | `XGCornerRadius.Small` | `XGCornerRadius.small` |
| Line default height | `SkeletonLineDefaultHeight = 14.dp` | `SkeletonConstants.lineDefaultHeight = 14` |
| Accessibility (shapes) | No `contentDescription` | `.accessibilityHidden(true)` |
| Accessibility (wrapper) | `semantics { contentDescription }` | `.accessibilityLabel(Text(...))` |
| Preview macro | `@Preview` | `#Preview` |
| Preview count | 5 | 5 |

---

## Related Documentation

- [Motion Tokens](./motion-tokens.md) — `XGMotion` token reference (crossfade and shimmer token source)
- [Shimmer Modifier](./shimmer-modifier.md) — `shimmerEffect()` modifier consumed by all skeleton shapes
