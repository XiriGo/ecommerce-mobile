# M0-04: Navigation -- Feature Specification

## Overview

The Navigation feature establishes the app's tab-based navigation structure, type-safe routing
for all screens across milestones M0 through M4, deep linking support, and auth-gated navigation.
This replaces the placeholder "Molt Marketplace" text screen with a fully functional four-tab
layout, where each tab maintains its own independent navigation stack.

### User Stories

- As a **buyer**, I want a tab bar at the bottom so I can quickly switch between Home, Categories, Cart, and Profile.
- As a **buyer**, I want each tab to remember where I was when I switch between tabs, so I do not lose my place.
- As a **buyer**, I want to tap the active tab to go back to its root screen.
- As a **buyer**, I want to see a badge on the Cart tab showing how many items are in my cart.
- As a **buyer**, I want to open product pages from links shared by others (deep linking).
- As a **guest**, I want to browse products, categories, and view my cart without logging in.
- As a **guest**, when I try to access a screen that requires login, I want to be redirected to the login screen and returned to my intended destination after logging in.
- As a **developer**, I want type-safe routes with compile-time checked parameters so I cannot navigate with invalid data.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Four-tab bottom bar (Home, Categories, Cart, Profile) | Home screen content (M1-04) |
| Independent navigation stack per tab | Category/product list screens (M1-05, M1-06) |
| Type-safe route definitions for all M0--M4 screens | Auth token storage/refresh (M0-06) |
| Auth-gated navigation (redirect to Login) | Network layer (M0-03) |
| Deep link parsing and routing | DI module registrations (M0-05) |
| Cart badge count display | Cart business logic (M2-01) |
| Tab state preservation on switch | Screen implementations (M1+) |
| Return-to-destination after login | MoltBottomBar/MoltTabBar component internals (M0-02) |
| Placeholder content per tab (temporary) | |

### Dependencies on Other Features

| Feature | What This Feature Needs |
|---------|------------------------|
| M0-01: App Scaffold | `MainActivity.kt`, `MoltMarketplaceApp.swift`, `MoltTheme`, project structure |
| M0-02: Design System | `MoltBottomBar` (Android), `MoltTabBar` (iOS) components |

### Features That Depend on This

All M1+ features. Every screen in the app uses the routing and navigation infrastructure
defined here. Specific dependencies:

- M0-06: Auth Infrastructure -- uses `Route.Login(returnTo:)` for auth-gated redirects
- M1-01 through M1-08: All core buyer screens register as navigation destinations
- M2-01: Cart -- provides `cartBadgeCount` for tab badge
- M2-04 through M2-07: Checkout flow uses sequential navigation within Cart tab
- M3-01 through M3-08: Profile sub-screens use Profile tab navigation stack
- M4-01 through M4-05: Advanced features register additional routes

---

## 1. API Mapping

Navigation is entirely client-side. There are no backend API calls associated with this feature.

The cart badge count is provided by the cart state (M2-01) once implemented. Until then,
the badge count defaults to `0` and is hidden.

The auth state is provided by the auth infrastructure (M0-06) once implemented. Until then,
all routes are treated as accessible (no auth gating enforced).

---

## 2. Data Models

### 2.1 Tab Enum

Defines the four top-level tabs displayed in the bottom navigation bar.

| Tab | Index | Icon (Android Material) | Icon (iOS SF Symbol) | Label Key | Auth Required |
|-----|-------|------------------------|---------------------|-----------|---------------|
| Home | 0 | `Icons.Outlined.Home` / `Icons.Filled.Home` | `house` / `house.fill` | `nav_tab_home` | No |
| Categories | 1 | `Icons.Outlined.Category` / `Icons.Filled.Category` | `square.grid.2x2` / `square.grid.2x2.fill` | `nav_tab_categories` | No |
| Cart | 2 | `Icons.Outlined.ShoppingCart` / `Icons.Filled.ShoppingCart` | `cart` / `cart.fill` | `nav_tab_cart` | No |
| Profile | 3 | `Icons.Outlined.Person` / `Icons.Filled.Person` | `person` / `person.fill` | `nav_tab_profile` | Partial |

**Partial auth on Profile tab**: The tab itself is always accessible. When the user is a guest,
the Profile tab root shows the Login screen. When authenticated, it shows the Profile screen.

**Android (Kotlin)**:

```
Enum: TopLevelDestination
Package: com.molt.marketplace.core.navigation

Properties:
  - route: Route (the root route for this tab's nav graph)
  - selectedIcon: ImageVector
  - unselectedIcon: ImageVector
  - labelResId: Int (R.string.nav_tab_*)

Values:
  HOME(route = Route.Home, selectedIcon = Icons.Filled.Home, unselectedIcon = Icons.Outlined.Home, labelResId = R.string.nav_tab_home)
  CATEGORIES(route = Route.Categories, selectedIcon = Icons.Filled.Category, unselectedIcon = Icons.Outlined.Category, labelResId = R.string.nav_tab_categories)
  CART(route = Route.Cart, selectedIcon = Icons.Filled.ShoppingCart, unselectedIcon = Icons.Outlined.ShoppingCart, labelResId = R.string.nav_tab_cart)
  PROFILE(route = Route.Profile, selectedIcon = Icons.Filled.Person, unselectedIcon = Icons.Outlined.Person, labelResId = R.string.nav_tab_profile)
```

