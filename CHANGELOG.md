# Changelog

All notable changes to the Molt Marketplace Mobile App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

#### M0-01: App Scaffold

- **Android project structure** with Gradle KTS and version catalog (`libs.versions.toml`)
  - 23 implementation files (MoltApplication, MainActivity, design system theme shell)
  - Three build types: debug, staging, release with environment-specific API URLs
  - Hilt DI setup (@HiltAndroidApp, @AndroidEntryPoint)
  - Android 12+ splash screen with edge-to-edge support
  - Network security configuration (HTTPS enforced)
  - SDK: minSdk 26, targetSdk 35, compileSdk 35, Kotlin 2.1.10, Compose BOM 2026.01.01
- **iOS project structure** with Xcode and SPM dependencies
  - 13 implementation files (MoltMarketplaceApp, Config, design system theme shell)
  - Three xcconfig files: Debug, Staging, Release with environment-specific API URLs
  - Factory DI container setup
  - SwiftUI entry point with placeholder screen
  - iOS 17.0 minimum, Swift 6.0, Strict Concurrency Complete
- **Design system theme shell** (both platforms)
  - MoltColors: 67 Android colors / 32 iOS colors from design tokens
  - MoltTypography: 15 text styles (Display, Headline, Title, Body, Label)
  - MoltSpacing: 16 spacing constants (base + layout)
  - MoltTheme: Composable theme wrapper (Android) / ViewModifier (iOS)
- **Base localization resources** (both platforms)
  - Three languages: English (en), Maltese (mt), Turkish (tr)
  - 12 common string resources
  - Android: XML string resources per locale
  - iOS: String Catalog (Localizable.xcstrings)
- **Comprehensive test suites**
  - Android: 33 tests (5 test files) covering theme, BuildConfig, strings, app initialization
  - iOS: 50 tests (4 test files) covering Config, theme, localization
  - 100% coverage on all tested components
  - Frameworks: JUnit 4 + Truth (Android), Swift Testing (iOS)
- **Clean Architecture directory structure**
  - Placeholder directories for core modules (designsystem, network, di, domain, common)
  - Placeholder directories for feature modules
  - Test infrastructure for both platforms

#### Infrastructure Guides

- **device-support**: Platform infrastructure guide covering phone-first approach, portrait-only orientation lock, screen size adaptation (WindowWidthSizeClass / horizontalSizeClass), safe area handling, Dynamic Type, dark mode, status bar, minimum screen sizes, and accessibility touch targets (Android + iOS)
- **local-storage**: Platform infrastructure guide covering all four storage layers (Proto DataStore, Tink-encrypted DataStore, Room, OkHttp Cache on Android; UserDefaults, KeychainAccess, SwiftData, URLCache on iOS), full entity schemas for CartItem / WishlistItem / RecentSearch / RecentlyViewed, DAO interfaces, offline-first patterns, data retention rules, migration strategy, and backup/security considerations (Android + iOS)
- **testing-strategy**: Platform infrastructure guide covering test pyramid (unit / integration / E2E), framework summary (JUnit 4 + Truth + MockK + Turbine on Android; Swift Testing on iOS), E2E scenarios (Guest Browse, Login, Add to Cart, Checkout, Search), API mock strategy (MockWebServer + Dispatcher on Android; MockURLProtocol on iOS), shared test fixtures layout, fake repository pattern, snapshot testing (Paparazzi on Android; swift-snapshot-testing on iOS), performance baselines, CI integration, flaky test policy, and agentic testing agent responsibilities (Android + iOS)

#### Project Setup

- Claude Code Agent Teams pipeline with 7 specialized teammates
- CLAUDE.md coding standards for both platforms
- Design tokens (colors, typography, spacing)
- API contracts for auth, products, cart, orders, customers, shipping
- Feature queue with 34 features across 5 phases (M0-M4)
- 9 interactive Claude skills for pipeline operations
- PROMPTS/BUYER_APP.md with full buyer app requirements
