# M4-05: App Onboarding -- Feature Specification

## Overview

The App Onboarding feature provides a first-launch experience consisting of a branded splash
screen followed by a horizontal pager with 4 onboarding pages. The splash screen showcases
the XiriGo brand identity with layered gradients, a tiled X-pattern overlay, and the logo mark.
The onboarding pages introduce key app features with illustrations, titles, and descriptions.
The entire flow is shown only once per device installation.

### User Stories

- As a **new user**, I want to see a branded splash screen when I first open the app so I recognize the XiriGo brand.
- As a **new user**, I want to swipe through onboarding pages explaining key features so I understand what the app offers.
- As a **new user**, I want to skip the onboarding at any point so I can start using the app immediately.
- As a **new user**, I want to tap "Get Started" on the last page to enter the main app.
- As a **returning user**, I want the onboarding to never appear again after I have seen it once.
- As a **developer**, I want the branded gradient and logo components to be reusable so they can be used on Login and Home screens.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Branded splash screen (gradient + pattern + logo + vignette) | Login screen UI (M1-01, reuses XGBrandGradient) |
| 4-page horizontal onboarding pager | Home hero banner (M1-04, reuses XGBrandGradient) |
| Page dots, Skip button, Get Started button | Onboarding content A/B testing |
| Show-once flag in local storage | Force-update check (handled by Firebase Remote Config) |
| XGBrandGradient reusable component | Animation/motion design beyond page transitions |
| XGBrandPattern reusable component | Video or Lottie illustrations |
| XGLogoMark reusable component | |
| XGPaginationDots reusable component | |

### Dependencies on Other Features

| Feature | What This Feature Needs |
|---------|------------------------|
| M0-01: App Scaffold | Project structure, `XGTheme`, entry points, splash screen hook |
| M0-02: Design System | `XGButton` (primary variant), design token infrastructure |
| M0-04: Navigation | `Route.Onboarding` route definition, `AppRouter.isShowingOnboarding` (iOS) |
| M0-05: DI Setup | DI container for repository binding |

### Features That Depend on This

| Feature | What It Reuses |
|---------|---------------|
| M1-01: Login | `XGBrandGradient`, `XGBrandPattern`, `XGLogoMark` |
| M1-04: Home | `XGBrandGradient` (hero banner), `XGPaginationDots` (hero carousel, flash sale) |

---

## 1. API Mapping

This feature is entirely client-side. There are no backend API calls. All data is local:

- Onboarding content comes from localized string resources and bundled illustration assets.
- The "has seen onboarding" flag is stored in local storage (DataStore on Android, UserDefaults on iOS).

---

## 2. Data Models

### 2.1 OnboardingPage

A data model representing a single onboarding page. Content is driven by localized string
keys and bundled illustration resource references.

**Android (Kotlin)**:

```
Data class: OnboardingPage
Package: com.xirigo.ecommerce.feature.onboarding.domain.model

Properties:
  - titleResId: Int              -- R.string.onboarding_page_*_title
  - descriptionResId: Int        -- R.string.onboarding_page_*_description
  - illustrationResId: Int       -- R.drawable.onboarding_illustration_*
```

**iOS (Swift)**:

```
Struct: OnboardingPage
File: OnboardingPage.swift
Conforms to: Identifiable, Sendable

Properties:
  - id: Int                      -- page index (0-3)
  - titleKey: String.LocalizationValue  -- localization key for title
  - descriptionKey: String.LocalizationValue  -- localization key for description
  - illustrationName: String     -- asset catalog image name
```

**Page Content Table**:

| Page | Title Key | Description Key | Illustration Asset |
|------|-----------|-----------------|-------------------|
| 0 | `onboarding_page_browse_title` | `onboarding_page_browse_description` | `onboarding_illustration_browse` |
| 1 | `onboarding_page_compare_title` | `onboarding_page_compare_description` | `onboarding_illustration_compare` |
| 2 | `onboarding_page_checkout_title` | `onboarding_page_checkout_description` | `onboarding_illustration_checkout` |
| 3 | `onboarding_page_track_title` | `onboarding_page_track_description` | `onboarding_illustration_track` |

### 2.2 OnboardingUiState

**Android (Kotlin)**:

```
Sealed interface: OnboardingUiState
Package: com.xirigo.ecommerce.feature.onboarding.presentation.state

Values:
  - Loading            -- checking if onboarding has been seen
  - ShowOnboarding     -- first launch, display the onboarding flow
  - OnboardingComplete -- flag is set, navigate to main app
```

**iOS (Swift)**:

```
Enum: OnboardingUiState
File: OnboardingUiState.swift
Conforms to: Equatable, Sendable

Cases:
  - loading            -- checking if onboarding has been seen
  - showOnboarding     -- first launch, display the onboarding flow
  - onboardingComplete -- flag is set, navigate to main app
```

---

## 3. Architecture

### 3.1 Clean Architecture Layers

```
SplashScreen/OnboardingScreen
        |
        v
  OnboardingViewModel
        |
        v
  CheckOnboardingUseCase / CompleteOnboardingUseCase
        |
        v
  OnboardingRepository (interface)
        |
        v
  OnboardingRepositoryImpl (DataStore / UserDefaults)
```

### 3.2 Domain Layer

#### OnboardingRepository Interface

**Android (Kotlin)**:

```
Interface: OnboardingRepository
Package: com.xirigo.ecommerce.feature.onboarding.domain.repository

Methods:
  - suspend fun hasSeenOnboarding(): Boolean
  - suspend fun setOnboardingSeen()
```

**iOS (Swift)**:

```
Protocol: OnboardingRepository
File: OnboardingRepository.swift
Conforms to: Sendable

Methods:
  - func hasSeenOnboarding() async -> Bool
  - func setOnboardingSeen() async
```

#### CheckOnboardingUseCase

**Android (Kotlin)**:

```
Class: CheckOnboardingUseCase
Package: com.xirigo.ecommerce.feature.onboarding.domain.usecase
Constructor: @Inject constructor(private val repository: OnboardingRepository)

Method:
  - suspend operator fun invoke(): Boolean
    Returns repository.hasSeenOnboarding()
```

**iOS (Swift)**:

