# Handoff: app-onboarding -- Architect

## Feature
**M4-05: App Onboarding** -- First-launch branded splash screen, 4-page onboarding pager, show-once local storage flag, and 4 new reusable design system components.

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/app-onboarding.md` |
| This Handoff | `docs/pipeline/app-onboarding-architect.handoff.md` |

## Summary of Spec

The app-onboarding spec defines a first-launch experience with a branded splash screen and horizontal onboarding pager for both Android and iOS platforms.

### Core Flow
- **Branded Splash Screen**: 4-layer visual stack -- XGBrandGradient (base radial gradient), XGBrandPattern (6% white X-tile overlay), XGLogoMark (green + white chevrons, centered), XGBrandGradient dark overlay (vignette).
- **Onboarding Pager**: 4 horizontal pages with illustrations, titles (Poppins-SemiBold 24px, white), and descriptions (Poppins-Regular 16px, white 80% opacity).
- **Navigation**: Skip button on pages 0-2 (top-right), Get Started button on page 3 only (XGButton with secondary brand colors), XGPaginationDots at bottom.
- **Show Once**: Boolean flag in DataStore (Android) / UserDefaults (iOS). Checked on app launch via OnboardingViewModel.

### New Design System Components (4 total, in core/designsystem/component/)
1. **XGBrandGradient** -- Two-layer radial gradient (base + dark overlay) from `gradients.json > brandHeader`. Reused in Login and Home hero.
2. **XGBrandPattern** -- Tiled X-motif at 6% white opacity from `gradients.json > splashPatternOverlay`. Reused on any branded surface.
3. **XGLogoMark** -- Two-chevron logo mark (green #94D63A + white #FFFFFF). Reused in loading states.
4. **XGPaginationDots** -- Animated pill/circle dots from `components.json > XGPaginationDots`. Active: 18w, inactive: 6w, height: 6, gap: 4. Reused in Home hero carousel and Flash sale.

### Architecture (Clean Architecture)
- **Domain**: `OnboardingRepository` interface, `CheckOnboardingUseCase`, `CompleteOnboardingUseCase`, `OnboardingPage` model
- **Data**: `OnboardingRepositoryImpl` backed by DataStore (Android) / UserDefaults (iOS)
- **Presentation**: `OnboardingViewModel` with `OnboardingUiState` (Loading/ShowOnboarding/OnboardingComplete), `SplashScreen`, `OnboardingScreen`, `OnboardingPageContent`
- **DI**: Hilt module (Android) / Factory container extension (iOS)

### Android
- 15 new feature files in `feature/onboarding/` following Clean Architecture
- 4 new design system component files in `core/designsystem/component/`
- 6 new drawable resources (4 placeholder illustrations, pattern tile, logo mark)
- Modifications to `MainActivity.kt` (onboarding check flow)
- 16 new string keys across 3 languages
- `HorizontalPager` for page swiping
- 4 test files (ViewModel, use cases, fake repository)

### iOS
- 14 new feature files in `Feature/Onboarding/` following Clean Architecture
- 4 new design system component files in `Core/DesignSystem/Component/`
- 6 new asset catalog imagesets (4 placeholder illustrations, pattern tile, logo mark)
- 1 new DI file (`Container+Onboarding.swift`)
- Modifications to `XiriGoEcommerceApp.swift` (onboarding check flow)
- 16 new string keys across 3 languages in `Localizable.xcstrings`
- `TabView` with `.page` style for swiping
- 4 test files (ViewModel, use cases, fake repository)

### Localization
- 10 content string keys (skip, get started, 4 titles, 4 descriptions) in English, Maltese, Turkish
- 6 accessibility string keys

## Key Decisions

1. **Design system components in core, not feature module**: XGBrandGradient, XGBrandPattern, XGLogoMark, and XGPaginationDots live in `core/designsystem/component/` because they are reused across features (Login, Home, etc.). They are not feature-specific.

2. **UserDefaults for iOS (not Keychain)**: The onboarding flag is a non-sensitive boolean. UserDefaults is appropriate and simpler than Keychain. Consistent with the principle of using the simplest storage for non-sensitive data.

3. **DataStore<Preferences> for Android (not EncryptedDataStore)**: Same reasoning -- non-sensitive boolean flag. Uses the existing DataStore instance from the scaffold.

4. **Three UI states (Loading, ShowOnboarding, OnboardingComplete)**: The Loading state displays the branded splash screen while checking the flag, providing a seamless visual transition. No need for a separate "loading the splash" state.

5. **Get Started button uses brand.secondary colors**: The button on the last page uses `$brand.secondary` (#94D63A) background with `$brand.onSecondary` (#6000FE) text, matching the design specification. This is a distinct visual variant from the standard XGButton.primary.

6. **Placeholder illustrations**: Simple vector/SF Symbol illustrations are used until real design assets are provided. These can be swapped by replacing asset files without code changes.

7. **Page content as localized string keys**: All onboarding page content is driven by localized string resources, not hardcoded. This enables translation and future content updates without code changes.

8. **Poppins font required**: The onboarding typography spec calls for Poppins-SemiBold (titles) and Poppins-Regular (descriptions). Developers must ensure Poppins is embedded in the project if not already done in prior milestones.

9. **Integration with M0-04 Navigation**: Uses existing `Route.Onboarding` and `AppRouter.isShowingOnboarding` from the navigation spec. The onboarding check happens at the app entry point level (`MainActivity`/`XiriGoEcommerceApp`), before the main navigation host renders.

## Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Dev | File manifest (section 11.1), design system component APIs (section 4), architecture (section 3), Android implementation notes (section 12.1), verification criteria (section 13) |
| iOS Dev | File manifest (section 11.2), design system component APIs (section 4), architecture (section 3), iOS implementation notes (section 12.2), verification criteria (section 13) |

## Verification

Downstream developers should verify their implementation using the criteria in spec section 13.

## Notes for Next Features

- **M1-01 (Login)**: Reuses `XGBrandGradient` and `XGBrandPattern` as the background. Also reuses `XGLogoMark` above the login form. These components must be importable from `core/designsystem/component/`.
- **M1-04 (Home)**: Reuses `XGBrandGradient` for the hero banner background. Reuses `XGPaginationDots` for the hero carousel and flash sale banner pagination.
- **Illustration assets**: When real illustrations are provided by the design team, replace the placeholder assets in the drawable/asset catalog without any code changes.
