# M0-04: Navigation

## Overview

The Navigation feature establishes the app's full routing and tab-based navigation infrastructure for both Android and iOS. It replaces the placeholder app entry point with a functional four-tab layout, where each tab maintains its own independent navigation stack. All screens from M0 through M4 are registered as typed route destinations; unimplemented screens show placeholder views until their milestone arrives.

**Status**: Complete
**Phase**: M0 (Foundation)
**Platforms**: Android (Kotlin + Jetpack Compose) + iOS (Swift + SwiftUI)
**Blocks**: All M1+ features (every screen registers as a navigation destination here)

### What This Feature Provides

- Four-tab bottom bar (Home, Categories, Cart, Profile) using `MoltBottomBar` (Android) / `MoltTabBar` (iOS)
- Independent per-tab navigation stack with back-stack preservation on tab switch
- 29 type-safe route definitions covering all M0–M4 screens
- `molt://` custom scheme and `https://molt.mt/` universal link deep linking
- Auth-gated navigation with `returnTo` redirect to Login for protected routes
- Cart badge count wiring (hidden at 0 until M2-01 provides the cart count)
- Placeholder screens for all unimplemented routes (replaced feature-by-feature in M1+)
- 10 new localization keys in English, Maltese, and Turkish

### Dependencies

| Depends On | What Is Needed |
|-----------|----------------|
| M0-01: App Scaffold | `MainActivity.kt`, `MoltMarketplaceApp.swift`, project structure |
| M0-02: Design System | `MoltBottomBar` (Android), `MoltTabBar` (iOS) |

---

## Architecture

### Route Definitions

All screens in the app are declared as a single sealed type hierarchy. Routes that are not yet implemented show a placeholder view until their milestone feature is built.

**Android** — `Route` is a `sealed interface` in `core/navigation`. Every route variant is annotated with `@Serializable` (Kotlin Serialization) for type-safe Compose Navigation 2.8+. Auth requirement is expressed via an `isAuthRequired` computed property using an exhaustive `when` expression.

```kotlin
// android/app/src/main/java/com/molt/marketplace/core/navigation/Route.kt
sealed interface Route {
    @Serializable data object Home : Route
    @Serializable data class ProductDetail(val productId: String) : Route
    @Serializable data class Login(val returnTo: String? = null) : Route
    // ... 26 more routes

    val Route.isAuthRequired: Boolean get() = when (this) {
        is Checkout, is CheckoutAddress, is CheckoutShipping,
        is CheckoutPayment, is OrderConfirmation, is OrderList,
        is OrderDetail, is Settings, is AddressManagement,
        is Wishlist, is PaymentMethods, is Notifications,
        is WriteReview, is PriceAlerts -> true
        else -> false
    }
}
```

**iOS** — `Route` is a `Hashable` enum in `Core/Navigation`. Associated values carry route parameters. Auth requirement is a computed `requiresAuth: Bool` property. The `login` case uses `returnTo: String?` (not `Route?`) to avoid recursive Hashable conformance.

```swift
// ios/MoltMarketplace/Core/Navigation/Route.swift
enum Route: Hashable {
    case home
    case productDetail(productId: String)
    case login(returnTo: String? = nil)
    // ... 26 more cases

    var requiresAuth: Bool {
        switch self {
        case .checkout, .checkoutAddress, .checkoutShipping,
             .checkoutPayment, .orderConfirmation, .orderList,
             .orderDetail, .settings, .addressManagement,
             .wishlist, .paymentMethods, .notifications,
             .writeReview, .priceAlerts: return true
        default: return false
        }
    }
}
```

**Complete Route Table** (29 routes):

