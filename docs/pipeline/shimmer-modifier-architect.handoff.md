# Handoff: shimmer-modifier -- Architect

## Feature
**DQ-03/04: Shimmer Effect Modifier** -- Animated gradient sweep modifier for loading placeholders, implemented as a design system primitive on both Android and iOS.

## Status
COMPLETE (retroactive spec -- code already implemented and merged)

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/shimmer-modifier.md` |
| This Handoff | `docs/pipeline/shimmer-modifier-architect.handoff.md` |

## Summary of Spec

The shimmer-modifier spec documents a loading placeholder animation applied via a single modifier call on both platforms.

### API

- **Android**: `Modifier.shimmerEffect(enabled: Boolean = true)` -- Compose modifier extension
- **iOS**: `View.shimmerEffect(active: Bool = true)` -- SwiftUI ViewModifier extension

### Animation Parameters (from `XGMotion.Shimmer` tokens)

- **Duration**: 1200ms (1.2s)
- **Angle**: 20 degrees
- **Colors**: `#E0E0E0` -> `#F5F5F5` -> `#E0E0E0` (gray-white-gray sweep)
- **Repeat**: Restart from left (no reverse)
- **Easing**: Linear

### Rendering Approach

| Platform | Technique |
|----------|-----------|
| Android | `graphicsLayer { }` + `drawWithContent` + `drawRect` with translating `Brush.linearGradient` |
| iOS | `.overlay(LinearGradient)` + `.mask(content)` with `@State phase` offset animation |

Both approaches are GPU-accelerated and avoid expensive layout/recomposition per frame.

### Files

| Platform | File | Purpose |
|----------|------|---------|
| Android | `android/.../core/designsystem/component/ShimmerModifier.kt` | Modifier extension |
| Android | `android/.../core/designsystem/theme/XGMotion.kt` | Motion tokens (Shimmer object) |
| iOS | `ios/.../Core/DesignSystem/Component/ShimmerModifier.swift` | ViewModifier + View extension |
| iOS | `ios/.../Core/DesignSystem/Theme/XGMotion.swift` | Motion tokens (Shimmer enum) |

## Key Decisions

1. **Modifier extension, not a wrapper component**: The shimmer is applied via `Modifier.shimmerEffect()` / `.shimmerEffect()` rather than a dedicated `XGShimmerView` component. This allows any view shape to be shimmer-animated without nesting.

2. **Linear easing over standard easing**: Linear easing provides a constant-speed sweep that looks natural for loading indicators. Standard ease-in-out would create an undesirable acceleration/deceleration pattern.

3. **Three-color gradient (not two)**: The `#E0E0E0 -> #F5F5F5 -> #E0E0E0` pattern creates a centered highlight band that sweeps across, rather than a simple edge-to-edge fade. This matches established shimmer patterns (Facebook, YouTube).

4. **GPU acceleration explicit on Android**: `graphicsLayer { }` is applied before `drawWithContent` to ensure hardware layer promotion. On iOS, SwiftUI handles layer promotion implicitly for offset animations.

5. **Different rendering strategies, same visual result**: Android uses `drawWithContent` for direct canvas control. iOS uses `.overlay` + `.mask` for shape-aware rendering. Both produce visually identical output.

6. **Parameter naming follows platform convention**: `enabled` (Android/Compose convention) vs `active` (iOS/SwiftUI convention). The function name `shimmerEffect` is identical.

7. **No dark mode variant (yet)**: The current gradient colors are fixed. Dark mode shimmer colors would require extending `XGMotion.Shimmer` tokens with theme-aware variants. This is out of scope for the current implementation.

## Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Tester | Verification criteria (spec section 11), API surface (section 2), usage patterns (section 7) |
| iOS Tester | Verification criteria (spec section 11), API surface (section 2), usage patterns (section 7) |
| Doc Writer | Feature overview, API documentation, cross-platform parity table (section 8) |
| Reviewer | All sections, especially performance (section 6) and code quality criteria (section 11) |

## Verification

Testers should verify using the criteria in spec section 11 (Verification Criteria), covering functional correctness, performance, code quality, and cross-platform parity.

## Notes for Next Features

- **Skeleton Components**: Will compose `shimmerEffect()` on placeholder shapes (rectangles, circles, rounded rects) to build full skeleton screens for product cards, lists, etc.
- **XGImage loading state**: Already uses shimmer via `XGMotion.Shimmer` tokens for the image loading placeholder.
- **Dark mode**: When dark mode is implemented, extend `XGMotion.Shimmer.gradientColors` to return theme-appropriate colors (e.g., `#2A2A2A -> #3A3A3A -> #2A2A2A`).
