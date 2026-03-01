# DQ-02 Motion Tokens - iOS Dev Handoff

## Task
Create `XGMotion.swift` with all motion token constants from `shared/design-tokens/foundations/motion.json`, and replace hardcoded animation values in existing components.

## Files Created
- `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGMotion.swift` (new)

## Files Modified
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGImage.swift` - replaced hardcoded `0.25` duration with `XGMotion.Crossfade.imageFadeIn`
- `ios/XiriGoEcommerce/Core/DesignSystem/Component/XGPaginationDots.swift` - replaced hardcoded `.spring(response: 0.3, dampingFraction: 0.7)` with `XGMotion.Easing.spring`
- `ios/XiriGoEcommerce.xcodeproj/project.pbxproj` - added XGMotion.swift to project

## Token Mapping (motion.json to XGMotion.swift)

| JSON Path | Swift Constant | Value |
|-----------|---------------|-------|
| duration.instant | Duration.instant | 0.1s |
| duration.fast | Duration.fast | 0.2s |
| duration.normal | Duration.normal | 0.3s |
| duration.slow | Duration.slow | 0.45s |
| duration.pageTransition | Duration.pageTransition | 0.35s |
| easing.standard | Easing.standard | .easeInOut |
| easing.decelerate | Easing.decelerate | .easeOut |
| easing.accelerate | Easing.accelerate | .easeIn |
| easing.spring | Easing.spring | .spring(response: 0.35, dampingFraction: 0.7) |
| shimmer.durationMs | Shimmer.duration | 1.2s |
| shimmer.angleDegrees | Shimmer.angleDegrees | 20 |
| shimmer.gradientColors | Shimmer.gradientColors | [#E0E0E0, #F5F5F5, #E0E0E0] |
| crossfade.imageFadeIn | Crossfade.imageFadeIn | 0.3s |
| crossfade.contentSwitch | Crossfade.contentSwitch | 0.2s |
| scroll.prefetchDistance | Scroll.prefetchDistance | 5 |
| scroll.scrollRestorationEnabled | Scroll.scrollRestorationEnabled | true |
| entranceAnimation.staggerDelayMs | EntranceAnimation.staggerDelay | 0.05s |
| entranceAnimation.maxStaggerItems | EntranceAnimation.maxStaggerItems | 8 |
| entranceAnimation.fadeFromOpacity | EntranceAnimation.fadeFrom | 0 |
| entranceAnimation.fadeToOpacity | EntranceAnimation.fadeTo | 1 |
| entranceAnimation.slideOffsetY | EntranceAnimation.slideOffsetY | 20 |
| performanceBudgets.frameTimeMs | Performance.frameTime | 0.016s |
| performanceBudgets.startupColdMs | Performance.startupCold | 2.0s |
| performanceBudgets.screenTransitionMs | Performance.screenTransition | 0.3s |
| performanceBudgets.listScrollFps | Performance.listScrollFps | 60 |
| performanceBudgets.firstContentfulPaintMs | Performance.firstContentfulPaint | 1.0s |

## Android Parity
Matches `XGMotion.kt` structure with platform-idiomatic naming (camelCase vs SCREAMING_SNAKE_CASE, TimeInterval seconds vs Int milliseconds).

## Lint Status
SwiftLint: 0 violations across all 3 files.

## Build Status
XGMotion.swift, XGImage.swift, and XGPaginationDots.swift compile without errors. Pre-existing build error in HomeScreenSections.swift is unrelated.
