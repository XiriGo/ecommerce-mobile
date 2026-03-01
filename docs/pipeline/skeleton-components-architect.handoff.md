# Handoff: skeleton-components -- Architect

## Feature
**DQ-05: Skeleton Base Components** -- Three reusable skeleton loading-placeholder primitives (`SkeletonBox`, `SkeletonLine`, `SkeletonCircle`) and a content-wrapping crossfade composable/modifier (`XGSkeleton` / `.skeleton(visible:)`) for the XiriGo design system.

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/skeleton-components.md` |
| This Handoff | `docs/pipeline/skeleton-components-architect.handoff.md` |

## Summary of Spec

The spec defines four design-system-level atoms that live in `core/designsystem/component/`. These are infrastructure primitives -- not a user-facing screen.

### Components

1. **SkeletonBox(width, height, cornerRadius)** -- Rectangular shimmer placeholder. Default corner radius: `XGCornerRadius.Medium` (10dp). Background: `XGColors.skeleton` (#F1F5F9). Animated via existing `shimmerEffect()` modifier.

2. **SkeletonLine(width, height)** -- Text-line shimmer placeholder. Fixed corner radius: `XGCornerRadius.Small` (6dp). Default height: 14dp (approximates bodyMedium line height). Same background and animation as SkeletonBox.

3. **SkeletonCircle(size)** -- Circular shimmer placeholder (for avatars, icons). Uses `CircleShape` / `Circle()`. Same background and animation.

4. **XGSkeleton(visible, placeholder, content)** (Android) / **.skeleton(visible:placeholder:)** (iOS) -- Content wrapper that crossfades between a skeleton placeholder layout and real content using `XGMotion.Crossfade.CONTENT_SWITCH` (200ms). Android uses `AnimatedContent` with `fadeIn`/`fadeOut`. iOS uses a `ViewModifier` with `.animation(.easeInOut)`.

### Implementation Details

- **Single file per platform**: All four components in `Skeleton.kt` (Android) / `Skeleton.swift` (iOS)
- **No new dependencies**: Uses only existing `ShimmerModifier`, `XGColors`, `XGCornerRadius`, `XGMotion`
- **No domain/data layer**: Pure UI components with zero architecture overhead
- **Accessibility**: Individual shapes are decorative (hidden from a11y tree). The `XGSkeleton` wrapper announces "Loading content" via localized string `skeleton_loading_placeholder`

### Token References

| Token | Value | Platform API |
|-------|-------|-------------|
| Background | #F1F5F9 | `XGColors.Shimmer` / `XGColors.shimmer` |
| Shimmer duration | 1200ms | `XGMotion.Shimmer.DURATION_MS` / `.duration` |
| Shimmer angle | 20 deg | `XGMotion.Shimmer.ANGLE_DEGREES` / `.angleDegrees` |
| Crossfade duration | 200ms | `XGMotion.Crossfade.CONTENT_SWITCH` / `.contentSwitch` |
| Corner (box default) | 10dp | `XGCornerRadius.Medium` / `.medium` |
| Corner (line fixed) | 6dp | `XGCornerRadius.Small` / `.small` |
| Line default height | 14dp | Constant in file |

## Key Decisions

1. **All components in a single file**: `SkeletonBox`, `SkeletonLine`, `SkeletonCircle`, and `XGSkeleton` are small, tightly related atoms. A single file reduces navigation overhead and keeps the design system directory clean.

2. **`SkeletonLine` corner radius is NOT configurable**: Fixed at `XGCornerRadius.Small` to enforce visual consistency for text-line placeholders app-wide. Use `SkeletonBox` if a different radius is needed.

3. **`XGSkeleton` is a composable wrapper, not a true `Modifier`** (Android): Compose modifiers cannot host `@Composable` content. The API is a `@Composable` function with `placeholder` and `content` slots. On iOS, it works as a proper `ViewModifier` since SwiftUI supports `@ViewBuilder` in modifiers.

4. **Default line height of 14dp**: Chosen to approximate `bodyMedium` typography line height, making `SkeletonLine(width: X)` immediately usable without specifying height for most text placeholders.

5. **Accessibility on wrapper, not shapes**: Individual skeleton shapes are decorative and hidden from the a11y tree. Only the `XGSkeleton` wrapper announces "Loading content" to avoid noisy screen reader output for layouts with many skeleton shapes.

6. **No reduced-motion handling in skeleton components**: The existing `ShimmerModifier` is responsible for respecting reduced-motion preferences. Skeleton components delegate to it and do not duplicate that concern.

7. **New design token file**: `shared/design-tokens/components/atoms/xg-skeleton.json` documents the component API in the token format for tooling consistency.

## Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Dev | File manifest (section 11.1), component APIs (section 4), pseudocode (Android blocks), platform notes (section 12.1), verification criteria (section 13) |
| iOS Dev | File manifest (section 11.2), component APIs (section 4), pseudocode (iOS blocks), platform notes (section 12.2), verification criteria (section 13) |

## Verification

Downstream developers should verify their implementation using the criteria in spec section 13 (23 criteria covering functional, accessibility, and code quality).

## Notes for Next Features

- **Screen-specific skeletons** (e.g., `HomeSkeletonScreen`, `ProductListSkeleton`): These will compose `SkeletonBox`, `SkeletonLine`, and `SkeletonCircle` into screen-shaped layouts. Each feature's spec should define its own skeleton layout using these primitives.
- **Component-level skeletons** (e.g., `XGProductCard.skeleton()`): Future specs may add `.skeleton()` static factory methods or companion composables to existing design system components. These will internally use the primitives from this spec.
- **Dark mode**: The `XGColors.skeleton` token currently only has a light-mode value. When dark-mode tokens are added, the skeleton components will automatically pick up the new color through the theme system -- no code changes needed.
