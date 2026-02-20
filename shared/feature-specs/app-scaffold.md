# M0-01: App Scaffold — Feature Specification

## Overview

The App Scaffold is the foundational project structure for the Molt Marketplace buyer app.
It establishes the project skeleton, build system, dependency management, environment
configuration, entry points, and placeholder directories for all future features.
No business logic is implemented here; this is purely structural.

### User Stories

- As a **developer**, I want a well-organized project structure so that I can add features consistently.
- As a **developer**, I want environment-specific configuration so that I can target dev, staging, and production servers.
- As a **developer**, I want DI initialized at app startup so that dependencies are available throughout the app.
- As a **buyer**, I want to see a splash screen with the app logo when the app launches.

### Scope

| In Scope | Out of Scope |
|----------|-------------|
| Project file structure (packages, modules) | Network layer implementation (M0-03) |
| Gradle KTS + version catalog (Android) | Navigation / tab bar (M0-04) |
| SPM + Xcode project (iOS) | DI module registrations beyond base (M0-05) |
| Application / App entry point | Auth infrastructure (M0-06) |
| Environment config (dev/staging/prod) | Design system components (M0-02) |
| Splash screen (static logo) | Any feature screens |
| Base resource files (strings, assets) | |
| Placeholder directories for core + features | |
| Design system theme shell (MoltTheme, MoltColors, MoltSpacing, MoltTypography) | |

### Dependencies on Other Features

None. This is the first feature. All other features depend on this.

### Features That Depend on This

All features: M0-02 through M4-05.

---

## 1. Android Project Structure

### 1.1 Gradle Project Layout

```
android/
  build.gradle.kts                    # Project-level (plugins, repositories)
  settings.gradle.kts                 # Module includes, version catalog
  gradle.properties                   # JVM args, Kotlin config
  gradle/
    libs.versions.toml                # Version catalog
    wrapper/
      gradle-wrapper.properties
  app/
    build.gradle.kts                  # App-level (android block, dependencies)
    proguard-rules.pro                # R8/ProGuard rules
    src/
      main/
        AndroidManifest.xml
        java/com/molt/marketplace/
          MoltApplication.kt          # @HiltAndroidApp entry point
          MainActivity.kt             # @AndroidEntryPoint, single-activity
          core/
            common/
              .gitkeep
            designsystem/
              theme/
                MoltColors.kt         # Color constants from design tokens
                MoltTypography.kt     # Typography from design tokens
                MoltSpacing.kt        # Spacing constants
                MoltTheme.kt          # @Composable theme wrapper
              component/
                .gitkeep              # Components added in M0-02
            di/
              .gitkeep
            domain/
              error/
                .gitkeep
            network/
              .gitkeep
          feature/
            .gitkeep                  # Features added starting M1
        res/
          values/
            strings.xml               # English (default)
            colors.xml                # Color resources (referencing theme)
            themes.xml                # App theme (splash)
          values-mt/
            strings.xml               # Maltese
          values-tr/
            strings.xml               # Turkish
          drawable/
            ic_launcher_foreground.xml # App icon foreground (placeholder)
            splash_logo.xml           # Splash screen logo (placeholder vector)
            placeholder.xml           # Image placeholder
          mipmap-*/
            ic_launcher.webp          # Adaptive icon (placeholder)
            ic_launcher_round.webp
          xml/
            network_security_config.xml
      debug/
        AndroidManifest.xml           # Debug-specific manifest (cleartext traffic for dev)
      staging/
        .gitkeep                      # Staging build type placeholder
      release/
        .gitkeep                      # Release build type placeholder
      test/
        java/com/molt/marketplace/
          .gitkeep                    # Unit tests
      androidTest/
        java/com/molt/marketplace/
          .gitkeep                    # Instrumented tests
```

### 1.2 Version Catalog (`gradle/libs.versions.toml`)