```
Struct: CheckOnboardingUseCase
File: CheckOnboardingUseCase.swift
Conforms to: Sendable

Property:
  - private let repository: OnboardingRepository

Method:
  - func execute() async -> Bool
    Returns await repository.hasSeenOnboarding()
```

#### CompleteOnboardingUseCase

**Android (Kotlin)**:

```
Class: CompleteOnboardingUseCase
Package: com.xirigo.ecommerce.feature.onboarding.domain.usecase
Constructor: @Inject constructor(private val repository: OnboardingRepository)

Method:
  - suspend operator fun invoke()
    Calls repository.setOnboardingSeen()
```

**iOS (Swift)**:

```
Struct: CompleteOnboardingUseCase
File: CompleteOnboardingUseCase.swift
Conforms to: Sendable

Property:
  - private let repository: OnboardingRepository

Method:
  - func execute() async
    Calls await repository.setOnboardingSeen()
```

### 3.3 Data Layer

#### OnboardingRepositoryImpl

**Android (Kotlin)**:

```
Class: OnboardingRepositoryImpl
Package: com.xirigo.ecommerce.feature.onboarding.data.repository
Constructor: @Inject constructor(private val dataStore: DataStore<Preferences>)

Storage key:
  - private val HAS_SEEN_ONBOARDING = booleanPreferencesKey("has_seen_onboarding")

Methods:
  - suspend fun hasSeenOnboarding(): Boolean
    return dataStore.data.first()[HAS_SEEN_ONBOARDING] ?: false

  - suspend fun setOnboardingSeen()
    dataStore.edit { prefs -> prefs[HAS_SEEN_ONBOARDING] = true }
```

**iOS (Swift)**:

```
Final class: OnboardingRepositoryImpl
File: OnboardingRepositoryImpl.swift
Conforms to: OnboardingRepository, Sendable

Storage key:
  - private static let hasSeenOnboardingKey = "has_seen_onboarding"

Properties:
  - private let defaults: UserDefaults

Init:
  - init(defaults: UserDefaults = .standard)

Methods:
  - func hasSeenOnboarding() async -> Bool
    return defaults.bool(forKey: Self.hasSeenOnboardingKey)

  - func setOnboardingSeen() async
    defaults.set(true, forKey: Self.hasSeenOnboardingKey)
```

**Note**: UserDefaults is appropriate here because this is a non-sensitive boolean flag.
Auth tokens and credentials use Keychain/EncryptedDataStore per security standards.

### 3.4 Presentation Layer

#### OnboardingViewModel

**Android (Kotlin)**:

```
Class: OnboardingViewModel
Package: com.xirigo.ecommerce.feature.onboarding.presentation.viewmodel
Annotation: @HiltViewModel
Constructor: @Inject constructor(
    private val checkOnboarding: CheckOnboardingUseCase,
    private val completeOnboarding: CompleteOnboardingUseCase
)

State:
  - private val _uiState = MutableStateFlow<OnboardingUiState>(OnboardingUiState.Loading)
  - val uiState: StateFlow<OnboardingUiState> = _uiState.asStateFlow()

  - private val _currentPage = MutableStateFlow(0)
  - val currentPage: StateFlow<Int> = _currentPage.asStateFlow()

Init:
  - viewModelScope.launch {
      val hasSeen = checkOnboarding()
      _uiState.value = if (hasSeen) OnboardingUiState.OnboardingComplete
                        else OnboardingUiState.ShowOnboarding
    }

Methods:
  - fun onPageChanged(page: Int)
    _currentPage.value = page

  - fun onSkip()
    viewModelScope.launch {
        completeOnboarding()
        _uiState.value = OnboardingUiState.OnboardingComplete
    }

  - fun onGetStarted()
    viewModelScope.launch {
        completeOnboarding()
        _uiState.value = OnboardingUiState.OnboardingComplete
    }

Pages (companion object or top-level):
  val pages = listOf(
      OnboardingPage(R.string.onboarding_page_browse_title, R.string.onboarding_page_browse_description, R.drawable.onboarding_illustration_browse),
      OnboardingPage(R.string.onboarding_page_compare_title, R.string.onboarding_page_compare_description, R.drawable.onboarding_illustration_compare),
      OnboardingPage(R.string.onboarding_page_checkout_title, R.string.onboarding_page_checkout_description, R.drawable.onboarding_illustration_checkout),
      OnboardingPage(R.string.onboarding_page_track_title, R.string.onboarding_page_track_description, R.drawable.onboarding_illustration_track)
  )
```

**iOS (Swift)**:

```
@MainActor @Observable
Final class: OnboardingViewModel
File: OnboardingViewModel.swift

Properties:
  - private let checkOnboarding: CheckOnboardingUseCase
  - private let completeOnboarding: CompleteOnboardingUseCase

  - private(set) var uiState: OnboardingUiState = .loading
  - var currentPage: Int = 0

  - let pages: [OnboardingPage] = [
      OnboardingPage(id: 0, titleKey: "onboarding_page_browse_title", descriptionKey: "onboarding_page_browse_description", illustrationName: "onboarding_illustration_browse"),
      OnboardingPage(id: 1, titleKey: "onboarding_page_compare_title", descriptionKey: "onboarding_page_compare_description", illustrationName: "onboarding_illustration_compare"),
      OnboardingPage(id: 2, titleKey: "onboarding_page_checkout_title", descriptionKey: "onboarding_page_checkout_description", illustrationName: "onboarding_illustration_checkout"),
      OnboardingPage(id: 3, titleKey: "onboarding_page_track_title", descriptionKey: "onboarding_page_track_description", illustrationName: "onboarding_illustration_track")
  ]

Init:
  - init(checkOnboarding: CheckOnboardingUseCase, completeOnboarding: CompleteOnboardingUseCase)

Methods:
  - func checkOnboardingStatus() async
    let hasSeen = await checkOnboarding.execute()
    uiState = hasSeen ? .onboardingComplete : .showOnboarding

  - func onSkip() async
    await completeOnboarding.execute()
    uiState = .onboardingComplete

  - func onGetStarted() async
    await completeOnboarding.execute()
    uiState = .onboardingComplete
```

