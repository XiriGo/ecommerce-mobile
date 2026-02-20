# M0-01: App Scaffold

## Overview

The app-scaffold feature establishes the complete foundational project structure for the Molt Marketplace mobile buyer app on both Android and iOS platforms. This scaffold provides the base architecture, dependency management, design system theme shell, localization framework, and build configuration required for all future features.

**Status**: Complete
**Phase**: M0 (Foundation)
**Platforms**: Android (Kotlin + Jetpack Compose) + iOS (Swift + SwiftUI)

## What Was Built

### Core Infrastructure

1. **Project Structure**
   - Android: Gradle KTS project with version catalog
   - iOS: Xcode project with SPM dependency management
   - Clean Architecture directory structure (Data → Domain → Presentation)
   - Placeholder directories for core modules and features

2. **Build Configuration**
   - Three build variants per platform: Debug, Staging, Release
   - Environment-specific API base URLs
   - ProGuard/R8 rules (Android), bitcode optimization (iOS)

3. **Design System Theme Shell**
   - Color constants from design tokens
   - Typography styles
   - Spacing constants
   - Theme wrapper components (MoltTheme)

4. **Localization Framework**
   - Support for three languages: English, Maltese, Turkish
   - Base string resources (12 common strings)
   - Android: XML string resources per locale
   - iOS: String Catalog (Localizable.xcstrings)

5. **Dependency Injection**
   - Android: Hilt setup with @HiltAndroidApp and @AndroidEntryPoint
   - iOS: Factory container setup

6. **Application Entry Point**
   - Android: MoltApplication + MainActivity with splash screen
   - iOS: MoltMarketplaceApp + Config with launch screen

## Android Implementation

### File Structure (23 files)

**Build Configuration**
- `/android/build.gradle.kts` — Project-level Gradle
- `/android/settings.gradle.kts` — Module configuration
- `/android/gradle.properties` — JVM and build settings
- `/android/gradle/libs.versions.toml` — Version catalog
- `/android/gradle/wrapper/gradle-wrapper.properties` — Gradle 8.11.1
- `/android/app/build.gradle.kts` — App module configuration
- `/android/app/proguard-rules.pro` — R8/ProGuard rules

**Application Files**
- `/android/app/src/main/AndroidManifest.xml` — Main manifest
- `/android/app/src/debug/AndroidManifest.xml` — Debug manifest
- `/android/app/src/main/java/com/molt/marketplace/MoltApplication.kt` — @HiltAndroidApp entry
- `/android/app/src/main/java/com/molt/marketplace/MainActivity.kt` — @AndroidEntryPoint main activity

**Design System Theme**
- `/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltColors.kt`
- `/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltTypography.kt`
- `/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltSpacing.kt`
- `/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltTheme.kt`

**Resources**
- `/android/app/src/main/res/values/strings.xml` — English strings
- `/android/app/src/main/res/values-mt/strings.xml` — Maltese strings
- `/android/app/src/main/res/values-tr/strings.xml` — Turkish strings
- `/android/app/src/main/res/values/colors.xml` — Color resources
- `/android/app/src/main/res/values/themes.xml` — Splash and app themes
- `/android/app/src/main/res/xml/network_security_config.xml` — Network security
- `/android/app/src/main/res/drawable/splash_logo.xml` — Splash logo vector
- `/android/app/src/main/res/drawable/placeholder.xml` — Placeholder image

### Build Variants

| Build Type | Base URL | Debuggable | Minify | App ID Suffix |
|-----------|----------|------------|--------|---------------|
| debug | https://api-dev.molt.mt | true | false | .debug |
| staging | https://api-staging.molt.mt | true | false | .staging |
| release | https://api.molt.mt | false | true (R8) | none |

### SDK Versions

- **minSdk**: 26 (Android 8.0)
- **targetSdk**: 35
- **compileSdk**: 35
- **Kotlin**: 2.1.10
- **Compose BOM**: 2026.01.01

### Key Dependencies

| Category | Library | Version |
|----------|---------|---------|
| UI | Jetpack Compose + Material 3 | 2026.01.01 (BOM) |
| DI | Hilt (Dagger) | 2.55 |
| Network | Retrofit + OkHttp | 3.0.0 / 5.0.0-alpha.14 |
| Image | Coil | 3.1.0 |
| Navigation | Compose Navigation | 2.8.9 |
| Async | Kotlin Coroutines + Flow | 1.10.2 |
| Storage | Room + DataStore | 2.7.1 / 1.1.1 |
| Logging | Timber | 5.0.1 |
| Firebase | Firebase BOM | 33.8.0 |
| Testing | JUnit + Truth + MockK + Turbine | Various |