```toml
[versions]
agp = "8.8.0"
kotlin = "2.1.10"
ksp = "2.1.10-1.0.31"
composeBom = "2026.01.01"
hilt = "2.55"
hiltNavigationCompose = "1.2.0"
retrofit = "3.0.0"
okhttp = "5.0.0-alpha.14"
kotlinxSerialization = "1.8.0"
coil = "3.1.0"
navigationCompose = "2.8.9"
lifecycle = "2.8.7"
coroutines = "1.10.1"
paging = "3.4.0"
datastore = "1.1.4"
tink = "1.16.0"
room = "2.7.1"
timber = "5.0.1"
firebaseBom = "33.8.0"
biometric = "1.4.0-alpha02"
coreKtx = "1.16.0"
activityCompose = "1.10.1"
splashscreen = "1.0.1"
junit = "4.13.2"
truth = "1.4.4"
mockk = "1.13.16"
turbine = "1.2.0"
composeUiTest = "1.7.8"
leakcanary = "2.14"
chucker = "4.0.0"
ktlint = "12.1.2"
detekt = "1.23.8"

[libraries]
# Compose BOM
compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "composeBom" }
compose-ui = { group = "androidx.compose.ui", name = "ui" }
compose-ui-graphics = { group = "androidx.compose.ui", name = "ui-graphics" }
compose-ui-tooling-preview = { group = "androidx.compose.ui", name = "ui-tooling-preview" }
compose-ui-tooling = { group = "androidx.compose.ui", name = "ui-tooling" }
compose-material3 = { group = "androidx.compose.material3", name = "material3" }
compose-material-icons-extended = { group = "androidx.compose.material", name = "material-icons-extended" }

# Core
core-ktx = { group = "androidx.core", name = "core-ktx", version.ref = "coreKtx" }
activity-compose = { group = "androidx.activity", name = "activity-compose", version.ref = "activityCompose" }
splashscreen = { group = "androidx.core", name = "core-splashscreen", version.ref = "splashscreen" }

# Lifecycle
lifecycle-runtime-compose = { group = "androidx.lifecycle", name = "lifecycle-runtime-compose", version.ref = "lifecycle" }
lifecycle-viewmodel-compose = { group = "androidx.lifecycle", name = "lifecycle-viewmodel-compose", version.ref = "lifecycle" }

# Navigation
navigation-compose = { group = "androidx.navigation", name = "navigation-compose", version.ref = "navigationCompose" }

# Hilt
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
hilt-compiler = { group = "com.google.dagger", name = "hilt-android-compiler", version.ref = "hilt" }
hilt-navigation-compose = { group = "androidx.hilt", name = "hilt-navigation-compose", version.ref = "hiltNavigationCompose" }

# Network
retrofit = { group = "com.squareup.retrofit2", name = "retrofit", version.ref = "retrofit" }
retrofit-kotlinx-serialization = { group = "com.squareup.retrofit2", name = "converter-kotlinx-serialization", version.ref = "retrofit" }
okhttp = { group = "com.squareup.okhttp3", name = "okhttp", version.ref = "okhttp" }
okhttp-logging = { group = "com.squareup.okhttp3", name = "logging-interceptor", version.ref = "okhttp" }
kotlinx-serialization-json = { group = "org.jetbrains.kotlinx", name = "kotlinx-serialization-json", version.ref = "kotlinxSerialization" }

# Image
coil-compose = { group = "io.coil-kt.coil3", name = "coil-compose", version.ref = "coil" }
coil-network-okhttp = { group = "io.coil-kt.coil3", name = "coil-network-okhttp", version.ref = "coil" }

# Async
coroutines-core = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-core", version.ref = "coroutines" }
coroutines-android = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-android", version.ref = "coroutines" }

# Pagination
paging-runtime = { group = "androidx.paging", name = "paging-runtime", version.ref = "paging" }
paging-compose = { group = "androidx.paging", name = "paging-compose", version.ref = "paging" }

# Storage
datastore = { group = "androidx.datastore", name = "datastore", version.ref = "datastore" }
datastore-preferences = { group = "androidx.datastore", name = "datastore-preferences", version.ref = "datastore" }
tink = { group = "com.google.crypto.tink", name = "tink-android", version.ref = "tink" }
room-runtime = { group = "androidx.room", name = "room-runtime", version.ref = "room" }
room-ktx = { group = "androidx.room", name = "room-ktx", version.ref = "room" }
room-compiler = { group = "androidx.room", name = "room-compiler", version.ref = "room" }

# Logging
timber = { group = "com.jakewharton.timber", name = "timber", version.ref = "timber" }

# Firebase
firebase-bom = { group = "com.google.firebase", name = "firebase-bom", version.ref = "firebaseBom" }
firebase-analytics = { group = "com.google.firebase", name = "firebase-analytics-ktx" }
firebase-crashlytics = { group = "com.google.firebase", name = "firebase-crashlytics-ktx" }
firebase-messaging = { group = "com.google.firebase", name = "firebase-messaging-ktx" }
firebase-config = { group = "com.google.firebase", name = "firebase-config-ktx" }

# Biometric
biometric = { group = "androidx.biometric", name = "biometric", version.ref = "biometric" }

# Testing
junit = { group = "junit", name = "junit", version.ref = "junit" }
truth = { group = "com.google.truth", name = "truth", version.ref = "truth" }
mockk = { group = "io.mockk", name = "mockk", version.ref = "mockk" }
turbine = { group = "app.cash.turbine", name = "turbine", version.ref = "turbine" }
coroutines-test = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-test", version.ref = "coroutines" }
compose-ui-test-junit4 = { group = "androidx.compose.ui", name = "ui-test-junit4" }
compose-ui-test-manifest = { group = "androidx.compose.ui", name = "ui-test-manifest" }

# Debug
leakcanary = { group = "com.squareup.leakcanary", name = "leakcanary-android", version.ref = "leakcanary" }
chucker = { group = "com.github.chuckerteam.chucker", name = "library", version.ref = "chucker" }
chucker-noop = { group = "com.github.chuckerteam.chucker", name = "library-no-op", version.ref = "chucker" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
kotlin-compose = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
kotlin-serialization = { id = "org.jetbrains.kotlin.plugin.serialization", version.ref = "kotlin" }
ksp = { id = "com.google.devtools.ksp", version.ref = "ksp" }
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
firebase-crashlytics = { id = "com.google.firebase.crashlytics", version = "3.0.3" }
gms = { id = "com.google.gms.google-services", version = "4.4.2" }
ktlint = { id = "org.jlleitschuh.gradle.ktlint", version.ref = "ktlint" }
detekt = { id = "io.gitlab.arturbosch.detekt", version.ref = "detekt" }
```