### 3.5 DI Registration

**Android (Hilt)**:

```
Module: OnboardingModule
Package: com.xirigo.ecommerce.feature.onboarding.di
Annotations: @Module, @InstallIn(SingletonComponent::class)

Bindings:
  @Binds @Singleton
  fun bindOnboardingRepository(impl: OnboardingRepositoryImpl): OnboardingRepository
```

**iOS (Factory)**:

```
Extension on Container (in Container+Onboarding.swift):

  var onboardingRepository: Factory<OnboardingRepository> {
      self { OnboardingRepositoryImpl() }.singleton
  }

  var checkOnboardingUseCase: Factory<CheckOnboardingUseCase> {
      self { CheckOnboardingUseCase(repository: self.onboardingRepository()) }
  }

  var completeOnboardingUseCase: Factory<CompleteOnboardingUseCase> {
      self { CompleteOnboardingUseCase(repository: self.onboardingRepository()) }
  }

  var onboardingViewModel: Factory<OnboardingViewModel> {
      self { OnboardingViewModel(
          checkOnboarding: self.checkOnboardingUseCase(),
          completeOnboarding: self.completeOnboardingUseCase()
      )}
  }
```

---

## 4. New Design System Components

Four new reusable components are added to `core/designsystem/component/`. These are used
in the onboarding flow and will be reused by Login (M1-01), Home (M1-04), and other features.

### 4.1 XGBrandGradient

Renders the brand's signature radial gradient background. Composed of two radial gradient layers
as defined in `shared/design-tokens/gradients.json` under `brandHeader`.

**Token Source**: `gradients.json > brandHeader`

**Visual Layers** (bottom to top):
1. **Base layer**: Radial gradient with stops `#9000FE` (0%) -> `#6900FE` (27%) -> `#6900FE` (66%) -> `#9000FE` (100%)
2. **Dark overlay**: Radial gradient with stops from `#6000FE` at 0% opacity (32%) through to `#3C00D2` at 100% opacity (90%)

**API**:

```
Android:
  @Composable
  fun XGBrandGradient(
      modifier: Modifier = Modifier,
      content: @Composable BoxScope.() -> Unit = {}
  )

iOS:
  struct XGBrandGradient<Content: View>: View {
      let content: () -> Content
      init(@ViewBuilder content: @escaping () -> Content = { EmptyView() })
  }
```

**Implementation Notes**:
- Use `Brush.radialGradient` (Android) / `RadialGradient` (iOS) for each layer.
- Both layers are stacked in a `Box` (Android) / `ZStack` (iOS) filling the entire available space.
- The gradient center should be approximately in the upper-center area of the view.
- Must fill the entire container (`.fillMaxSize()` / frame maxWidth/maxHeight `.infinity`).
- Content is rendered on top of both gradient layers.

**Reuse Locations**: Splash screen, Login screen background, Home hero banner background.

### 4.2 XGBrandPattern

Renders the tiled X-motif pattern overlay used on branded surfaces.

**Token Source**: `gradients.json > splashPatternOverlay`

**Visual Properties**:
- Color: `#FFFFFF` (white)
- Opacity: 6% (0.06)
- Pattern: Tiled X-shaped polygon pairs across the entire surface
- Repeat mode: Tile (seamless repeat in both axes)

**API**:

```
Android:
  @Composable
  fun XGBrandPattern(
      modifier: Modifier = Modifier
  )

iOS:
  struct XGBrandPattern: View
```

**Implementation Notes**:
- The X pattern can be implemented as:
  - **Option A (preferred)**: A vector drawable / SVG asset (`brand_pattern_tile.xml` / `BrandPatternTile` in asset catalog) containing a single tile of the X motif, drawn as a repeating pattern.
  - **Option B**: A `Canvas` (Android) / `Canvas` (iOS) drawing rotated X shapes programmatically.
- The pattern tile should be extracted from the design SVG file `XiriGo-Design/Svg/XiriGo_App_01.svg`.
- Applied at 6% opacity over the gradient background.
- Must fill the entire container.

**Reuse Locations**: Splash screen, any future branded surface.

### 4.3 XGLogoMark

Renders the XiriGo logo mark consisting of two chevron shapes.

**Visual Properties**:
- **Top chevron**: Green `#94D63A` (`$brand.secondary`)
- **Bottom chevron**: White `#FFFFFF` (`$brand.onPrimary`)
- **Approximate size**: 120 x 124 points (scalable)
- **Position**: Centered in container

**API**:

```
Android:
  @Composable
  fun XGLogoMark(
      modifier: Modifier = Modifier,
      size: Dp = 120.dp
  )

iOS:
  struct XGLogoMark: View {
      var size: CGFloat = 120
  }
```

**Implementation Notes**:
- Use a vector drawable (Android) / SVG asset or Shape (iOS) for the two chevrons.
- The logo asset should be extracted from `XiriGo-Design/Svg/XiriGo_Logo_Design.svg` or `XiriGo_App_01.svg`.
- The component renders only the logo mark (chevrons), not the wordmark.
- `size` controls the width; height scales proportionally (~1.03:1 ratio).

**Reuse Locations**: Splash screen, loading states, about screen.

### 4.4 XGPaginationDots

Renders a horizontal row of pagination indicators with an active dot that is wider (pill shape)
and inactive dots that are small circles.

**Token Source**: `spacing.json > paginationDots` and `components.json > XGPaginationDots`

**Visual Properties**:
- Active dot width: 18dp/pt
- Inactive dot width: 6dp/pt
- Dot height: 6dp/pt
- Corner radius: 3dp/pt (fully rounded)
- Gap between dots: 4dp/pt
- Active color: `#6000FE` (`$paginationDots.active`)
- Inactive color: `#D1D5DB` (`$paginationDots.inactive`)

**API**:

```
Android:
  @Composable
  fun XGPaginationDots(
      totalPages: Int,
      currentPage: Int,
      modifier: Modifier = Modifier,
      activeColor: Color = XGColors.paginationDots.active,
      inactiveColor: Color = XGColors.paginationDots.inactive
  )

iOS:
  struct XGPaginationDots: View {
      let totalPages: Int
      let currentPage: Int
      var activeColor: Color = .xgPaginationDotsActive
      var inactiveColor: Color = .xgPaginationDotsInactive
  }
```