| Route | Parameters | Auth Required | Primary Tab | Milestone |
|-------|-----------|---------------|-------------|-----------|
| `Home` | — | No | Home | M1-04 |
| `Categories` | — | No | Categories | M1-05 |
| `CategoryProducts` | `categoryId`, `categoryName` | No | Categories | M1-05 |
| `ProductList` | `categoryId?`, `query?` | No | Categories | M1-06 |
| `ProductDetail` | `productId` | No | Any | M1-07 |
| `ProductSearch` | — | No | Any | M1-08 |
| `Cart` | — | No | Cart | M2-01 |
| `Checkout` | — | Yes | Cart | M2-04 |
| `CheckoutAddress` | — | Yes | Cart | M2-04 |
| `CheckoutShipping` | — | Yes | Cart | M2-05 |
| `CheckoutPayment` | — | Yes | Cart | M2-06 |
| `OrderConfirmation` | `orderId` | Yes | Cart | M2-07 |
| `Profile` | — | Partial | Profile | M3-03 |
| `Login` | `returnTo?` | No | Modal | M1-01 |
| `Register` | — | No | Modal | M1-02 |
| `ForgotPassword` | — | No | Modal | M1-03 |
| `OrderList` | — | Yes | Profile | M3-01 |
| `OrderDetail` | `orderId` | Yes | Profile | M3-02 |
| `Settings` | — | Yes | Profile | M3-06 |
| `AddressManagement` | — | Yes | Profile | M2-03 |
| `Wishlist` | — | Yes | Profile | M2-02 |
| `PaymentMethods` | — | Yes | Profile | M3-04 |
| `Notifications` | — | Yes | Profile | M3-05 |
| `VendorStore` | `vendorId` | No | Any | M3-08 |
| `ProductReviews` | `productId` | No | Any | M3-07 |
| `WriteReview` | `productId` | Yes | Any | M3-07 |
| `RecentlyViewed` | — | No | Profile | M4-02 |
| `PriceAlerts` | — | Yes | Profile | M4-03 |
| `Onboarding` | — | No | Fullscreen | M4-05 |

### Tab Definitions

**Android** — `TopLevelDestination` enum (`core/navigation/TopLevelDestination.kt`) with four entries: `HOME`, `CATEGORIES`, `CART`, `PROFILE`. Each entry carries a `Route`, a filled/outlined `ImageVector` icon pair, and a label string resource ID.

**iOS** — `Tab` enum conforming to `String, CaseIterable, Identifiable` (`Core/Navigation/Tab.swift`). Each case provides a localized `title`, an unselected `systemImage` (SF Symbol name), and a `selectedSystemImage`.

| Tab | Index | Android Icon | iOS Symbol | Label Key | Auth |
|-----|-------|-------------|------------|-----------|------|
| Home | 0 | `Icons.Filled.Home` | `house.fill` | `nav_tab_home` | No |
| Categories | 1 | `Icons.Filled.Category` | `square.grid.2x2.fill` | `nav_tab_categories` | No |
| Cart | 2 | `Icons.Filled.ShoppingCart` | `cart.fill` | `nav_tab_cart` | No |
| Profile | 3 | `Icons.Filled.Person` | `person.fill` | `nav_tab_profile` | Partial |

Profile tab is always accessible. Guests see a login prompt; authenticated users see the profile menu.

### Navigation State

**Android — `MoltAppScaffold`** (`core/navigation/MoltAppScaffold.kt`)

Single `NavHostController` manages the entire nav graph. Tab switching uses `saveState`/`restoreState` to preserve per-tab back stacks:

```kotlin
navController.navigate(destination.route) {
    popUpTo(navController.graph.findStartDestination().id) { saveState = true }
    launchSingleTop = true
    restoreState = true
}
```

Bottom bar visibility is determined by the current route — hidden for Login, Register, ForgotPassword, Onboarding, CheckoutAddress, CheckoutShipping, CheckoutPayment, and OrderConfirmation.

**iOS — `AppRouter`** (`Core/Navigation/AppRouter.swift`)

`@MainActor @Observable` class managing one `NavigationPath` per tab. The tab layout uses ZStack with opacity-based switching (not native `TabView`) to preserve all four NavigationStack states simultaneously.