### 1.3 Build Variants

Three build types with distinct configurations:

| Build Type | `API_BASE_URL` | Debuggable | Minify | Signing |
|-----------|----------------|------------|--------|---------|
| `debug` | `https://api-dev.molt.mt` | true | false | debug keystore |
| `staging` | `https://api-staging.molt.mt` | true | false | release keystore |
| `release` | `https://api.molt.mt` | false | true (R8) | release keystore |

**`app/build.gradle.kts`** key configuration:

```kotlin
android {
    namespace = "com.molt.marketplace"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.molt.marketplace"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        debug {
            isDebuggable = true
            isMinifyEnabled = false
            buildConfigField("String", "API_BASE_URL", "\"https://api-dev.molt.mt\"")
            applicationIdSuffix = ".debug"
        }
        create("staging") {
            isDebuggable = true
            isMinifyEnabled = false
            buildConfigField("String", "API_BASE_URL", "\"https://api-staging.molt.mt\"")
            applicationIdSuffix = ".staging"
            signingConfig = signingConfigs.getByName("debug") // staging uses release keystore in CI
        }
        release {
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            buildConfigField("String", "API_BASE_URL", "\"https://api.molt.mt\"")
        }
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}
```

### 1.4 Entry Point: `MoltApplication.kt`

```
Package: com.molt.marketplace
Annotation: @HiltAndroidApp
Extends: Application()

Responsibilities:
  - Initialize Hilt (automatic via annotation)
  - Initialize Timber (debug builds only: Timber.plant(DebugTree()))
  - No other initialization in M0-01 (Firebase, crash reporting added later)
```

### 1.5 Entry Point: `MainActivity.kt`

```
Package: com.molt.marketplace
Annotation: @AndroidEntryPoint
Extends: ComponentActivity()

Responsibilities:
  - Install splash screen (installSplashScreen())
  - Enable edge-to-edge display (enableEdgeToEdge())
  - Set content with MoltTheme { ... }
  - In M0-01: show a placeholder "Molt Marketplace" text centered on screen
  - Navigation host added in M0-04
```

### 1.6 Splash Screen (Android 12+ API)

```xml
<!-- res/values/themes.xml -->
<style name="Theme.MoltMarketplace.Splash" parent="Theme.SplashScreen">
    <item name="windowSplashScreenBackground">@color/splash_background</item>
    <item name="windowSplashScreenAnimatedIcon">@drawable/splash_logo</item>
    <item name="postSplashScreenTheme">@style/Theme.MoltMarketplace</item>
</style>
```

- Splash background color: `#FFFBFE` (surface light)
- Logo: placeholder vector drawable (simple "M" or Molt text)
- Duration: system default (no artificial delay)

### 1.7 Base String Resources

**`res/values/strings.xml`** (English -- default):
```xml
<resources>
    <string name="app_name">Molt Marketplace</string>
    <string name="common_loading_message">Loading...</string>
    <string name="common_retry_button">Retry</string>
    <string name="common_error_network">Connection error. Please check your internet.</string>
    <string name="common_error_server">Something went wrong. Please try again later.</string>
    <string name="common_error_unauthorized">Please log in to continue.</string>
    <string name="common_error_not_found">The requested item was not found.</string>
    <string name="common_error_unknown">An unexpected error occurred.</string>
    <string name="common_ok_button">OK</string>
    <string name="common_cancel_button">Cancel</string>
    <string name="common_close_button">Close</string>
    <string name="common_search_placeholder">Search</string>
</resources>
```

**`res/values-mt/strings.xml`** (Maltese):
```xml
<resources>
    <string name="app_name">Molt Marketplace</string>
    <string name="common_loading_message">Qed jillowdja...</string>
    <string name="common_retry_button">Erga' ipprova</string>
    <string name="common_error_network">Problema fil-konnessjoni. Iccekja l-internet tieghek.</string>
    <string name="common_error_server">Xi haga marret hazin. Erga' ipprova aktar tard.</string>
    <string name="common_error_unauthorized">Jekk joghgbok idhlol biex tkompli.</string>
    <string name="common_error_not_found">L-oggett mitlub ma nstabx.</string>
    <string name="common_error_unknown">Sehhet problema mhux mistennija.</string>
    <string name="common_ok_button">OK</string>
    <string name="common_cancel_button">Ikkanella</string>
    <string name="common_close_button">Aghlaq</string>
    <string name="common_search_placeholder">Fittex</string>
</resources>
```

