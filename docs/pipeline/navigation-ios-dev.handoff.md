# Navigation iOS Dev Handoff

## Feature: M0-04 Navigation (iOS)
## Agent: ios-dev
## Status: Complete

---

## Files Created

### Core/Navigation/ (8 files)

| File | Description |
|------|-------------|
| `ios/XiriGoEcommerce/Core/Navigation/Tab.swift` | `Tab` enum (home, categories, cart, profile) with SF Symbol icons and localized titles |
| `ios/XiriGoEcommerce/Core/Navigation/Route.swift` | `Route` enum with all M0-M4 screen destinations, `requiresAuth` computed property |
| `ios/XiriGoEcommerce/Core/Navigation/AppRouter.swift` | `@MainActor @Observable` router managing per-tab NavigationPaths, tab selection, auth presentation, deep linking |
| `ios/XiriGoEcommerce/Core/Navigation/MainTabView.swift` | Root TabView with 4 independent NavigationStacks, XGTabBar integration, fullscreen auth cover, onOpenURL handling |
| `ios/XiriGoEcommerce/Core/Navigation/NavigationDestinationModifier.swift` | ViewModifier registering `.navigationDestination(for: Route.self)` |
| `ios/XiriGoEcommerce/Core/Navigation/RouteView.swift` | Maps Route to View (all placeholders until M1+) |
| `ios/XiriGoEcommerce/Core/Navigation/DeepLinkParser.swift` | Parses `xirigo://` and `https://xirigo.com/` URLs into Route values |
| `ios/XiriGoEcommerce/Core/Navigation/PlaceholderView.swift` | Temporary placeholder with icon, title, and "Coming soon" text |

### Modified Files

| File | Change |
|------|--------|
| `ios/XiriGoEcommerce/XiriGoEcommerceApp.swift` | Replaced ContentView with MainTabView as root |
| `ios/XiriGoEcommerce/Resources/Info.plist` | Added CFBundleURLTypes for `xirigo` URL scheme |
| `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` | Added nav_tab_*, nav_placeholder_*, nav_profile_*, nav_cart_*, common_back_button strings (en, mt, tr) |
| `ios/XiriGoEcommerce.xcodeproj/project.pbxproj` | Added Navigation group and all 8 source files to project |

---

## Architecture

- **Tab management**: `Tab` enum (CaseIterable, Identifiable) defines 4 tabs
- **Route definitions**: `Route` enum with associated values for all M0-M4 screens, `Hashable` conformance for NavigationPath
- **Router**: `AppRouter` (@Observable, @MainActor) manages 4 NavigationPaths, selectedTab, presentedAuth, cartBadgeCount
- **Tab layout**: ZStack with opacity-based tab switching (preserves all tab states) + XGTabBar overlay
- **Navigation destination**: Single ViewModifier applied to each tab's root, maps Route -> RouteView
- **Deep linking**: `DeepLinkParser` static methods parse xirigo:// and https://xirigo.com/ URLs
- **Auth gating**: `Route.requiresAuth` computed property, AppRouter redirects to login for auth-required routes

## Key Design Decisions

1. **Opacity-based tab switching** instead of SwiftUI TabView: Preserves all 4 NavigationStack states simultaneously without SwiftUI TabView's native tab bar
2. **Route.login(returnTo: String?)** instead of `Route?`: Avoids recursive Hashable conformance issue (Route containing Route)
3. **Auth stub**: All auth-required routes currently redirect to login placeholder. M0-06 will provide actual auth state
4. **Cart badge**: Wired to `AppRouter.cartBadgeCount` (defaults to 0). M2-01 will update it

## Build Verification

- [x] `xcodebuild -scheme XiriGoEcommerce build` succeeds
- [x] Zero warnings from new files
- [x] Zero strict concurrency issues
- [x] App launches with 4-tab layout
- [x] Tab switching works with state preservation
- [x] Deep link URL scheme registered in Info.plist
- [x] All strings localized (en, mt, tr)

## Test Coverage Needed

Tests to be written by iOS Tester:
- `DeepLinkParserTests.swift` - Valid/invalid URL parsing
- `RouteTests.swift` - requiresAuth correctness for all routes
- `AppRouterTests.swift` - Tab switching, navigation, pop-to-root, auth presentation, deep link handling

---

## Handoff Timestamp
2026-02-21
