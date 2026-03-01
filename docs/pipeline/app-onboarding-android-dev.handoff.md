# App Onboarding Android Dev Handoff

## Feature: M4-05 App Onboarding
## Platform: Android
## Agent: android-dev
## Date: 2026-02-28

## Summary

Implemented the full app onboarding feature for Android including 4 new design system components (XGBrandGradient, XGBrandPattern, XGLogoMark, XGPaginationDots), a complete onboarding feature module with Clean Architecture layers (data/domain/presentation), a branded splash screen, a 4-page horizontal pager onboarding flow, and integration into MainActivity for first-launch detection. All strings localized in English, Maltese, and Turkish.

## Files Created

### Design System Components (`android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/component/`)

| File | Description |
|------|-------------|
| `XGBrandGradient.kt` | Reusable branded radial gradient background with two layers (base + dark overlay) from gradients.json brandHeader tokens. Includes @Preview. |
| `XGBrandPattern.kt` | Tiled X-motif pattern overlay drawn via Canvas at 6% white opacity. Fills entire container. Includes @Preview. |
| `XGLogoMark.kt` | Two-chevron logo mark (green #94D63A top + white bottom) drawn via Canvas. Configurable size with proportional height. Includes @Preview. |
| `XGPaginationDots.kt` | Animated pill (18dp active) / circle (6dp inactive) pagination dots. Uses animateDpAsState with 300ms tween. Customizable colors. Includes @Preview. |

### Feature Module (`android/app/src/main/java/com/xirigo/ecommerce/feature/onboarding/`)

| File | Description |
|------|-------------|
| `domain/model/OnboardingPage.kt` | Immutable data class with @StringRes titleResId, @StringRes descriptionResId, @DrawableRes illustrationResId. |
| `domain/repository/OnboardingRepository.kt` | Interface with `suspend hasSeenOnboarding(): Boolean` and `suspend setOnboardingSeen()`. |
| `domain/usecase/CheckOnboardingUseCase.kt` | Use case wrapping `hasSeenOnboarding()`. @Inject constructor. |
| `domain/usecase/CompleteOnboardingUseCase.kt` | Use case wrapping `setOnboardingSeen()`. @Inject constructor. |
| `data/repository/OnboardingRepositoryImpl.kt` | DataStore<Preferences> backed implementation. Uses `booleanPreferencesKey("has_seen_onboarding")`. IOException caught with Timber logging, defaults to false. |
| `presentation/state/OnboardingUiState.kt` | @Stable sealed interface: Loading, ShowOnboarding, OnboardingComplete. |
| `presentation/viewmodel/OnboardingViewModel.kt` | @HiltViewModel managing uiState (MutableStateFlow) and currentPage (MutableStateFlow). init block checks flag, onSkip/onGetStarted complete and transition. Companion object holds static pages list. |
| `presentation/screen/SplashScreen.kt` | 4-layer branded splash: XGBrandGradient + XGBrandPattern + XGLogoMark (centered) + dark vignette overlay. Includes @Preview. |
| `presentation/screen/OnboardingScreen.kt` | Main screen composable. Observes uiState to show SplashScreen (Loading), OnboardingContent (ShowOnboarding), or trigger navigation (OnboardingComplete). OnboardingContent uses HorizontalPager, animated Skip/Get Started buttons, XGPaginationDots. Includes @Preview for first and last page. |
| `presentation/screen/OnboardingPageContent.kt` | Single page composable: illustration Image (200dp) + title (headlineSmall, white, SemiBold) + description (bodyLarge, white 80% opacity). Semantic heading on title. Includes @Preview. |
| `di/OnboardingModule.kt` | Hilt @Module @InstallIn(SingletonComponent) with @Binds @Singleton binding OnboardingRepositoryImpl to OnboardingRepository. |

### Resource Files

| File | Description |
|------|-------------|
| `res/drawable/onboarding_illustration_browse.xml` | Placeholder vector: shopping bag with magnifying glass. |
| `res/drawable/onboarding_illustration_compare.xml` | Placeholder vector: balance scale with price tags. |
| `res/drawable/onboarding_illustration_checkout.xml` | Placeholder vector: shield with checkmark. |
| `res/drawable/onboarding_illustration_track.xml` | Placeholder vector: delivery truck with location pin and route. |

## Files Modified

| File | Change |
|------|--------|
| `MainActivity.kt` | Replaced direct XGAppScaffold() with OnboardingViewModel state observation. Shows SplashScreen (Loading), OnboardingScreen (ShowOnboarding), or XGAppScaffold (OnboardingComplete). Uses system splash screen keepOnScreenCondition for Loading state. |
| `res/values/strings.xml` | Added 16 onboarding string keys: 10 content + 6 accessibility (English). |
| `res/values-mt/strings.xml` | Added 16 onboarding string keys (Maltese). |
| `res/values-tr/strings.xml` | Added 16 onboarding string keys (Turkish). |

## Key Decisions

1. **DataStore<Preferences> reuse**: Uses the existing singleton DataStore from StorageModule (key: `has_seen_onboarding`) rather than creating a separate DataStore file.
2. **IOException handling**: OnboardingRepositoryImpl catches IOException on both read and write, logs via Timber, defaults to false on read failure (shows onboarding again -- safe fallback).
3. **ViewModel shared between MainActivity and OnboardingScreen**: Single OnboardingViewModel instance created at Activity level via `by viewModels()` and passed to OnboardingScreen to avoid duplicate state.
4. **System splash screen integration**: installSplashScreen().setKeepOnScreenCondition keeps the native splash visible during the Loading state, providing seamless transition to the branded SplashScreen.
5. **Brand colors as local constants**: Onboarding-specific brand colors (#94D63A, #6000FE) defined as private constants in OnboardingScreen rather than added to XGColors, since they are brand-specific overrides for the Get Started button and pagination dots.
6. **Placeholder illustrations**: Created meaningful vector drawables (shopping bag, balance scale, shield, truck) that communicate each page's concept. Can be swapped for final illustrations without code changes.
7. **Skip button hidden on last page, Get Started shown only on last page**: Both use AnimatedVisibility with fadeIn/fadeOut for smooth transitions.

## Build Verification

- All design system components have @Preview annotations
- All screen composables have @Preview annotations
- Domain layer has zero imports from data/ or presentation/
- No `Any` type, no `!!` force unwrap anywhere
- All user-facing strings use stringResource() -- zero hardcoded text
- OnboardingUiState uses @Stable annotation
- OnboardingPage uses @Immutable annotation

## Test Entry Points for Tester

- `OnboardingViewModel`: Test Loading->ShowOnboarding (first launch), Loading->OnboardingComplete (returning user), onSkip transitions, onGetStarted transitions, onPageChanged updates currentPage
- `CheckOnboardingUseCase`: Delegates to repository.hasSeenOnboarding()
- `CompleteOnboardingUseCase`: Delegates to repository.setOnboardingSeen()
- `FakeOnboardingRepository`: Needs to be created by tester -- in-memory boolean flag

## Integration Points for Future Features

- M1-01 (Login): Import and use XGBrandGradient + XGBrandPattern + XGLogoMark for login screen background
- M1-04 (Home): Import and use XGBrandGradient for hero banner, XGPaginationDots for hero carousel and flash sale