**`res/values-tr/strings.xml`** (Turkish):
```xml
<resources>
    <string name="app_name">Molt Marketplace</string>
    <string name="common_loading_message">Yukleniyor...</string>
    <string name="common_retry_button">Tekrar Dene</string>
    <string name="common_error_network">Baglanti hatasi. Lutfen internetinizi kontrol edin.</string>
    <string name="common_error_server">Bir seyler ters gitti. Lutfen daha sonra tekrar deneyin.</string>
    <string name="common_error_unauthorized">Devam etmek icin lutfen giris yapin.</string>
    <string name="common_error_not_found">Aranan oge bulunamadi.</string>
    <string name="common_error_unknown">Beklenmedik bir hata olustu.</string>
    <string name="common_ok_button">Tamam</string>
    <string name="common_cancel_button">Iptal</string>
    <string name="common_close_button">Kapat</string>
    <string name="common_search_placeholder">Ara</string>
</resources>
```

### 1.8 Network Security Config

**`res/xml/network_security_config.xml`**:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    <!-- Debug: allow cleartext for local dev server -->
    <debug-overrides>
        <trust-anchors>
            <certificates src="user" />
        </trust-anchors>
    </debug-overrides>
</network-security-config>
```

---

## 2. iOS Project Structure

### 2.1 File Layout

```
ios/
  MoltMarketplace.xcodeproj/
    project.pbxproj
    xcshareddata/
      xcschemes/
        MoltMarketplace-Debug.xcscheme
        MoltMarketplace-Staging.xcscheme
        MoltMarketplace-Release.xcscheme
  MoltMarketplace/
    MoltMarketplaceApp.swift          # @main SwiftUI App entry point
    Config.swift                       # Environment configuration
    Core/
      Common/
        .gitkeep
      DesignSystem/
        Theme/
          MoltColors.swift             # Color constants from design tokens
          MoltTypography.swift         # Font styles from design tokens
          MoltSpacing.swift            # Spacing constants
          MoltTheme.swift              # ViewModifier theme wrapper
        Component/
          .gitkeep                     # Components added in M0-02
      DI/
        Container+Extensions.swift     # Factory container registrations
      Domain/
        Error/
          .gitkeep
      Network/
        .gitkeep
    Feature/
      .gitkeep                         # Features added starting M1
    Resources/
      Assets.xcassets/
        AccentColor.colorset/          # Brand accent color
        AppIcon.appiconset/            # App icon (placeholder)
        SplashLogo.imageset/           # Splash screen logo
        Placeholder.imageset/          # Image placeholder
      Localizable.xcstrings            # String Catalog (en, mt, tr)
      Info.plist                        # App configuration
    Configuration/
      Debug.xcconfig                   # Dev environment
      Staging.xcconfig                 # Staging environment
      Release.xcconfig                 # Production environment
  MoltMarketplaceTests/
    .gitkeep
  MoltMarketplaceUITests/
    .gitkeep
  Package.swift                        # SPM dependencies (if using package-based approach)
```

### 2.2 SPM Dependencies

Declared in Xcode project (or `Package.swift` for modular approach):

```swift
// Package.swift (dependencies section)
dependencies: [
    // DI
    .package(url: "https://github.com/hmlongco/Factory", from: "2.4.0"),
    // Image Loading
    .package(url: "https://github.com/kean/Nuke", from: "12.8.0"),
    // Keychain
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
    // Firebase
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.7.0"),
    // Testing
    .package(url: "https://github.com/nicklockwood/ViewInspector", from: "0.10.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0"),
]
```

### 2.3 Environment Configuration

Three xcconfig files:

**`Configuration/Debug.xcconfig`**:
```
API_BASE_URL = https:/$()/api-dev.molt.mt
BUNDLE_ID_SUFFIX = .debug
PRODUCT_BUNDLE_IDENTIFIER = com.molt.marketplace$(BUNDLE_ID_SUFFIX)
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG
```

**`Configuration/Staging.xcconfig`**:
```
API_BASE_URL = https:/$()/api-staging.molt.mt
BUNDLE_ID_SUFFIX = .staging
PRODUCT_BUNDLE_IDENTIFIER = com.molt.marketplace$(BUNDLE_ID_SUFFIX)
SWIFT_ACTIVE_COMPILATION_CONDITIONS = STAGING
```

**`Configuration/Release.xcconfig`**:
```
API_BASE_URL = https:/$()/api.molt.mt
BUNDLE_ID_SUFFIX =
PRODUCT_BUNDLE_IDENTIFIER = com.molt.marketplace
SWIFT_ACTIVE_COMPILATION_CONDITIONS = RELEASE
```

**`Config.swift`** reads from Info.plist (which inherits from xcconfig):
```
Struct: Config
Properties:
  - static let apiBaseURL: URL  — reads "API_BASE_URL" from Info.plist
  - static let bundleVersion: String
  - static let buildNumber: String
