# DQ-23: XGHeroBanner Upgrade -- Shimmer + Motion -- Feature Specification

## 1. Overview

This specification describes the upgrade of the `XGHeroBanner` molecule component to add
a `HeroBannerSkeleton` loading placeholder, centralize the auto-scroll interval as a motion
token, and verify that gradient overlay colors come from design tokens.

### Purpose

- Add `HeroBannerSkeleton` composable/view using skeleton primitives (`SkeletonBox`, `SkeletonLine`)
- Verify image loading shimmer is already handled by `XGImage` (DQ-07) -- no changes needed
- Verify gradient overlay colors reference `XGColors.BrandPrimary` from tokens -- no changes needed
- Add `XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS` (Android) / `XGMotion.Scroll.autoScrollInterval` (iOS)
- Update `HomeScreen` on both platforms to use the new motion token instead of hardcoded 5000ms/5s

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Add `HeroBannerSkeleton` to both platforms | XGHeroBanner layout changes |
| Add auto-scroll token to `XGMotion.Scroll` | XGImage loading changes (DQ-07) |
| Replace hardcoded auto-scroll constants in HomeScreen | Banner carousel logic changes |
| Update `xg-hero-banner.json` with skeleton reference | New animation types |
| Verify gradient overlay from tokens | Color token changes |

### Dependencies

- **DQ-03** (Shimmer Android) -- MERGED
- **DQ-04** (Shimmer iOS) -- MERGED
- **DQ-07** (XGImage upgrade) -- MERGED (image shimmer already works)

---

## 2. Current State

### 2.1 Android (`XGHeroBanner.kt`)

The component uses `XGImage` for background images (shimmer handled by XGImage).
Gradient overlay uses `XGColors.BrandPrimary` -- compliant.
No skeleton placeholder exists.

Auto-scroll is hardcoded in `HomeScreen.kt`:
```kotlin
private const val AUTO_SCROLL_DELAY_MS = 5000L
```

### 2.2 iOS (`XGHeroBanner.swift`)

The component uses `XGImage` for background images (shimmer handled by XGImage).
Gradient overlay uses `XGColors.brandPrimary` -- compliant.
No skeleton placeholder exists.

Auto-scroll is hardcoded in `HomeScreenSections.swift`:
```swift
static let autoScrollInterval: TimeInterval = 5
```

### 2.3 Token File (`xg-hero-banner.json`)

No skeleton reference exists. Needs `skeleton` section added.

### 2.4 Motion Token File (`motion.json`)

No `autoScroll` value exists in the `scroll` section. Needs to be added.

---

## 3. Required Changes

### 3.1 Motion Token (`foundations/motion.json`)

Add auto-scroll interval to the `scroll` section:
```json
"scroll": {
  "autoScrollIntervalMs": 5000,
  ...
}
```

### 3.2 Android `XGMotion.kt`

Add to `Scroll` object:
```kotlin
const val AUTO_SCROLL_INTERVAL_MS = 5000L // scroll.autoScrollIntervalMs
```

### 3.3 iOS `XGMotion.swift`

Add to `Scroll` enum:
```swift
static let autoScrollInterval: TimeInterval = 5.0
```

### 3.4 Android `HeroBannerSkeleton` (in `XGHeroBanner.kt`)

Add a `HeroBannerSkeleton` composable that mimics the banner layout:
- Full-width `SkeletonBox` at 192dp height with medium corner radius
- Overlaid `SkeletonLine` elements for tag badge, headline, and subtitle

```kotlin
@Composable
fun HeroBannerSkeleton(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(192.dp)
            .clip(RoundedCornerShape(XGCornerRadius.Medium)),
    ) {
        SkeletonBox(width = ..., height = 192.dp) // full background
        // Bottom-aligned text skeletons
        Column(...) {
            SkeletonLine(width = 120.dp) // headline
            SkeletonLine(width = 80.dp)  // subtitle
        }
    }
}
```

### 3.5 iOS `HeroBannerSkeleton` (in `XGHeroBanner.swift`)

Add a `HeroBannerSkeleton` view:
```swift
struct HeroBannerSkeleton: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SkeletonBox(width: .infinity, height: 192)
            // Bottom-aligned text skeletons
            VStack(alignment: .leading) {
                SkeletonLine(width: 120)
                SkeletonLine(width: 80)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
    }
}
```

### 3.6 Android `HomeScreen.kt`

Replace:
```kotlin
private const val AUTO_SCROLL_DELAY_MS = 5000L
```
With reference:
```kotlin
delay(XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS)
```

### 3.7 iOS `HomeScreenSections.swift`

Replace:
```swift
static let autoScrollInterval: TimeInterval = 5
```
With reference:
```swift
static let autoScrollInterval: TimeInterval = XGMotion.Scroll.autoScrollInterval
```

### 3.8 Token File (`xg-hero-banner.json`)

Add skeleton section:
```json
"skeleton": {
  "component": "HeroBannerSkeleton",
  "layout": "ZStack: [SkeletonBox(full), VStack(SkeletonLine x2)]",
  "background": "$atoms/xg-skeleton.SkeletonBox",
  "textLines": "$atoms/xg-skeleton.SkeletonLine",
  "autoScrollInterval": "$foundations/motion.scroll.autoScrollIntervalMs"
}
```

---

## 4. Verification Criteria

- [ ] `HeroBannerSkeleton` exists on Android with shimmer animation
- [ ] `HeroBannerSkeleton` exists on iOS with shimmer animation
- [ ] `XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS` exists on Android (5000L)
- [ ] `XGMotion.Scroll.autoScrollInterval` exists on iOS (5.0)
- [ ] Android `HomeScreen` uses `XGMotion.Scroll.AUTO_SCROLL_INTERVAL_MS`
- [ ] iOS `HomeScreenSections` uses `XGMotion.Scroll.autoScrollInterval`
- [ ] Gradient overlay on both platforms references `XGColors.BrandPrimary` (verified, no change)
- [ ] Image shimmer handled by `XGImage` (verified, no change)
- [ ] `xg-hero-banner.json` has skeleton section and autoScroll reference
- [ ] `motion.json` has `autoScrollIntervalMs` in scroll section
- [ ] Both platforms have Preview for `HeroBannerSkeleton`
- [ ] No force unwrap (`!!`/`!`) in either implementation
- [ ] All existing tests pass on both platforms

---

## 5. File Manifest

| File | Change Type | Platform |
|------|------------|----------|
| `shared/design-tokens/foundations/motion.json` | Modify | Shared |
| `shared/design-tokens/components/molecules/xg-hero-banner.json` | Modify | Shared |
| `android/.../core/designsystem/theme/XGMotion.kt` | Modify | Android |
| `android/.../core/designsystem/component/XGHeroBanner.kt` | Modify | Android |
| `android/.../feature/home/presentation/screen/HomeScreen.kt` | Modify | Android |
| `ios/.../Core/DesignSystem/Theme/XGMotion.swift` | Modify | iOS |
| `ios/.../Core/DesignSystem/Component/XGHeroBanner.swift` | Modify | iOS |
| `ios/.../Feature/Home/Presentation/Screen/HomeScreenSections.swift` | Modify | iOS |