```swift
@MainActor @Observable
final class AppRouter {
    private(set) var selectedTab: Tab = .home
    private(set) var homePath = NavigationPath()
    private(set) var categoriesPath = NavigationPath()
    private(set) var cartPath = NavigationPath()
    private(set) var profilePath = NavigationPath()
    private(set) var presentedAuth: Route? = nil
    var cartBadgeCount: Int = 0

    func navigate(to route: Route)
    func popToRoot()
    func popAllToRoot()
    func presentLogin(returnTo: Route? = nil)
    func handleDeepLink(_ url: URL)
}
```

### Deep Linking

**Supported URI patterns:**

| URI Pattern | Target Route | Auth |
|-------------|-------------|------|
| `molt://product/{id}` | `ProductDetail(productId: id)` | No |
| `molt://category/{id}` | `CategoryProducts(categoryId: id, categoryName: "")` | No |
| `molt://cart` | `Cart` | No |
| `molt://order/{id}` | `OrderDetail(orderId: id)` | Yes |
| `molt://profile` | `Profile` | Partial |
| `https://molt.mt/product/{id}` | `ProductDetail(productId: id)` | No |
| `https://molt.mt/category/{id}` | `CategoryProducts(categoryId: id, categoryName: "")` | No |

Invalid or unrecognized deep links are silently ignored; the app remains on the current screen.

**Android**: Intent filters declared in `AndroidManifest.xml`; `MainActivity` handles via `onNewIntent`. `DeepLinkParser` object (`core/navigation/DeepLinkParser.kt`) parses `Uri` → `Route?`.

**iOS**: `onOpenURL` modifier on `MainTabView`; URL scheme registered in `Info.plist` `CFBundleURLTypes`. `DeepLinkParser` enum (`Core/Navigation/DeepLinkParser.swift`) parses `URL` → `Route?` using static methods.

### Auth-Gated Navigation Flow

```
User navigates to auth-required route
             |
             v
    Is user authenticated?
    |  Yes               |  No
    v                    v
Navigate to target    Present Login(returnTo: route)
                             |
                   User logs in successfully?
                   |  Yes          |  No
                   v               v
              Navigate to       Stay on Login
              returnTo route    (or Home if dismissed)
```

Auth gating is wired in M0-04 but enforces "always guest" until M0-06 replaces the stub with a real `AuthStateProvider`.

---

## Navigation Flows

### Tab Back-Stack Behavior

1. Each tab owns an independent navigation stack. Switching tabs preserves the previous tab's stack.
2. Tapping the active tab pops all screens back to the tab root.
3. Android system Back from a non-Home tab root switches to Home tab. From the Home root, it exits the app.
4. iOS swipe-back pops the current tab's NavigationStack normally.

### Tab Stacks

**Home tab**: `Home` → `ProductDetail` → `ProductSearch` → `VendorStore` → `ProductReviews`

**Categories tab**: `Categories` → `CategoryProducts` → `ProductDetail`; or `ProductList` → `ProductDetail`; or `ProductSearch`

**Cart tab**: `Cart` → `Checkout` → `CheckoutAddress` → `CheckoutShipping` → `CheckoutPayment` → `OrderConfirmation`

**Profile tab (authenticated)**: `Profile` → `OrderList` → `OrderDetail`; `Wishlist` → `ProductDetail`; `AddressManagement`; `PaymentMethods`; `Notifications`; `Settings`; `RecentlyViewed`; `PriceAlerts`

### Tab Bar Visibility

| Screen Type | Tab Bar Visible |
|-------------|----------------|
| Tab root screens | Yes |
| Pushed screens within tabs | Yes |
| Login / Register / ForgotPassword | No |
| Onboarding | No |
| Checkout sub-screens (Address, Shipping, Payment) | No |
| OrderConfirmation | No |

---

## Localization

10 new string keys added in English, Maltese, and Turkish:

