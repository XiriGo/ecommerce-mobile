# Handoff: navigation -- Doc Writer

## Feature
**M0-04: Navigation** -- Type-safe routing, bottom navigation bar, deep linking, and auth-gated navigation

## Agent
doc-writer

## Date
2026-02-21

## Status
COMPLETE

---

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Feature README | `docs/features/navigation.md` |
| CHANGELOG entry | `CHANGELOG.md` under `[Unreleased] → ### Added → #### M0-04: Navigation` |
| This Handoff | `docs/pipeline/navigation-doc.handoff.md` |

---

## Source Files Read

| File | Purpose |
|------|---------|
| `shared/feature-specs/navigation.md` | Architect spec: route table, data models, UI wireframes, navigation flows, file manifest |
| `docs/pipeline/navigation-architect.handoff.md` | Key decisions, scope summary |
| `docs/pipeline/navigation-android-dev.handoff.md` | Files created, naming decisions (`isAuthRequired` vs `requiresAuth`), build verification, test counts |
| `docs/pipeline/navigation-ios-dev.handoff.md` | Files created (8 iOS files), key design decisions (opacity tab switching, `Route.login(returnTo: String?)`), build verification |
| `docs/pipeline/navigation-android-test.handoff.md` | Android test file names, types, test counts (~138 total) |
| `docs/pipeline/navigation-ios-test.handoff.md` | iOS test file names, coverage areas, test counts (~167 total) |
| `docs/features/design-system.md` | Pattern reference for feature README structure |
| `CHANGELOG.md` | Existing changelog format for entry placement |

---

## Documentation Summary

### Feature README (`docs/features/navigation.md`)

Covers:
- **Overview**: What the feature provides, dependency table
- **Architecture**: Route definitions (both platforms with code samples), tab definitions table, navigation state management (`XGAppScaffold` / `AppRouter`), deep linking (URI pattern table, platform implementations), auth-gated navigation flow diagram
- **Navigation Flows**: Tab back-stack behavior, per-tab stack structures, tab bar visibility rules
- **Localization**: 10 new string keys in all three languages
- **File Structure**: Complete file manifest for both Android and iOS with descriptions of each file, modified files table
- **Testing**: Per-platform test breakdown (dev tests + tester tests), combined summary table, test paths and run commands
- **Integration Points**: What each future feature needs to change

### CHANGELOG Entry

Placed under `## [Unreleased] → ### Added → #### M0-04: Navigation` (above M0-03: Network Layer, consistent with milestone-descending order).

Bullets cover: tab bar, per-tab stacks, route definitions, auth property, auth-gated navigation, deep linking, AndroidManifest/Info.plist declarations, cart badge wiring, auth stub, placeholder screens, tab bar hiding rules, localization, and test counts.

---

## Key Documentation Decisions

1. **Named `isAuthRequired` (Android) instead of `requiresAuth` (spec)**: Android dev changed the name for detekt `BooleanPropertyNaming` compliance. The feature README and CHANGELOG use `isAuthRequired` / `requiresAuth` side-by-side to reflect the actual code in each platform.

2. **iOS uses opacity-based tab switching (not native TabView)**: Documented as architecture note because this is a meaningful departure from the spec's `TabView` approach. Reason: preserves all four `NavigationStack` states simultaneously without SwiftUI TabView's native tab bar interference.

3. **`Route.login(returnTo: String?)` not `Route?`**: Documented rationale (avoids recursive Hashable conformance). Impacts how `returnTo` is passed between platforms — Android serializes to String, iOS uses in-memory `String?` on `AppRouter.presentedAuth`.

4. **8 iOS files (not 7 from spec)**: iOS dev added `RouteView.swift` (Route → View mapping) as a separate file beyond the 7 in the spec. Documented accurately from the dev handoff.

5. **Test counts reflect actual handoff numbers**: Android ~138 (dev: 45 + tester: ~93); iOS ~167 (all from tester). Total ~305.

---

## Notes for Reviewer

- `core/navigation/` is a new package on Android — verify it is not placed under `feature/` by mistake
- iOS `AppRouter` uses `@Observable` (not `ObservableObject`) — requires iOS 17+, which matches the scaffold's minimum deployment target
- Auth stub behaviour means `AppRouterTests` must be revisited when M0-06 wires real auth state
- `Robolectric` was added as a test dependency for `DeepLinkParser` (needs `android.net.Uri`); reviewer should confirm the version (`4.14.1`) is compatible with `compileSdk 35`
- `RouteView.swift` was added by iOS dev but not in the original spec file manifest; reviewer should confirm it is in the Xcode project target

---

## Commit

```
docs(navigation): add navigation documentation [agent:doc] [platform:both]
```

Files staged:
- `docs/features/navigation.md`
- `docs/pipeline/navigation-doc.handoff.md`
- `CHANGELOG.md`
