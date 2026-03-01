# Firebase Setup Guide

**Scope**: XiriGo Ecommerce Mobile Buyer App — Android + iOS
**Last Updated**: 2026-02-20

This guide covers the complete Firebase setup for the XiriGo Ecommerce mobile buyer app. Firebase is used for Analytics, Crashlytics, Cloud Messaging (FCM/APNs), and Remote Config on both platforms.

---

## 1. Firebase Project Setup

### Create the Firebase Project

1. Open the [Firebase Console](https://console.firebase.google.com/) and sign in with the XiriGo Google account.
2. Click **Add project**.
3. Enter the project name. Use the naming pattern `xirigo-ecommerce-<env>`:
   - `xirigo-ecommerce-dev` — development
   - `xirigo-ecommerce-staging` — staging
   - `xirigo-ecommerce-prod` — production
4. Enable Google Analytics when prompted (required for Crashlytics breadcrumbs and A/B testing).
5. Select an existing Google Analytics account or create a new one named `XiriGo Ecommerce`.
6. Click **Create project**.

### Environment Strategy

The project uses three build variants — debug, staging, and release — each with a different application ID suffix. Use **separate Firebase projects per environment** (one project per tier, not one project with multiple environments).

| Firebase Project | Android App ID | iOS Bundle ID | Build Variant |
|-----------------|----------------|---------------|---------------|
| `xirigo-ecommerce-dev` | `com.xirigo.ecommerce.debug` | `com.xirigo.ecommerce.debug` | debug |
| `xirigo-ecommerce-staging` | `com.xirigo.ecommerce.staging` | `com.xirigo.ecommerce.staging` | staging |
| `xirigo-ecommerce-prod` | `com.xirigo.ecommerce` | `com.xirigo.ecommerce` | release |

Separate projects ensure analytics data, crash reports, and Remote Config values are fully isolated between environments.

### Register the Android App

Within each Firebase project:

1. Click **Add app** and choose the Android icon.
2. Enter the **Android package name** for the environment:
   - Dev: `com.xirigo.ecommerce.debug`
   - Staging: `com.xirigo.ecommerce.staging`
   - Prod: `com.xirigo.ecommerce`
3. Enter the **App nickname** (e.g., `XiriGo Ecommerce Android Dev`).
4. Enter the **Debug signing certificate SHA-1**. Obtain it by running:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA-1 from the `debug` variant output.
5. Click **Register app**.
6. Download `google-services.json`. Do not place it yet — see Section 2.
7. Skip the Gradle setup steps shown in the console — they are already configured (see Section 3).

### Register the iOS App

Within each Firebase project:

1. Click **Add app** and choose the iOS icon.
2. Enter the **iOS bundle ID** for the environment:
   - Dev: `com.xirigo.ecommerce.debug`
   - Staging: `com.xirigo.ecommerce.staging`
   - Prod: `com.xirigo.ecommerce`
3. Enter the **App nickname** (e.g., `XiriGo Ecommerce iOS Dev`).
4. Leave the **App Store ID** blank until the app is published.
5. Click **Register app**.
6. Download `GoogleService-Info.plist`. Do not place it yet — see Section 2.
7. Skip the SDK setup steps shown in the console — they are already configured (see Section 4).

---

## 2. Configuration Files

### File Placement

| File | Platform | Placement Path |
|------|----------|---------------|
| `google-services.json` | Android | `android/app/google-services.json` |
| `GoogleService-Info.plist` | iOS | `ios/XiriGoEcommerce/Resources/GoogleService-Info.plist` |

For multi-environment builds, place environment-specific files at build time — see Section 9 for the CI/CD strategy.

### Add to .gitignore

These files contain API keys and project identifiers. They must never be committed to version control. Add the following entries to the root `.gitignore`:

```
# Firebase configuration files (never commit)
android/app/google-services.json
ios/XiriGoEcommerce/Resources/GoogleService-Info.plist
```

Each developer and CI/CD runner must obtain these files from a secure source (see Section 9).

### Verify File Content

After placing the files, verify each contains the correct project/bundle IDs.

**google-services.json** — check `package_name` inside `client`:
```json
{
  "client": [
    {
      "client_info": {
        "android_client_info": {
          "package_name": "com.xirigo.ecommerce.debug"
        }
      }
    }
  ]
}
```

**GoogleService-Info.plist** — check `BUNDLE_ID`:
```xml
<key>BUNDLE_ID</key>
<string>com.xirigo.ecommerce.debug</string>
```

---

## 3. Android Initialization

### How Auto-Initialization Works

The `google-services` Gradle plugin reads `google-services.json` at build time and generates a `google-services.xml` resource file. Firebase SDKs use a `ContentProvider` registered in the merged manifest to call `FirebaseApp.initializeApp()` before `Application.onCreate()`. No manual initialization code is needed.

### Gradle Configuration

The plugins are already declared in the project. Verify they appear as shown:

**`android/build.gradle.kts`** (project-level):
```kotlin
plugins {
    alias(libs.plugins.firebase.crashlytics) apply false
    alias(libs.plugins.gms) apply false
}
```

**`android/app/build.gradle.kts`** (app-level) — add the plugins at the top of the `plugins` block:
```kotlin
plugins {
    // ... existing plugins ...
    alias(libs.plugins.gms)                  // com.google.gms.google-services
    alias(libs.plugins.firebase.crashlytics) // com.google.firebase.crashlytics
}
```

**`android/gradle/libs.versions.toml`** — plugin versions already declared:
```toml
[plugins]
firebase-crashlytics = { id = "com.google.firebase.crashlytics", version = "3.0.3" }
gms = { id = "com.google.gms.google-services", version = "4.4.2" }
```

Firebase BOM and service dependencies are already declared in `android/app/build.gradle.kts`:
```kotlin
dependencies {
    implementation(platform(libs.firebase.bom))   // BOM: 33.8.0
    implementation(libs.firebase.analytics)        // firebase-analytics-ktx
    implementation(libs.firebase.crashlytics)      // firebase-crashlytics-ktx
    implementation(libs.firebase.messaging)        // firebase-messaging-ktx
    implementation(libs.firebase.config)           // firebase-config-ktx
}
```

No call to `FirebaseApp.initializeApp()` is required in `XGApplication.kt`.

---

## 4. iOS Initialization

### SPM Dependency

Firebase is declared as an SPM dependency. The relevant packages are pulled from the Firebase Apple SDK. The iOS app scaffold at `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/XiriGoEcommerceApp.swift` does not yet call `FirebaseApp.configure()`. Add this call as shown below.

### Add FirebaseCore Import and Configure Call

Edit `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/XiriGoEcommerceApp.swift`:

```swift
import SwiftUI
import FirebaseCore

@main
struct XiriGoEcommerceApp: App {

    init() {
        FirebaseApp.configure()
        // DI container setup will be added in M0-05
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

`FirebaseApp.configure()` reads `GoogleService-Info.plist` from the app bundle and initializes all Firebase services. It must be called before any Firebase service is accessed. Calling it inside `init()` (before `body`) satisfies this requirement.

### Xcode Project Setup

After downloading `GoogleService-Info.plist`:

1. In Xcode, drag `GoogleService-Info.plist` into the `XiriGoEcommerce/Resources/` group.
2. In the file addition dialog, ensure **Add to target: XiriGoEcommerce** is checked.
3. Verify the file appears under **Build Phases > Copy Bundle Resources** in the target settings.

---

## 5. Firebase Services Table

| Service | Android Dependency (libs.versions.toml) | iOS Package | Status | Notes |
|---------|----------------------------------------|-------------|--------|-------|
| Analytics | `firebase-analytics-ktx` | `FirebaseAnalytics` | Dependency declared | Needs event setup per Section 6 |
| Crashlytics | `firebase-crashlytics-ktx` | `FirebaseCrashlytics` | Dependency declared | Needs dSYM upload build phase (iOS) — see Section 8 |
| Cloud Messaging | `firebase-messaging-ktx` | `FirebaseMessaging` | Dependency declared | Needs push entitlements + service class |
| Remote Config | `firebase-config-ktx` | `FirebaseRemoteConfig` | Dependency declared | Needs default values file — see Section 7 |

All four dependencies are pulled under the Firebase BOM (`firebase-bom:33.8.0` on Android, Firebase Apple SDK `11.7.0` on iOS).

---

## 6. Analytics Event Catalog

### Standard Events

These events are logged across the app. All event names use `snake_case`. All parameter values are strings unless noted.

| Event | Parameters | Trigger Point |
|-------|-----------|---------------|
| `screen_view` | `screen_name` (String), `screen_class` (String) | Every screen becomes visible |
| `product_view` | `product_id` (String), `product_name` (String), `price` (Double) | Product detail screen opened |
| `add_to_cart` | `product_id` (String), `variant_id` (String), `quantity` (Int), `price` (Double) | Add to cart button tapped |
| `remove_from_cart` | `product_id` (String), `variant_id` (String) | Item removed from cart |
| `begin_checkout` | `cart_total` (Double), `item_count` (Int) | Checkout flow started |
| `purchase` | `order_id` (String), `total` (Double), `currency` (String), `item_count` (Int) | Order completed successfully |
| `login` | `method` = `"email"` | Successful login |
| `sign_up` | `method` = `"email"` | Successful registration |
| `search` | `search_term` (String) | Search performed |

### Android — Logging Events

```kotlin
import com.google.firebase.Firebase
import com.google.firebase.analytics.analytics
import com.google.firebase.analytics.logEvent

// Screen view
Firebase.analytics.logEvent("screen_view") {
    param("screen_name", "ProductList")
    param("screen_class", "ProductListScreen")
}

// Product view
Firebase.analytics.logEvent("product_view") {
    param("product_id", product.id)
    param("product_name", product.title)
    param("price", product.price)
}

// Add to cart
Firebase.analytics.logEvent("add_to_cart") {
    param("product_id", productId)
    param("variant_id", variantId)
    param("quantity", quantity.toLong())
    param("price", price)
}

// Purchase
Firebase.analytics.logEvent("purchase") {
    param("order_id", order.id)
    param("total", order.total)
    param("currency", "EUR")
    param("item_count", order.items.size.toLong())
}

// Search
Firebase.analytics.logEvent("search") {
    param("search_term", query)
}
```

Log events from the repository or ViewModel layer — not from UI composables. Inject an `AnalyticsTracker` interface to keep feature code testable.

### iOS — Logging Events

```swift
import FirebaseAnalytics

// Screen view
Analytics.logEvent(AnalyticsEventScreenView, parameters: [
    AnalyticsParameterScreenName: "ProductList",
    AnalyticsParameterScreenClass: "ProductListView"
])

// Product view
Analytics.logEvent("product_view", parameters: [
    "product_id": product.id,
    "product_name": product.title,
    "price": product.price
])

// Add to cart
Analytics.logEvent("add_to_cart", parameters: [
    "product_id": productId,
    "variant_id": variantId,
    "quantity": quantity,
    "price": price
])

// Purchase
Analytics.logEvent("purchase", parameters: [
    "order_id": order.id,
    "total": order.total,
    "currency": "EUR",
    "item_count": order.items.count
])

// Search
Analytics.logEvent("search", parameters: [
    "search_term": query
])
```

### User Properties

Set user properties after login to segment analytics data:

**Android**:
```kotlin
Firebase.analytics.setUserId(userId)
Firebase.analytics.setUserProperty("user_type", "registered") // or "guest"
Firebase.analytics.setUserProperty("locale", Locale.getDefault().language)
```

**iOS**:
```swift
Analytics.setUserID(userId)
Analytics.setUserProperty("registered", forName: "user_type") // or "guest"
Analytics.setUserProperty(Locale.current.language, forName: "locale")
```

Clear user data on logout:

**Android**: `Firebase.analytics.setUserId(null)`
**iOS**: `Analytics.setUserID(nil)`

---

## 7. Remote Config Keys

### Default Values

These keys must be defined in the Firebase Console under **Remote Config** for each environment project. The table below shows the keys, types, and defaults.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `min_supported_version_android` | String | `"1.0.0"` | Minimum Android version; trigger force update if current version is lower |
| `min_supported_version_ios` | String | `"1.0.0"` | Minimum iOS version; trigger force update if current version is lower |
| `maintenance_mode` | Boolean | `false` | When `true`, show full-screen maintenance message and block app usage |
| `feature_wishlist_enabled` | Boolean | `true` | Enable or disable the wishlist feature entirely |
| `feature_reviews_enabled` | Boolean | `true` | Enable or disable product reviews and ratings |

### Android — Remote Config Setup

Create a `remote_config_defaults.xml` file at `android/app/src/main/res/xml/remote_config_defaults.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<defaultsMap>
    <entry>
        <key>min_supported_version_android</key>
        <value>1.0.0</value>
    </entry>
    <entry>
        <key>maintenance_mode</key>
        <value>false</value>
    </entry>
    <entry>
        <key>feature_wishlist_enabled</key>
        <value>true</value>
    </entry>
    <entry>
        <key>feature_reviews_enabled</key>
        <value>true</value>
    </entry>
</defaultsMap>
```

Fetch and activate Remote Config values on app launch:

```kotlin
import com.google.firebase.Firebase
import com.google.firebase.remoteconfig.remoteConfig
import com.google.firebase.remoteconfig.remoteConfigSettings

// In XGApplication or an AppInitializer
val remoteConfig = Firebase.remoteConfig

val configSettings = remoteConfigSettings {
    minimumFetchIntervalInSeconds = if (BuildConfig.DEBUG) 0L else 3600L
}
remoteConfig.setConfigSettingsAsync(configSettings)
remoteConfig.setDefaultsAsync(R.xml.remote_config_defaults)

// Fetch and activate — do not block app startup; use a coroutine
remoteConfig.fetchAndActivate().addOnCompleteListener { task ->
    if (task.isSuccessful) {
        val minVersion = remoteConfig.getString("min_supported_version_android")
        val maintenanceMode = remoteConfig.getBoolean("maintenance_mode")
        // handle force update / maintenance mode in ViewModel
    }
}
```

Read individual values after activation:

```kotlin
val wishlistEnabled = Firebase.remoteConfig.getBoolean("feature_wishlist_enabled")
val reviewsEnabled  = Firebase.remoteConfig.getBoolean("feature_reviews_enabled")
```

### iOS — Remote Config Setup

Create a `RemoteConfigDefaults.plist` file at `ios/XiriGoEcommerce/Resources/RemoteConfigDefaults.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>min_supported_version_ios</key>
    <string>1.0.0</string>
    <key>maintenance_mode</key>
    <false/>
    <key>feature_wishlist_enabled</key>
    <true/>
    <key>feature_reviews_enabled</key>
    <true/>
</dict>
</plist>
```

Fetch and activate on app launch:

```swift
import FirebaseRemoteConfig

let remoteConfig = RemoteConfig.remoteConfig()

// Apply defaults
remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")

// Set minimum fetch interval (0 in debug for immediate updates)
let settings = RemoteConfigSettings()
#if DEBUG
settings.minimumFetchInterval = 0
#else
settings.minimumFetchInterval = 3600
#endif
remoteConfig.configSettings = settings

// Fetch and activate
remoteConfig.fetchAndActivate { status, error in
    if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
        let minVersion = remoteConfig.configValue(forKey: "min_supported_version_ios").stringValue
        let maintenanceMode = remoteConfig.configValue(forKey: "maintenance_mode").boolValue
        // handle force update / maintenance mode
    }
}
```

Read individual values after activation:

```swift
let wishlistEnabled = RemoteConfig.remoteConfig()["feature_wishlist_enabled"].boolValue
let reviewsEnabled  = RemoteConfig.remoteConfig()["feature_reviews_enabled"].boolValue
```

### Force Update Logic

The app checks `min_supported_version_android` (or `min_supported_version_ios`) against `BuildConfig.VERSION_NAME` (Android) or `Config.bundleVersion` (iOS) on each launch after Remote Config activates. If the current version is lower, a blocking dialog is shown directing the user to the store.

---

## 8. Crashlytics Setup

### Android

Crashlytics is initialized automatically via the `google-services` plugin and the `firebase-crashlytics-ktx` dependency. Crashes are collected without additional code.

Add custom keys to crashes to aid diagnosis:

```kotlin
import com.google.firebase.Firebase
import com.google.firebase.crashlytics.crashlytics

