# Handoff: motion-tokens -- Architect

## Feature
**DQ-01 / DQ-02: Motion Tokens** -- Centralized animation, transition, shimmer, scroll, and performance budget constants for the XiriGo design system, surfaced as `XGMotion` on both platforms.

## Status
COMPLETE (retroactive spec -- code already implemented and merged)

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/motion-tokens.md` |
| This Handoff | `docs/pipeline/motion-tokens-architect.handoff.md` |

## Summary of Spec

The motion-tokens spec documents the `XGMotion` constant namespace that lives in the design system theme layer alongside `XGColors`, `XGTypography`, and `XGSpacing`.

### Token Categories (7 total)

1. **Duration** -- 5 timing constants (instant 100ms, fast 200ms, normal 300ms, slow 450ms, pageTransition 350ms).
2. **Easing** -- 4 curve/spring specs (standard, decelerate, accelerate, spring). Android exposes generic factory functions returning `AnimationSpec<T>`; iOS exposes `Animation` values.
3. **Shimmer** -- Gradient sweep parameters (3-color gradient, 20-degree angle, 1200ms cycle, restart repeat). Rule: all loading placeholders MUST use shimmer, never static color.
4. **Crossfade** -- 2 durations (imageFadeIn 300ms, contentSwitch 200ms).
5. **Scroll** -- Prefetch distance (5) and scroll restoration flag (true). Rule: all lists >4 items must use lazy rendering.
6. **EntranceAnimation** -- Staggered reveal parameters (50ms delay, max 8 items, fade 0-1, slide 20dp/pt). Rule: first load only, not pagination.
7. **Performance** -- Budget thresholds (16ms frame, 2s cold start, 300ms transition, 60 FPS scroll, 1s FCP). Reference constants for profiling.

### Source of Truth
`shared/design-tokens/foundations/motion.json` -- all values are mirrored in platform code.

### Implementation Files

| Platform | File |
|----------|------|
| Android | `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGMotion.kt` |
| iOS | `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGMotion.swift` |

## Key Decisions

1. **Theme layer, not component layer**: `XGMotion` sits in `core/designsystem/theme/` alongside color and typography tokens, not in `component/`. It defines values; components and screens consume them.

2. **No repository/use case/ViewModel**: This is a pure constant definition. No network, persistence, or state management is involved.

3. **imageLoading tokens excluded from XGMotion**: The JSON source file defines an `imageLoading` section (cache budgets, WebP, downsampling) but these are image-library configuration values, not motion tokens. They are consumed by Coil/Nuke setup code directly.

4. **Unit conventions differ by platform**: Android uses `Int` milliseconds and `Dp`; iOS uses `TimeInterval` (seconds) and `CGFloat`. Both represent the same values from the JSON source.

5. **Android easing as generic factories**: `XGMotion.Easing.standardTween<T>(durationMillis)` returns `AnimationSpec<T>`, allowing callers to specify the animated type. iOS uses `Animation` values composed with duration separately via SwiftUI modifiers.

6. **Spring parity**: Both platforms target the same spring behavior (damping 0.7). Android uses `Spring.StiffnessMedium`; iOS uses `response: 0.35` to achieve a comparable natural period.

7. **Preview included (Android only)**: `XGMotionTokenPreview` renders all token values for visual inspection in Android Studio. iOS does not require an equivalent since SwiftUI previews are not applicable to pure constant enums.

## Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Tester | Verification criteria (spec section 9), token completeness checks, value accuracy assertions |
| iOS Tester | Verification criteria (spec section 9), token completeness checks, value accuracy assertions |
| Doc Writer | Token categories (spec section 2), usage guidelines (spec section 5), cross-platform parity notes (spec section 6) |
| Reviewer | All sections; focus on value accuracy (section 9.2), API usability (section 9.3), and imageLoading exclusion rationale (section 6.4) |

## Verification

Downstream agents should verify using the criteria in spec section 9, covering:
- Token completeness against `motion.json`
- Value accuracy across JSON, Android, and iOS
- API usability (generic functions on Android, Animation values on iOS)
- Code quality (preview, lint, documentation)

## Notes for Next Features

- **Skeleton Components**: Will consume `XGMotion.Shimmer` tokens for shimmer animation parameters (gradient colors, duration, angle, repeat mode).
- **XGLoadingView**: Should reference `XGMotion.Shimmer` instead of any hardcoded shimmer values.
- **XGImage**: Should use `XGMotion.Crossfade.IMAGE_FADE_IN` for image load transitions.
- **Home Screen Sections**: Entrance animations should reference `XGMotion.EntranceAnimation` tokens.
- **Navigation Transitions**: Screen transitions should use `XGMotion.Duration.PAGE_TRANSITION` and `XGMotion.Easing.decelerate`/`accelerate` curves.