| Key | English |
|-----|---------|
| `nav_tab_home` | Home |
| `nav_tab_categories` | Categories |
| `nav_tab_cart` | Cart |
| `nav_tab_profile` | Profile |
| `nav_placeholder_coming_soon` | Coming soon |
| `nav_profile_guest_title` | Log in to manage your account |
| `nav_profile_guest_login_button` | Log In |
| `nav_profile_guest_register_button` | Create Account |
| `nav_cart_badge_description` | %d items in cart |
| `common_back_button` | Back |

**Android**: `res/values/strings.xml`, `res/values-mt/strings.xml`, `res/values-tr/strings.xml`
**iOS**: `Resources/Localizable.xcstrings` (String Catalog, all three languages)

---

## File Structure

### Android

**Root**: `android/app/src/main/java/com/molt/marketplace/core/navigation/`

```
core/navigation/
  Route.kt                   # Sealed interface with all 28 @Serializable routes; isAuthRequired property
  TopLevelDestination.kt     # Enum: HOME, CATEGORIES, CART, PROFILE; icons + label resource IDs
  MoltNavHost.kt             # Single NavHost with all 28 composable() destinations; PlaceholderScreen fallback
  MoltAppScaffold.kt         # Scaffold + MoltBottomBar + MoltNavHost; tab selection; bottom bar visibility
  NavigationExtensions.kt    # navigateToTopLevel(), navigateToRoute() NavController extensions
  DeepLinkParser.kt          # parse(Uri): Route? for molt:// and https://molt.mt/
  PlaceholderScreen.kt       # Temporary placeholder: icon + title + "Coming soon"
```

**Modified files:**

| File | Change |
|------|--------|
| `MainActivity.kt` | Replaced placeholder `Box/Text` with `MoltAppScaffold()`; added `onNewIntent` for deep links |
| `AndroidManifest.xml` | Added `launchMode="singleTask"`; intent filters for `molt://` and `https://molt.mt` |
| `res/values/strings.xml` | 10 navigation string keys (en) |
| `res/values-mt/strings.xml` | 10 navigation string keys (mt) |
| `res/values-tr/strings.xml` | 10 navigation string keys (tr) |
| `gradle/libs.versions.toml` | Added Robolectric 4.14.1 for DeepLinkParser unit tests |
| `app/build.gradle.kts` | Added `testImplementation(libs.robolectric)` |

### iOS

**Root**: `ios/MoltMarketplace/Core/Navigation/`

```
Core/Navigation/
  Tab.swift                           # Tab enum (home, categories, cart, profile); SF Symbol names + titles
  Route.swift                         # Route enum with associated values; requiresAuth: Bool
  AppRouter.swift                     # @MainActor @Observable router; 4 NavigationPaths; tab + auth + deep link
  MainTabView.swift                   # Root ZStack layout; NavigationStack per tab; fullScreenCover for auth
  NavigationDestinationModifier.swift # ViewModifier: .navigationDestination(for: Route.self)
  RouteView.swift                     # Maps Route -> View (PlaceholderView until M1+)
  DeepLinkParser.swift                # parse(_ url: URL) -> Route? for molt:// and https://molt.mt/
  PlaceholderView.swift               # Temporary placeholder: SF Symbol icon + title + "Coming soon"
```

**Modified files:**

| File | Change |
|------|--------|
| `MoltMarketplaceApp.swift` | Replaced `ContentView()` with `MainTabView()`; injected `AppRouter` into environment |
| `Resources/Info.plist` | Added `CFBundleURLTypes` entry for `molt` URL scheme |
| `Resources/Localizable.xcstrings` | 10 navigation string keys (en, mt, tr) |
| `ios/MoltMarketplace.xcodeproj/project.pbxproj` | Added Navigation group and 8 source files |

---

## Testing

### Android

**Test framework**: JUnit 4 + Truth + Compose UI Test + Robolectric

**Tests written by Android Dev** (3 files, 45 tests):

