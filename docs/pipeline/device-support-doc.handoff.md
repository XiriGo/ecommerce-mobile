# Handoff: device-support — doc-writer

**Date**: 2026-02-20
**Agent**: doc-writer
**Feature**: device-support (platform infrastructure guide)

## Artifacts Produced

### 1. Guide Document

**File**: `docs/guides/device-support.md`

A new `docs/guides/` directory was created for platform infrastructure guides (distinct from `docs/features/` which holds feature READMEs and `docs/adr/` which holds architecture decision records).

The guide covers 9 topics in full:

| Section | Android Config | iOS Config |
|---------|---------------|------------|
| Phone-First | Rationale only | Rationale only |
| Portrait Lock | `android:screenOrientation="portrait"` in `AndroidManifest.xml` | `UISupportedInterfaceOrientations` in `Info.plist` |
| Screen Size Adaptation | `WindowWidthSizeClass` (Compact/Medium/Expanded) | `horizontalSizeClass` (.compact/.regular) |
| Safe Area / Notch | `enableEdgeToEdge()` + `Modifier.windowInsetsPadding()` | SwiftUI automatic + `.safeAreaInset()` |
| Dynamic Type | `sp` units via `XGTypography`, test at 200% | `.dynamicTypeSize`, Accessibility Inspector |
| Dark Mode | `isSystemInDarkTheme()` in `XGTheme` | `@Environment(\.colorScheme)` in `XGThemeModifier` |
| Status/Nav Bar | `enableEdgeToEdge()`, `SystemBarStyle` for overrides | `.preferredColorScheme()`, `.toolbarBackground(.hidden)` |
| Min Screen Size | 320dp, no hardcoded widths | 375pt (iPhone SE 3rd gen) |
| Touch Targets | `XGSpacing.MinTouchTarget` = 48dp | `XGSpacing.minTouchTarget` = 44pt |

### 2. CHANGELOG Entry

Added under `[Unreleased] > Added > Infrastructure Guides`:

```
- **device-support**: Platform infrastructure guide covering phone-first approach,
  portrait-only orientation lock, screen size adaptation (WindowWidthSizeClass /
  horizontalSizeClass), safe area handling, Dynamic Type, dark mode, status bar,
  minimum screen sizes, and accessibility touch targets (Android + iOS)
```

## Source Files Verified

All code snippets in the guide were validated against actual source files:

- `android/app/src/main/AndroidManifest.xml` — orientation attribute location confirmed (not yet set; guide documents the required configuration)
- `android/app/src/main/java/com/xirigo/ecommerce/MainActivity.kt` — `enableEdgeToEdge()` call confirmed at line 23
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGTheme.kt` — `isSystemInDarkTheme()` and color scheme switching confirmed
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/theme/XGSpacing.kt` — `MinTouchTarget = 48.dp` confirmed at line 24
- `ios/XiriGoEcommerce/Resources/Info.plist` — orientation key location confirmed (key not yet set; guide documents the required configuration)
- `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGTheme.swift` — `@Environment(\.colorScheme)` usage confirmed
- `ios/XiriGoEcommerce/Core/DesignSystem/Theme/XGSpacing.swift` — `minTouchTarget = 44` confirmed at line 23

### Notes on Current Manifest State

The `android:screenOrientation="portrait"` attribute and `UISupportedInterfaceOrientations` plist key are documented as required configuration but are NOT yet present in the actual files (as of the time this guide was written). These should be applied when the navigation scaffold (M0-04) is implemented.

## Commit

`docs(device-support): add device-support guide [agent:doc]`
