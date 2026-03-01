# DQ-06 Skeleton Base Components (iOS) - Dev Handoff

## Status: COMPLETE

## What was implemented

### New file
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/Skeleton.swift`

### Modified files
- `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` (added `skeleton_loading_placeholder` key)
- `ios/XiriGoEcommerce.xcodeproj/project.pbxproj` (added Skeleton.swift file references)

### Summary
Four skeleton components for loading-state placeholders:

1. **SkeletonBox** -- Rectangular shimmer placeholder with configurable width, height, and corner radius (default `XGCornerRadius.medium`). Fill: `XGColors.shimmer`. Shape: `RoundedRectangle`.
2. **SkeletonLine** -- Text-line shimmer placeholder with configurable width and height (default 14pt). Corner radius fixed at `XGCornerRadius.small` (6pt), not configurable.
3. **SkeletonCircle** -- Circular shimmer placeholder with configurable size. Shape: `Circle()`.
4. **SkeletonModifier** -- Content-wrapping `ViewModifier` that crossfades between a skeleton placeholder and real content using `.transition(.opacity)` with `XGMotion.Crossfade.contentSwitch` duration (0.2s).

### API
```swift
// Rectangular placeholder
SkeletonBox(width: 170, height: 170)
SkeletonBox(width: 170, height: 170, cornerRadius: XGCornerRadius.large)

// Text-line placeholder
SkeletonLine(width: 140)
SkeletonLine(width: 80, height: 12)

// Circular placeholder
SkeletonCircle(size: 48)

// Crossfade modifier
Text("Loaded content")
    .skeleton(visible: isLoading) {
        SkeletonLine(width: 140)
    }
```

### Design tokens used (no hardcoded values)
- `XGColors.shimmer` -- `Color(hex: "#F1F5F9")` fill color
- `XGCornerRadius.small` -- 6pt (SkeletonLine fixed radius)
- `XGCornerRadius.medium` -- 10pt (SkeletonBox default radius)
- `XGCornerRadius.large` -- 16pt (available as override)
- `XGMotion.Crossfade.contentSwitch` -- 0.2s crossfade duration
- `XGSpacing.sm`, `XGSpacing.xs`, `XGSpacing.base` -- preview layout spacing

### Implementation details
- All three shape components apply `.shimmerEffect()` from `ShimmerModifier.swift`
- All shape components use `.accessibilityHidden(true)` (decorative)
- `SkeletonModifier` applies `.accessibilityLabel(Text("skeleton_loading_placeholder"))` when visible
- `SkeletonConstants` private enum for `lineDefaultHeight: CGFloat = 14`
- `PreviewConstants` private enum for all preview magic numbers
- `Text(verbatim:)` used for preview-only strings (developer-facing, not user-facing)

### Localization
- Key: `skeleton_loading_placeholder`
- EN: "Loading content"
- MT: "Qed jitghabba l-kontenut"
- TR: "Icerik yukleniyor"

### Previews (5 total)
1. **SkeletonBox** -- Box with default and large corner radius
2. **SkeletonLine** -- Line with default and small height
3. **SkeletonCircle** -- Circle with two sizes (48pt, 12pt)
4. **Product Card Skeleton** -- Composed layout mimicking a product card
5. **Skeleton Crossfade** -- Interactive crossfade demo with toggle button

### Android parity
Matches Android `Skeleton.kt` behavior:
- Same four components: `SkeletonBox`, `SkeletonLine`, `SkeletonCircle`, `XGSkeleton` (iOS: `.skeleton()` modifier)
- Same default line height (14pt)
- Same fixed small corner radius for SkeletonLine
- Same configurable corner radius for SkeletonBox with medium default
- Same crossfade animation using `XGMotion.Crossfade.contentSwitch`
- Same 5 previews (box, line, circle, product card, crossfade)
- Same preview constants for consistent visual comparison
- iOS uses `ViewModifier` extension pattern instead of wrapping composable

## Checklist
- [x] Uses `XGColors.shimmer` token (no hardcoded colors)
- [x] Uses `XGCornerRadius.*` tokens (no hardcoded corner radii)
- [x] Uses `XGMotion.Crossfade.contentSwitch` token (no hardcoded durations)
- [x] `.shimmerEffect()` applied to all skeleton shapes
- [x] `.accessibilityHidden(true)` on all decorative shapes
- [x] `.accessibilityLabel` on SkeletonModifier when visible
- [x] Localized string added to Localizable.xcstrings (EN, MT, TR)
- [x] `#Preview` macro used (not PreviewProvider)
- [x] `.xgTheme()` applied to all previews
- [x] `PreviewConstants` enum for magic numbers
- [x] `SkeletonConstants` enum for default values
- [x] No force unwrap (`!`)
- [x] No hardcoded `Color(hex:)` in components
- [x] MARK section headers throughout
- [x] Added to Xcode project (PBXBuildFile, PBXFileReference, PBXGroup, Sources)
- [x] Behavioral parity with Android implementation

## Files changed
1. `ios/XiriGoEcommerce/Core/DesignSystem/Component/Skeleton.swift` (NEW)
2. `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` (MODIFIED -- added key)
3. `ios/XiriGoEcommerce.xcodeproj/project.pbxproj` (MODIFIED -- added file references)
