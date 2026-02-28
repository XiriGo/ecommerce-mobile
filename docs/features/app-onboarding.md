# App Onboarding (M4-05)

**GitHub Issue**: #35
**Milestone**: M4 — Enhancements
**Platforms**: Android + iOS

---

## Overview

The App Onboarding feature provides a first-launch experience for new users. It consists of a branded splash screen followed by a 4-page horizontal pager that introduces key app features. The flow is shown only once per device installation; returning users bypass it entirely.

The feature also introduces four new reusable design system components (`XGBrandGradient`, `XGBrandPattern`, `XGLogoMark`, `XGPaginationDots`) used across multiple future screens.

### User Stories

- New user sees a branded splash screen on first open, establishing the XiriGo brand identity.
- New user swipes through 4 onboarding pages explaining Browse, Compare, Checkout, and Track.
- New user can tap "Skip" on any page (except the last) to enter the app immediately.
- New user taps "Get Started" on the last page to complete onboarding.
- Returning user never sees onboarding again after completing it once.
- Developer can import `XGBrandGradient` and `XGLogoMark` for use on Login and Home screens.

---

## Architecture

### Clean Architecture Layers

```
SplashScreen / OnboardingScreen
        |
        v
  OnboardingViewModel
  (uiState: Loading | ShowOnboarding | OnboardingComplete)
  (currentPage: Int 0-3)
        |
        v
  CheckOnboardingUseCase    CompleteOnboardingUseCase
        |                            |
        +------------+---------------+
                     |
                     v
           OnboardingRepository (interface)
                     |
                     v
         OnboardingRepositoryImpl
         (DataStore<Preferences>)    (UserDefaults)
               Android                   iOS
```

### State Machine

```
[Loading]
    |
    +--> hasSeenOnboarding == true  --> [OnboardingComplete] --> Main App
    |
    +--> hasSeenOnboarding == false --> [ShowOnboarding]
                                            |
                                            +--> Skip / Get Started
                                            |
                                            v
                                       [OnboardingComplete] --> Main App
```

### Layer Summary

| Layer | Responsibility |
|-------|---------------|
| Domain | `OnboardingPage` model, `OnboardingRepository` interface, `CheckOnboardingUseCase`, `CompleteOnboardingUseCase` |
| Data | `OnboardingRepositoryImpl` — reads/writes a boolean flag via DataStore (Android) or UserDefaults (iOS) |
| Presentation | `OnboardingViewModel`, `OnboardingUiState`, `SplashScreen`, `OnboardingScreen`, `OnboardingPageContent` |
| Design System | `XGBrandGradient`, `XGBrandPattern`, `XGLogoMark`, `XGPaginationDots` |

---

## Design System Components

Four new components added to `core/designsystem/component/`. All are reusable across the app.

### XGBrandGradient

Renders the brand's signature radial gradient background. Used as the full-bleed background for the Splash screen, Onboarding screen, Login screen, and Home hero banner.

**Visual Layers** (bottom to top):
1. Base radial gradient: `#9000FE` (0%) → `#6900FE` (27%) → `#6900FE` (66%) → `#9000FE` (100%)
2. Dark overlay radial gradient: `#6000FE` at 0% opacity (32%) → `#3C00D2` at 100% opacity (90%)

**API**:

```kotlin
// Android
@Composable
fun XGBrandGradient(
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit = {}
)
```

```swift
// iOS
struct XGBrandGradient<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content = { EmptyView() })
}
```

### XGBrandPattern

Renders the tiled white X-motif pattern overlay used on branded surfaces. Applied at 6% opacity on top of `XGBrandGradient`.

**Token**: `gradients.json > splashPatternOverlay` — color `#FFFFFF`, opacity 6%
**Asset**: `brand_pattern_tile.xml` (Android) / `BrandPatternTile.imageset` (iOS)

**API**:

```kotlin
// Android
@Composable fun XGBrandPattern(modifier: Modifier = Modifier)
```

```swift
// iOS
struct XGBrandPattern: View
```