**iOS (Swift)**:

```
Enum: Tab
File: Tab.swift
Conforms to: String, CaseIterable, Identifiable

Properties:
  - title: String (localized)
  - systemImage: String (SF Symbol name, unselected)
  - selectedSystemImage: String (SF Symbol name, selected)

Cases:
  case home       -> title: String(localized: "nav_tab_home"),       systemImage: "house",           selectedSystemImage: "house.fill"
  case categories -> title: String(localized: "nav_tab_categories"), systemImage: "square.grid.2x2", selectedSystemImage: "square.grid.2x2.fill"
  case cart       -> title: String(localized: "nav_tab_cart"),       systemImage: "cart",             selectedSystemImage: "cart.fill"
  case profile    -> title: String(localized: "nav_tab_profile"),    systemImage: "person",           selectedSystemImage: "person.fill"

var id: String { rawValue }
```

### 2.2 Route Definition

All screens across all milestones are defined in a single sealed hierarchy. Routes that are
not yet implemented render a placeholder view with the route name until their milestone is reached.

**Android (Kotlin)**:

```
Sealed interface: Route
Package: com.molt.marketplace.core.navigation
Annotation: @Serializable on each route

All routes use Kotlin Serialization for type-safe Compose Navigation (Navigation 2.8+).
```

**iOS (Swift)**:

```
Enum: Route
File: Route.swift
Conforms to: Hashable, Codable
```

**Complete Route Table**:

| Route | Parameters | Auth Required | Primary Tab | Milestone |
|-------|-----------|---------------|-------------|-----------|
| `Home` | -- | No | Home | M1-04 |
| `Categories` | -- | No | Categories | M1-05 |
| `CategoryProducts` | `categoryId: String`, `categoryName: String` | No | Categories | M1-05 |
| `ProductList` | `categoryId: String?`, `query: String?` | No | Categories | M1-06 |
| `ProductDetail` | `productId: String` | No | Any | M1-07 |
| `ProductSearch` | -- | No | Any | M1-08 |
| `Cart` | -- | No | Cart | M2-01 |
| `Checkout` | -- | Yes | Cart | M2-04 |
| `CheckoutAddress` | -- | Yes | Cart | M2-04 |
| `CheckoutShipping` | -- | Yes | Cart | M2-05 |
| `CheckoutPayment` | -- | Yes | Cart | M2-06 |
| `OrderConfirmation` | `orderId: String` | Yes | Cart | M2-07 |
| `Profile` | -- | Partial | Profile | M3-03 |
| `Login` | `returnTo: String?` | No | -- (modal/fullscreen) | M1-01 |
| `Register` | -- | No | -- (modal/fullscreen) | M1-02 |
| `ForgotPassword` | -- | No | -- (modal/fullscreen) | M1-03 |
| `OrderList` | -- | Yes | Profile | M3-01 |
| `OrderDetail` | `orderId: String` | Yes | Profile | M3-02 |
| `Settings` | -- | Yes | Profile | M3-06 |
| `AddressManagement` | -- | Yes | Profile | M2-03 |
| `Wishlist` | -- | Yes | Profile | M2-02 |
| `PaymentMethods` | -- | Yes | Profile | M3-04 |
| `Notifications` | -- | Yes | Profile | M3-05 |
| `VendorStore` | `vendorId: String` | No | Any | M3-08 |
| `ProductReviews` | `productId: String` | No | Any | M3-07 |
| `WriteReview` | `productId: String` | Yes | Any | M3-07 |
| `RecentlyViewed` | -- | No | Profile | M4-02 |
| `PriceAlerts` | -- | Yes | Profile | M4-03 |
| `Onboarding` | -- | No | -- (fullscreen) | M4-05 |

**Android Route Definitions (Kotlin Serialization)**:

```
@Serializable data object Home : Route
@Serializable data object Categories : Route
@Serializable data class CategoryProducts(val categoryId: String, val categoryName: String) : Route
@Serializable data class ProductList(val categoryId: String? = null, val query: String? = null) : Route
@Serializable data class ProductDetail(val productId: String) : Route
@Serializable data object ProductSearch : Route
@Serializable data object Cart : Route
@Serializable data object Checkout : Route
@Serializable data object CheckoutAddress : Route
@Serializable data object CheckoutShipping : Route
@Serializable data object CheckoutPayment : Route
@Serializable data class OrderConfirmation(val orderId: String) : Route
@Serializable data object Profile : Route
@Serializable data class Login(val returnTo: String? = null) : Route
@Serializable data object Register : Route
@Serializable data object ForgotPassword : Route
@Serializable data class OrderDetail(val orderId: String) : Route
@Serializable data object OrderList : Route
@Serializable data object Settings : Route
@Serializable data object AddressManagement : Route
@Serializable data object Wishlist : Route
@Serializable data object PaymentMethods : Route
@Serializable data object Notifications : Route
@Serializable data class VendorStore(val vendorId: String) : Route
@Serializable data class ProductReviews(val productId: String) : Route
@Serializable data class WriteReview(val productId: String) : Route
@Serializable data object RecentlyViewed : Route
@Serializable data object PriceAlerts : Route
@Serializable data object Onboarding : Route
```

