# Changelog

All notable changes to the XiriGo Ecommerce Mobile App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

#### Design Quality Backfill (DQ-26)

- **XGLoadingView skeleton-aware rewrite**: Replaced centered spinner pattern (`CircularProgressIndicator` on Android, `ProgressView` on iOS) with skeleton-aware loading on both platforms. `XGLoadingView` and `XGLoadingIndicator` now accept an optional skeleton content slot (`@Composable` / `@ViewBuilder`) for custom skeleton placeholders. When no slot is provided, a default shimmer layout (box + lines for full-screen, line for inline) is shown. Added crossfade overloads (`isLoading: Boolean` + `content` slot) using `XGMotion.Crossfade.CONTENT_SWITCH` (200ms). Backward compatible: `XGLoadingView()` call sites continue to work without changes. All shimmer uses existing `shimmerEffect()` modifier and `XGColors.Shimmer` token. 14 Android Compose UI tests + 20 iOS Swift Testing tests verified. (#70) (Android + iOS)

### Added

#### Design Quality Backfill (DQ-19)

- **XGDivider component**: New `XGDivider` and `XGLabeledDivider` atom components added to the design system on both platforms. `XGDivider` wraps the platform-native divider with token defaults (color: `XGColors.Divider` `#E5E7EB`, thickness: 1dp/pt). `XGLabeledDivider` renders a line-label-line pattern using `captionMedium` typography (12sp/pt Poppins Medium) with `XGColors.TextTertiary` label color and 16dp/pt horizontal padding -- used for "OR CONTINUE WITH" dividers on the Login screen. Replaced raw `HorizontalDivider` in `ProfileScreen.kt` with `XGDivider`. 8 Android JVM token tests + 12 Android Compose UI tests + 19 iOS Swift Testing tests verified. (#63) (Android + iOS)

### Changed

#### Design Quality Backfill (DQ-15)

- **XGWishlistButton motion token upgrade**: Replaced static heart icon toggle with animated transitions on both platforms. Android: added `animateColorAsState` with `XGMotion.Easing.standardTween(XGMotion.Duration.INSTANT)` (100ms) for color transition, added `Animatable` + `XGMotion.Easing.springSpec()` (dampingRatio=0.7, stiffness=Medium) for scale bounce effect (1.2x snap then spring back to 1.0x). iOS: added `.easeInOut(duration: XGMotion.Duration.instant)` for color transition, added `XGMotion.Easing.spring` for scale bounce via `@State bounceScale`. Updated component token JSON to reference `$foundations/motion.duration.instant` and `$foundations/motion.easing.spring`. 15 Android JUnit token tests + 8 Android Compose UI tests + 24 iOS Swift Testing tests verified. (#59) (Android + iOS)

#### Design Quality Backfill (DQ-13)

- **XGSectionHeader token audit**: Audited and aligned `XGSectionHeader` on both platforms against `shared/design-tokens/components/atoms/xg-section-header.json`. Android: replaced 6 inline font constants (`fontFamily/fontSize/fontWeight`) with `MaterialTheme.typography.titleMedium` and `MaterialTheme.typography.labelLarge`, fixed subtitle font weight from `Normal` to `Medium`, corrected arrow icon size from 16dp to 12dp, added explicit subtitle spacing via `Arrangement.spacedBy(XGSpacing.XXS)`, removed `PoppinsFontFamily` direct import. iOS: removed unused `Constants.titleFontSize` and `Constants.seeAllFontSize` dead code, enhanced doc comment with full token mapping. 15 Android JUnit tests + 19 iOS Swift Testing tests verified. (#57) (Android + iOS)

#### Design Quality Backfill (DQ-12)

- **XGSearchBar token audit**: Audited and aligned `XGSearchBar` on both platforms against `shared/design-tokens/components/atoms/xg-search-bar.json`. Android: replaced `Card` wrapper with `Row` + `background` + `border` + `clip`, changed background from `SurfaceVariant` to `InputBackground`, corner radius from `Medium` (10dp) to `Pill` (28dp), removed elevation, added `OutlineVariant` border at 1dp, fixed padding from `Base` (16dp) to `MD` (12dp), added explicit 24dp icon size, removed redundant `PoppinsFontFamily` override. iOS: changed corner radius from `full` (999pt) to `pill` (28pt). 15 Android JUnit tests + 19 iOS Swift Testing tests verified. (#56) (Android + iOS)

### Added

#### Design Quality Backfill (DQ-09)

- **XGPaginationDots motion token upgrade**: Replaced hardcoded `tween(300ms)` animation on Android with `XGMotion.Easing.springSpec()` (spring with dampingRatio=0.7, stiffness=StiffnessMedium). iOS was already compliant (`XGMotion.Easing.spring`). Updated component token JSON to reference `$foundations/motion.easing.spring` instead of hardcoded spring parameters. Both platforms now use matching spring-based dot width animations. 6 Android instrumentation tests + 8 iOS unit tests verified. (#53) (Android + iOS)

#### Design Quality Backfill (DQ-08)

- **XGBadge token audit**: Audited and aligned the full badge component family (`XGBadge`, `XGCountBadge`, `XGStatusBadge`) against `shared/design-tokens/components/atoms/xg-badge.json`. Android: added `XGBadgeVariant` enum (Primary/Secondary), added `XGBadge` composable, fixed `XGStatusBadge` to use `XGColors` tokens instead of `MaterialTheme.colorScheme` references, corrected `XGCountBadge` shape from `CircleShape` to `RoundedCornerShape(XGCornerRadius.Full)` (capsule), added `XGCustomTextStyles.CaptionSemiBold` (12sp SemiBold Poppins). iOS: removed unused `Constants.fontSize` dead code; all token references were already spec-aligned. 56 Android tests (37 JVM unit + 19 Compose UI) + 89 iOS tests (88 passing, 1 skipped) across 11 suites. (Android + iOS)

#### Design Quality Backfill (DQ-01 – DQ-06)

- **Skeleton base components** (`SkeletonBox`, `SkeletonLine`, `SkeletonCircle`) for iOS — rectangular, text-line, and circular shimmer loading placeholders built on `XGColors.shimmer`, `XGCornerRadius`, and the existing `shimmerEffect()` modifier. `SkeletonLine` corner radius is fixed at `XGCornerRadius.small` (6pt); `SkeletonBox` defaults to `XGCornerRadius.medium` (10pt) and is configurable. (#50)
- **Content-wrapping `.skeleton(visible:placeholder:)` modifier for iOS** — `SkeletonModifier` (`ViewModifier`) crossfades between a skeleton placeholder layout and real content using `.transition(.opacity)` with `XGMotion.Crossfade.contentSwitch` (0.2s) easeInOut animation. Individual shapes are accessibility-hidden; the modifier announces "Loading content" (`skeleton_loading_placeholder`) to VoiceOver when visible. 37 Swift Testing unit tests across 7 suites. (iOS)

#### Design Quality Backfill (DQ-01 – DQ-04)

- **Motion Tokens (XGMotion)**: Centralized animation, transition, shimmer, scroll, and performance token namespace added to the design system theme layer (`XGMotion.kt` / `XGMotion.swift`). Covers 7 token categories — Duration (5), Easing (4), Shimmer (4), Crossfade (2), Scroll (2), EntranceAnimation (5), Performance (5) — all sourced from `shared/design-tokens/foundations/motion.json`. Replaces all previously hardcoded animation values in `XGImage` and `XGPaginationDots`. Includes `XGMotionTokenPreview` `@Preview` composable on Android. (Android + iOS)
- **Shimmer Effect Modifier**: `Modifier.shimmerEffect(enabled: Boolean)` extension (Android) and `View.shimmerEffect(active: Bool)` extension via `ShimmerModifier` ViewModifier (iOS). Applies an animated three-color linear gradient sweep (left-to-right, 20°, 1200ms, `#E0E0E0/#F5F5F5/#E0E0E0`) to any view shape for loading placeholder animations. GPU-accelerated via `graphicsLayer` (Android) / implicit SwiftUI layer (iOS). No-op when disabled. All parameters from `XGMotion.Shimmer` tokens. (Android + iOS)

#### M1-04: Home Screen

- **Home Screen**: Vertical scrollable feed with 7 sections (welcome header, search bar, hero banner carousel, categories, popular products, daily deal, new arrivals, flash sale banner) (Android + iOS)
- **6 new design system components**: `XGHeroBanner` (192dp gradient card), `XGCategoryIcon` (79dp colored tile), `XGSectionHeader` (title + subtitle + see-all action), `XGWishlistButton` (32dp heart toggle), `XGDailyDealCard` (163dp countdown card), `XGFlashSaleBanner` (133dp yellow banner with Canvas-drawn diagonal accent stripes) (Android + iOS)
- **Clean Architecture**: `HomeViewModel` with 6 use cases (`GetHomeBannersUseCase`, `GetHomeCategoriesUseCase`, `GetPopularProductsUseCase`, `GetDailyDealUseCase`, `GetNewArrivalsUseCase`, `GetFlashSaleUseCase`), `HomeRepository` interface, `FakeHomeRepository` with hardcoded sample data (Android + iOS)
- **Pull-to-refresh** with `wishedProductIds` preservation across reloads (Android + iOS)
- **Loading / Error / Empty states** via `HomeUiState.Loading`, `HomeUiState.Error`, `XGLoadingView`, `XGErrorView` (Android + iOS)
- **Hero banner auto-scroll** every 5 seconds with `XGPaginationDots`; resets timer on manual swipe (Android: `HorizontalPager` + `LaunchedEffect`; iOS: `TabView(.page)` + `Timer.publish`)
- **Daily deal countdown timer** ticking to zero, shows "ENDED" when expired (Android: `LaunchedEffect` loop; iOS: `TimelineView(.periodic)`) (Android + iOS)
- **Wishlist toggle** on product cards — local `Set<String>` state; will sync with shared wishlist repository in M2-02 (Android + iOS)
- **XGProductCard updated**: added optional `deliveryLabel` badge and `onAddToCartClick`/`onAddToCartAction` callback; internal wishlist replaced with `XGWishlistButton` component (Android + iOS)
- **12 new Android string keys** + **10 new iOS localization keys** (en / tr / mt) (Android + iOS)
- **157 unit tests**: 65 Android (8 files) + 92 iOS (8 files) covering ViewModel state transitions, all 6 use cases, FakeHomeRepository, and data integrity assertions (Android + iOS)

#### M4-05: App Onboarding

- **App onboarding**: 4-page horizontal pager shown on first launch only; returns immediately to main app on subsequent launches via DataStore (Android) / UserDefaults (iOS) flag (#35) (Android + iOS)
- **Splash screen**: Branded 4-layer background — `XGBrandGradient` base + `XGBrandPattern` X-tile overlay + `XGLogoMark` centered + `XGBrandGradient` dark overlay — displayed during the onboarding flag check (Android + iOS)
- **XGBrandGradient**: New design system component — reusable brand radial gradient background with 2-layer composition; used on Splash, Login (M1-01), and Home hero (M1-04) (Android + iOS)
- **XGBrandPattern**: New design system component — tiled white X-motif pattern overlay at 6% opacity for branded surfaces (Android + iOS)
- **XGLogoMark**: New design system component — two-chevron logo mark (green `#94D63A` + white `#FFFFFF`), scalable via `size` parameter (Android + iOS)
- **XGPaginationDots**: New design system component — animated horizontal pagination indicator with pill-shaped active dot (18dp) and circle inactive dots (6dp); reused on Home hero carousel and flash sale banner (Android + iOS)
- **Localization**: 10 content strings + 6 accessibility strings for onboarding screens in English, Maltese, and Turkish (Android + iOS)
- **Tests**: Android — 3 unit test files (`CheckOnboardingUseCaseTest`, `CompleteOnboardingUseCaseTest`, `OnboardingViewModelTest`) + `FakeOnboardingRepository`; iOS — 3 unit test files (`CheckOnboardingUseCaseTests`, `CompleteOnboardingUseCaseTests`, `OnboardingViewModelTests`) + `FakeOnboardingRepository` (Android + iOS)

#### M0-06: Auth Infrastructure

- **Auth Infrastructure**: Encrypted token storage, auth state management, session lifecycle, and token provider integration for the XiriGo Ecommerce buyer app (Android + iOS)
  - `TokenStorage` interface + `EncryptedTokenStorage` (Android, dedicated DataStore with Tink AES256_GCM encryption) / `KeychainTokenStorage` (iOS, KeychainAccess with `.whenUnlockedThisDeviceOnly`) for encrypted-at-rest JWT storage
  - `AuthState` sealed interface (Android) / enum (iOS): `Loading`, `Authenticated(token: String)`, `Guest` — annotated `@Stable` (Android) / `Equatable, Sendable` (iOS)
  - `AuthStateManager` interface + `AuthStateManagerImpl`: observable `StateFlow<AuthState>` (Android, `@Singleton`) / `@MainActor @Observable` class (iOS) with `checkStoredToken()`, `onLoginSuccess(token:)`, `onLogout()`
  - `SessionManager` as single public API for M1+ screens: coordinates `AuthApi` / `AuthEndpoint` + `TokenStorage` + `AuthStateManager`; `Mutex`-protected token refresh (Android) / private `RefreshActor` (iOS)
  - `AuthApi` Retrofit interface (Android) / `AuthEndpoint` Endpoint enum (iOS) covering all 5 auth endpoints: login, register, createSession, destroySession, refreshToken
  - `BiometricTokenStorage` interface stub (both platforms; implementation deferred to M3)
  - `AuthModule` (Android Hilt): `AuthBindsModule` + `AuthProvidesModule` with private `SessionTokenProvider` adapter + `Lazy<SessionManager>` for circular dependency resolution
  - `Container+Extensions.swift` updated (iOS): replaced `NoOpTokenProvider` with `LazyTokenProvider` + added `tokenStorage`, `authStateManager`, `sessionManager` singletons
  - `NetworkModule.kt` modified (Android): removed `InMemoryTokenProvider` and `provideTokenProvider()` — `TokenProvider` binding moved to `AuthModule`
  - Fire-and-forget logout (always clears local state regardless of API result), optimistic session on network failure (stays `Authenticated` if session validation fails due to network)
- **Tests**: 65 Android unit tests (5 files) + 56 iOS unit tests (5 files) — 121 total (Android + iOS)
  - Android: `TokenStorageTest` (11), `AuthStateManagerTest` (20), `SessionManagerTest` (20), `AuthModuleTest` (14) — `FakeTokenStorage` + `FakeAuthApi` fake pattern; Turbine for `StateFlow`/`Flow` assertions
  - iOS: `TokenStorageTests` (9), `AuthStateManagerTests` (11), `SessionManagerTests` (14), `AuthEndpointTests` (22) — `FakeTokenStorage` with call count tracking; `MockURLProtocol` for HTTP-level tests; `@Suite(.serialized)` for shared mock state

#### M0-05: DI Setup

- **DI Setup**: Hilt modules (Android) + Factory container registrations (iOS) for network, storage, coroutine, and common infrastructure dependencies (Android + iOS)
  - Five `@Qualifier` annotations (`@IoDispatcher`, `@MainDispatcher`, `@DefaultDispatcher`, `@AuthenticatedClient`, `@UnauthenticatedClient`) in `Qualifiers.kt` (Android)
  - `CoroutineModule`: three `CoroutineDispatcher` providers + app-scoped `CoroutineScope` with `SupervisorJob` + `@DefaultDispatcher` (Android)
  - `StorageModule`: `DataStore<Preferences>` (general preferences) + `XGDatabase` Room abstract class shell with `PlaceholderEntity` (required by Room KSP; removed when first real entity is added in M2-01) (Android)
  - `NetworkModule` updated with `@AuthenticatedClient` / `@UnauthenticatedClient` OkHttpClient split; `Retrofit` updated to use `@AuthenticatedClient` client (Android)
  - `Container+Extensions.swift` verified with `apiClient`, `tokenProvider`, `networkMonitor` singletons; feature DI pattern documented as inline MARK comments (iOS)
  - `NetworkMonitor` concrete `@Observable` class using `NWPathMonitor`; registered as `.singleton` in Container (iOS — from M0-03, verified in M0-05)
  - Canonical feature DI pattern documented for M1+: repository `@Binds` in `ViewModelComponent` + use case `@Inject constructor` (Android); `Container+<Name>.swift` extension with transient scope (iOS)
  - Test replacement pattern: `@TestInstallIn` for Hilt (Android); `Container.shared.reset()` + `.register { }` override (iOS)
  - All infrastructure dependencies scoped as singletons; repositories ViewModel-scoped (Android) / transient (iOS); use cases always transient
- **Tests**: 55 Android unit tests (4 files) + 21 iOS unit tests (2 files) — 76 total (Android + iOS)
  - Android: `QualifiersTest` (11), `CoroutineModuleTest` (10), `NetworkModuleTest` (25), `StorageModuleTest` (9) — Robolectric for Storage tests
  - iOS: `ContainerTests` (14), `NetworkMonitorTests` (7) — `@Suite(.serialized)` with `Container.shared.reset()` in `init()`

#### M0-04: Navigation

- **Navigation**: Type-safe tab-based routing and navigation infrastructure (Android + iOS)
  - Four-tab bottom bar (Home, Categories, Cart, Profile) using `XGBottomBar` (Android) / `XGTabBar` (iOS) from M0-02 Design System
  - Independent per-tab navigation stack with back-stack preservation on tab switch (`saveState`/`restoreState` on Android; four `NavigationPath` instances in `AppRouter` on iOS)
  - 29 type-safe route definitions covering all M0–M4 screens (`@Serializable` sealed interface on Android; `Hashable` enum with associated values on iOS)
  - `isAuthRequired` / `requiresAuth` computed property on `Route` for 14 auth-protected destinations
  - Auth-gated navigation with `returnTo` redirect: guests attempting auth-required routes are redirected to Login and returned to their intended destination after login
  - Deep link parsing for `xirigo://` custom scheme and `https://xirigo.com/` universal links (`DeepLinkParser` object/enum with stateless `parse()` function)
  - Deep link intent filters and `singleTask` launch mode declared in `AndroidManifest.xml`; `CFBundleURLTypes` registered in iOS `Info.plist`
  - Cart badge count wired to `XGBottomBar`/`XGTabBar` (defaults to 0 and hidden until M2-01 provides cart count)
  - Auth gating wired with stub (always guest) until M0-06 Auth Infrastructure provides `AuthStateProvider`
  - Placeholder screens (`PlaceholderScreen` / `PlaceholderView`) for all unimplemented routes, replaced feature-by-feature in M1+
  - Tab bar hidden for fullscreen flows: Login, Register, ForgotPassword, Onboarding, all Checkout sub-screens, OrderConfirmation
  - 10 new localization keys in English, Maltese, and Turkish (tab labels, placeholder copy, guest profile prompt, cart badge description)
- **Tests**: ~138 Android tests (7 files, JUnit 4 + Truth + Compose UI Test + Robolectric) + ~167 iOS tests (5 files, Swift Testing) — ~305 total
  - Android: `DeepLinkParserTest` (15), `RouteAuthTest` (19), `TopLevelDestinationTest` (11), `RouteSerializationTest` (~44), `DeepLinkParserEdgeCasesTest` (~28), `XGAppScaffoldTest` (~11), `PlaceholderScreenTest` (~10)
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

- **Design System**: 14 reusable `XG*` UI components implemented on both Android and iOS (Android + iOS)
  - `XGButton` (4 variants: primary, secondary, outlined, text; loading state; leading icon)
  - `XGTextField` (label, placeholder, error message, helper text, password toggle, maxLength counter)
  - `XGCard` (`XGProductCard` with image/price/rating/wishlist + `XGInfoCard` generic)
  - `XGChip` (`XGFilterChip` with selected state + `XGCategoryChip`)
  - `XGTopBar` (back button, title, action slots with badge support)
  - `XGBottomBar` / `XGTabBar` (4-tab navigation with cart badge count)
  - `XGLoadingView` (full-screen spinner) + `XGLoadingIndicator` (inline)
  - `XGErrorView` (error icon, message, optional retry)
  - `XGEmptyView` (icon, message, optional action)
  - `XGImage` (async image with shimmer placeholder and crossfade)
  - `XGBadge` (`XGCountBadge` 0/1–99/99+ + `XGStatusBadge` 5 statuses)
  - `XGRatingBar` (read-only, half-star precision, optional value and review count)
  - `XGPriceText` (currency display, sale strikethrough, 3 size variants)
  - `XGQuantityStepper` (increment/decrement with min/max enforcement)
- **Design tokens**: Full color palette (28 light + 28 dark + 15 semantic tokens), 15 typography styles, 9 base spacing tokens, layout constants, 6 corner radius levels, 6 elevation levels (Android + iOS)
- **Theme support**: `XGTheme` composable wrapper (Android) / `ViewModifier` (iOS) with automatic light/dark mode switching (Android + iOS)
- **Localization**: 17 design system string keys (common accessibility labels, tab names, action strings) in English, Maltese, and Turkish (Android + iOS)
- **Tests**: ~90 Android Compose UI tests (15 files) + ~175 iOS Swift Testing tests (16 files); 14/14 components covered on both platforms (Android + iOS)

#### M0-01: App Scaffold

- **Android project structure** with Gradle KTS and version catalog (`libs.versions.toml`)
  - 23 implementation files (XGApplication, MainActivity, design system theme shell)
  - Three build types: debug, staging, release with environment-specific API URLs
  - Hilt DI setup (@HiltAndroidApp, @AndroidEntryPoint)
  - Android 12+ splash screen with edge-to-edge support
  - Network security configuration (HTTPS enforced)
  - SDK: minSdk 26, targetSdk 35, compileSdk 35, Kotlin 2.1.10, Compose BOM 2026.01.01
- **iOS project structure** with Xcode and SPM dependencies
  - 13 implementation files (XiriGoEcommerceApp, Config, design system theme shell)
  - Three xcconfig files: Debug, Staging, Release with environment-specific API URLs
  - Factory DI container setup
  - SwiftUI entry point with placeholder screen
  - iOS 17.0 minimum, Swift 6.0, Strict Concurrency Complete
- **Design system theme shell** (both platforms)
  - XGColors: 67 Android colors / 32 iOS colors from design tokens
  - XGTypography: 15 text styles (Display, Headline, Title, Body, Label)
  - XGSpacing: 16 spacing constants (base + layout)
  - XGTheme: Composable theme wrapper (Android) / ViewModifier (iOS)
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
