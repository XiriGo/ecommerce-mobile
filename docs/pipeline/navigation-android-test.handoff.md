# Handoff: navigation -- Android Tester

## Feature
**M0-04: Navigation** -- Type-safe routing, bottom navigation, deep linking

## Status
COMPLETE

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Route Serialization Tests | `android/app/src/test/java/com/molt/marketplace/core/navigation/RouteSerializationTest.kt` |
| DeepLink Edge Case Tests | `android/app/src/test/java/com/molt/marketplace/core/navigation/DeepLinkParserEdgeCasesTest.kt` |
| AppScaffold UI Tests | `android/app/src/androidTest/java/com/molt/marketplace/core/navigation/MoltAppScaffoldTest.kt` |
| PlaceholderScreen UI Tests | `android/app/src/androidTest/java/com/molt/marketplace/core/navigation/PlaceholderScreenTest.kt` |
| This Handoff | `docs/pipeline/navigation-android-test.handoff.md` |

## Test Summary

### New Tests Added (4 files, 89 tests)

| File | Type | Tests | What is Covered |
|------|------|-------|-----------------|
| `RouteSerializationTest.kt` | Unit (JUnit 4) | 44 | All 20 data-object routes and 14 data-class routes serialize/deserialize via `@Serializable`; JSON structure verification; data-class equality contract; singleton identity for data objects |
| `DeepLinkParserEdgeCasesTest.kt` | Unit (Robolectric) | 30 | URL-encoded blank IDs, missing host, null scheme, http scheme accepted, wrong host/subdomain, unsupported schemes (ftp/file/market), missing required params for all routes, extra path segments ignored, query params ignored, auth flag propagation, ID/name extraction from parsed routes |
| `MoltAppScaffoldTest.kt` | Compose UI | 9 | All 4 tab labels displayed, Home selected by default, tab switching to Categories/Cart/Profile, return to Home, cart badge hidden at zero, bottom bar visible on Home/Categories routes, placeholder content rendered per tab |
| `PlaceholderScreenTest.kt` | Compose UI | 10 | Title rendered for 5 distinct routes (Home, Categories, Cart, Profile, Product Detail), "Coming soon" subtitle always present, title + subtitle coexist, different titles produce distinct text nodes |

### Pre-existing Tests from Developer (3 files, 45 tests)

| File | Tests | What is Covered |
|------|-------|-----------------|
| `DeepLinkParserTest.kt` | 15 | Happy paths for all deep link patterns; unknown routes; missing IDs; wrong host; unsupported scheme; empty URI |
| `RouteAuthTest.kt` | 19 | `isAuthRequired` for every Route variant — all public and auth-protected routes |
| `TopLevelDestinationTest.kt` | 11 | Four destinations exist; correct routes/labels/icons per entry; distinct selected/unselected icons; correct order |

### Total Navigation Unit Tests: 134 (45 pre-existing + 89 new)

## Coverage Analysis

| Area | Before | After |
|------|--------|-------|
| `DeepLinkParser.kt` | Happy paths only | Edge cases: blank IDs, extra segments, query params, http scheme, wrong host, all scheme variants |
| `Route.kt` | Auth flag only | Serialization round-trip for every variant; JSON structure; equality contract |
| `TopLevelDestination.kt` | Basic properties | Fully covered by pre-existing tests |
| `MoltAppScaffold.kt` | 0% | Tab rendering, selection, switching, badge, bottom bar visibility |
| `PlaceholderScreen.kt` | 0% | Title rendering, subtitle rendering, coexistence |

## Lint / Quality

- ktlint: passes (BUILD SUCCESSFUL)
- detekt: new files introduce no new violations (pre-existing VariableMinLength failures in AppErrorEdgeCasesTest.kt are not from this agent)
- All unit tests: BUILD SUCCESSFUL (134 navigation tests, all pass)

## For Reviewer

Key test patterns to verify:
- `RouteSerializationTest` uses concrete serializers (e.g., `encodeToString<Route.ProductDetail>`) not the polymorphic parent, matching how Compose Navigation 2.8+ serializes back-stack entries.
- `DeepLinkParserEdgeCasesTest` uses `@RunWith(RobolectricTestRunner::class)` because `Uri.parse()` requires Android SDK.
- `MoltAppScaffoldTest` and `PlaceholderScreenTest` are in `src/androidTest/` (instrumented) using `createComposeRule`.

## Next Agent: Doc Writer

The navigation feature implementation and tests are complete. The doc writer can now produce the feature documentation from:
- `shared/feature-specs/navigation.md` (spec)
- `docs/pipeline/navigation-android-dev.handoff.md` (Android dev artifacts)
- `docs/pipeline/navigation-ios-dev.handoff.md` (iOS dev artifacts)
- This file (Android test artifacts)
- `docs/pipeline/navigation-ios-test.handoff.md` (iOS test artifacts)

## Commit

```
test(navigation): add navigation tests [agent:android-test] [platform:android]
```