### XGLogoMark

Renders the XiriGo two-chevron logo mark (green top chevron `#94D63A`, white bottom chevron `#FFFFFF`). Used on the Splash screen and future loading/about screens.

**API**:

```kotlin
// Android
@Composable
fun XGLogoMark(modifier: Modifier = Modifier, size: Dp = 120.dp)
```

```swift
// iOS
struct XGLogoMark: View {
    var size: CGFloat = 120
}
```

### XGPaginationDots

Animated horizontal pagination indicator. Active dot is a pill (18dp wide), inactive dots are circles (6dp wide). Animates width on page change.

**Tokens**: `$paginationDots.active` = `#6000FE`, `$paginationDots.inactive` = `#D1D5DB`
**Reuse locations**: Onboarding pager, Home hero carousel, Flash sale banner.

**API**:

```kotlin
// Android
@Composable
fun XGPaginationDots(
    totalPages: Int,
    currentPage: Int,
    modifier: Modifier = Modifier,
    activeColor: Color = XGColors.paginationDots.active,
    inactiveColor: Color = XGColors.paginationDots.inactive
)
```

```swift
// iOS
struct XGPaginationDots: View {
    let totalPages: Int
    let currentPage: Int
    var activeColor: Color = .xgPaginationDotsActive
    var inactiveColor: Color = .xgPaginationDotsInactive
}
```

---

## Screen Descriptions

### Splash Screen

Displayed during the `Loading` state while `OnboardingViewModel` checks the `hasSeenOnboarding` flag. No timer — transitions immediately when the check completes.

**Visual layer stack** (bottom to top):
1. `XGBrandGradient` base layer (full bleed)
2. `XGBrandPattern` (white X tiles at 6% opacity)
3. `XGLogoMark` (centered, ~120×124)
4. `XGBrandGradient` dark overlay

### Onboarding Pager Screen

Shown when `uiState == ShowOnboarding`. A full-bleed `XGBrandGradient` background with a `HorizontalPager` (Android) / `TabView(.page)` (iOS) of 4 pages.

**Pages**:

| # | Title | Description |
|---|-------|-------------|
| 0 | Browse Thousands of Products | Explore a wide range of products from multiple vendors in one place |
| 1 | Compare Vendors & Prices | Find the best deals by comparing prices across different vendors |
| 2 | Fast & Secure Checkout | Pay securely with multiple payment options and fast processing |
| 3 | Track Your Orders | Stay updated with real-time order tracking from purchase to delivery |

**Controls**:
- "Skip" text button (top-right, white, 14px) — visible on pages 0–2, hidden on page 3
- `XGPaginationDots` (centered, bottom) — animated active dot tracking current page
- "Get Started" `XGButton` (full-width, secondary style) — visible only on page 3

### OnboardingPageContent

Single-page composable/view: centered illustration (~200×200), title (Poppins SemiBold 24px, white), description (Poppins Regular 16px, 80% white opacity).

---

## Navigation Flow

### App Launch

```
App Launch
    |
    v
OnboardingViewModel.init() → checkOnboarding()
    |
    +--> true  → uiState = OnboardingComplete → Main App (no animation)
    |
    +--> false → uiState = ShowOnboarding
                     |
                     +--> Swipe pages (page 0-3)
                     +--> Tap "Skip" → completeOnboarding() → Main App
                     +--> Tap "Get Started" (page 3) → completeOnboarding() → Main App
```

### Platform Integration

**Android**: `MainActivity` observes `uiState`. Shows `SplashScreen` during `Loading`, `OnboardingScreen` during `ShowOnboarding`, `XGAppScaffold` during `OnboardingComplete`. Navigation uses `popUpTo(Route.Onboarding) { inclusive = true }` to prevent back-navigation to onboarding.

**iOS**: `XiriGoEcommerceApp` observes `OnboardingViewModel.uiState`. Shows `SplashScreen` / `OnboardingScreen` / `MainTabView` based on state. Uses `AppRouter.isShowingOnboarding` flag defined in M0-04 Navigation.

