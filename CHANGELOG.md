# Changelog

All notable changes to the Molt Marketplace Mobile App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

#### M0-04: Navigation

- **Navigation**: Type-safe tab-based routing and navigation infrastructure (Android + iOS)
  - Four-tab bottom bar (Home, Categories, Cart, Profile) using `MoltBottomBar` (Android) / `MoltTabBar` (iOS) from M0-02 Design System
  - Independent per-tab navigation stack with back-stack preservation on tab switch (`saveState`/`restoreState` on Android; four `NavigationPath` instances in `AppRouter` on iOS)
  - 29 type-safe route definitions covering all M0–M4 screens (`@Serializable` sealed interface on Android; `Hashable` enum with associated values on iOS)
  - `isAuthRequired` / `requiresAuth` computed property on `Route` for 14 auth-protected destinations
  - Auth-gated navigation with `returnTo` redirect: guests attempting auth-required routes are redirected to Login and returned to their intended destination after login
  - Deep link parsing for `molt://` custom scheme and `https://molt.mt/` universal links (`DeepLinkParser` object/enum with stateless `parse()` function)
  - Deep link intent filters and `singleTask` launch mode declared in `AndroidManifest.xml`; `CFBundleURLTypes` registered in iOS `Info.plist`
  - Cart badge count wired to `MoltBottomBar`/`MoltTabBar` (defaults to 0 and hidden until M2-01 provides cart count)
  - Auth gating wired with stub (always guest) until M0-06 Auth Infrastructure provides `AuthStateProvider`
  - Placeholder screens (`PlaceholderScreen` / `PlaceholderView`) for all unimplemented routes, replaced feature-by-feature in M1+
  - Tab bar hidden for fullscreen flows: Login, Register, ForgotPassword, Onboarding, all Checkout sub-screens, OrderConfirmation
  - 10 new localization keys in English, Maltese, and Turkish (tab labels, placeholder copy, guest profile prompt, cart badge description)
- **Tests**: ~138 Android tests (7 files, JUnit 4 + Truth + Compose UI Test + Robolectric) + ~167 iOS tests (5 files, Swift Testing) — ~305 total
  - Android: `DeepLinkParserTest` (15), `RouteAuthTest` (19), `TopLevelDestinationTest` (11), `RouteSerializationTest` (~44), `DeepLinkParserEdgeCasesTest` (~28), `MoltAppScaffoldTest` (~11), `PlaceholderScreenTest` (~10)
  - iOS: `TabTests` (26), `RouteTests` (42), `DeepLinkParserTests` (30), `AppRouterTests` (44), `PlaceholderViewTests` (25)

#### M0-03: Network Layer

- **Network Layer**: HTTP client infrastructure for Medusa v2 REST API communication (Android + iOS)
  - Retrofit 3.0 + OkHttp 5.0 + Kotlin Serialization (Android); URLSession + async/await (iOS)
  - Auth interceptor (`AuthInterceptor` / inline `APIClient` logic) injects `Authorization: Bearer` token on authenticated requests; skips public endpoints
  - Automatic token refresh on 401 using mutex-serialized concurrency (`kotlinx.coroutines.sync.Mutex` / Swift `actor TokenRefreshActor`); max 1 retry per request
  - Retry policy: 3 retries for 500/502/503/504 with exponential backoff (1s, 2s, 4s) and ±20% jitter
  - Medusa error response parsing (`MedusaErrorDto/DTO`) mapped to typed `AppError` sealed class/enum (5 cases: Network, Server, NotFound, Unauthorized, Unknown)
  - `AppError.toUserMessageResId()` (Android) / `Error.toUserMessage` (iOS) map errors to localized string keys from M0-01
  - Global snake_case ↔ camelCase JSON conversion (`JsonNamingStrategy.SnakeCase` on Android; `.convertFromSnakeCase` on iOS); ISO 8601 date handling; `ignoreUnknownKeys = true`
  - Debug-only request/response logging (`HttpLoggingInterceptor` + Timber on Android; `os.Logger` + `#if DEBUG` on iOS)
  - `NetworkMonitor` for device connectivity state (`StateFlow<Boolean>` on Android; `@Observable isConnected: Bool` on iOS via `NWPathMonitor`)
  - `PaginationMeta` helper for Medusa offset-based pagination (`count`, `limit`, `offset`, computed `hasMore`)
  - `TokenProvider` interface/protocol defined here; `NoOpTokenProvider` placeholder until M0-06 (Auth Infrastructure) provides the real implementation
  - Hilt `NetworkModule` (Android) / Factory `Container+Extensions` (iOS) providing singleton `Retrofit`/`APIClient`, `OkHttpClient`, `NetworkMonitor`
  - OkHttp timeouts: 30s connect, 60s read/write; URLSession: 60s request, 300s resource; 10 MB disk cache (Android + iOS)
- **Tests**: 133 Android unit tests (13 files, JUnit 4 + Truth + MockWebServer) + ~141 iOS unit tests (10 files, Swift Testing + MockURLProtocol)
  - Android: `FakeTokenProvider` in-memory fake; `MockWebServer` for HTTP-level interceptor tests
  - iOS: `MockURLProtocol` (URLProtocol subclass, no external dependencies); `APIClient.makeTestClient(...)` test factory
  - Coverage: `AuthInterceptor`, `TokenRefreshAuthenticator`/`TokenRefreshActor`, `RetryInterceptor`/`RetryPolicy`, `ApiErrorMapper`/`APIClient` error mapping, `AppError` user message mapping, `PaginationMeta.hasMore`, `JSONCoders`, `Endpoint`, `MedusaErrorDTO`, `NetworkConfig`

#### M0-02: Design System

- **Design System**: 14 reusable `Molt*` UI components implemented on both Android and iOS (Android + iOS)
  - `MoltButton` (4 variants: primary, secondary, outlined, text; loading state; leading icon)
  - `MoltTextField` (label, placeholder, error message, helper text, password toggle, maxLength counter)
  - `MoltCard` (`MoltProductCard` with image/price/rating/wishlist + `MoltInfoCard` generic)
  - `MoltChip` (`MoltFilterChip` with selected state + `MoltCategoryChip`)
  - `MoltTopBar` (back button, title, action slots with badge support)
  - `MoltBottomBar` / `MoltTabBar` (4-tab navigation with cart badge count)
  - `MoltLoadingView` (full-screen spinner) + `MoltLoadingIndicator` (inline)
  - `MoltErrorView` (error icon, message, optional retry)
  - `MoltEmptyView` (icon, message, optional action)
  - `MoltImage` (async image with shimmer placeholder and crossfade)
  - `MoltBadge` (`MoltCountBadge` 0/1–99/99+ + `MoltStatusBadge` 5 statuses)
  - `MoltRatingBar` (read-only, half-star precision, optional value and review count)
  - `MoltPriceText` (currency display, sale strikethrough, 3 size variants)
  - `MoltQuantityStepper` (increment/decrement with min/max enforcement)
- **Design tokens**: Full color palette (28 light + 28 dark + 15 semantic tokens), 15 typography styles, 9 base spacing tokens, layout constants, 6 corner radius levels, 6 elevation levels (Android + iOS)
- **Theme support**: `MoltTheme` composable wrapper (Android) / `ViewModifier` (iOS) with automatic light/dark mode switching (Android + iOS)
- **Localization**: 17 design system string keys (common accessibility labels, tab names, action strings) in English, Maltese, and Turkish (Android + iOS)
- **Tests**: ~90 Android Compose UI tests (15 files) + ~175 iOS Swift Testing tests (16 files); 14/14 components covered on both platforms (Android + iOS)

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
