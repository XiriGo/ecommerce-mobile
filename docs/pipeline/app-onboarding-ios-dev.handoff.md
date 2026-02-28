# App Onboarding - iOS Dev Handoff

**Feature**: App Onboarding (M4-05)
**Agent**: ios-dev
**Platform**: iOS
**Issue**: #35
**Date**: 2026-02-28

## Summary

Implemented the app onboarding feature for iOS, consisting of 4 new design system components and a complete feature module following Clean Architecture. The feature provides a branded splash screen and 4-page horizontal onboarding pager shown only on first launch.

## Files Created

### Design System Components (4 files)

| File | Description |
|------|-------------|
| `Core/DesignSystem/Component/XGBrandGradient.swift` | Reusable branded radial gradient background with `@ViewBuilder` content overlay. Two-layer radial gradient from `gradients.json > brandHeader`. |
| `Core/DesignSystem/Component/XGBrandPattern.swift` | Tiled X-motif pattern overlay at 6% white opacity using `Canvas` drawing. |
| `Core/DesignSystem/Component/XGLogoMark.swift` | Green (#94D63A) + white two-chevron logo mark using SwiftUI `Shape`/`Path`. Configurable size. |
| `Core/DesignSystem/Component/XGPaginationDots.swift` | Animated pill (active 18pt) / circle (inactive 6pt) pagination dots with spring animation. Configurable colors. |

### Feature Module (10 files)

Base path: `ios/XiriGoEcommerce/Feature/Onboarding/`

| # | File | Layer | Description |
|---|------|-------|-------------|
| 1 | `Domain/Model/OnboardingPage.swift` | Domain | Struct: `Identifiable`, `Sendable`, `Equatable`. Holds titleKey, descriptionKey, illustrationName. Static `allPages` array. |
| 2 | `Domain/Repository/OnboardingRepository.swift` | Domain | Protocol: `hasSeenOnboarding() async -> Bool`, `setOnboardingSeen() async`. Conforms to `Sendable`. |
| 3 | `Domain/UseCase/CheckOnboardingUseCase.swift` | Domain | Struct wrapping `repository.hasSeenOnboarding()`. `Sendable`. |
| 4 | `Domain/UseCase/CompleteOnboardingUseCase.swift` | Domain | Struct wrapping `repository.setOnboardingSeen()`. `Sendable`. |
| 5 | `Data/Repository/OnboardingRepositoryImpl.swift` | Data | `final class`, UserDefaults-backed. Key: `has_seen_onboarding`. `@unchecked Sendable`. |
| 6 | `Presentation/State/OnboardingUiState.swift` | Presentation | Enum: `.loading`, `.showOnboarding`, `.onboardingComplete`. `Equatable`, `Sendable`. |
| 7 | `Presentation/ViewModel/OnboardingViewModel.swift` | Presentation | `@MainActor @Observable final class`. Manages uiState, currentPage, pages. Actions: `checkOnboardingStatus()`, `onSkip()`, `onGetStarted()`. |
| 8 | `Presentation/Screen/SplashScreen.swift` | Presentation | 4-layer stack: XGBrandGradient + XGBrandPattern + XGLogoMark + vignette overlay. `#Preview` included. |
| 9 | `Presentation/Screen/OnboardingScreen.swift` | Presentation | `TabView` with `.page` style, Skip button (pages 0-2), Get Started button (page 3), XGPaginationDots. `#Preview` included. |
| 10 | `Presentation/Screen/OnboardingPageContent.swift` | Presentation | Single page: illustration (with SF Symbol fallback) + title + description. Accessibility labels per page. `#Preview` included. |

### DI Registration (1 file)

| File | Description |
|------|-------------|
| `Core/DI/Container+Onboarding.swift` | Factory container extension: `onboardingRepository` (singleton), `checkOnboardingUseCase`, `completeOnboardingUseCase`, `onboardingViewModel`. |

### Modified Files (1 file)

| File | Change |
|------|--------|
| `XiriGoEcommerceApp.swift` | Integrated onboarding flow: observes `OnboardingViewModel.uiState` to conditionally show SplashScreen / OnboardingScreen / MainTabView. Added Factory import. |

### Localization

| File | Change |
|------|--------|
| `Resources/Localizable.xcstrings` | Added 17 new string keys (10 content + 7 accessibility) in English, Maltese, and Turkish. |

### Assets (4 imagesets)

| Directory | Description |
|-----------|-------------|
| `Resources/Assets.xcassets/OnboardingIllustrations/onboarding_illustration_browse.imageset/` | Placeholder for browse page illustration. |
| `Resources/Assets.xcassets/OnboardingIllustrations/onboarding_illustration_compare.imageset/` | Placeholder for compare page illustration. |
| `Resources/Assets.xcassets/OnboardingIllustrations/onboarding_illustration_checkout.imageset/` | Placeholder for checkout page illustration. |
| `Resources/Assets.xcassets/OnboardingIllustrations/onboarding_illustration_track.imageset/` | Placeholder for track page illustration. |

## Architecture Compliance

- Clean Architecture: Data -> Domain -> Presentation (zero cross-layer imports)
- Domain layer has zero imports from Data or Presentation
- All user-facing strings localized via `String(localized:)`
- No force unwrap (`!`) anywhere
- No `Any`/`AnyObject` in domain/presentation
- All models are immutable structs
- ViewModel uses `@MainActor @Observable`
- All views have `#Preview`
- Design system components placed in `Core/DesignSystem/Component/` for reuse
- Feature screens use XG* components (XGButton variant for Get Started, XGPaginationDots, XGBrandGradient, etc.)
- Accessibility labels on all interactive elements and illustrations
- Minimum touch target 44pt observed

## Behavioral Consistency with Android

- Same 3-state flow: Loading -> ShowOnboarding/OnboardingComplete
- Same 4 pages with identical content keys
- Skip visible on pages 0-2, hidden on page 3
- Get Started visible only on page 3
- Same UserDefaults/DataStore key: `has_seen_onboarding`
- Same branded gradient tokens from `gradients.json`
- Same pagination dot specs from `components.json > XGPaginationDots`

## Known Limitations

- Illustration assets are empty placeholders (SF Symbol fallbacks active). Real illustrations will be provided by the design team.
- Poppins font not yet embedded; uses system font. Will be added when font files are provided.

## Testing Notes

- `OnboardingViewModel` is fully testable via init-based injection with `FakeOnboardingRepository`
- Use cases are simple pass-through, testable in isolation
- Repository uses UserDefaults which can be replaced with a custom `UserDefaults(suiteName:)` in tests
- All state transitions: loading -> showOnboarding, loading -> onboardingComplete, showOnboarding -> onboardingComplete (via skip), showOnboarding -> onboardingComplete (via getStarted)
