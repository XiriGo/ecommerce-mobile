# Handoff: app-scaffold -- Architect

## Feature
**M0-01: App Scaffold** -- Foundation project structure for Molt Marketplace buyer app.

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/app-scaffold.md` |
| This Handoff | `docs/pipeline/app-scaffold-architect.handoff.md` |

## Summary of Spec

The app-scaffold spec defines the complete project skeleton for both Android and iOS platforms:

### Android
- Gradle KTS project with version catalog (`libs.versions.toml`) containing all dependency versions
- Three build types: debug, staging, release with distinct `API_BASE_URL` values
- `MoltApplication` (`@HiltAndroidApp`) + `MainActivity` (`@AndroidEntryPoint`, splash screen)
- Design system theme shell: `MoltColors`, `MoltTypography`, `MoltSpacing`, `MoltTheme`
- Base string resources in English, Maltese, and Turkish
- Placeholder directories for `core/` and `feature/` packages
- Network security config, ProGuard rules, splash theme
- SDK: minSdk 26, targetSdk 35, compileSdk 35, Kotlin 2.1.10, Compose BOM 2026.01.01

### iOS
- Xcode project with SPM dependencies (Factory, Nuke, KeychainAccess, Firebase)
- Three xcconfig files: Debug, Staging, Release with distinct `API_BASE_URL` values
- `MoltMarketplaceApp` (`@main` SwiftUI App entry point) + `Config.swift`
- Design system theme shell: `MoltColors`, `MoltTypography`, `MoltSpacing`, `MoltTheme`
- String Catalog (`Localizable.xcstrings`) with English, Maltese, Turkish
- Placeholder directories for `Core/` and `Feature/` modules
- iOS 17.0 minimum, Swift 6.2, Strict Concurrency Complete

### Shared
- All color, spacing, typography, and corner radius tokens from `shared/design-tokens/`
- Environment URLs: dev (`api-dev.molt.mt`), staging (`api-staging.molt.mt`), prod (`api.molt.mt`)
- Splash screen: surface background, placeholder logo, no artificial delay
- Placeholder screen: centered "Molt Marketplace" text using `headlineSmall` style

## Key Decisions

1. **Version catalog approach (Android)**: All dependency versions centralized in `libs.versions.toml`
2. **xcconfig-based environments (iOS)**: Avoids preprocessor macros; clean separation per scheme
3. **Theme shell in scaffold**: `MoltColors`, `MoltTypography`, `MoltSpacing`, `MoltTheme` created here so M0-02 components can reference them immediately
4. **No Firebase in scaffold**: Firebase initialization deferred to when analytics/crash features are added
5. **Splash uses platform APIs**: Android 12+ SplashScreen API, iOS launch screen via Info.plist
6. **Three languages from day one**: String resources pre-created for en, mt, tr

## Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Dev | Full file manifest (section 10.1), Gradle config (section 1.2-1.3), theme shell (section 3) |
| iOS Dev | Full file manifest (section 10.2), SPM deps (section 2.2), xcconfig (section 2.3), theme shell (section 3) |

## Verification

Downstream developers should verify their scaffold build succeeds using the criteria in spec section 11.

## Notes for Next Features

- **M0-02 (Design System)**: Implement `Molt*` components inside `core/designsystem/component/`. Theme files already exist.
- **M0-03 (Network Layer)**: Implement inside `core/network/`. Base URL is already configured per environment.
- **M0-04 (Navigation)**: Replace placeholder screen in `MainActivity`/`MoltMarketplaceApp` with tab bar + navigation.
- **M0-05 (DI Setup)**: Expand `core/di/` (Android Hilt modules) and `Container+Extensions.swift` (iOS Factory).