| File | Tests | Coverage |
|------|-------|----------|
| `DeepLinkParserTest.kt` | 15 | Valid molt://, valid https://molt.mt/, missing params, empty IDs, wrong host |
| `RouteAuthTest.kt` | 19 | Every route verified for correct `isAuthRequired` value |
| `TopLevelDestinationTest.kt` | 11 | Count, routes, labels, icons, ordering |

**Tests written by Android Tester** (4 files, ~93 tests):

| File | Type | Tests | Coverage |
|------|------|-------|----------|
| `RouteSerializationTest.kt` | Unit | ~44 | All Route variants serialize/deserialize round-trip; JSON key verification; equality |
| `DeepLinkParserEdgeCasesTest.kt` | Unit (Robolectric) | ~28 | Empty/blank input, malformed URIs, extra segments, wrong schemes, query params |
| `MoltAppScaffoldTest.kt` | Compose UI | ~11 | Tab labels, Home default selection, tab switching, cart badge hidden at 0, bottom bar visibility |
| `PlaceholderScreenTest.kt` | Compose UI | ~10 | Title rendering for 5 routes, "Coming soon" subtitle, title uniqueness |

**Total Android navigation tests: ~138**

Test paths:
- Unit: `android/app/src/test/java/com/molt/marketplace/core/navigation/`
- UI: `android/app/src/androidTest/java/com/molt/marketplace/core/navigation/`

Run unit tests: `./gradlew testDebugUnitTest --tests "com.molt.marketplace.core.navigation.*"`

### iOS

**Test framework**: Swift Testing (`@Test` macro, `@Suite`)

**Tests written by iOS Tester** (5 files, ~167 tests):

| File | Tests | Coverage |
|------|-------|----------|
| `TabTests.swift` | 26 | All 4 tabs, order, `Identifiable`, unique IDs, correct SF Symbol names, `Sendable` |
| `RouteTests.swift` | 42 | 14 auth-required routes, 20 public routes, associated values, `Hashable`, `Route.title` |
| `DeepLinkParserTests.swift` | 30 | All valid patterns, missing params, unknown hosts/schemes, edge cases, auth flags on parsed routes |
| `AppRouterTests.swift` | 44 | Initial state, tab switching, navigate, pop, popToRoot, popAllToRoot, presentLogin, dismissAuth, cartBadgeCount, handleDeepLink |
| `PlaceholderViewTests.swift` | 25 | PlaceholderView initialisation, body renders for all inputs, integration with `Route.title`, RouteView renders all 29 routes |

**Total iOS navigation tests: ~167**

Test path: `ios/MoltMarketplaceTests/Core/Navigation/`

### Combined Test Summary

| Platform | Test Files | Test Cases |
|----------|-----------|-----------|
| Android | 7 | ~138 |
| iOS | 5 | ~167 |
| **Total** | **12** | **~305** |

---

## Integration Points for Future Features

| Feature | What Needs to Change |
|---------|---------------------|
| M0-06 Auth Infrastructure | Replace auth stub in `NavigationExtensions.kt` / `AppRouter.navigate(to:)` with real `AuthStateProvider` |
| M1-01 Login Screen | Replace `PlaceholderScreen`/`PlaceholderView` for `Route.Login` with real login screen; handle `returnTo` on success |
| M1-04 Home Screen | Replace placeholder for `Route.Home` |
| M2-01 Cart | Provide `cartItemCount` flow/stream to update `cartBadgeCount` on tab bar |
| All M1+ features | Each feature replaces its placeholder in `MoltNavHost` (Android) / `RouteView` (iOS) with the real screen |

---

## Documentation References

- **Architect Spec**: `shared/feature-specs/navigation.md`
- **CLAUDE.md Standards**: `CLAUDE.md`
- **Android Standards**: `docs/standards/android.md`
- **iOS Standards**: `docs/standards/ios.md`

---

**Last Updated**: 2026-02-21
**Agent**: doc-writer
**Status**: Complete