**Implementation Notes**:
- Active dot animates width from 6 to 18 with a spring/ease animation (300ms).
- Inactive dots animate from 18 to 6 when deselected.
- Use `animateContentSize()` (Android) / `animation(.easeInOut)` (iOS) for smooth transitions.
- The row of dots is horizontally centered.
- Tap on dots is not interactive (display only).

**Reuse Locations**: Onboarding pager, Home hero carousel, Flash sale banner.

---

## 5. UI Wireframe

### 5.1 Splash Screen (Custom Branded -- Replaces M0-01 Placeholder)

This is the custom branded splash screen that replaces the simple M0-01 placeholder splash.
It is displayed during the `Loading` state while the ViewModel checks the onboarding flag.

```
+------------------------------------------+
|                                          |
|  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|  <-- XGBrandGradient (base layer)
|  ~ ~ X ~ X ~ X ~ X ~ X ~ X ~ X ~ X ~ ~ |  <-- XGBrandPattern (6% white X tiles)
|  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
|                                          |
|                                          |
|              /\                          |
|             /  \    (green #94D63A)      |  <-- XGLogoMark (top chevron)
|            /    \                        |
|             \  /    (white #FFFFFF)      |  <-- XGLogoMark (bottom chevron)
|              \/                          |
|                                          |
|                                          |
|  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|  <-- Dark vignette overlay
+------------------------------------------+

Visual layer stack (bottom to top):
  1. XGBrandGradient base (radial: #9000FE -> #6900FE -> #9000FE)
  2. XGBrandPattern (white X tiles at 6% opacity)
  3. XGLogoMark (centered, ~120x124)
  4. XGBrandGradient darkOverlay (radial: #6000FE@0% -> #3C00D2@100%)
```

**Duration**: Not time-based. Displayed while `uiState == Loading`. Transitions to
OnboardingScreen or MainApp based on the `hasSeenOnboarding` check result.

### 5.2 Onboarding Screen (Page 1-3, non-last pages)

```
+------------------------------------------+
|                                 [ Skip ] |  <-- "Skip" text button (top-right)
|                                          |      bodyMedium, white, 14px
|                                          |      padding: 16 from top, 20 from right
|                                          |
|                                          |
|         [  Illustration  ]              |  <-- centered illustration
|         [    ~200x200    ]              |      asset from onboarding_illustration_*
|                                          |
|                                          |
|     Browse Thousands of Products        |  <-- headline: Poppins-SemiBold 24px
|                                          |      color: white #FFFFFF
|                                          |      textAlign: center
|                                          |
|     Explore a wide range of products    |  <-- bodyLarge: Poppins-Regular 16px
|     from multiple vendors in one place  |      color: white at 80% opacity
|                                          |      textAlign: center
|                                          |
|                                          |
|             o  o  --  o                 |  <-- XGPaginationDots (4 dots)
|                                          |      active = pill (18w), inactive = circle (6w)
|                                          |      32dp/pt from bottom safe area
+------------------------------------------+

Background: XGBrandGradient (full bleed, behind all content)
```

### 5.3 Onboarding Screen (Page 4, last page)

```
+------------------------------------------+
|                                          |  <-- No "Skip" button on last page
|                                          |
|                                          |
|         [  Illustration  ]              |
|         [    ~200x200    ]              |
|                                          |
|                                          |
|        Track Your Orders                |  <-- headline
|                                          |
|     Stay updated with real-time order   |  <-- bodyLarge at 80% opacity
|     tracking from purchase to delivery  |
|                                          |
|                                          |
|     [      Get Started      ]           |  <-- XGButton.primary
|                                          |      full-width (with horizontal padding)
|                                          |      height: 56, cornerRadius: 10
|                                          |      background: #94D63A ($brand.secondary)
|                                          |      textColor: #6000FE ($brand.onSecondary)
|                                          |
|             o  o  o  --                 |  <-- XGPaginationDots
|                                          |      32dp/pt from bottom safe area
+------------------------------------------+

Background: XGBrandGradient (full bleed)
```

### 5.4 Layout Specifications