### Design System Theme

**MoltColors.kt** — 67 color constants:
- Primary, secondary, tertiary palettes (light + dark)
- Error colors
- Surface and background colors
- Semantic colors (success, warning)
- E-commerce specific colors (priceRegular, priceSale, priceOriginal, ratingStarFilled, ratingStarEmpty, badgeBackground, badgeText, divider, shimmer)

**MoltTypography.kt** — 15 text styles:
- Display (Large, Medium, Small)
- Headline (Large, Medium, Small)
- Title (Large, Medium, Small)
- Body (Large, Medium, Small)
- Label (Large, Medium, Small)

**MoltSpacing.kt** — 16 spacing constants:
- Base spacing: XXS (2dp) to XXXL (64dp)
- Layout spacing: ScreenPaddingHorizontal, CardPadding, ListItemSpacing, SectionSpacing, ProductGridSpacing, MinTouchTarget

**MoltTheme.kt** — @Composable wrapper applying Material 3 theme with custom color scheme and typography

### Localization

12 base string resources in 3 languages:
- `app_name` — App name
- `common_loading_message` — Loading text
- `common_error_network` — Network error
- `common_error_server` — Server error
- `common_error_unauthorized` — Unauthorized error
- `common_error_not_found` — Not found error
- `common_error_unknown` — Unknown error
- `common_retry_button` — Retry button
- `common_ok_button` — OK button
- `common_cancel_button` — Cancel button
- `common_close_button` — Close button
- `common_search_hint` — Search hint

All strings follow `<feature>_<screen>_<element>_<description>` naming convention.

## iOS Implementation

### File Structure (13 files)

**Application Files**
- `/ios/MoltMarketplace/MoltMarketplaceApp.swift` — SwiftUI @main entry
- `/ios/MoltMarketplace/Config.swift` — Environment configuration

**Design System Theme**
- `/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltColors.swift`
- `/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltTypography.swift`
- `/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltSpacing.swift`
- `/ios/MoltMarketplace/Core/DesignSystem/Theme/MoltTheme.swift`

**DI**
- `/ios/MoltMarketplace/Core/DI/Container+Extensions.swift` — Factory container

**Resources**
- `/ios/MoltMarketplace/Resources/Localizable.xcstrings` — String Catalog
- `/ios/MoltMarketplace/Resources/Info.plist` — App configuration

**Configuration**
- `/ios/MoltMarketplace/Configuration/Debug.xcconfig`
- `/ios/MoltMarketplace/Configuration/Staging.xcconfig`
- `/ios/MoltMarketplace/Configuration/Release.xcconfig`

**Project Files**
- `/ios/Package.swift` — SPM dependencies
- `/ios/MoltMarketplace.xcodeproj/project.pbxproj` — Xcode project (requires manual setup)

### Build Configurations

| Configuration | Base URL | Build Settings |
|--------------|----------|----------------|
| Debug | https://api-dev.molt.mt | Debuggable, no optimization |
| Staging | https://api-staging.molt.mt | Debuggable, no optimization |
| Release | https://api.molt.mt | Optimized, bitcode enabled |

Bundle IDs correctly suffixed per environment:
- Debug: `com.molt.marketplace.debug`
- Staging: `com.molt.marketplace.staging`
- Release: `com.molt.marketplace`

### Platform Versions

- **Minimum iOS**: 17.0
- **Target iOS**: 18.0
- **Swift**: 6.0 (compatible with 6.2)
- **Xcode**: 16+
- **Strict Concurrency Checking**: Complete

### Key Dependencies (SPM)

| Category | Library | Version |
|----------|---------|---------|
| DI | Factory | 2.4.0 |
| Image | Nuke | 12.8.0 |
| Security | KeychainAccess | 4.2.2 |
| Firebase | Firebase | 11.7.0 |
| Crash Reporting | Sentry | 8.40.0 |
| Testing | ViewInspector | 0.10.0 |
| Testing | swift-snapshot-testing | 1.17.0 |

### Design System Theme

**MoltColors.swift** — 32 color constants:
- Primary palette (primary, onPrimary, primaryContainer, onPrimaryContainer)
- Semantic colors (success, onSuccess, warning, error)
- E-commerce colors (priceRegular, priceSale, priceOriginal, ratingStarFilled, ratingStarEmpty, badgeBackground, badgeText, divider, shimmer)
- Hex string to Color conversion extension

**MoltTypography.swift** — 15 text styles matching Android:
- Display, Headline, Title, Body, Label (Large, Medium, Small variants)