```

### 2.4 Entry Point: `MoltMarketplaceApp.swift`

```
Struct: MoltMarketplaceApp
Conforms to: App
Annotation: @main

Body:
  WindowGroup {
      ContentView()  // Placeholder — replaced with navigation in M0-04
  }

Responsibilities:
  - Configure Factory DI container (if needed)
  - In M0-01: show placeholder "Molt Marketplace" text centered
```

### 2.5 Splash Screen (iOS)

iOS uses a launch storyboard or Info.plist configuration.

**`Info.plist`** key entries:
```
UILaunchScreen:
  BackgroundColor: splashBackground (asset catalog named color)
  ImageName: SplashLogo
  ImageRespectsSafeAreaInsets: true
```

- Background color: `#FFFBFE` (surface light) registered in Assets.xcassets
- Logo: placeholder image in `SplashLogo.imageset`
- No artificial delay

### 2.6 Base Localization (String Catalog)

**`Localizable.xcstrings`** contains all three languages. Initial keys:

| Key | English (en) | Maltese (mt) | Turkish (tr) |
|-----|------|---------|---------|
| `app_name` | Molt Marketplace | Molt Marketplace | Molt Marketplace |
| `common_loading_message` | Loading... | Qed jillowdja... | Yukleniyor... |
| `common_retry_button` | Retry | Erga' ipprova | Tekrar Dene |
| `common_error_network` | Connection error. Please check your internet. | Problema fil-konnessjoni. Iccekja l-internet tieghek. | Baglanti hatasi. Lutfen internetinizi kontrol edin. |
| `common_error_server` | Something went wrong. Please try again later. | Xi haga marret hazin. Erga' ipprova aktar tard. | Bir seyler ters gitti. Lutfen daha sonra tekrar deneyin. |
| `common_error_unauthorized` | Please log in to continue. | Jekk joghgbok idhlol biex tkompli. | Devam etmek icin lutfen giris yapin. |
| `common_error_not_found` | The requested item was not found. | L-oggett mitlub ma nstabx. | Aranan oge bulunamadi. |
| `common_error_unknown` | An unexpected error occurred. | Sehhet problema mhux mistennija. | Beklenmedik bir hata olustu. |
| `common_ok_button` | OK | OK | Tamam |
| `common_cancel_button` | Cancel | Ikkanella | Iptal |
| `common_close_button` | Close | Aghlaq | Kapat |
| `common_search_placeholder` | Search | Fittex | Ara |

### 2.7 Xcode Project Settings

| Setting | Value |
|---------|-------|
| Deployment Target | iOS 17.0 |
| Swift Language Version | 6.2 |
| Supported Orientations (iPhone) | Portrait only |
| Supported Orientations (iPad) | All |
| Build Active Architecture Only (Debug) | Yes |
| Enable Bitcode | No (deprecated) |
| Strict Concurrency Checking | Complete |

---

## 3. Design System Theme Shell

The scaffold includes the theme shell files. These provide the token values that all
future `Molt*` components will reference. The actual components are added in M0-02.

### 3.1 Color Tokens

Source: `shared/design-tokens/colors.json`

Both platforms must define the following colors from design tokens:

**Light Theme Colors:**

| Token | Hex |
|-------|-----|
| `primary` | `#6750A4` |
| `onPrimary` | `#FFFFFF` |
| `primaryContainer` | `#EADDFF` |
| `onPrimaryContainer` | `#21005D` |
| `secondary` | `#625B71` |
| `onSecondary` | `#FFFFFF` |
| `secondaryContainer` | `#E8DEF8` |
| `onSecondaryContainer` | `#1D192B` |
| `tertiary` | `#7D5260` |
| `onTertiary` | `#FFFFFF` |
| `tertiaryContainer` | `#FFD8E4` |
| `onTertiaryContainer` | `#31111D` |
| `error` | `#B3261E` |
| `onError` | `#FFFFFF` |
| `errorContainer` | `#F9DEDC` |
| `onErrorContainer` | `#410E0B` |
| `surface` | `#FFFBFE` |
| `onSurface` | `#1C1B1F` |
| `surfaceVariant` | `#E7E0EC` |
| `onSurfaceVariant` | `#49454F` |
| `outline` | `#79747E` |
| `outlineVariant` | `#CAC4D0` |
| `background` | `#FFFBFE` |
| `onBackground` | `#1C1B1F` |
| `inverseSurface` | `#313033` |
| `inverseOnSurface` | `#F4EFF4` |
| `inversePrimary` | `#D0BCFF` |
| `scrim` | `#000000` |

**Dark Theme Colors:**