**iOS Route Definitions (Swift Enum)**:

```
enum Route: Hashable {
    // Home tab
    case home

    // Categories tab
    case categories
    case categoryProducts(categoryId: String, categoryName: String)
    case productList(categoryId: String? = nil, query: String? = nil)

    // Shared (can appear in any tab)
    case productDetail(productId: String)
    case productSearch
    case vendorStore(vendorId: String)
    case productReviews(productId: String)
    case writeReview(productId: String)

    // Cart tab
    case cart
    case checkout
    case checkoutAddress
    case checkoutShipping
    case checkoutPayment
    case orderConfirmation(orderId: String)

    // Profile tab
    case profile
    case orderList
    case orderDetail(orderId: String)
    case settings
    case addressManagement
    case wishlist
    case paymentMethods
    case notifications
    case recentlyViewed
    case priceAlerts

    // Auth (modal / fullscreen, not in a tab)
    case login(returnTo: Route? = nil)
    case register
    case forgotPassword

    // Onboarding (fullscreen, not in a tab)
    case onboarding
}
```

### 2.3 Auth-Required Routes

A static set/list defining which routes require authentication:

```
Auth-required routes:
  - Checkout
  - CheckoutAddress
  - CheckoutShipping
  - CheckoutPayment
  - OrderConfirmation
  - OrderList
  - OrderDetail
  - Settings
  - AddressManagement
  - Wishlist
  - PaymentMethods
  - Notifications
  - WriteReview
  - PriceAlerts
```

**Android**: Companion object or top-level property on Route sealed interface:
```
val Route.requiresAuth: Boolean (computed property via exhaustive when)
```

**iOS**: Computed property on Route enum:
```
var requiresAuth: Bool (computed property via switch)
```

### 2.4 Deep Link Mapping

| URI Pattern | Target Route | Auth Required |
|-------------|-------------|---------------|
| `molt://product/{id}` | `ProductDetail(productId: id)` | No |
| `molt://category/{id}` | `CategoryProducts(categoryId: id, categoryName: "")` | No |
| `molt://cart` | `Cart` | No |
| `molt://order/{id}` | `OrderDetail(orderId: id)` | Yes |
| `molt://profile` | `Profile` | Partial |
| `https://molt.mt/product/{id}` | `ProductDetail(productId: id)` | No |
| `https://molt.mt/category/{id}` | `CategoryProducts(categoryId: id, categoryName: "")` | No |

**Android**: Defined via `deepLinks` parameter in `composable()` within NavHost.
Also declared in `AndroidManifest.xml` for `https://` links:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="molt" />
    <data android:scheme="https" android:host="molt.mt" />
</intent-filter>
```

**iOS**: Handled via `onOpenURL` modifier in `MainTabView`.
URL scheme `molt` declared in Info.plist `CFBundleURLTypes`.
Universal links via associated domains (`applinks:molt.mt`).

---

## 3. UI Wireframe

### 3.1 Main App Layout (Tab Bar Active)

```
+------------------------------------------+
|  [Status Bar]                            |
+------------------------------------------+
|                                          |
|                                          |
|                                          |
|          [Content Area]                  |
|     (NavigationStack per tab)            |
|     Each tab has independent             |
|     back stack                           |
|                                          |
|                                          |
|                                          |
+------------------------------------------+
|                                          |
| [ Home ]  [ Categories ]  [ Cart ]  [ Profile ] |
|    |           |            |  3       |
|  (icon)     (icon)       (icon)     (icon)
|  (label)    (label)      (label)    (label)
|    ^                       ^
|  active                  badge
|  (filled,                (red circle
|   primary)                with count)
+------------------------------------------+
```

**Tab bar visibility rules**:
- Visible on all root screens (Home, Categories, Cart, Profile)
- Visible on most pushed screens
- Hidden on fullscreen modals: Login, Register, ForgotPassword, Onboarding
- Hidden during Checkout flow (CheckoutAddress, CheckoutShipping, CheckoutPayment)

### 3.2 Tab Bar Detail

```
+------------------------------------------+
|  [Home]    [Categories]   [Cart]  [Profile]|
|                                          |
|  house     grid.2x2      cart    person  |  <-- icons (outlined when inactive, filled when active)
|  Home      Categories    Cart    Profile |  <-- labels (always visible)
|  ----                     (3)            |
|  primary                badge            |  <-- active indicator + badge
+------------------------------------------+