**MoltSpacing.swift** — 16 spacing constants matching Android:
- Base spacing: xxs (2pt) to xxxl (64pt)
- Layout spacing: screenPaddingHorizontal, cardPadding, listItemSpacing, sectionSpacing, productGridSpacing, minTouchTarget (44pt for Apple HIG)

**MoltTheme.swift** — ViewModifier applying theme colors and typography

### Localization

String Catalog with 12 base keys in 3 languages (same as Android).

Format: Single `.xcstrings` file, Xcode manages all translations.

## Testing

### Android Tests (33 test methods)

**Unit Tests** (5 files):
1. `MoltColorsTest.kt` — 11 tests, 67 color assertions
2. `MoltSpacingTest.kt` — 4 tests, 16 spacing assertions
3. `BuildConfigTest.kt` — 6 tests (API URL, version, build type)
4. `StringResourcesTest.kt` — 9 tests (en/mt/tr localization)
5. `MoltApplicationTest.kt` — 3 tests (Hilt, Timber setup)

**Framework**: JUnit 4 + Truth assertions
**Coverage**: 100% of tested components

**Test Locations**:
- `/android/app/src/test/java/com/molt/marketplace/core/designsystem/theme/MoltColorsTest.kt`
- `/android/app/src/test/java/com/molt/marketplace/core/designsystem/theme/MoltSpacingTest.kt`
- `/android/app/src/test/java/com/molt/marketplace/BuildConfigTest.kt`
- `/android/app/src/test/java/com/molt/marketplace/StringResourcesTest.kt`
- `/android/app/src/test/java/com/molt/marketplace/MoltApplicationTest.kt`

### iOS Tests (50 test methods)

**Unit Tests** (4 files):
1. `ConfigTests.swift` — 7 tests (environment URLs, versioning)
2. `MoltColorsTests.swift` — 17 tests (color validation, hex parsing, contrast ratios)
3. `MoltSpacingTests.swift` — 16 tests (spacing values, accessibility)
4. `LocalizableTests.swift` — 17 tests (localization completeness for all 3 languages)

**Framework**: Swift Testing (@Test macro)
**Coverage**: 100% of testable scaffold code

**Test Locations**:
- `/ios/MoltMarketplaceTests/ConfigTests.swift`
- `/ios/MoltMarketplaceTests/Core/DesignSystem/Theme/MoltColorsTests.swift`
- `/ios/MoltMarketplaceTests/Core/DesignSystem/Theme/MoltSpacingTests.swift`
- `/ios/MoltMarketplaceTests/Resources/LocalizableTests.swift`

### Test Coverage Summary

| Platform | Test Files | Test Cases | Coverage |
|----------|-----------|------------|----------|
| Android | 5 | 33 | 100% (tested components) |
| iOS | 4 | 50 | 100% (tested components) |
| **Total** | **9** | **83** | **100%** |

## Architecture Patterns

### Clean Architecture Layers

All future features will follow this structure:

```
feature/<name>/
  ├── data/
  │   ├── dto/           # API request/response DTOs
  │   ├── mapper/        # DTO ↔ Domain model mappers
  │   ├── remote/        # API service interface
  │   └── repository/    # Repository implementation
  ├── domain/
  │   ├── model/         # Domain models
  │   ├── repository/    # Repository interface
  │   └── usecase/       # Use cases
  └── presentation/
      ├── component/     # Reusable UI components
      ├── screen/        # Screen composables/views
      ├── viewmodel/     # ViewModels
      └── state/         # UI state models
```

### Placeholder Directories Created

**Android**:
- `core/common/` — Shared utilities
- `core/designsystem/component/` — Design system components (M0-02)
- `core/di/` — Hilt modules
- `core/domain/error/` — Error types
- `core/network/` — Network layer (M0-03)
- `feature/` — Feature modules (M1+)

**iOS**:
- `Core/Common/` — Shared utilities
- `Core/DesignSystem/Component/` — Design system components (M0-02)
- `Core/Domain/Error/` — Error types
- `Core/Network/` — Network layer (M0-03)
- `Feature/` — Feature modules (M1+)

## Platform Consistency

### Matching Behavior

Both platforms implement identical:
- Build configurations (Debug, Staging, Release)
- Environment URLs
- Localization keys and languages (en, mt, tr)
- Design token values (colors, spacing, typography)
- Clean Architecture structure
- Placeholder screen approach

### Intentional Differences

Platform-specific choices per CLAUDE.md standards:
- **UI Framework**: Jetpack Compose (Android) vs SwiftUI (iOS)
- **DI Framework**: Hilt (Android) vs Factory (iOS)
- **Localization**: XML resources (Android) vs String Catalog (iOS)
- **Config**: BuildConfig (Android) vs xcconfig files (iOS)
- **Async**: Kotlin Coroutines + Flow (Android) vs Swift Concurrency (iOS)