---

## Data Flow

```
UI Event (Skip / GetStarted / PageChanged)
    |
    v
OnboardingViewModel.on{Skip,GetStarted,PageChanged}()
    |
    v
CompleteOnboardingUseCase.invoke() / execute()
    |
    v
OnboardingRepository.setOnboardingSeen()
    |
    v
DataStore.edit { prefs[HAS_SEEN_ONBOARDING] = true }   (Android)
UserDefaults.set(true, forKey: "has_seen_onboarding")  (iOS)
    |
    v
_uiState.value = OnboardingComplete  (Android StateFlow)
uiState = .onboardingComplete        (iOS @Observable)
    |
    v
UI transitions to Main App
```

---

## Localization

16 string keys added across English (en), Maltese (mt), and Turkish (tr).

### Content Strings

| Key | English |
|-----|---------|
| `onboarding_skip_button` | Skip |
| `onboarding_get_started_button` | Get Started |
| `onboarding_page_browse_title` | Browse Thousands of Products |
| `onboarding_page_browse_description` | Explore a wide range of products from multiple vendors in one place |
| `onboarding_page_compare_title` | Compare Vendors & Prices |
| `onboarding_page_compare_description` | Find the best deals by comparing prices across different vendors |
| `onboarding_page_checkout_title` | Fast & Secure Checkout |
| `onboarding_page_checkout_description` | Pay securely with multiple payment options and fast processing |
| `onboarding_page_track_title` | Track Your Orders |
| `onboarding_page_track_description` | Stay updated with real-time order tracking from purchase to delivery |

### Accessibility Strings

| Key | English |
|-----|---------|
| `onboarding_skip_button_a11y` | Skip onboarding |
| `onboarding_page_indicator_a11y` | Page %1$d of %2$d |
| `onboarding_illustration_a11y_browse` | Illustration of marketplace browsing |
| `onboarding_illustration_a11y_compare` | Illustration of price comparison |
| `onboarding_illustration_a11y_checkout` | Illustration of secure checkout |
| `onboarding_illustration_a11y_track` | Illustration of order tracking |

**Android**: Added to `res/values/strings.xml`, `res/values-mt/strings.xml`, `res/values-tr/strings.xml`
**iOS**: Added to `Resources/Localizable.xcstrings` String Catalog for all three locales

---

## Test Coverage

### Android — 4 test files

| File | Description |
|------|-------------|
| `CheckOnboardingUseCaseTest.kt` | Unit tests for `CheckOnboardingUseCase` — delegates to repository |
| `CompleteOnboardingUseCaseTest.kt` | Unit tests for `CompleteOnboardingUseCase` — delegates to repository |
| `OnboardingViewModelTest.kt` | ViewModel state transitions: Loading→ShowOnboarding, Loading→OnboardingComplete, Skip, GetStarted, PageChanged |
| `FakeOnboardingRepository.kt` | In-memory fake implementing `OnboardingRepository` for test isolation |

### iOS — 4 test files

| File | Description |
|------|-------------|
| `CheckOnboardingUseCaseTests.swift` | Unit tests for `CheckOnboardingUseCase.execute()` |
| `CompleteOnboardingUseCaseTests.swift` | Unit tests for `CompleteOnboardingUseCase.execute()` |
| `OnboardingViewModelTests.swift` | ViewModel state transitions: loading→showOnboarding, loading→onboardingComplete, onSkip, onGetStarted |
| `FakeOnboardingRepository.swift` | In-memory fake conforming to `OnboardingRepository` |

---

## File Manifest

### Android

**Design System** — `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/`

| File | Description |
|------|-------------|
| `XGBrandGradient.kt` | Brand radial gradient background (2-layer) |
| `XGBrandPattern.kt` | Tiled X-motif pattern overlay at 6% opacity |
| `XGLogoMark.kt` | Two-chevron logo mark (green + white) |
| `XGPaginationDots.kt` | Animated pill/circle pagination indicator |