| Token | Hex |
|-------|-----|
| `primary` | `#D0BCFF` |
| `onPrimary` | `#381E72` |
| `primaryContainer` | `#4F378B` |
| `onPrimaryContainer` | `#EADDFF` |
| `secondary` | `#CCC2DC` |
| `onSecondary` | `#332D41` |
| `secondaryContainer` | `#4A4458` |
| `onSecondaryContainer` | `#E8DEF8` |
| `tertiary` | `#EFB8C8` |
| `onTertiary` | `#492532` |
| `tertiaryContainer` | `#633B48` |
| `onTertiaryContainer` | `#FFD8E4` |
| `error` | `#F2B8B5` |
| `onError` | `#601410` |
| `errorContainer` | `#8C1D18` |
| `onErrorContainer` | `#F9DEDC` |
| `surface` | `#1C1B1F` |
| `onSurface` | `#E6E1E5` |
| `surfaceVariant` | `#49454F` |
| `onSurfaceVariant` | `#CAC4D0` |
| `outline` | `#938F99` |
| `outlineVariant` | `#49454F` |
| `background` | `#1C1B1F` |
| `onBackground` | `#E6E1E5` |
| `inverseSurface` | `#E6E1E5` |
| `inverseOnSurface` | `#313033` |
| `inversePrimary` | `#6750A4` |
| `scrim` | `#000000` |

**Semantic Colors** (shared across light/dark):

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#4CAF50` | Success states |
| `onSuccess` | `#FFFFFF` | Text on success |
| `warning` | `#FF9800` | Warning states |
| `priceRegular` | `#1C1B1F` | Regular price text |
| `priceSale` | `#B3261E` | Sale price text |
| `priceOriginal` | `#79747E` | Strikethrough original price |
| `ratingStarFilled` | `#FFC107` | Filled star |
| `ratingStarEmpty` | `#E0E0E0` | Empty star |
| `badgeBackground` | `#B3261E` | Badge background |
| `badgeText` | `#FFFFFF` | Badge text |
| `divider` | `#CAC4D0` | Divider lines |
| `shimmer` | `#E7E0EC` | Loading shimmer |

### 3.2 Spacing Tokens

Source: `shared/design-tokens/spacing.json`

| Token | Value (dp/pt) | Usage |
|-------|---------------|-------|
| `xxs` | 2 | Minimal gaps |
| `xs` | 4 | Tight spacing |
| `sm` | 8 | Small spacing, list item gaps |
| `md` | 12 | Medium spacing, card padding |
| `base` | 16 | Base padding, standard gaps |
| `lg` | 24 | Section spacing |
| `xl` | 32 | Large gaps |
| `xxl` | 48 | Extra large gaps |
| `xxxl` | 64 | Maximum spacing |

**Layout Constants:**

| Token | Value | Usage |
|-------|-------|-------|
| `screenPaddingHorizontal` | 16 | Screen horizontal padding |
| `screenPaddingVertical` | 16 | Screen vertical padding |
| `cardPadding` | 12 | Card internal padding |
| `listItemSpacing` | 8 | Spacing between list items |
| `sectionSpacing` | 24 | Spacing between sections |
| `productGridSpacing` | 8 | Product grid gap |
| `productGridColumns` | 2 | Default grid columns |
| `minTouchTarget` | 48 (Android) / 44 (iOS) | Min tap target |

### 3.3 Typography Tokens

Source: `shared/design-tokens/typography.json`

| Style | Size (sp/pt) | Line Height | Weight | Letter Spacing |
|-------|-------------|-------------|--------|---------------|
| `displayLarge` | 57 | 64 | 400 | -0.25 |
| `displayMedium` | 45 | 52 | 400 | 0 |
| `displaySmall` | 36 | 44 | 400 | 0 |
| `headlineLarge` | 32 | 40 | 400 | 0 |
| `headlineMedium` | 28 | 36 | 400 | 0 |
| `headlineSmall` | 24 | 32 | 400 | 0 |
| `titleLarge` | 22 | 28 | 400 | 0 |
| `titleMedium` | 16 | 24 | 500 | 0.15 |
| `titleSmall` | 14 | 20 | 500 | 0.1 |
| `bodyLarge` | 16 | 24 | 400 | 0.5 |
| `bodyMedium` | 14 | 20 | 400 | 0.25 |
| `bodySmall` | 12 | 16 | 400 | 0.4 |
| `labelLarge` | 14 | 20 | 500 | 0.1 |
| `labelMedium` | 12 | 16 | 500 | 0.5 |
| `labelSmall` | 11 | 16 | 500 | 0.5 |

Font families:
- Android: System default (Roboto)
- iOS: SF Pro (system default)

### 3.4 Corner Radius Tokens

| Token | Value (dp/pt) |
|-------|---------------|
| `none` | 0 |
| `small` | 4 |
| `medium` | 8 |
| `large` | 12 |
| `extraLarge` | 16 |
| `full` | 999 (pill shape) |

### 3.5 MoltTheme Implementation Notes

