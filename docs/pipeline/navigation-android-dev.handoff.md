# Navigation Android Dev Handoff

## Feature: M0-04 Navigation
## Platform: Android
## Agent: android-dev
## Date: 2026-02-21

## Summary

Implemented the full navigation infrastructure for the Android app including type-safe routing, four-tab bottom navigation with independent back stacks, deep linking support, and auth-gated route definitions.

## Files Created

### Navigation Core (`android/app/src/main/java/com/xirigo/ecommerce/core/navigation/`)

| File | Description |
|------|-------------|
| `Route.kt` | Sealed interface with all 28 @Serializable route definitions (M0-M4). Includes `isAuthRequired` computed property with exhaustive `when`. |
| `TopLevelDestination.kt` | Enum with HOME, CATEGORIES, CART, PROFILE entries. Each has route, icons (filled/outlined), and label resource ID. |
| `DeepLinkParser.kt` | Object with `parse(Uri): Route?` for `xirigo://` and `https://xirigo.com/` deep links. Returns null for invalid URIs. |
| `PlaceholderScreen.kt` | Composable showing icon + title + "Coming soon" text. Used for all unimplemented screens. |
| `XGNavHost.kt` | Single NavHost with all 28 composable destinations. Uses PlaceholderScreen for each. |
| `NavigationExtensions.kt` | `navigateToTopLevel()` with saveState/restoreState for tab switching. `navigateToRoute()` for push navigation. |
| `XGAppScaffold.kt` | Top-level Scaffold with XGBottomBar + XGNavHost. Handles tab selection, bottom bar visibility, cart badge (hardcoded 0). |

### Tests (`android/app/src/test/java/com/xirigo/ecommerce/core/navigation/`)

| File | Description |
|------|-------------|
| `DeepLinkParserTest.kt` | 15 tests: valid xirigo://, valid https://xirigo.com/, missing params, empty IDs, wrong host, unsupported scheme. |
| `RouteAuthTest.kt` | 19 tests: every route verified for correct `isAuthRequired` value. |
| `TopLevelDestinationTest.kt` | 11 tests: count, routes, labels, icons, ordering. |

## Files Modified

| File | Change |
|------|--------|
| `MainActivity.kt` | Replaced placeholder Box/Text with XGAppScaffold(). Added onNewIntent for deep links. |
| `AndroidManifest.xml` | Added `launchMode="singleTask"`, intent filters for `xirigo://` scheme and `https://xirigo.com` host. |
| `res/values/strings.xml` | Added 10 navigation string keys (en). |
| `res/values-mt/strings.xml` | Added 10 navigation string keys (mt). |
| `res/values-tr/strings.xml` | Added 10 navigation string keys (tr). |
| `gradle/libs.versions.toml` | Added Robolectric 4.14.1 dependency for DeepLinkParser tests. |
| `app/build.gradle.kts` | Added `testImplementation(libs.robolectric)`. |

## Key Decisions

1. **Single NavHost with saveState/restoreState** for tab switching (per Compose Navigation 2.8+ best practices)
2. **`isAuthRequired`** naming (detekt BooleanPropertyNaming compliance) instead of spec's `requiresAuth`
3. **Bottom bar hidden** for Login, Register, ForgotPassword, Onboarding, CheckoutAddress, CheckoutShipping, CheckoutPayment, OrderConfirmation
4. **Cart badge hardcoded to 0** until M2-01 provides cart state
5. **Auth gating wired but not enforced** until M0-06 provides auth state
6. **Robolectric added** for DeepLinkParser tests (android.net.Uri dependency)

## Build Verification

- `./gradlew assembleDebug` -- PASS
- `./gradlew testDebugUnitTest --tests "com.xirigo.ecommerce.core.navigation.*"` -- PASS (45 tests)
- No detekt issues in navigation files
- No ktlint issues in navigation files (auto-formatted)

## Integration Points for Future Features

- M0-06 (Auth): Replace hardcoded LoggedOut state in NavigationExtensions with real auth state check
- M2-01 (Cart): Replace `cartBadgeCount = 0` in XGAppScaffold with real cart state observation
- M1+ (All features): Replace PlaceholderScreen calls in XGNavHost with real screen composables
