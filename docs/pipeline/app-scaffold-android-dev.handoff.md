# M0-01 App Scaffold — Android Dev Handoff

## Summary

Android app scaffold has been successfully implemented with complete project structure, Gradle configuration, Hilt DI setup, design system theme shell, and base resource files.

## Artifacts Delivered

### Core Files (23 files)

1. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/build.gradle.kts` — Project-level Gradle with plugin aliases
2. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/settings.gradle.kts` — Module includes and version catalog reference
3. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/gradle.properties` — JVM args and Kotlin/Android config
4. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/gradle/libs.versions.toml` — Complete version catalog with all dependencies
5. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/gradle/wrapper/gradle-wrapper.properties` — Gradle 8.11.1 wrapper
6. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/build.gradle.kts` — App module with debug/staging/release build types
7. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/proguard-rules.pro` — R8/ProGuard rules for Retrofit + Kotlinx Serialization
8. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/AndroidManifest.xml` — Main manifest with MoltApplication and MainActivity
9. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/debug/AndroidManifest.xml` — Debug manifest with cleartext traffic
10. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/MoltApplication.kt` — @HiltAndroidApp entry point with Timber init
11. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/MainActivity.kt` — @AndroidEntryPoint with splash screen and MoltTheme
12. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltColors.kt` — Light/dark color scheme from design tokens
13. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltTypography.kt` — Typography from design tokens
14. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltSpacing.kt` — Spacing constants
15. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltTheme.kt` — @Composable theme wrapper
16. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/res/values/strings.xml` — English strings
17. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/res/values-mt/strings.xml` — Maltese strings
18. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/res/values-tr/strings.xml` — Turkish strings
19. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/res/values/colors.xml` — Color resources
20. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/res/values/themes.xml` — Splash + app themes
21. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/res/xml/network_security_config.xml` — Network security config
22. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/res/drawable/splash_logo.xml` — Placeholder splash logo vector
23. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/res/drawable/placeholder.xml` — Placeholder image vector
24. `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/res/drawable/ic_launcher_foreground.xml` — Launcher icon foreground

### Placeholder Directories (with .gitkeep)

- `android/app/src/main/java/com/molt/marketplace/core/common/`
- `android/app/src/main/java/com/molt/marketplace/core/designsystem/component/`
- `android/app/src/main/java/com/molt/marketplace/core/di/`
- `android/app/src/main/java/com/molt/marketplace/core/domain/error/`
- `android/app/src/main/java/com/molt/marketplace/core/network/`
- `android/app/src/main/java/com/molt/marketplace/feature/`
- `android/app/src/test/java/com/molt/marketplace/`
- `android/app/src/androidTest/java/com/molt/marketplace/`
- `android/app/src/staging/`
- `android/app/src/release/`

## Build Variants

Three build types configured:

| Build Type | Base URL | Debuggable | Minify | App ID Suffix |
|-----------|----------|------------|--------|---------------|
| debug | https://api-dev.molt.mt | true | false | .debug |
| staging | https://api-staging.molt.mt | true | false | .staging |
| release | https://api.molt.mt | false | true (R8) | none |

## Design System Theme

All theme files follow design tokens from `shared/design-tokens/`:

- **MoltColors.kt**: 67 color constants (light + dark theme + semantic colors)
- **MoltTypography.kt**: 15 text styles (displayLarge → labelSmall)
- **MoltSpacing.kt**: 9 base spacing values + 7 layout constants
- **MoltTheme.kt**: @Composable wrapper applying colorScheme + typography

## Localization

Base string resources created for 3 languages:

- **English** (`values/strings.xml`) — 12 common strings
- **Maltese** (`values-mt/strings.xml`) — 12 common strings
- **Turkish** (`values-tr/strings.xml`) — 12 common strings

## Architecture Setup

- **Package structure**: `core/` (designsystem, network, di, domain, common) + `feature/`
- **Hilt DI**: @HiltAndroidApp on MoltApplication, @AndroidEntryPoint on MainActivity
- **Timber logging**: Initialized in debug builds only
- **Splash screen**: Android 12+ API with placeholder logo
- **Edge-to-edge**: Enabled in MainActivity
- **Network security**: HTTPS enforced, cleartext allowed for debug builds

## Key Dependencies (from Version Catalog)

| Category | Library | Version |
|----------|---------|---------|
| Kotlin | kotlin-android | 2.1.10 |
| Compose BOM | compose-bom | 2026.01.01 |
| Hilt | hilt-android | 2.55 |
| Retrofit | retrofit | 3.0.0 |
| OkHttp | okhttp | 5.0.0-alpha.14 |
| Coil | coil-compose | 3.1.0 |
| Navigation | navigation-compose | 2.8.9 |
| Room | room-runtime | 2.7.1 |
| Timber | timber | 5.0.1 |
| Firebase BOM | firebase-bom | 33.8.0 |

## Placeholder Screen

MainActivity shows centered "Molt Marketplace" text using `MaterialTheme.typography.headlineSmall` wrapped in `MoltTheme`. This will be replaced by navigation + tab bar in M0-04.

## Verification Checklist

- [x] All 23 core files created
- [x] All placeholder directories created with .gitkeep
- [x] Version catalog includes all required dependencies
- [x] Build types configured: debug, staging, release
- [x] MoltApplication with @HiltAndroidApp annotation
- [x] MainActivity with splash screen and edge-to-edge
- [x] Design system theme files (MoltColors, MoltTypography, MoltSpacing, MoltTheme)
- [x] String resources for 3 languages (en, mt, tr)
- [x] Network security config
- [x] Placeholder drawables (splash_logo, placeholder, ic_launcher_foreground)
- [x] Gradle wrapper configured (8.11.1)

## Known Limitations

- No Gradle wrapper JAR files included (will be generated on first build)
- No mipmap launcher icons (placeholder only in drawable/)
- No Firebase configuration files (google-services.json added in M0-06)
- No actual Molt logo (placeholder vector drawable used)

## Next Steps for Downstream Teammates

### Android Tester (M0-01 Testing)

1. Verify Gradle sync succeeds
2. Verify `./gradlew assembleDebug` builds successfully
3. Verify `./gradlew assembleStaging` builds successfully
4. Verify app launches on emulator and shows splash → placeholder screen
5. Verify `BuildConfig.API_BASE_URL` returns correct URL per build type
6. Verify Hilt DI initializes without crash

### Design System Components (M0-02)

1. Add Molt* components to `core/designsystem/component/`:
   - MoltButton.kt
   - MoltCard.kt
   - MoltTextField.kt
   - MoltTopBar.kt
   - MoltBottomBar.kt
   - MoltLoadingView.kt
   - MoltErrorView.kt
   - MoltEmptyView.kt
   - MoltImage.kt
   - MoltBadge.kt

## Agent Notes

All implementation follows CLAUDE.md standards:
- Explicit return types on all public functions
- No `!!` force non-null operators
- No `Any` type in domain/presentation layers
- Immutable data classes (none in scaffold, but enforced for future)
- Material 3 theming via MoltTheme wrapper
- No hardcoded strings (all via stringResource())
- Kotlin 2.1.10, Compose BOM 2026.01.01
- minSdk 26, targetSdk 35, compileSdk 35

---

**Delivered by**: android-dev
**Date**: 2026-02-11
**Commit**: Ready for commit