**Android** (`MoltTheme.kt`):
- `@Composable fun MoltTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit)`
- Builds `lightColorScheme(...)` and `darkColorScheme(...)` from `MoltColors`
- Sets `MaterialTheme(colorScheme, typography = MoltTypography, content = content)`
- Provides `CompositionLocalProvider` for any custom locals

**iOS** (`MoltTheme.swift`):
- ViewModifier that applies color scheme overrides
- Provides environment values for custom spacing, colors
- Used via `.moltTheme()` modifier or wrapping in `MoltThemeView { content }`

---

## 4. API Configuration (No Endpoints in M0-01)

No API calls in the scaffold. The base URL is configured per environment for
future use by the network layer (M0-03).

### Environment URLs

| Environment | Base URL |
|-------------|----------|
| Development | `https://api-dev.molt.mt` |
| Staging | `https://api-staging.molt.mt` |
| Production | `https://api.molt.mt` |

---

## 5. UI Wireframe

### 5.1 Splash Screen (Both Platforms)

```
+----------------------------------+
|                                  |
|                                  |
|                                  |
|           [Molt Logo]            |
|                                  |
|           MOLT                   |
|         MARKETPLACE              |
|                                  |
|                                  |
|                                  |
+----------------------------------+

Background: surface (#FFFBFE)
Logo: placeholder vector/image
Duration: system default (no artificial delay)
```

### 5.2 Placeholder Screen (After Splash)

```
+----------------------------------+
|                                  |
|                                  |
|                                  |
|                                  |
|       Molt Marketplace           |  <-- headlineSmall, centered
|                                  |
|                                  |
|                                  |
|                                  |
+----------------------------------+
```

This placeholder is replaced by the Home screen + Tab Bar in M0-04.

---

## 6. Navigation Flow

No navigation in M0-01. Single screen only.

```
App Launch → Splash Screen → Placeholder Screen
```

Navigation infrastructure (tab bar, navigation stacks, routes) added in M0-04.

---

## 7. State Management

No stateful screens in M0-01. The placeholder screen has no states.

---

## 8. Error Scenarios

No error scenarios in M0-01. Base error string resources are created for future use.

---

## 9. Accessibility

### Splash Screen
- Logo has content description: "Molt Marketplace logo"
- No interactive elements

### Placeholder Screen
- Text uses semantic heading role
- Respects Dynamic Type (iOS) / font scale (Android)

---

## 10. File Manifest

### 10.1 Android Files

| # | File Path | Description |
|---|----------|-------------|
| 1 | `android/build.gradle.kts` | Project-level Gradle (plugins block) |
| 2 | `android/settings.gradle.kts` | Module includes, plugin management, version catalog |
| 3 | `android/gradle.properties` | JVM args, Kotlin/Android config flags |
| 4 | `android/gradle/libs.versions.toml` | Version catalog (all dependencies) |
| 5 | `android/app/build.gradle.kts` | App module: SDK versions, build types, dependencies |
| 6 | `android/app/proguard-rules.pro` | R8 ProGuard rules (empty scaffold) |
| 7 | `android/app/src/main/AndroidManifest.xml` | Manifest with application, activity, network config |
| 8 | `android/app/src/main/java/com/molt/marketplace/MoltApplication.kt` | `@HiltAndroidApp` entry point |
| 9 | `android/app/src/main/java/com/molt/marketplace/MainActivity.kt` | `@AndroidEntryPoint` single activity |
| 10 | `android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltColors.kt` | Color constants |
| 11 | `android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltTypography.kt` | Typography |
| 12 | `android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltSpacing.kt` | Spacing constants |
| 13 | `android/app/src/main/java/com/molt/marketplace/core/designsystem/theme/MoltTheme.kt` | Theme composable |
| 14 | `android/app/src/main/res/values/strings.xml` | English strings |
| 15 | `android/app/src/main/res/values/colors.xml` | Color resources |
| 16 | `android/app/src/main/res/values/themes.xml` | Splash theme + app theme |
| 17 | `android/app/src/main/res/values-mt/strings.xml` | Maltese strings |
| 18 | `android/app/src/main/res/values-tr/strings.xml` | Turkish strings |
| 19 | `android/app/src/main/res/drawable/splash_logo.xml` | Splash logo vector |
| 20 | `android/app/src/main/res/drawable/placeholder.xml` | Image placeholder |
| 21 | `android/app/src/main/res/xml/network_security_config.xml` | Network security |
| 22 | `android/app/src/debug/AndroidManifest.xml` | Debug manifest overrides |
| 23 | `android/app/src/main/res/drawable/ic_launcher_foreground.xml` | Adaptive icon foreground |

**Placeholder directories** (with `.gitkeep`):
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

### 10.2 iOS Files

