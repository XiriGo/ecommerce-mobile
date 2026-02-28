# Handoff: navigation -- Architect

## Feature
**M0-04: Navigation** -- Tab bar navigation, type-safe routing, deep linking, and auth-gated navigation for the XiriGo Ecommerce buyer app.

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature Spec | `shared/feature-specs/navigation.md` |
| This Handoff | `docs/pipeline/navigation-architect.handoff.md` |

## Summary of Spec

The navigation spec defines the complete routing and tab-based navigation infrastructure for both Android and iOS platforms:

### Core Structure
- **Four-tab bottom bar**: Home, Categories, Cart, Profile with filled/outlined icon states
- **Independent navigation stack per tab**: Each tab preserves its back stack when switching
- **Type-safe routes**: 29 route definitions covering all screens from M0 through M4
- **Deep linking**: `xirigo://` custom scheme and `https://xirigo.com/` universal links
- **Auth-gated navigation**: Routes marked as `requiresAuth` redirect guests to Login with `returnTo` parameter

### Android
- `Route` sealed interface with `@Serializable` annotations for type-safe Compose Navigation (Navigation 2.8+)
- `TopLevelDestination` enum with icon pairs, label resource IDs, and root routes
- `XGAppScaffold` composable managing Scaffold + XGBottomBar + XGNavHost
- Tab switching via `popUpTo` with `saveState`/`restoreState` for back stack preservation
- Deep links declared in AndroidManifest.xml with `singleTask` launch mode
- `DeepLinkParser` object for parsing URIs into Route instances
- 7 new files in `core/navigation/`, modifications to `MainActivity.kt` and `AndroidManifest.xml`

### iOS
- `Route` enum conforming to `Hashable` with associated values for parameters
- `Tab` enum conforming to `CaseIterable, Identifiable` with SF Symbol names
- `AppRouter` `@Observable` class managing `NavigationPath` per tab, auth presentation, deep links
- `MainTabView` with `TabView` + `NavigationStack` per tab + `.fullScreenCover` for auth
- `NavigationDestinationModifier` for registering all route destinations
- URL scheme declared in Info.plist `CFBundleURLTypes`
- 7 new files in `Core/Navigation/`, modifications to `XiriGoEcommerceApp.swift` and `Info.plist`

### Shared
- 10 new localization keys in English, Maltese, and Turkish
- Placeholder screens for all unimplemented routes (replaced feature-by-feature in M1+)
- Auth gating wired but non-functional until M0-06 provides auth state (uses stub)
- Cart badge wired but hidden until M2-01 provides cart item count (defaults to 0)

## Key Decisions

1. **Single NavHost vs. nested NavGraphs (Android)**: Single NavHost with `saveState`/`restoreState` on tab switches. Simpler than four separate NavHosts while achieving the same per-tab back stack behavior.
2. **Four NavigationPaths (iOS)**: One `NavigationPath` per tab in `AppRouter`. Clean separation, each tab owns its own stack.
3. **Route.requiresAuth computed property**: Auth requirement encoded directly on the route enum/sealed interface, not in a separate lookup table. Keeps route and access control co-located.
4. **returnTo as serialized String (Android) / optional Route (iOS)**: Android serializes the return route as a string parameter (navigation args must be primitive). iOS can pass the Route enum directly since it uses in-memory `AppRouter`.
5. **Placeholder screens**: All unimplemented routes show a temporary placeholder view. This allows the navigation infrastructure to be fully wired without depending on feature screen implementations.
6. **Tab bar hiding for checkout/auth flows**: Fullscreen presentation for Login/Register/ForgotPassword/Onboarding. Checkout sub-screens hide tab bar for focused flow.
7. **Deep link parser as pure function**: Stateless, no dependencies, easy to unit test exhaustively.
8. **Partial auth on Profile tab**: Tab is always accessible. Shows login prompt when guest, profile content when authenticated.

## Downstream Dependencies

| Downstream Agent | What They Need From This |
|-----------------|--------------------------|
| Android Dev | File manifest (section 9.1), route definitions (section 2.2), Android implementation notes (section 10.1), verification criteria (section 11) |
| iOS Dev | File manifest (section 9.2), route definitions (section 2.2), iOS implementation notes (section 10.2), verification criteria (section 11) |

## Verification

Downstream developers should verify their navigation implementation using the criteria in spec section 11.

## Notes for Next Features

- **M0-05 (DI Setup)**: No navigation-specific DI needed. `AppRouter` (iOS) can be registered in Factory container.
- **M0-06 (Auth Infrastructure)**: Replace the auth state stub with real `AuthState` observation. Wire `navigateWithAuthCheck` to use actual auth state.
- **M1-01 (Login Screen)**: Replace `PlaceholderScreen` for `Route.Login` in NavHost/NavigationDestination. Handle `returnTo` parameter on login success.
- **M1-04 (Home Screen)**: Replace `PlaceholderScreen` for `Route.Home` in NavHost/NavigationDestination.
- **M2-01 (Cart)**: Provide `cartItemCount` flow/stream to update cart badge on tab bar.
- **All M1+ features**: Each feature replaces its placeholder with the real screen implementation in the NavHost (Android) / NavigationDestination switch (iOS).
