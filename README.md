# Molt Marketplace - Mobile Buyer App

[![Android CI](https://github.com/atknatk/molt-mobile/actions/workflows/android-ci.yml/badge.svg?branch=develop)](https://github.com/atknatk/molt-mobile/actions/workflows/android-ci.yml)
[![iOS CI](https://github.com/atknatk/molt-mobile/actions/workflows/ios-ci.yml/badge.svg?branch=develop)](https://github.com/atknatk/molt-mobile/actions/workflows/ios-ci.yml)
[![PR Gate](https://github.com/atknatk/molt-mobile/actions/workflows/pr-gate.yml/badge.svg)](https://github.com/atknatk/molt-mobile/actions/workflows/pr-gate.yml)

| Platform | Build | Lint | Tests |
|----------|-------|------|-------|
| Android | [![Build](https://img.shields.io/github/actions/workflow/status/atknatk/molt-mobile/android-ci.yml?branch=develop&label=build&logo=android&logoColor=white)](https://github.com/atknatk/molt-mobile/actions/workflows/android-ci.yml) | [![Lint](https://img.shields.io/badge/ktlint%20%2B%20detekt-passing-brightgreen?logo=kotlin&logoColor=white)](https://github.com/atknatk/molt-mobile/actions/workflows/android-ci.yml) | [![Tests](https://img.shields.io/badge/unit%20tests-passing-brightgreen?logo=junit5&logoColor=white)](https://github.com/atknatk/molt-mobile/actions/workflows/android-ci.yml) |
| iOS | [![Build](https://img.shields.io/github/actions/workflow/status/atknatk/molt-mobile/ios-ci.yml?branch=develop&label=build&logo=apple&logoColor=white)](https://github.com/atknatk/molt-mobile/actions/workflows/ios-ci.yml) | [![Lint](https://img.shields.io/badge/SwiftLint%20%2B%20SwiftFormat-passing-brightgreen?logo=swift&logoColor=white)](https://github.com/atknatk/molt-mobile/actions/workflows/ios-ci.yml) | [![Tests](https://img.shields.io/badge/59%20tests%20%C2%B7%205%20suites-passing-brightgreen?logo=swift&logoColor=white)](https://github.com/atknatk/molt-mobile/actions/workflows/ios-ci.yml) |

## Tech Stack

| | Android | iOS |
|---|---------|-----|
| Language | Kotlin 2.1 | Swift 6.2 |
| UI | Jetpack Compose + Material 3 | SwiftUI |
| Architecture | Clean Architecture (MVVM) | Clean Architecture (MVVM) |
| DI | Hilt (Dagger) | Factory |
| Network | Retrofit 3 + Kotlin Serialization | URLSession + async/await |
| Image | Coil | Nuke |
| Navigation | Compose Navigation | NavigationStack |
| Testing | JUnit 4 + Truth + MockK + Turbine | Swift Testing + ViewInspector |
| Lint | ktlint + detekt | SwiftLint + SwiftFormat |
| CI/CD | GitHub Actions | GitHub Actions |

## Architecture

```
feature/<name>/
  ├── data/          # DTOs, API services, repository implementations
  ├── domain/        # Models, repository interfaces, use cases
  └── presentation/  # Screens, ViewModels, UI state
```

All feature screens use `Molt*` design system components (never raw Material 3 / SwiftUI primitives) for Figma-safe abstraction.

## Project Structure

```
molt-mobile/
├── android/                    # Android app (Kotlin + Compose)
│   ├── app/src/main/java/com/molt/marketplace/
│   │   ├── core/designsystem/  # MoltTheme, MoltColors, MoltSpacing, Molt* components
│   │   └── feature/            # Feature modules
│   └── config/detekt/          # Static analysis config
├── ios/                        # iOS app (Swift + SwiftUI)
│   ├── MoltMarketplace/
│   │   ├── Core/DesignSystem/  # MoltTheme, MoltColors, MoltSpacing, Molt* components
│   │   └── Feature/            # Feature modules
│   └── MoltMarketplaceTests/
├── shared/
│   ├── api-contracts/          # Backend API endpoint definitions
│   ├── design-tokens/          # Cross-platform design tokens (colors, typography)
│   └── feature-specs/          # Platform-agnostic feature specifications
├── .github/workflows/          # CI/CD pipelines
└── .claude/                    # Agent pipeline (subagents + skills)
```

## Getting Started

### Android

```bash
cd android
./gradlew assembleDebug        # Build
./gradlew test                 # Unit tests
./gradlew ktlintCheck          # Lint
./gradlew detekt               # Static analysis
```

**Requirements**: JDK 17+, Android Studio Ladybug+

### iOS

```bash
cd ios
xcodebuild build -scheme MoltMarketplace -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild test -scheme MoltMarketplace -destination 'platform=iOS Simulator,name=iPhone 16'
```

**Requirements**: Xcode 16+, iOS 17.0+ deployment target

## Quality Gates

Every PR must pass:

- **Android**: ktlint + detekt + unit tests + debug build
- **iOS**: SwiftLint + SwiftFormat + unit tests + debug build
- **PR Gate**: Aggregated status check (only runs affected platform checks)

## Backend

Medusa v2 REST API. Endpoints defined in `shared/api-contracts/`.

## Localization

| Language | Code | Status |
|----------|------|--------|
| English | `en` | Default |
| Maltese | `mt` | Scaffolded |
| Turkish | `tr` | Scaffolded |

## License

Proprietary - Molt Marketplace