// Set user context — call after login
Firebase.crashlytics.setUserId(userId)

// Set current screen — call from ViewModel or navigation observer
Firebase.crashlytics.setCustomKey("screen_name", "ProductList")

// Log non-fatal errors (e.g., API error that was handled gracefully)
Firebase.crashlytics.recordException(exception)

// Add breadcrumb log
Firebase.crashlytics.log("User tapped Add to Cart for product $productId")
```

### iOS — dSYM Upload Build Phase

Crashlytics requires dSYM files for symbolication (translating memory addresses to readable stack traces). Add the upload script as a build phase in Xcode:

1. In Xcode, select the **XiriGoEcommerce** target.
2. Go to **Build Phases**.
3. Click **+** and choose **New Run Script Phase**.
4. Name it `Upload Crashlytics dSYMs`.
5. Set the script body:
   ```bash
   "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
   ```
6. Under **Input Files**, add:
   ```
   ${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
   $(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
   ```
7. Move this phase to run **after** the Compile Sources phase.

Add custom keys and non-fatal logging:

```swift
import FirebaseCrashlytics

// Set user context — call after login
Crashlytics.crashlytics().setUserID(userId)

// Set current screen
Crashlytics.crashlytics().setCustomValue("ProductList", forKey: "screen_name")

// Log non-fatal errors
Crashlytics.crashlytics().record(error: error)

// Add breadcrumb log
Crashlytics.crashlytics().log("User tapped Add to Cart for product \(productId)")
```

### Crash Key Conventions

Always set these two keys to maximize the utility of crash reports:

| Key | Type | Set When |
|-----|------|----------|
| `user_id` | String | After successful login; clear on logout |
| `screen_name` | String | On each navigation event |

---

## 9. Environment Separation

### Per-Environment Config Files

Each Firebase project produces separate `google-services.json` and `GoogleService-Info.plist` files with different API keys and project IDs. These are not interchangeable.

The build variants in `android/app/build.gradle.kts` use different `applicationId` suffixes, which correspond to the correct Firebase app registrations:

```kotlin
buildTypes {
    debug {
        applicationIdSuffix = ".debug"     // matches com.xirigo.ecommerce.debug in firebase-dev
    }
    create("staging") {
        applicationIdSuffix = ".staging"   // matches com.xirigo.ecommerce.staging in firebase-staging
    }
    release {
        // no suffix                        // matches com.xirigo.ecommerce in firebase-prod
    }
}
```

### Developer Local Setup

Developers need to obtain `google-services.json` and `GoogleService-Info.plist` for the dev environment. These files are stored in a secure location (1Password, Google Drive with restricted access, or AWS Secrets Manager).

Steps for a new developer:

1. Request access to the Firebase dev project config files from the team lead.
2. Place `google-services.json` at `android/app/google-services.json`.
3. Place `GoogleService-Info.plist` at `ios/XiriGoEcommerce/Resources/GoogleService-Info.plist`.
4. Verify both files are listed in `.gitignore` and are not staged for commit:
   ```bash
   git status  # these files must NOT appear here
   ```

### CI/CD Setup with GitHub Actions

Store config files as GitHub Actions secrets:

1. In the Firebase Console, download the `google-services.json` for each environment.
2. Base64-encode each file:
   ```bash
   base64 -i google-services.json | pbcopy
   ```
3. In GitHub repository **Settings > Secrets and variables > Actions**, create secrets:
   - `GOOGLE_SERVICES_JSON_DEBUG` — base64-encoded dev `google-services.json`
   - `GOOGLE_SERVICES_JSON_STAGING` — base64-encoded staging `google-services.json`
   - `GOOGLE_SERVICES_JSON_RELEASE` — base64-encoded prod `google-services.json`
   - `GOOGLE_SERVICE_INFO_PLIST_DEBUG` — base64-encoded dev `GoogleService-Info.plist`
   - `GOOGLE_SERVICE_INFO_PLIST_STAGING` — base64-encoded staging `GoogleService-Info.plist`
   - `GOOGLE_SERVICE_INFO_PLIST_RELEASE` — base64-encoded prod `GoogleService-Info.plist`

4. In the GitHub Actions workflow file, decode and place the files before the build step:

**Android**:
```yaml
- name: Decode google-services.json (debug)
  run: |
    echo "${{ secrets.GOOGLE_SERVICES_JSON_DEBUG }}" | base64 --decode \
      > android/app/google-services.json
```

**iOS**:
```yaml
- name: Decode GoogleService-Info.plist (debug)
  run: |
    echo "${{ secrets.GOOGLE_SERVICE_INFO_PLIST_DEBUG }}" | base64 --decode \
      > ios/XiriGoEcommerce/Resources/GoogleService-Info.plist
```

Use the appropriate secret name (`_DEBUG`, `_STAGING`, or `_RELEASE`) based on the build variant being assembled in that workflow job.

---

## Related Files

| File | Purpose |
|------|---------|
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/app/build.gradle.kts` | Firebase BOM + service dependencies, build variants |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/gradle/libs.versions.toml` | Firebase BOM version (`33.8.0`), plugin declarations |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/build.gradle.kts` | `gms` and `firebase-crashlytics` plugin declarations |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/XiriGoEcommerceApp.swift` | Add `FirebaseApp.configure()` here |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/Config.swift` | App version for force update comparison |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/.gitignore` | Add Firebase config files here |
| `android/app/google-services.json` | Android Firebase config — gitignored, from secure storage |
| `ios/XiriGoEcommerce/Resources/GoogleService-Info.plist` | iOS Firebase config — gitignored, from secure storage |
| `android/app/src/main/res/xml/remote_config_defaults.xml` | Remote Config default values (Android) |
| `ios/XiriGoEcommerce/Resources/RemoteConfigDefaults.plist` | Remote Config default values (iOS) |