| # | File Path | Description |
|---|----------|-------------|
| 1 | `ios/MoltMarketplace/MoltMarketplaceApp.swift` | `@main` SwiftUI App entry point |
| 2 | `ios/MoltMarketplace/Config.swift` | Environment configuration reader |
| 3 | `ios/MoltMarketplace/Core/DesignSystem/Theme/MoltColors.swift` | Color constants |
| 4 | `ios/MoltMarketplace/Core/DesignSystem/Theme/MoltTypography.swift` | Typography styles |
| 5 | `ios/MoltMarketplace/Core/DesignSystem/Theme/MoltSpacing.swift` | Spacing constants |
| 6 | `ios/MoltMarketplace/Core/DesignSystem/Theme/MoltTheme.swift` | Theme ViewModifier |
| 7 | `ios/MoltMarketplace/Core/DI/Container+Extensions.swift` | Factory DI registrations |
| 8 | `ios/MoltMarketplace/Resources/Localizable.xcstrings` | String Catalog (en, mt, tr) |
| 9 | `ios/MoltMarketplace/Resources/Assets.xcassets/` | Asset catalog (colors, icons, images) |
| 10 | `ios/MoltMarketplace/Resources/Info.plist` | App configuration (launch screen, URLs) |
| 11 | `ios/MoltMarketplace/Configuration/Debug.xcconfig` | Dev environment config |
| 12 | `ios/MoltMarketplace/Configuration/Staging.xcconfig` | Staging environment config |
| 13 | `ios/MoltMarketplace/Configuration/Release.xcconfig` | Production environment config |

**Placeholder directories** (with `.gitkeep`):
- `ios/MoltMarketplace/Core/Common/`
- `ios/MoltMarketplace/Core/DesignSystem/Component/`
- `ios/MoltMarketplace/Core/Domain/Error/`
- `ios/MoltMarketplace/Core/Network/`
- `ios/MoltMarketplace/Feature/`
- `ios/MoltMarketplaceTests/`
- `ios/MoltMarketplaceUITests/`

### 10.3 Xcode Project

The Xcode project file (`ios/MoltMarketplace.xcodeproj`) must be created with:
- Three build configurations: Debug, Staging, Release
- Each configuration linked to its `.xcconfig` file
- SPM dependencies added as described in section 2.2
- Target deployment: iOS 17.0
- Strict Concurrency Checking: Complete
- Swift Language Version: 6.2

---

## 11. Build Verification Criteria

The scaffold is complete when:

### Android
- [ ] `./gradlew assembleDebug` succeeds without errors
- [ ] `./gradlew assembleStaging` succeeds without errors
- [ ] `./gradlew assembleRelease` succeeds (unsigned is OK for scaffold)
- [ ] App launches on emulator, shows splash then placeholder screen
- [ ] `BuildConfig.API_BASE_URL` returns correct URL per build type
- [ ] All three string resource files parse without errors
- [ ] Hilt DI initializes without crash

### iOS
- [ ] `xcodebuild -scheme MoltMarketplace-Debug build` succeeds
- [ ] App launches in simulator, shows splash then placeholder screen
- [ ] `Config.apiBaseURL` returns correct URL per configuration
- [ ] String Catalog loads all three languages
- [ ] Factory container initializes without crash
- [ ] No strict concurrency warnings

---

## 12. Implementation Notes for Developers

### For Android Developer

1. Start with `settings.gradle.kts` + `libs.versions.toml` -- establish all versions first
2. Create `build.gradle.kts` (project) with plugin aliases
3. Create `app/build.gradle.kts` with full dependency list and build types
4. Create `MoltApplication.kt` with `@HiltAndroidApp` and Timber init
5. Create `MainActivity.kt` with splash screen install and `MoltTheme` wrapper
6. Create design system theme files (`MoltColors`, `MoltTypography`, `MoltSpacing`, `MoltTheme`)
7. Create all resource files (strings, themes, drawables)
8. Create placeholder directories with `.gitkeep`
9. Verify: `./gradlew assembleDebug` passes

### For iOS Developer

1. Create Xcode project with SPM dependencies
2. Create xcconfig files for three environments
3. Create `Config.swift` to read environment from Info.plist
4. Create `MoltMarketplaceApp.swift` entry point
5. Create design system theme files (`MoltColors`, `MoltTypography`, `MoltSpacing`, `MoltTheme`)
6. Create `Container+Extensions.swift` for Factory DI
7. Create String Catalog with all base keys in three languages
8. Create asset catalog with placeholder icon and splash logo
9. Create placeholder directories with `.gitkeep`
10. Verify: scheme builds and app launches in simulator

### Common Rules (Both Platforms)

- Follow CLAUDE.md exactly for naming conventions, file locations, architecture layers
- Use design token values from `shared/design-tokens/*.json` -- do not invent colors/spacing
- English is the development language; provide Maltese and Turkish translations for base strings
- No business logic, no network calls, no navigation -- just the shell
- The placeholder screen text "Molt Marketplace" should use the `headlineSmall` typography token
- All colors must come from `MoltColors`, all spacing from `MoltSpacing`