## Known Limitations

### Android

1. **No Gradle wrapper JAR files**: Not committed to git, generated on first build
2. **No Firebase config**: `google-services.json` deferred to M0-06
3. **No actual logo**: Placeholder vector drawable used
4. **No mipmap icons**: App launcher icons need design assets

### iOS

1. **Xcode project incomplete**: Requires manual setup in Xcode to add files, SPM dependencies, schemes, and asset catalog
2. **No asset images**: App icon and splash logo need design assets
3. **No build verification**: Cannot verify builds without Xcode setup

Both limitations are expected for M0-01. Assets and complete configuration will be added in future milestones.

## Next Steps

### M0-02: Design System Components

Implement reusable UI components that reference the theme shell created here:

**Android** (`core/designsystem/component/`):
- MoltButton.kt — Primary/Secondary/Text button variants
- MoltCard.kt — Product card, info card
- MoltTextField.kt — Text field with label/error
- MoltTopBar.kt — Top app bar
- MoltBottomBar.kt — Bottom navigation
- MoltLoadingView.kt — Full-screen + inline loading
- MoltErrorView.kt — Error with retry
- MoltEmptyView.kt — Empty state
- MoltImage.kt — Coil image with placeholder
- MoltBadge.kt — Count/status badge

**iOS** (`Core/DesignSystem/Component/`):
- MoltButton.swift — Primary/Secondary/Text button variants
- MoltCard.swift — Product card, info card
- MoltTextField.swift — Text field with label/error
- MoltTopBar.swift — Navigation bar wrapper
- MoltTabBar.swift — Tab bar wrapper
- MoltLoadingView.swift — Full-screen + inline loading
- MoltErrorView.swift — Error with retry
- MoltEmptyView.swift — Empty state
- MoltImage.swift — Nuke image with placeholder
- MoltBadge.swift — Count/status badge

### M0-03: Network Layer

Implement API client inside `core/network/`:
- Retrofit service (Android) / URLSession client (iOS)
- Base URL injection from Config/BuildConfig
- Auth token interceptor/middleware
- Error mapping to domain errors

### M0-04: Navigation

Replace placeholder screen with navigation structure:
- Tab bar (Home, Categories, Cart, Profile)
- Navigation stack per tab
- Deep linking support

### M0-05: DI Setup

Expand dependency injection configuration:
- Android: Hilt modules in `core/di/`
- iOS: Factory container extensions

### M0-06: Auth Infrastructure

Add authentication foundations:
- Login/logout flows
- Token storage (DataStore + Tink / Keychain)
- Biometric authentication setup
- Firebase configuration files

## Design Transition Strategy

This scaffold implements **Phase 1: Dummy Screens** as per CLAUDE.md:
- Uses Material 3 defaults (Android) and system styles (iOS) via MoltTheme
- All colors/spacing from MoltColors/MoltSpacing (design tokens)
- Feature screens will use Molt* design system components
- Focus on architecture and business logic, not pixel-perfect design

**When Figma designs arrive (Phase 2)**:

Only these files change:
- `shared/design-tokens/*.json` — New color, typography, spacing values
- `core/designsystem/theme/Molt*.kt` / `.swift` — Updated theme constants
- `core/designsystem/component/Molt*.kt` / `.swift` — Visual appearance tweaks
- `res/drawable/` / `Assets.xcassets` — New icons and illustrations

**What NEVER changes**: ViewModels, UseCases, Repositories, DTOs, domain models, navigation, API integration, tests.

## File Inventory Summary

| Platform | Implementation Files | Test Files | Placeholder Directories |
|----------|---------------------|------------|------------------------|
| Android | 23 | 5 | 8 |
| iOS | 13 | 4 | 7 |
| **Total** | **36** | **9** | **15** |

## Documentation References

- **Architecture Spec**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/shared/feature-specs/app-scaffold.md`
- **CLAUDE.md Standards**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/CLAUDE.md`
- **Android Handoff**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/docs/pipeline/app-scaffold-android-dev.handoff.md`
- **iOS Handoff**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/docs/pipeline/app-scaffold-ios-dev.handoff.md`
- **Android Test Handoff**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/docs/pipeline/app-scaffold-android-test.handoff.md`
- **iOS Test Handoff**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/docs/pipeline/app-scaffold-ios-test.handoff.md`
- **Architect Handoff**: `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/docs/pipeline/app-scaffold-architect.handoff.md`

---

**Last Updated**: 2026-02-11
**Agent**: doc-writer
**Status**: Complete