**Feature** — `android/app/src/main/java/com/xirigo/ecommerce/feature/onboarding/`

| File | Description |
|------|-------------|
| `domain/model/OnboardingPage.kt` | Data class: `titleResId`, `descriptionResId`, `illustrationResId` |
| `domain/repository/OnboardingRepository.kt` | Interface: `hasSeenOnboarding()`, `setOnboardingSeen()` |
| `domain/usecase/CheckOnboardingUseCase.kt` | Use case wrapping `hasSeenOnboarding()` |
| `domain/usecase/CompleteOnboardingUseCase.kt` | Use case wrapping `setOnboardingSeen()` |
| `data/repository/OnboardingRepositoryImpl.kt` | DataStore-backed implementation, key `"has_seen_onboarding"` |
| `presentation/state/OnboardingUiState.kt` | Sealed interface: `Loading`, `ShowOnboarding`, `OnboardingComplete` |
| `presentation/viewmodel/OnboardingViewModel.kt` | `@HiltViewModel` with `uiState: StateFlow`, `currentPage: StateFlow` |
| `presentation/screen/SplashScreen.kt` | Branded splash: gradient + pattern + logo + dark overlay |
| `presentation/screen/OnboardingScreen.kt` | `HorizontalPager` with skip, get started, pagination dots |
| `presentation/screen/OnboardingPageContent.kt` | Single page: illustration + title + description |
| `di/OnboardingModule.kt` | Hilt `@Module` binding `OnboardingRepositoryImpl` → `OnboardingRepository` |

**Resources** — `android/app/src/main/res/`

| File | Description |
|------|-------------|
| `drawable/onboarding_illustration_browse.xml` | Placeholder vector: browse page |
| `drawable/onboarding_illustration_compare.xml` | Placeholder vector: compare page |
| `drawable/onboarding_illustration_checkout.xml` | Placeholder vector: checkout page |
| `drawable/onboarding_illustration_track.xml` | Placeholder vector: track page |
| `drawable/brand_pattern_tile.xml` | Single X-motif tile for `XGBrandPattern` |
| `drawable/logo_mark.xml` | Two-chevron logo mark vector |
| `values/strings.xml` | +16 onboarding string keys (EN) |
| `values-mt/strings.xml` | +16 onboarding string keys (MT) |
| `values-tr/strings.xml` | +16 onboarding string keys (TR) |

**Tests** — `android/app/src/test/java/com/xirigo/ecommerce/feature/onboarding/`

| File | Description |
|------|-------------|
| `domain/usecase/CheckOnboardingUseCaseTest.kt` | Use case tests |
| `domain/usecase/CompleteOnboardingUseCaseTest.kt` | Use case tests |
| `presentation/viewmodel/OnboardingViewModelTest.kt` | ViewModel state transition tests |
| `data/repository/FakeOnboardingRepository.kt` | Test fake |

**Modified**:

| File | Change |
|------|--------|
| `MainActivity.kt` | Observes `OnboardingViewModel.uiState` to show Splash / Onboarding / Main App |

---

### iOS

**Design System** — `ios/XiriGoEcommerce/Core/DesignSystem/Component/`

| File | Description |
|------|-------------|
| `XGBrandGradient.swift` | `struct XGBrandGradient<Content: View>` with 2-layer radial gradient |
| `XGBrandPattern.swift` | `struct XGBrandPattern: View` tiled X-motif at 6% opacity |
| `XGLogoMark.swift` | `struct XGLogoMark: View` two-chevron logo mark |
| `XGPaginationDots.swift` | `struct XGPaginationDots: View` animated pill/circle indicator |

**Feature** — `ios/XiriGoEcommerce/Feature/Onboarding/`