Badge:
  - Only on Cart tab
  - Shows item count from cart state
  - Hidden when count is 0
  - Red circle (#B3261E) with white text
  - Max display: "99+" for counts > 99
```

### 3.3 Placeholder Tab Content (Until Features Are Implemented)

Each tab shows a temporary placeholder view until its milestone feature is built.

```
+------------------------------------------+
|                                          |
|                                          |
|                                          |
|          [Tab Icon - large]              |
|                                          |
|          "Home"                          |  <-- tab name, headlineSmall
|          "Coming soon"                   |  <-- bodyMedium, secondary color
|                                          |
|                                          |
|                                          |
+------------------------------------------+
| [ Home ]  [ Categories ]  [ Cart ]  [ Profile ] |
+------------------------------------------+
```

### 3.4 Auth-Gated Navigation Flow

```
Guest taps "Checkout"  or  Guest taps auth-required route
         |
         v
    +-----------------+
    | Is user logged  |
    | in?             |
    +-----------------+
    |  Yes    |  No   |
    v         v
Navigate     Present Login Screen
to target    (Login(returnTo: "Checkout"))
             |
             v
        +-----------------+
        | Login success?  |
        +-----------------+
        |  Yes    |  No   |
        v         v
   Navigate    Stay on
   to returnTo Login
   (or Profile
   if null)
```

### 3.5 Profile Tab -- Guest vs. Authenticated

**Guest**:
```
+------------------------------------------+
|                                          |
|          [Person icon - large]           |
|                                          |
|     "Log in to manage your account"      |
|                                          |
|     [  Log In  ]  (primary button)       |
|     [  Create Account  ] (text button)   |
|                                          |
+------------------------------------------+
| [ Home ]  [ Categories ]  [ Cart ]  [ Profile ] |
+------------------------------------------+
```

**Authenticated**:
```
+------------------------------------------+
|  Profile                          [gear] |
+------------------------------------------+
|                                          |
|  [Avatar]  John Doe                      |
|            john@example.com              |
|                                          |
|  ---- My Account ---------------------   |
|  [>] Orders                              |
|  [>] Wishlist                            |
|  [>] Addresses                           |
|  [>] Payment Methods                     |
|  [>] Notifications                       |
|  [>] Recently Viewed                     |
|  [>] Price Alerts                        |
|  ---- Settings -----------------------   |
|  [>] Settings                            |
|                                          |
+------------------------------------------+
| [ Home ]  [ Categories ]  [ Cart ]  [ Profile ] |
+------------------------------------------+
```

---

## 4. Navigation Flow

### 4.1 Tab Switching Behavior

1. **Each tab owns its own NavigationStack/NavHost** with an independent back stack.
2. **Switching tabs** preserves the navigation state of the previous tab. When the user
   returns to a tab, they see the exact screen they left.
3. **Tapping the active tab** pops all screens in that tab's stack back to the root.
4. **System back button (Android)** pops the current tab's stack. If at the root of a
   non-Home tab, it switches to the Home tab. If at the Home tab root, it exits the app.
5. **Swipe back (iOS)** pops the current tab's navigation stack normally.

### 4.2 Navigation Within Tabs

**Home tab stack**:
```
Home (root)
  -> ProductDetail(productId)
  -> ProductSearch
  -> VendorStore(vendorId)
  -> ProductReviews(productId)
```

**Categories tab stack**:
```
Categories (root)
  -> CategoryProducts(categoryId, categoryName)
    -> ProductDetail(productId)
  -> ProductList(categoryId, query)
    -> ProductDetail(productId)
  -> ProductSearch
```

**Cart tab stack**:
```
Cart (root)
  -> Checkout
    -> CheckoutAddress
      -> CheckoutShipping
        -> CheckoutPayment
          -> OrderConfirmation(orderId)
```

**Profile tab stack (authenticated)**:
```
Profile (root)
  -> OrderList
    -> OrderDetail(orderId)
  -> Wishlist
    -> ProductDetail(productId)
  -> AddressManagement
  -> PaymentMethods
  -> Notifications
  -> Settings
  -> RecentlyViewed
    -> ProductDetail(productId)
  -> PriceAlerts
    -> ProductDetail(productId)
```

### 4.3 Cross-Tab Navigation

Some routes can be pushed onto any tab's stack (they are "shared" destinations):

- `ProductDetail(productId)` -- accessible from Home, Categories, Cart (via order items), Profile (via wishlist, orders)
- `ProductSearch` -- accessible from Home, Categories
- `VendorStore(vendorId)` -- accessible from Product Detail in any tab
- `ProductReviews(productId)` -- accessible from Product Detail in any tab
- `WriteReview(productId)` -- accessible from Product Reviews in any tab

These are pushed onto the **current tab's** navigation stack, not a separate stack.

### 4.4 Auth-Gated Navigation Rules

1. When a user attempts to navigate to a route where `requiresAuth == true`:
   a. Check the current auth state (provided by M0-06).
   b. If authenticated: proceed to the target route normally.
   c. If not authenticated: redirect to `Login(returnTo: targetRouteSerialized)`.
2. The `returnTo` parameter is a serialized route string (e.g., `"checkout"`, `"order/abc123"`).
3. After successful login:
   a. If `returnTo` is not null: navigate to the deserialized route.
   b. If `returnTo` is null: navigate to Profile (default post-login destination).
4. After successful registration: navigate to Home (with welcome snackbar/toast).
5. After logout:
   a. Pop all tab navigation stacks to root.
   b. Switch to the Home tab.
   c. Clear any cached auth-dependent data.

### 4.5 Deep Link Handling

1. App receives a deep link URL (via `molt://` scheme or `https://molt.mt/` universal link).
2. Parse the URL to extract the route and parameters.
3. If the route requires auth and the user is not authenticated:
   a. Navigate to Login with `returnTo` set to the deep link route.
4. If the route is valid:
   a. Determine which tab the route belongs to.
   b. Switch to that tab.
   c. Push the route onto that tab's navigation stack.
5. If the route is invalid or cannot be parsed:
   a. Ignore the deep link silently.
   b. Show the Home tab (no error to user).

### 4.6 Transition Animations

- **Android**: Default Material motion transitions (shared axis, container transform as appropriate). No custom animations in M0-04.
- **iOS**: Default UINavigationController push/pop animations. No custom transitions in M0-04.
- **Tab switching**: Instant (no animation between tab content areas). This is default platform behavior.

### 4.7 Tab Bar Hiding

The tab bar is hidden for the following screen types:

| Screen Type | Tab Bar Visible | Reason |
|-------------|----------------|--------|
| Tab root screens (Home, Categories, Cart, Profile) | Yes | Primary navigation |
| Pushed screens within tabs (ProductDetail, OrderList, etc.) | Yes | User needs tab access |
| Login / Register / ForgotPassword | No | Fullscreen auth flow |
| Onboarding | No | Fullscreen onboarding flow |
| Checkout sub-screens (Address, Shipping, Payment) | No | Focused checkout flow |
| OrderConfirmation | No | Fullscreen confirmation |

**Android implementation**: The `MoltAppScaffold` conditionally shows `MoltBottomBar` based on the current route.
**iOS implementation**: `MainTabView` presents auth/onboarding flows as fullscreen covers. Checkout sub-screens use a nested `NavigationStack` without the tab bar.

---

## 5. State Management

### 5.1 Navigation State

**Android**:

```
Class: NavigationState (managed by MoltAppScaffold)

Properties:
  - navController: NavHostController (single controller for the entire nav graph)
  - currentDestination: NavDestination? (observed via currentBackStackEntryAsState)
  - selectedTab: TopLevelDestination (derived from currentDestination)

Tab back stack management uses Compose Navigation's saveState/restoreState:
  navController.navigate(destination.route) {
      popUpTo(navController.graph.findStartDestination().id) { saveState = true }
      launchSingleTop = true
      restoreState = true
  }
```

**iOS**:

```
@MainActor @Observable
final class AppRouter {
    private(set) var selectedTab: Tab = .home
    private(set) var homePath = NavigationPath()
    private(set) var categoriesPath = NavigationPath()
    private(set) var cartPath = NavigationPath()
    private(set) var profilePath = NavigationPath()

    // Auth (fullscreen presentation)
    private(set) var presentedAuth: Route? = nil  // .login, .register, .forgotPassword
    private(set) var isShowingOnboarding: Bool = false

    // Cart badge
    var cartBadgeCount: Int = 0

    // Computed
    var currentPath: NavigationPath (get/set based on selectedTab)

    // Methods
    func selectTab(_ tab: Tab)
    func navigate(to route: Route)
    func popToRoot()
    func popToRoot(tab: Tab)
    func popAllToRoot()
    func presentLogin(returnTo: Route? = nil)
    func dismissAuth()
    func handleDeepLink(_ url: URL)
}
```

### 5.2 Cart Badge State

The cart badge count is an integer representing the total number of items in the cart.

- **Source**: Cart feature (M2-01) exposes a `cartItemCount: Flow<Int>` (Android) / `AsyncStream<Int>` (iOS).
- **Until M2-01 is implemented**: Badge count is hardcoded to `0` and the badge is hidden.
- **Android**: `MoltAppScaffold` observes the cart count and passes it to `MoltBottomBar`.
- **iOS**: `AppRouter.cartBadgeCount` is updated by the cart feature. `MainTabView` reads it.
- **Display rules**: Hidden when `0`. Shows count for `1..99`. Shows `"99+"` for `>= 100`.

### 5.3 Auth State Integration

Navigation observes the auth state to enforce auth-gating.

- **Source**: Auth feature (M0-06) exposes `authState: StateFlow<AuthState>` (Android) / `@Observable authState: AuthState` (iOS).
- **Until M0-06 is implemented**: Auth state defaults to `LoggedOut`. Auth gating is wired but all routes are accessible (no actual login enforcement until M0-06 provides the state).
- **Auth state values**: `LoggedIn(customer)`, `LoggedOut`, `Loading`.

**Stub for M0-04** (replaced when M0-06 is implemented):

```
Android: AuthStateProvider interface with a stub returning LoggedOut
iOS: AuthStateProvider protocol with a stub returning .loggedOut
```

---

## 6. Localization Strings

### 6.1 New String Keys

| Key | English (en) | Maltese (mt) | Turkish (tr) |
|-----|-------------|-------------|-------------|
| `nav_tab_home` | Home | Dar | Ana Sayfa |
| `nav_tab_categories` | Categories | Kategoriji | Kategoriler |
| `nav_tab_cart` | Cart | Kartella | Sepet |
| `nav_tab_profile` | Profile | Profil | Profil |
| `nav_placeholder_coming_soon` | Coming soon | Dalwaqt | Yakinda |
| `nav_profile_guest_title` | Log in to manage your account | Idhlol biex tamministra l-kont tieghek | Hesabinizi yonetmek icin giris yapin |
| `nav_profile_guest_login_button` | Log In | Idhlol | Giris Yap |
| `nav_profile_guest_register_button` | Create Account | Ohlok Kont | Hesap Olustur |
| `nav_cart_badge_description` | %d items in cart | %d oggetti fil-kartella | Sepette %d urun |
| `common_back_button` | Back | Lura | Geri |

### 6.2 Android Strings

Add to `res/values/strings.xml`, `res/values-mt/strings.xml`, `res/values-tr/strings.xml`.

### 6.3 iOS Strings

Add to `Localizable.xcstrings` String Catalog for all three languages.

---

## 7. Error Scenarios

### 7.1 Invalid Deep Link

| Scenario | Behavior |
|----------|----------|
| URL scheme matches (`molt://`) but path is unrecognized | Ignore silently, show Home tab |
| URL has valid route but missing required parameter | Ignore silently, show Home tab |
| URL has valid route but parameter value is empty string | Ignore silently, show Home tab |

### 7.2 Auth-Required Deep Link When Guest

| Scenario | Behavior |
|----------|----------|
| `molt://order/123` received while user is logged out | Navigate to Login with `returnTo` = `OrderDetail(orderId: "123")` |
| User completes login | Navigate to `OrderDetail(orderId: "123")` |
| User cancels/dismisses login | Navigate to Home tab |

### 7.3 Navigation to Non-Existent Route

| Scenario | Behavior |
|----------|----------|
| Code attempts to navigate to a route not yet registered in NavHost | Show placeholder screen with route name (development aid) |
| Route exists but the feature screen is not yet implemented | Show placeholder screen: icon + "Coming soon" |

### 7.4 State Restoration

| Scenario | Behavior |
|----------|----------|
| App is killed by system while in background | Restore selected tab on relaunch, navigation stacks reset to root |
| Configuration change (rotation, dark mode toggle) | Full state preserved (handled by platform) |
| Process death and recreation | Selected tab restored, stacks reset to root |

---

## 8. Accessibility

### 8.1 Tab Bar

| Element | Android (`contentDescription`) | iOS (`accessibilityLabel`) |
|---------|-------------------------------|---------------------------|
| Tab item | Tab label text (e.g., "Home") | Tab label text (e.g., "Home") |
| Tab item (active) | "[Tab], selected" (automatic) | "[Tab], selected, tab" (automatic) |
| Cart badge | "Cart, %d items in cart" | "Cart, %d items in cart" |
| Cart badge (0 items) | "Cart" (no badge announced) | "Cart" (no badge announced) |

- **Android**: `MoltBottomBar` uses `NavigationBar` which provides automatic semantics. Badge count is added via `BadgedBox` with `contentDescription`.
- **iOS**: `MoltTabBar` uses `TabView` which provides automatic VoiceOver semantics. Badge is added via `.badge()` modifier.

### 8.2 Navigation

| Element | Android | iOS |
|---------|---------|-----|
| Back button | `contentDescription = stringResource(R.string.common_back_button)` | Automatic via `NavigationStack` |
| Screen title | Announced as heading via `Modifier.semantics { heading() }` | Automatic via `.navigationTitle()` |

### 8.3 General

- All tab icons have corresponding text labels (labels are always visible, not icon-only).
- Minimum touch target for tab items: 48dp (Android) / 44pt (iOS). Platform tab bar components meet this by default.
- Tab bar respects Dynamic Type (iOS) and font scaling (Android) for label text.

---

## 9. File Manifest

### 9.1 Android Files

Base path: `android/app/src/main/java/com/molt/marketplace/core/navigation/`

| # | File | Description |
|---|------|-------------|
| 1 | `Route.kt` | Sealed interface `Route` with all `@Serializable` route objects/data classes. Includes `requiresAuth` computed property. |
| 2 | `TopLevelDestination.kt` | Enum `TopLevelDestination` with `HOME`, `CATEGORIES`, `CART`, `PROFILE`. Each entry has `route`, `selectedIcon`, `unselectedIcon`, `labelResId`. |
| 3 | `MoltNavHost.kt` | `@Composable fun MoltNavHost(navController, modifier)` -- defines all `composable()` destinations with deep link registrations. Unimplemented screens show placeholder composable. |
| 4 | `MoltAppScaffold.kt` | `@Composable fun MoltAppScaffold()` -- top-level Scaffold with `MoltBottomBar` and `MoltNavHost`. Manages tab selection, back stack save/restore, bottom bar visibility, cart badge count. |
| 5 | `NavigationExtensions.kt` | Extension functions on `NavController`: `navigateToTopLevel(destination)`, `navigateToRoute(route)`, `navigateWithAuthCheck(route, authState)`. Helper for deep link parsing. |
| 6 | `DeepLinkParser.kt` | Object `DeepLinkParser` with `fun parse(uri: Uri): Route?` -- parses `molt://` and `https://molt.mt/` URIs into `Route` instances. Returns null for invalid links. |
| 7 | `PlaceholderScreen.kt` | `@Composable fun PlaceholderScreen(title: String, icon: ImageVector)` -- temporary placeholder for unimplemented screens. Shows icon + title + "Coming soon" text. |

**Modify existing**:

| # | File | Change |
|---|------|--------|
| 1 | `MainActivity.kt` | Replace placeholder `Box { Text(...) }` with `MoltAppScaffold()`. Add deep link intent handling in `onCreate` and `onNewIntent`. |
| 2 | `AndroidManifest.xml` | Add `<intent-filter>` for `molt://` scheme and `https://molt.mt` host on `MainActivity`. Add `android:launchMode="singleTask"` to `MainActivity`. |

**String resources to add** (all three language files):

| # | File | Keys Added |
|---|------|-----------|
| 1 | `res/values/strings.xml` | `nav_tab_home`, `nav_tab_categories`, `nav_tab_cart`, `nav_tab_profile`, `nav_placeholder_coming_soon`, `nav_profile_guest_title`, `nav_profile_guest_login_button`, `nav_profile_guest_register_button`, `nav_cart_badge_description`, `common_back_button` |
| 2 | `res/values-mt/strings.xml` | Same keys, Maltese translations |
| 3 | `res/values-tr/strings.xml` | Same keys, Turkish translations |

**Test files**:

Base path: `android/app/src/test/java/com/molt/marketplace/core/navigation/`

| # | File | Description |
|---|------|-------------|
| 1 | `DeepLinkParserTest.kt` | Tests for all deep link patterns: valid routes, invalid URIs, missing params, auth-required deep links. |
| 2 | `RouteAuthTest.kt` | Tests that `requiresAuth` returns correct value for every route. |
| 3 | `TopLevelDestinationTest.kt` | Tests that all destinations have valid icons, labels, and routes. |

### 9.2 iOS Files

Base path: `ios/MoltMarketplace/Core/Navigation/`

| # | File | Description |
|---|------|-------------|
| 1 | `Tab.swift` | Enum `Tab: String, CaseIterable, Identifiable` with `home`, `categories`, `cart`, `profile`. Properties: `title`, `systemImage`, `selectedSystemImage`. |
| 2 | `Route.swift` | Enum `Route: Hashable` with all screen destinations and associated values. Includes `requiresAuth: Bool` computed property. |
| 3 | `AppRouter.swift` | `@MainActor @Observable final class AppRouter` -- manages `selectedTab`, `NavigationPath` per tab, auth presentation, deep link handling. |
| 4 | `MainTabView.swift` | `struct MainTabView: View` -- root `TabView` with `NavigationStack` per tab. Uses `MoltTabBar` for tab bar rendering. Presents auth flows as `.fullScreenCover`. |
| 5 | `NavigationDestinationModifier.swift` | `ViewModifier` that registers `.navigationDestination(for: Route.self)` with a `@ViewBuilder` switch over all routes. Unimplemented routes show `PlaceholderView`. |
| 6 | `DeepLinkParser.swift` | `enum DeepLinkParser` with `static func parse(_ url: URL) -> Route?` -- parses `molt://` and `https://molt.mt/` URLs into `Route`. Returns nil for invalid links. |
| 7 | `PlaceholderView.swift` | `struct PlaceholderView: View` -- temporary placeholder for unimplemented screens. Shows SF Symbol icon + title + "Coming soon". |

**Modify existing**:

| # | File | Change |
|---|------|--------|
| 1 | `MoltMarketplaceApp.swift` | Replace `ContentView()` with `MainTabView()`. Remove `ContentView` struct. Inject `AppRouter` into environment. |
| 2 | `Info.plist` | Add `CFBundleURLTypes` entry for `molt` URL scheme. |

**String resources to add**:

| # | File | Keys Added |
|---|------|-----------|
| 1 | `Localizable.xcstrings` | `nav_tab_home`, `nav_tab_categories`, `nav_tab_cart`, `nav_tab_profile`, `nav_placeholder_coming_soon`, `nav_profile_guest_title`, `nav_profile_guest_login_button`, `nav_profile_guest_register_button`, `nav_cart_badge_description`, `common_back_button` (all three languages) |

**Test files**:

Base path: `ios/MoltMarketplaceTests/Core/Navigation/`

| # | File | Description |
|---|------|-------------|
| 1 | `DeepLinkParserTests.swift` | Tests for all deep link patterns: valid routes, invalid URLs, missing params, auth-required deep links. |
| 2 | `RouteTests.swift` | Tests that `requiresAuth` returns correct value for every route. |
| 3 | `AppRouterTests.swift` | Tests for tab switching, navigation, pop-to-root, auth presentation, deep link handling. |

---

## 10. Implementation Notes for Developers

### 10.1 For Android Developer

1. **Create `Route.kt` first** -- all routes as a sealed interface with `@Serializable` annotations. Use `kotlinx.serialization` for type-safe Compose Navigation. Each route must be a `data object` (no params) or `data class` (with params).

2. **Create `TopLevelDestination.kt`** -- enum with four entries. Each references a `Route` and icon pair.

3. **Create `DeepLinkParser.kt`** -- pure function, no dependencies. Easy to unit test.

4. **Create `PlaceholderScreen.kt`** -- simple composable used as a fallback. Uses `MoltEmptyView` pattern (icon + text).

5. **Create `MoltNavHost.kt`** -- single `NavHost` with nested navigation graphs per tab:
   ```
   NavHost(navController, startDestination = Route.Home) {
       // Home tab graph
       composable<Route.Home> { PlaceholderScreen("Home", Icons.Outlined.Home) }
       composable<Route.ProductDetail> { backStackEntry -> ... }
       // Categories tab graph
       composable<Route.Categories> { PlaceholderScreen("Categories", Icons.Outlined.Category) }
       // ... all routes
   }
   ```

6. **Create `MoltAppScaffold.kt`** -- wraps `Scaffold` + `MoltBottomBar` + `MoltNavHost`:
   - Use `navController.currentBackStackEntryAsState()` to determine selected tab.
   - Use `navController.navigate(destination.route) { popUpTo(...) { saveState = true }; restoreState = true; launchSingleTop = true }` for tab switching.
   - Conditionally show/hide bottom bar based on current route.
   - Pass cart badge count to `MoltBottomBar` (hardcoded to 0 until M2-01).

7. **Create `NavigationExtensions.kt`** -- keep `NavController` extensions clean and reusable.

8. **Modify `MainActivity.kt`** -- replace placeholder with `MoltAppScaffold()`. Handle deep link intents:
   ```kotlin
   override fun onNewIntent(intent: Intent) {
       super.onNewIntent(intent)
       navController.handleDeepLink(intent)
   }
   ```
   Set `android:launchMode="singleTask"` in manifest.

9. **Add strings** to all three language files.

10. **Write tests** for `DeepLinkParser`, `Route.requiresAuth`, and `TopLevelDestination`.

### 10.2 For iOS Developer

1. **Create `Tab.swift` first** -- simple enum. All computed properties are straightforward.

2. **Create `Route.swift`** -- enum with associated values. Must conform to `Hashable`. Include `requiresAuth` computed property.

3. **Create `DeepLinkParser.swift`** -- static methods, no dependencies. Easy to unit test.

4. **Create `PlaceholderView.swift`** -- simple SwiftUI view with icon + text.

5. **Create `AppRouter.swift`** -- `@Observable` class managing all navigation state:
   - Four `NavigationPath` properties (one per tab).
   - `selectedTab: Tab` property.
   - `navigate(to:)` method that checks `requiresAuth` before pushing.
   - `handleDeepLink(_:)` method that parses URL and navigates.
   - `presentLogin(returnTo:)` and `dismissAuth()` for auth flow.

6. **Create `NavigationDestinationModifier.swift`** -- `ViewModifier` that registers `navigationDestination(for: Route.self)`. Each tab's `NavigationStack` applies this modifier.

7. **Create `MainTabView.swift`** -- root view with `TabView`:
   ```swift
   TabView(selection: $router.selectedTab) {
       NavigationStack(path: $router.homePath) {
           PlaceholderView(title: "Home", systemImage: "house")
               .moltNavigationDestinations(router: router)
       }
       .tag(Tab.home)
       .tabItem { ... }
       // ... repeat for each tab
   }
   .fullScreenCover(item: $router.presentedAuth) { route in ... }
   ```

8. **Modify `MoltMarketplaceApp.swift`** -- replace `ContentView()` with `MainTabView()`. Create and inject `AppRouter` via `@State` or `@Environment`.

9. **Update `Info.plist`** -- add `CFBundleURLTypes` with `molt` scheme.

10. **Add strings** to `Localizable.xcstrings`.

11. **Write tests** for `DeepLinkParser`, `Route.requiresAuth`, and `AppRouter`.

### 10.3 Common Rules (Both Platforms)

- Follow `CLAUDE.md` exactly for naming conventions, file locations, architecture patterns.
- **Tab bar component** (`MoltBottomBar` / `MoltTabBar`) is from M0-02. If not yet implemented, create a minimal version in the navigation module that can be replaced later.
- **All user-facing strings** must be localized (use string resource keys, never hardcoded).
- **Placeholder screens** are temporary. They will be replaced feature-by-feature in M1+. Use the `PlaceholderScreen`/`PlaceholderView` composable/view for consistency.
- **Auth gating** is wired in M0-04 but non-functional until M0-06 provides the auth state. Use a stub/default that treats the user as logged out.
- **Cart badge** is wired in M0-04 but shows `0` (hidden) until M2-01 provides the cart count.
- **Deep link parsing** must be thoroughly unit tested since it handles external input.

---

## 11. Build Verification Criteria

The navigation feature is complete when:

### Android

- [ ] App launches and shows four-tab bottom bar with Home, Categories, Cart, Profile.
- [ ] Tapping each tab switches to that tab's placeholder content.
- [ ] Tapping the active tab has no visible effect (already at root).
- [ ] System back from non-Home tab root switches to Home tab.
- [ ] System back from Home tab root exits the app.
- [ ] `DeepLinkParserTest` passes: all valid patterns resolve, all invalid patterns return null.
- [ ] `RouteAuthTest` passes: all auth-required routes correctly identified.
- [ ] `./gradlew assembleDebug` succeeds without errors.
- [ ] No lint warnings from new files (ktlint + detekt pass).

### iOS

- [ ] App launches and shows four-tab bar with Home, Categories, Cart, Profile.
- [ ] Tapping each tab switches to that tab's placeholder content.
- [ ] Tapping the active tab has no visible effect (already at root).
- [ ] `DeepLinkParserTests` pass: all valid patterns resolve, all invalid patterns return nil.
- [ ] `RouteTests` pass: all auth-required routes correctly identified.
- [ ] `AppRouterTests` pass: tab switching, navigation, pop-to-root work correctly.
- [ ] `xcodebuild -scheme MoltMarketplace-Debug build` succeeds.
- [ ] No strict concurrency warnings from new files.