| Element | Property | Value |
|---------|----------|-------|
| Skip button | font | Poppins-Medium 14px (bodyMedium) |
| Skip button | color | `#FFFFFF` (white) |
| Skip button | position | top-right, 16pt from top safe area, 20pt from right |
| Skip button | touch target | minimum 48dp/44pt |
| Illustration | size | ~200x200 (flexible, centered horizontally) |
| Illustration | position | vertically centered in upper half of screen |
| Title | font | Poppins-SemiBold 24px (headline) |
| Title | color | `#FFFFFF` |
| Title | alignment | center |
| Title | max lines | 2 |
| Description | font | Poppins-Regular 16px (bodyLarge) |
| Description | color | `#FFFFFF` at 80% opacity |
| Description | alignment | center |
| Description | max lines | 3 |
| Title-to-description gap | spacing | 12dp/pt (md) |
| Content horizontal padding | spacing | 32dp/pt (xxl) |
| Get Started button | variant | XGButton with `$brand.secondary` background |
| Get Started button | text color | `$brand.onSecondary` (#6000FE) |
| Get Started button | width | full width minus 40dp/pt horizontal padding (20 each side) |
| Get Started button | height | 56dp/pt |
| Get Started button | corner radius | 10dp/pt |
| Get Started button | bottom margin | 80dp/pt from bottom safe area |
| Pagination dots | position | 32dp/pt from bottom safe area |
| Pagination dots | alignment | center horizontal |

---

## 6. Navigation Flow

### 6.1 App Launch Flow

```
App Launch
    |
    v
+---------------------+
| OnboardingViewModel  |
| checks hasSeenFlag   |
+---------------------+
    |
    +--> hasSeenOnboarding == true  --> Navigate to Main App (Home tab)
    |
    +--> hasSeenOnboarding == false --> Show Onboarding Screen
                                            |
                                            +--> User swipes through pages
                                            |
                                            +--> User taps "Skip" (any page except last)
                                            |       |
                                            |       v
                                            |    setOnboardingSeen()
                                            |       |
                                            |       v
                                            |    Navigate to Main App
                                            |
                                            +--> User taps "Get Started" (last page)
                                                    |
                                                    v
                                                 setOnboardingSeen()
                                                    |
                                                    v
                                                 Navigate to Main App
```

### 6.2 Integration with Navigation (M0-04)

**Android**:
- `MainActivity` checks the onboarding state before setting up the main NavHost.
- If `uiState == ShowOnboarding`, display `OnboardingScreen` composable (fullscreen, no bottom bar).
- On completion, replace with `XGAppScaffold` (no back navigation to onboarding).
- Use `navController.navigate(Route.Home) { popUpTo(Route.Onboarding) { inclusive = true } }`.

**iOS**:
- `XiriGoEcommerceApp` or `MainTabView` observes `OnboardingViewModel.uiState`.
- If `uiState == .showOnboarding`, present `OnboardingScreen` as a fullscreen cover.
- On completion, dismiss the fullscreen cover to reveal `MainTabView`.
- Use `AppRouter.isShowingOnboarding` flag as already defined in the navigation spec.

### 6.3 Swipe Navigation

- Horizontal pager: `HorizontalPager` (Android Compose) / `TabView` with `PageTabViewStyle` (iOS).
- Users can swipe left/right between pages.
- Current page index syncs with `OnboardingViewModel.currentPage`.
- No wrap-around: cannot swipe left past page 0 or right past page 3.

---

## 7. State Management

### 7.1 OnboardingViewModel State Flow

```
                    +----------+
                    | Loading  |  (initial state)
                    +----------+
                         |
              hasSeenOnboarding()
                    /         \
                   /           \
            true  /             \ false
                 v               v
      +------------------+  +------------------+
      | OnboardingComplete |  | ShowOnboarding  |
      +------------------+  +------------------+
                                    |
                              Skip / GetStarted
                                    |
                                    v
                          +------------------+
                          | OnboardingComplete |
                          +------------------+
```

### 7.2 Page State

- `currentPage: Int` (0-3) tracks the currently visible page.
- Updated by the pager component on swipe and synced to ViewModel.
- Drives `XGPaginationDots` active index.
- Drives `Skip` button visibility (visible on pages 0-2, hidden on page 3).
- Drives `Get Started` button visibility (hidden on pages 0-2, visible on page 3).

---

## 8. Localization Strings

### 8.1 New String Keys

| Key | English (en) | Maltese (mt) | Turkish (tr) |
|-----|-------------|-------------|-------------|
| `onboarding_skip_button` | Skip | Aqbez | Atla |
| `onboarding_get_started_button` | Get Started | Ibda | Basla |
| `onboarding_page_browse_title` | Browse Thousands of Products | Esplora Eluf ta' Prodotti | Binlerce Urunu Kesfet |
| `onboarding_page_browse_description` | Explore a wide range of products from multiple vendors in one place | Esplora firxa wiesgha ta' prodotti minn diversi bejjiegha f'post wiehed | Bir cok saticinan genis urun yelpazesini tek bir yerde kesfet |
| `onboarding_page_compare_title` | Compare Vendors & Prices | Qabbel Bejjiegha u Prezzijiet | Saticilari ve Fiyatlari Karsilastir |
| `onboarding_page_compare_description` | Find the best deals by comparing prices across different vendors | Sib l-ahjar offerti billi tqabbel il-prezzijiet bejn bejjiegha differenti | Farkli saticilar arasinda fiyatlari karsilastirarak en iyi firsatlari bul |
| `onboarding_page_checkout_title` | Fast & Secure Checkout | Checkout Mghaggel u Sigur | Hizli ve Guvenli Odeme |
| `onboarding_page_checkout_description` | Pay securely with multiple payment options and fast processing | Hallas b'mod sigur b'ghazliet ta' hlas multipli u processing mghaggel | Birden fazla odeme secenegiyle guvenli ve hizli odeme yap |
| `onboarding_page_track_title` | Track Your Orders | Segwi l-Ordnijiet Tieghek | Siparislerini Takip Et |
| `onboarding_page_track_description` | Stay updated with real-time order tracking from purchase to delivery | Ibqa aggiornat bi tracking tal-ordni f'hin reali mix-xiri sal-kunsinna | Satin almadan teslimata kadar gercek zamanli siparis takibi ile guncel kal |

### 8.2 Android Strings

Add to `res/values/strings.xml`, `res/values-mt/strings.xml`, `res/values-tr/strings.xml`.

### 8.3 iOS Strings

Add to `Localizable.xcstrings` String Catalog for all three languages.

### 8.4 Accessibility Labels

| Key | English (en) |
|-----|-------------|
| `onboarding_skip_button_a11y` | Skip onboarding |
| `onboarding_page_indicator_a11y` | Page %1$d of %2$d |
| `onboarding_illustration_a11y_browse` | Illustration of marketplace browsing |
| `onboarding_illustration_a11y_compare` | Illustration of price comparison |
| `onboarding_illustration_a11y_checkout` | Illustration of secure checkout |
| `onboarding_illustration_a11y_track` | Illustration of order tracking |

---

## 9. Accessibility

### 9.1 Screen Reader Support

| Element | Android (`contentDescription`) | iOS (`accessibilityLabel`) |
|---------|-------------------------------|---------------------------|
| Skip button | "Skip onboarding" | "Skip onboarding" |
| Page illustration | Descriptive text per page (see accessibility labels in 8.4) | Same descriptive text |
| Page title | Announced as heading (`Modifier.semantics { heading() }`) | `.accessibilityAddTraits(.isHeader)` |
| Page description | Read as body text (automatic) | Read as body text (automatic) |
| Pagination dots | "Page X of Y" | "Page X of Y" |
| Get Started button | "Get Started" (from button text) | "Get Started" (from button text) |
| Logo mark | "XiriGo logo" | "XiriGo logo" |

### 9.2 Touch Targets

- Skip button: minimum 48dp (Android) / 44pt (iOS) touch target.
- Get Started button: 56dp/pt height, full width -- exceeds minimum.
- Pagination dots: decorative only, no tap interaction.

### 9.3 Dynamic Type

- Title and description text should scale with system text size settings.
- If text overflows at very large accessibility sizes, allow vertical scrolling on the page content area.
- Illustrations should maintain fixed size (do not scale with text size).

---

## 10. Error Scenarios

### 10.1 DataStore / UserDefaults Read Failure

| Scenario | Behavior |
|----------|----------|
| DataStore/UserDefaults read throws exception | Default to `false` (show onboarding). Log error. |
| DataStore/UserDefaults write fails | Onboarding will show again on next launch. Log error. No user-facing error. |

### 10.2 Missing Illustration Assets

| Scenario | Behavior |
|----------|----------|
| Illustration resource not found | Show empty space where illustration would be. Title and description still visible. |

### 10.3 Edge Cases

| Scenario | Behavior |
|----------|----------|
| User kills app during onboarding (before completing) | Onboarding shows again on next launch (flag not yet written). |
| User completes onboarding, then clears app data | Onboarding shows again (flag was in cleared storage). Expected behavior. |
| Very fast app launch (no visible splash) | Splash screen may flash briefly or not appear at all. This is acceptable -- the onboarding content is what matters. |
| Screen rotation during onboarding | Not applicable -- app is portrait-only. |

---

## 11. File Manifest

### 11.1 Android Files

**Design System Components** (new files in `core/designsystem/component/`):

Base path: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/`

| # | File | Description |
|---|------|-------------|
| 1 | `XGBrandGradient.kt` | `@Composable XGBrandGradient` -- brand radial gradient background with dark overlay. Includes `@Preview`. |
| 2 | `XGBrandPattern.kt` | `@Composable XGBrandPattern` -- tiled X-motif pattern overlay at 6% white opacity. Includes `@Preview`. |
| 3 | `XGLogoMark.kt` | `@Composable XGLogoMark` -- two-chevron logo mark (green + white). Includes `@Preview`. |
| 4 | `XGPaginationDots.kt` | `@Composable XGPaginationDots` -- animated pill/circle pagination indicator. Includes `@Preview`. |

**Feature Files** (new files in `feature/onboarding/`):

Base path: `android/app/src/main/java/com/xirigo/ecommerce/feature/onboarding/`

| # | File | Description |
|---|------|-------------|
| 5 | `domain/model/OnboardingPage.kt` | Data class for page content (title, description, illustration resource IDs). |
| 6 | `domain/repository/OnboardingRepository.kt` | Interface with `hasSeenOnboarding()` and `setOnboardingSeen()`. |
| 7 | `domain/usecase/CheckOnboardingUseCase.kt` | Use case wrapping `hasSeenOnboarding()`. |
| 8 | `domain/usecase/CompleteOnboardingUseCase.kt` | Use case wrapping `setOnboardingSeen()`. |
| 9 | `data/repository/OnboardingRepositoryImpl.kt` | DataStore-backed implementation of `OnboardingRepository`. |
| 10 | `presentation/state/OnboardingUiState.kt` | Sealed interface: `Loading`, `ShowOnboarding`, `OnboardingComplete`. |
| 11 | `presentation/viewmodel/OnboardingViewModel.kt` | `@HiltViewModel` managing state, page index, skip/get-started actions. |
| 12 | `presentation/screen/SplashScreen.kt` | `@Composable` branded splash (gradient + pattern + logo + vignette). Includes `@Preview`. |
| 13 | `presentation/screen/OnboardingScreen.kt` | `@Composable` with `HorizontalPager`, skip, get started, pagination dots. Includes `@Preview`. |
| 14 | `presentation/screen/OnboardingPageContent.kt` | `@Composable` for a single page (illustration + title + description). Includes `@Preview`. |
| 15 | `di/OnboardingModule.kt` | Hilt `@Module` binding `OnboardingRepositoryImpl` to `OnboardingRepository`. |

**Resource Files**:

| # | File | Description |
|---|------|-------------|
| 16 | `res/drawable/onboarding_illustration_browse.xml` | Placeholder vector drawable for browse page illustration. |
| 17 | `res/drawable/onboarding_illustration_compare.xml` | Placeholder vector drawable for compare page illustration. |
| 18 | `res/drawable/onboarding_illustration_checkout.xml` | Placeholder vector drawable for checkout page illustration. |
| 19 | `res/drawable/onboarding_illustration_track.xml` | Placeholder vector drawable for track page illustration. |
| 20 | `res/drawable/brand_pattern_tile.xml` | Single tile of X-motif pattern for `XGBrandPattern`. |
| 21 | `res/drawable/logo_mark.xml` | Vector drawable of the two-chevron logo mark. |

**Modified Files**:

| # | File | Change |
|---|------|--------|
| 1 | `MainActivity.kt` | Add onboarding check flow: observe `OnboardingViewModel.uiState` and show `SplashScreen` / `OnboardingScreen` / `XGAppScaffold` accordingly. |
| 2 | `res/values/strings.xml` | Add 10 new onboarding string keys (section 8.1) + 6 accessibility keys (section 8.4). |
| 3 | `res/values-mt/strings.xml` | Add same keys with Maltese translations. |
| 4 | `res/values-tr/strings.xml` | Add same keys with Turkish translations. |

**Test Files**:

Base path: `android/app/src/test/java/com/xirigo/ecommerce/feature/onboarding/`

| # | File | Description |
|---|------|-------------|
| 1 | `domain/usecase/CheckOnboardingUseCaseTest.kt` | Tests for checking onboarding flag. |
| 2 | `domain/usecase/CompleteOnboardingUseCaseTest.kt` | Tests for setting onboarding flag. |
| 3 | `presentation/viewmodel/OnboardingViewModelTest.kt` | Tests for all ViewModel state transitions: loading -> show/complete, skip, get started, page changes. |
| 4 | `data/repository/FakeOnboardingRepository.kt` | Fake repository for testing. |

### 11.2 iOS Files

**Design System Components** (new files in `Core/DesignSystem/Component/`):

Base path: `ios/XiriGoEcommerce/Core/DesignSystem/Component/`

| # | File | Description |
|---|------|-------------|
| 1 | `XGBrandGradient.swift` | `struct XGBrandGradient<Content>: View` -- brand radial gradient background with dark overlay. Includes `#Preview`. |
| 2 | `XGBrandPattern.swift` | `struct XGBrandPattern: View` -- tiled X-motif pattern overlay at 6% white opacity. Includes `#Preview`. |
| 3 | `XGLogoMark.swift` | `struct XGLogoMark: View` -- two-chevron logo mark (green + white). Includes `#Preview`. |
| 4 | `XGPaginationDots.swift` | `struct XGPaginationDots: View` -- animated pill/circle pagination indicator. Includes `#Preview`. |

**Feature Files** (new files in `Feature/Onboarding/`):

Base path: `ios/XiriGoEcommerce/Feature/Onboarding/`

| # | File | Description |
|---|------|-------------|
| 5 | `Domain/Model/OnboardingPage.swift` | Struct for page content (title key, description key, illustration name). |
| 6 | `Domain/Repository/OnboardingRepository.swift` | Protocol with `hasSeenOnboarding()` and `setOnboardingSeen()`. |
| 7 | `Domain/UseCase/CheckOnboardingUseCase.swift` | Use case wrapping `hasSeenOnboarding()`. |
| 8 | `Domain/UseCase/CompleteOnboardingUseCase.swift` | Use case wrapping `setOnboardingSeen()`. |
| 9 | `Data/Repository/OnboardingRepositoryImpl.swift` | UserDefaults-backed implementation of `OnboardingRepository`. |
| 10 | `Presentation/State/OnboardingUiState.swift` | Enum: `.loading`, `.showOnboarding`, `.onboardingComplete`. |
| 11 | `Presentation/ViewModel/OnboardingViewModel.swift` | `@Observable` class managing state, page index, skip/get-started actions. |
| 12 | `Presentation/Screen/SplashScreen.swift` | `struct SplashScreen: View` -- branded splash. Includes `#Preview`. |
| 13 | `Presentation/Screen/OnboardingScreen.swift` | `struct OnboardingScreen: View` -- pager with skip, get started, pagination dots. Includes `#Preview`. |
| 14 | `Presentation/Screen/OnboardingPageContent.swift` | `struct OnboardingPageContent: View` -- single page content. Includes `#Preview`. |

**DI File**:

| # | File | Description |
|---|------|-------------|
| 15 | `ios/XiriGoEcommerce/Core/DI/Container+Onboarding.swift` | Factory container extension registering onboarding dependencies. |

**Asset Files**:

| # | File | Description |
|---|------|-------------|
| 16 | `Resources/Assets.xcassets/OnboardingIllustrationBrowse.imageset/` | Placeholder image for browse page. |
| 17 | `Resources/Assets.xcassets/OnboardingIllustrationCompare.imageset/` | Placeholder image for compare page. |
| 18 | `Resources/Assets.xcassets/OnboardingIllustrationCheckout.imageset/` | Placeholder image for checkout page. |
| 19 | `Resources/Assets.xcassets/OnboardingIllustrationTrack.imageset/` | Placeholder image for track page. |
| 20 | `Resources/Assets.xcassets/BrandPatternTile.imageset/` | Single tile of X-motif pattern. |
| 21 | `Resources/Assets.xcassets/LogoMark.imageset/` | Two-chevron logo mark image. |

**Modified Files**:

| # | File | Change |
|---|------|--------|
| 1 | `XiriGoEcommerceApp.swift` | Add onboarding flow: observe `OnboardingViewModel.uiState`, conditionally show `SplashScreen` / `OnboardingScreen` / `MainTabView`. |
| 2 | `Resources/Localizable.xcstrings` | Add 10 new onboarding string keys (section 8.1) + 6 accessibility keys (section 8.4) in all three languages. |

**Test Files**:

Base path: `ios/XiriGoEcommerceTests/Feature/Onboarding/`

| # | File | Description |
|---|------|-------------|
| 1 | `Domain/UseCase/CheckOnboardingUseCaseTests.swift` | Tests for checking onboarding flag. |
| 2 | `Domain/UseCase/CompleteOnboardingUseCaseTests.swift` | Tests for setting onboarding flag. |
| 3 | `Presentation/ViewModel/OnboardingViewModelTests.swift` | Tests for all ViewModel state transitions. |
| 4 | `Data/Repository/FakeOnboardingRepository.swift` | Fake repository for testing. |

---

## 12. Implementation Notes for Developers

### 12.1 For Android Developer

1. **Start with design system components** (`XGBrandGradient`, `XGBrandPattern`, `XGLogoMark`, `XGPaginationDots`). These are independent of the feature and can be tested in isolation via `@Preview`.

2. **Extract logo and pattern assets** from `XiriGo-Design/Svg/XiriGo_App_01.svg`:
   - Logo mark: the two overlapping chevrons in the center of the splash.
   - Pattern tile: a single X-motif unit that can be tiled/repeated.
   - Create vector drawables for both.

3. **Create placeholder illustrations** for the 4 onboarding pages. Use simple vector drawables (e.g., shopping bag, balance scale, shield/lock, package/truck icons) until final illustrations are provided by the design team.

4. **Build the domain layer** (`OnboardingRepository`, use cases) -- these are simple and testable.

5. **Build the data layer** (`OnboardingRepositoryImpl`) using the existing `DataStore<Preferences>` instance that should already be provided via Hilt from the scaffold. Use a dedicated preferences key `"has_seen_onboarding"`.

6. **Build the ViewModel** with the three states. Test all transitions.

7. **Build the screens**:
   - `SplashScreen`: Stack `XGBrandGradient` > `XGBrandPattern` > `XGLogoMark` > dark overlay in a `Box`.
   - `OnboardingScreen`: Use `HorizontalPager` (from `accompanist` or `foundation`). Each page renders `OnboardingPageContent`.
   - The "Get Started" button uses `XGButton` but with `$brand.secondary` background and `$brand.onSecondary` text color. This may require a new `XGButton` variant or passing custom colors.

8. **Wire into `MainActivity.kt`**: The onboarding check should happen before the main NavHost renders. Use a `when` expression on `uiState` to decide what to show.

9. **HorizontalPager page sync**: Use `pagerState.currentPage` to drive `viewModel.onPageChanged()` and `XGPaginationDots.currentPage`.

10. **Poppins font**: The app uses Poppins as the primary font (per `typography.json`). Ensure Poppins is embedded in `res/font/` and referenced in `XGTypography`. If not yet embedded from previous milestones, add the font files.

### 12.2 For iOS Developer

1. **Start with design system components** (`XGBrandGradient`, `XGBrandPattern`, `XGLogoMark`, `XGPaginationDots`). Build and preview each independently.

2. **XGBrandGradient implementation**:
   - Use two `RadialGradient` views in a `ZStack`.
   - The base gradient uses `Gradient(stops:)` with the 4 stops from `gradients.json > brandHeader.base`.
   - The dark overlay uses `Gradient(stops:)` with the 6 stops from `gradients.json > brandHeader.darkOverlay`.

3. **XGBrandPattern implementation**:
   - Extract a single X-tile from the design SVG.
   - Option A: Import as an image asset, use `Image(tileable:)` or a custom `ShapeStyle`.
   - Option B: Draw using SwiftUI `Canvas` with `Path` for the X shapes.
   - Apply `.opacity(0.06)` and fill white.

4. **XGLogoMark**: Use the logo asset from `XiriGo-Design/Svg/` or create using SwiftUI `Shape` with two chevron paths.

5. **Create placeholder illustrations** -- simple SF Symbol-based or vector illustrations until real assets arrive.

6. **OnboardingScreen**: Use `TabView` with `.tabViewStyle(.page(indexDisplayMode: .never))` for the horizontal pager. Hide the default page indicator and use `XGPaginationDots` instead.

7. **Page sync**: Bind `$viewModel.currentPage` to the `TabView(selection:)` parameter.

8. **Get Started button**: Use `XGButton` with the secondary color variant. If `XGButton` does not yet support custom background/text colors, add a parameter or create a `.secondary` style.

9. **Wire into `XiriGoEcommerceApp.swift`**: Observe `onboardingViewModel.uiState`. In the `body`:
   ```
   if uiState == .loading -> SplashScreen()
   if uiState == .showOnboarding -> OnboardingScreen(viewModel)
   if uiState == .onboardingComplete -> MainTabView()
   ```

10. **Poppins font**: Ensure Poppins fonts are embedded via `Info.plist > UIAppFonts` and available in `XGTypography`. If not yet embedded from previous milestones, add the font files to the bundle.

11. **Strict concurrency**: `OnboardingRepositoryImpl` must be `Sendable`. Since `UserDefaults` is thread-safe for reads/writes of simple types, this is straightforward.

### 12.3 Common Rules (Both Platforms)

- **All user-facing strings must be localized** -- no hardcoded strings. Use string resource keys from section 8.
- **All colors from design tokens** -- no magic hex values in feature code. Reference `XGColors` / token constants.
- **All spacing from `XGSpacing`** -- no magic numbers.
- **Poppins font required** -- the onboarding screens use Poppins-SemiBold (titles) and Poppins-Regular (descriptions) as specified in `typography.json`. Ensure the font is embedded.
- **Illustrations are placeholders** -- use simple vector/SF Symbol illustrations. Real illustrations will be provided by the design team and can be swapped without code changes (just replace assets).
- **Fakes over mocks** in tests -- create `FakeOnboardingRepository` that stores the boolean in memory. No mocking frameworks needed.
- **`XGBrandGradient` must be reusable** -- Login and Home screens will import and use the same component. Do not embed it inside the onboarding feature module; it lives in `core/designsystem/component/`.
- **Same for `XGPaginationDots`** -- used in onboarding pager, home hero carousel, and flash sale banner.

---

## 13. Build Verification Criteria

The app-onboarding feature is complete when:

### Android

- [ ] App launches and shows the branded splash screen (gradient + pattern + logo).
- [ ] On first launch, onboarding pager appears with 4 pages after splash.
- [ ] Swiping left/right navigates between onboarding pages.
- [ ] `XGPaginationDots` correctly reflects the current page with animated width changes.
- [ ] "Skip" button is visible on pages 0-2, hidden on page 3.
- [ ] Tapping "Skip" marks onboarding as seen and navigates to the main app.
- [ ] "Get Started" button is visible only on page 3.
- [ ] Tapping "Get Started" marks onboarding as seen and navigates to the main app.
- [ ] On subsequent launches, splash transitions directly to the main app (no onboarding).
- [ ] `XGBrandGradient` renders correctly in isolation (`@Preview`).
- [ ] `XGBrandPattern` renders the tiled X-motif overlay.
- [ ] `XGLogoMark` renders the two-chevron logo.
- [ ] `XGPaginationDots` renders correctly with various page counts.
- [ ] All strings display correctly in English, Maltese, and Turkish.
- [ ] `OnboardingViewModelTest` passes all state transition tests.
- [ ] `./gradlew assembleDebug` succeeds without errors.
- [ ] No lint warnings from new files (ktlint + detekt pass).

### iOS

- [ ] App launches and shows the branded splash screen (gradient + pattern + logo).
- [ ] On first launch, onboarding pager appears with 4 pages after splash.
- [ ] Swiping left/right navigates between onboarding pages.
- [ ] `XGPaginationDots` correctly reflects the current page with animated width changes.
- [ ] "Skip" button is visible on pages 0-2, hidden on page 3.
- [ ] Tapping "Skip" marks onboarding as seen and navigates to the main app.
- [ ] "Get Started" button is visible only on page 3.
- [ ] Tapping "Get Started" marks onboarding as seen and navigates to the main app.
- [ ] On subsequent launches, splash transitions directly to the main app (no onboarding).
- [ ] `XGBrandGradient` renders correctly in isolation (`#Preview`).
- [ ] `XGBrandPattern` renders the tiled X-motif overlay.
- [ ] `XGLogoMark` renders the two-chevron logo.
- [ ] `XGPaginationDots` renders correctly with various page counts.
- [ ] All strings display correctly in English, Maltese, and Turkish.
- [ ] `OnboardingViewModelTests` pass all state transition tests.
- [ ] `xcodebuild -scheme XiriGoEcommerce-Debug build` succeeds.
- [ ] No strict concurrency warnings from new files.