| File | Description |
|------|-------------|
| `Domain/Model/OnboardingPage.swift` | `struct OnboardingPage: Identifiable, Sendable` |
| `Domain/Repository/OnboardingRepository.swift` | `protocol OnboardingRepository: Sendable` |
| `Domain/UseCase/CheckOnboardingUseCase.swift` | `struct CheckOnboardingUseCase: Sendable` |
| `Domain/UseCase/CompleteOnboardingUseCase.swift` | `struct CompleteOnboardingUseCase: Sendable` |
| `Data/Repository/OnboardingRepositoryImpl.swift` | `final class OnboardingRepositoryImpl: OnboardingRepository, Sendable` — UserDefaults |
| `Presentation/State/OnboardingUiState.swift` | `enum OnboardingUiState: Equatable, Sendable` |
| `Presentation/ViewModel/OnboardingViewModel.swift` | `@MainActor @Observable final class OnboardingViewModel` |
| `Presentation/Screen/SplashScreen.swift` | `struct SplashScreen: View` — branded splash |
| `Presentation/Screen/OnboardingScreen.swift` | `struct OnboardingScreen: View` — `TabView(.page)` pager |
| `Presentation/Screen/OnboardingPageContent.swift` | `struct OnboardingPageContent: View` — single page content |

**DI**:

| File | Description |
|------|-------------|
| `ios/XiriGoEcommerce/Core/DI/Container+Onboarding.swift` | Factory registrations for repository, use cases, and view model |

**Assets** — `ios/XiriGoEcommerce/Resources/Assets.xcassets/`

| Asset | Description |
|-------|-------------|
| `OnboardingIllustrationBrowse.imageset/` | Placeholder illustration: browse |
| `OnboardingIllustrationCompare.imageset/` | Placeholder illustration: compare |
| `OnboardingIllustrationCheckout.imageset/` | Placeholder illustration: checkout |
| `OnboardingIllustrationTrack.imageset/` | Placeholder illustration: track |
| `BrandPatternTile.imageset/` | X-motif tile for `XGBrandPattern` |
| `LogoMark.imageset/` | Two-chevron logo mark image |

**Tests** — `ios/XiriGoEcommerceTests/Feature/Onboarding/`

| File | Description |
|------|-------------|
| `Domain/UseCase/CheckOnboardingUseCaseTests.swift` | Use case tests |
| `Domain/UseCase/CompleteOnboardingUseCaseTests.swift` | Use case tests |
| `Presentation/ViewModel/OnboardingViewModelTests.swift` | ViewModel state transition tests |
| `Data/Repository/FakeOnboardingRepository.swift` | Test fake |

**Modified**:

| File | Change |
|------|--------|
| `XiriGoEcommerceApp.swift` | Observes `OnboardingViewModel.uiState` — shows SplashScreen / OnboardingScreen / MainTabView |
| `Resources/Localizable.xcstrings` | +16 onboarding string keys (EN, MT, TR) |

---

## API

This feature is entirely client-side. There are no backend API calls. All data originates from localized string resources, bundled illustration assets, and local storage (DataStore / UserDefaults).

---

## Dependencies

| Feature | What This Feature Needs |
|---------|------------------------|
| M0-01: App Scaffold | Project structure, `XGTheme`, entry points |
| M0-02: Design System | `XGButton` (primary/secondary variants), design tokens |
| M0-04: Navigation | `Route.Onboarding`, `AppRouter.isShowingOnboarding` |
| M0-05: DI Setup | DI container, `DataStore<Preferences>` provider |

## Downstream Dependents

| Feature | What It Reuses |
|---------|---------------|
| M1-01: Login | `XGBrandGradient`, `XGBrandPattern`, `XGLogoMark` |
| M1-04: Home | `XGBrandGradient` (hero banner), `XGPaginationDots` (hero carousel, flash sale) |

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| DataStore read throws | Defaults to `false` (show onboarding). Error logged. |
| DataStore write fails | Onboarding will show again on next launch. No user-facing error. |
| Missing illustration asset | Empty space rendered. Title and description still visible. |
| App killed during onboarding | Flag not written — onboarding shows again on next launch. Expected. |
| App data cleared | Flag erased — onboarding shows again. Expected. |
