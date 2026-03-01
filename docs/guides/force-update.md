# Force Update Guide

**Scope**: XiriGo Ecommerce Mobile Buyer App — Android + iOS
**Last Updated**: 2026-02-20

This guide covers the force update and maintenance mode mechanisms for the XiriGo Ecommerce mobile buyer app. Both features are driven by Firebase Remote Config and checked on every app launch.

---

## 1. Overview

The force update system ensures users run a minimum supported app version and prevents access to API versions the backend no longer supports.

| Mode | Trigger | User Experience |
|------|---------|----------------|
| Force update | Current version < `min_supported_version` | Full-screen blocking dialog, no dismiss |
| Soft update | Current version < `recommended_version` (future) | Dismissible banner, once per session |
| Maintenance | `maintenance_mode = true` | Full-screen blocking message, no dismiss |

### Check Priority

```
App Launch
    │
    ▼
Fetch Remote Config (12-hour cache; 0s in debug)
    │
    ▼
Check maintenance_mode
    ├── true  → Show Maintenance Screen (stop here)
    └── false → Continue
    │
    ▼
Read current app version from BuildConfig / Bundle
    │
    ▼
Compare with min_supported_version_{platform}
    ├── current < min  → Show Force Update Dialog (stop here)
    └── current >= min → Continue to app
```

Maintenance mode takes precedence over version checks. If both are true, show the maintenance screen.

---

## 2. Remote Config Integration

### Keys

Remote Config keys are defined in `docs/guides/firebase-setup.md` Section 7. The keys relevant to this feature:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `min_supported_version_android` | String | `"1.0.0"` | Minimum Android version; force update if current is lower |
| `min_supported_version_ios` | String | `"1.0.0"` | Minimum iOS version; force update if current is lower |
| `maintenance_mode` | Boolean | `false` | Show maintenance screen and block all usage |

### Fetch Strategy

Remote Config is fetched on every app launch with a 12-hour minimum fetch interval in production. In debug builds, the interval is 0 seconds for immediate testing.

```kotlin
// Android (from firebase-setup.md Section 7)
val configSettings = remoteConfigSettings {
    minimumFetchIntervalInSeconds = if (BuildConfig.DEBUG) 0L else 43200L // 12 hours
}
```

```swift
// iOS (from firebase-setup.md Section 7)
#if DEBUG
settings.minimumFetchInterval = 0
#else
settings.minimumFetchInterval = 43200 // 12 hours
#endif
```

### Fallback Behavior

If the Remote Config fetch fails (no network on first launch, Firebase outage), the SDK uses the last successfully fetched values. If no values have been fetched yet, it falls back to the in-app default values.

Default values: `min_supported_version = "1.0.0"`, `maintenance_mode = false`. With these defaults, the app launches normally. Do not set defaults that would block the app.

---

## 3. Version Comparison Algorithm

App version follows semantic versioning: `MAJOR.MINOR.PATCH` (e.g., `1.3.0`). Comparison is component-by-component left to right. The first differing component determines the result.

Examples:

| Current | Minimum | Result |
|---------|---------|--------|
| `1.2.3` | `1.2.3` | Equal — no update needed |
| `1.3.0` | `1.2.9` | Current is higher — no update needed |
| `1.2.3` | `1.3.0` | Current is lower — force update |
| `2.0.0` | `1.9.9` | Current is higher — no update needed |
| `1.0.0` | `1.0.1` | Current is lower — force update |

### Android

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/update/VersionChecker.kt

/**
 * Returns true if [current] is strictly less than [minimum].
 * Both strings must follow MAJOR.MINOR.PATCH semantic versioning.
 * Non-numeric or missing components default to 0.
 */
fun isVersionLessThan(current: String, minimum: String): Boolean {
    val currentParts = current.split(".").map { it.toIntOrNull() ?: 0 }
    val minimumParts = minimum.split(".").map { it.toIntOrNull() ?: 0 }

    val maxLength = maxOf(currentParts.size, minimumParts.size)

    for (i in 0 until maxLength) {
        val c = currentParts.getOrElse(i) { 0 }
        val m = minimumParts.getOrElse(i) { 0 }
        when {
            c < m -> return true
            c > m -> return false
        }
    }
    return false // equal
}

// Usage
val currentVersion = BuildConfig.VERSION_NAME          // e.g., "1.2.3"
val minimumVersion = Firebase.remoteConfig
    .getString("min_supported_version_android")        // e.g., "1.3.0"

val forceUpdate = isVersionLessThan(currentVersion, minimumVersion)
```

### iOS

```swift
// ios/XiriGoEcommerce/Core/Update/VersionChecker.swift

/// Returns true if `current` is strictly less than `minimum`.
/// Both strings must follow MAJOR.MINOR.PATCH semantic versioning.
/// Non-numeric or missing components default to 0.
func isVersionLessThan(_ current: String, minimum: String) -> Bool {
    let currentParts = current.split(separator: ".").map { Int($0) ?? 0 }
    let minimumParts = minimum.split(separator: ".").map { Int($0) ?? 0 }

    let maxLength = max(currentParts.count, minimumParts.count)

    for i in 0..<maxLength {
        let c = i < currentParts.count ? currentParts[i] : 0
        let m = i < minimumParts.count ? minimumParts[i] : 0
        if c < m { return true }
        if c > m { return false }
    }
    return false // equal
}

// Usage
let currentVersion = Config.bundleVersion                // e.g., "1.2.3"
let minimumVersion = RemoteConfig.remoteConfig()
    .configValue(forKey: "min_supported_version_ios")
    .stringValue ?? "1.0.0"                             // e.g., "1.3.0"

let forceUpdate = isVersionLessThan(currentVersion, minimum: minimumVersion)
```

`Config.bundleVersion` reads `CFBundleShortVersionString` from the app bundle. See `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/Config.swift`.

---

## 4. Update UI

### Force Update Dialog (Blocking)

Shown when `current < min_supported_version`. The user cannot dismiss it. The only action is to open the app store.

**Behavior**:
- Displayed over all content, covering the screen
- Back button / swipe-to-dismiss disabled
- Tapping "Update Now" opens the store listing
- The dialog remains until the user updates and the app restarts with the new version

#### Android

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/update/ForceUpdateDialog.kt
@Composable
fun ForceUpdateDialog(onUpdateClick: () -> Unit) {
    AlertDialog(
        onDismissRequest = { /* non-dismissible */ },
        title = { Text(stringResource(R.string.update_force_title)) },
        text = { Text(stringResource(R.string.update_force_message)) },
        confirmButton = {
            XGButton(
                text = stringResource(R.string.update_force_button),
                onClick = onUpdateClick,
            )
        },
        dismissButton = null,
        properties = DialogProperties(
            dismissOnBackPress = false,
            dismissOnClickOutside = false,
        ),
    )
}
```

#### iOS

```swift
// ios/XiriGoEcommerce/Core/Update/ForceUpdateView.swift
struct ForceUpdateView: View {
    let onUpdate: () -> Void

    var body: some View {
        VStack(spacing: XGSpacing.lg) {
            Spacer()
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 64))
                .foregroundStyle(XGColors.primary)

            Text(String(localized: "update_force_title"))
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(String(localized: "update_force_message"))
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            XGButton(String(localized: "update_force_button"), action: onUpdate)
                .padding(.horizontal, XGSpacing.xl)

            Spacer()
        }
        .padding(XGSpacing.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .interactiveDismissDisabled(true)
    }
}
```

Present as a full-screen cover from the root view so it cannot be dismissed by any navigation gesture.

### Soft Update Banner (Dismissible)

Used when a newer version is available but not yet required. Show once per app session; do not persist the dismissal across sessions.

```kotlin
// Android — dismissible banner shown in the root scaffold
@Composable
fun SoftUpdateBanner(onUpdateClick: () -> Unit, onDismiss: () -> Unit) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = MaterialTheme.colorScheme.primaryContainer,
    ) {
        Row(
            modifier = Modifier.padding(XGSpacing.Base),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = stringResource(R.string.update_soft_message),
                modifier = Modifier.weight(1f),
                style = MaterialTheme.typography.bodyMedium,
            )
            Row(horizontalArrangement = Arrangement.spacedBy(XGSpacing.SM)) {
                TextButton(onClick = onDismiss) {
                    Text(stringResource(R.string.update_soft_later_button))
                }
                XGButton(
                    text = stringResource(R.string.update_soft_button),
                    onClick = onUpdateClick,
                    style = XGButtonStyle.Secondary,
                )
            }
        }
    }
}
```

### Required String Resources

Add to `android/app/src/main/res/values/strings.xml` and corresponding locale files:

```xml
<string name="update_force_title">Update Required</string>
<string name="update_force_message">A new version of XiriGo Ecommerce is available. Please update to continue.</string>
<string name="update_force_button">Update Now</string>
<string name="update_soft_message">A new version is available</string>
<string name="update_soft_button">Update</string>
<string name="update_soft_later_button">Later</string>
<string name="maintenance_title">Under Maintenance</string>
<string name="maintenance_message">We\'re updating our systems. Please try again later.</string>
```

Add the same keys to `ios/XiriGoEcommerce/Resources/Localizable.xcstrings`.

---

## 5. Store Links

Opening the store listing uses a deep link URI. The URI scheme that opens the store app directly is preferred; fall back to the HTTPS URL if the URI scheme is not handled.

### Android

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/update/StoreNavigator.kt
object StoreNavigator {
    private const val PACKAGE_NAME = "com.xirigo.ecommerce"

    fun openPlayStore(context: Context) {
        val marketUri = Uri.parse("market://details?id=$PACKAGE_NAME")
        val webUri = Uri.parse("https://play.google.com/store/apps/details?id=$PACKAGE_NAME")

        try {
            context.startActivity(Intent(Intent.ACTION_VIEW, marketUri).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            })
        } catch (_: ActivityNotFoundException) {
            // Play Store app not installed — open browser
            context.startActivity(Intent(Intent.ACTION_VIEW, webUri).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            })
        }
    }
}
```

### iOS

```swift
// ios/XiriGoEcommerce/Core/Update/StoreNavigator.swift
enum StoreNavigator {
    // Replace APP_ID with the actual numeric App Store ID after publication
    private static let appStoreID = "APP_ID"

    static func openAppStore() {
        let storeURL = URL(string: "itms-apps://apps.apple.com/app/id\(appStoreID)")!
        let webURL = URL(string: "https://apps.apple.com/app/id\(appStoreID)")!

        if UIApplication.shared.canOpenURL(storeURL) {
            UIApplication.shared.open(storeURL)
        } else {
            UIApplication.shared.open(webURL)
        }
    }
}
```

Add `itms-apps` to the `LSApplicationQueriesSchemes` array in `Info.plist` so `canOpenURL` returns `true` for the App Store scheme:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>itms-apps</string>
</array>
```

---

## 6. Full Check Flow

The version and maintenance check runs in a dedicated ViewModel at the root of the navigation graph. It observes the result and shows the appropriate overlay.

### Android ViewModel

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/update/AppUpdateViewModel.kt
@HiltViewModel
class AppUpdateViewModel @Inject constructor(
    private val remoteConfig: FirebaseRemoteConfig,
) : ViewModel() {

    val uiState: StateFlow<AppUpdateUiState> = flow {
        emit(AppUpdateUiState.Loading)

        // Fetch Remote Config — suspending wrapper around the callback
        val fetchSuccess = remoteConfig.fetchAndActivate().await()

        val maintenanceMode = remoteConfig.getBoolean("maintenance_mode")
        if (maintenanceMode) {
            emit(AppUpdateUiState.Maintenance)
            return@flow
        }

        val minVersion = remoteConfig.getString("min_supported_version_android")
        val currentVersion = BuildConfig.VERSION_NAME

        if (isVersionLessThan(currentVersion, minVersion)) {
            emit(AppUpdateUiState.ForceUpdate)
            return@flow
        }

        emit(AppUpdateUiState.UpToDate)
    }.catch {
        // Fetch failed — default values are already set (no blocking)
        emit(AppUpdateUiState.UpToDate)
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = AppUpdateUiState.Loading,
    )
}

sealed interface AppUpdateUiState {
    data object Loading : AppUpdateUiState
    data object UpToDate : AppUpdateUiState
    data object ForceUpdate : AppUpdateUiState
    data object Maintenance : AppUpdateUiState
}
```

### iOS ViewModel

```swift
// ios/XiriGoEcommerce/Core/Update/AppUpdateViewModel.swift
@MainActor @Observable
final class AppUpdateViewModel {
    private(set) var uiState: AppUpdateUiState = .loading

    func checkForUpdates() async {
        uiState = .loading

        do {
            let remoteConfig = RemoteConfig.remoteConfig()
            _ = try await remoteConfig.fetchAndActivate()

            let maintenanceMode = remoteConfig["maintenance_mode"].boolValue
            if maintenanceMode {
                uiState = .maintenance
                return
            }

            let minVersion = remoteConfig["min_supported_version_ios"].stringValue ?? "1.0.0"
            let currentVersion = Config.bundleVersion

            if isVersionLessThan(currentVersion, minimum: minVersion) {
                uiState = .forceUpdate
                return
            }

            uiState = .upToDate
        } catch {
            // Fetch failed — defaults are in effect, proceed normally
            uiState = .upToDate
        }
    }
}

enum AppUpdateUiState {
    case loading
    case upToDate
    case forceUpdate
    case maintenance
}
```

### Root View Integration

```swift
// ios/XiriGoEcommerce/XiriGoEcommerceApp.swift (sketch)
struct RootView: View {
    @State private var updateViewModel = AppUpdateViewModel()

    var body: some View {
        Group {
            switch updateViewModel.uiState {
            case .loading:
                XGLoadingView()
            case .maintenance:
                MaintenanceView()
            case .forceUpdate:
                ForceUpdateView(onUpdate: StoreNavigator.openAppStore)
            case .upToDate:
                MainTabView()  // normal app content
            }
        }
        .task { await updateViewModel.checkForUpdates() }
    }
}
```

---

## 7. Maintenance Mode

Maintenance mode overrides version checks and blocks all app usage with a non-dismissible screen.

```kotlin
// Android maintenance screen
@Composable
fun MaintenanceScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(XGSpacing.Base),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(
            Icons.Outlined.Construction,
            contentDescription = null,
            modifier = Modifier.size(64.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Spacer(Modifier.height(XGSpacing.Base))
        Text(
            text = stringResource(R.string.maintenance_title),
            style = MaterialTheme.typography.headlineSmall,
        )
        Spacer(Modifier.height(XGSpacing.SM))
        Text(
            text = stringResource(R.string.maintenance_message),
            style = MaterialTheme.typography.bodyMedium,
            textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}
```

```swift
// iOS maintenance screen
struct MaintenanceView: View {
    var body: some View {
        VStack(spacing: XGSpacing.base) {
            Spacer()
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text(String(localized: "maintenance_title"))
                .font(.headline)
            Text(String(localized: "maintenance_message"))
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(XGSpacing.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .interactiveDismissDisabled(true)
    }
}
```

### Activating Maintenance Mode

In the Firebase Console, for the relevant environment project:

1. Go to Remote Config.
2. Set `maintenance_mode` to `true`.
3. Click Publish Changes.
4. The next app launch will show the maintenance screen (subject to the 12-hour cache).
5. To release immediately, click "Fetch and Activate" in the Firebase Console or reduce the cache interval temporarily.

---

## 8. Testing Strategy

### Firebase Remote Config Console

For manual QA, use the Firebase Remote Config Console to override values per device using Firebase A/B Testing or a condition targeting a specific installation ID.

### Debug Builds: Immediate Fetch

In debug builds, `minimumFetchIntervalInSeconds = 0` means every app launch fetches fresh values from the console. Set test values in the dev Firebase project (`xirigo-ecommerce-dev`) without affecting production.

### Unit Tests

Mock Remote Config to test all branches without network access:

```kotlin
// Android — fake AppUpdateViewModel with fixed state
class FakeRemoteConfig(
    private val maintenanceMode: Boolean = false,
    private val minVersion: String = "1.0.0",
) : RemoteConfigDelegate {
    override fun getBoolean(key: String): Boolean = when (key) {
        "maintenance_mode" -> maintenanceMode
        else -> false
    }
    override fun getString(key: String): String = when (key) {
        "min_supported_version_android" -> minVersion
        else -> ""
    }
}

// Test scenarios
class VersionCheckerTest {
    @Test fun `current version equal to minimum - no update needed`() {
        assertFalse(isVersionLessThan("1.0.0", "1.0.0"))
    }

    @Test fun `current version lower than minimum - force update`() {
        assertTrue(isVersionLessThan("1.2.3", "1.3.0"))
    }

    @Test fun `current version higher than minimum - no update needed`() {
        assertFalse(isVersionLessThan("2.0.0", "1.9.9"))
    }

    @Test fun `missing patch component defaults to zero`() {
        assertFalse(isVersionLessThan("1.3", "1.3.0"))
    }
}
```

```swift
// iOS unit tests (Swift Testing)
@Test func currentVersionEqualToMinimum() {
    #expect(isVersionLessThan("1.0.0", minimum: "1.0.0") == false)
}

@Test func currentVersionLowerThanMinimum() {
    #expect(isVersionLessThan("1.2.3", minimum: "1.3.0") == true)
}

@Test func currentVersionHigherThanMinimum() {
    #expect(isVersionLessThan("2.0.0", minimum: "1.9.9") == false)
}

@Test func missingPatchComponentDefaultsToZero() {
    #expect(isVersionLessThan("1.3", minimum: "1.3.0") == false)
}
```

### Manual Test Scenarios

| Scenario | Setup | Expected Result |
|----------|-------|----------------|
| Force update | Set `min_supported_version` to `99.0.0` in dev Remote Config | Blocking update dialog on launch |
| No update needed | Set `min_supported_version` to `1.0.0` | Normal app launch |
| Maintenance mode | Set `maintenance_mode = true` | Maintenance screen on launch |
| Fetch failure | Disable network before launch | App launches with default values (no block) |
| First launch (no cache) | Fresh install, no network | App launches with in-app defaults |

---

## Related Files

| File | Purpose |
|------|---------|
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/app/build.gradle.kts` | `BuildConfig.VERSION_NAME` source (`versionName = "1.0.0"`) |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/Config.swift` | `Config.bundleVersion` reads `CFBundleShortVersionString` |
| `docs/guides/firebase-setup.md` | Remote Config setup, default values, fetch configuration |
| `android/app/src/main/res/xml/remote_config_defaults.xml` | Default values for `min_supported_version_android`, `maintenance_mode` |
| `ios/XiriGoEcommerce/Resources/RemoteConfigDefaults.plist` | Default values for `min_supported_version_ios`, `maintenance_mode` |
| `android/app/src/main/res/values/strings.xml` | `update_force_title`, `update_force_message`, `maintenance_title` strings |
| `ios/XiriGoEcommerce/Resources/Localizable.xcstrings` | Same strings for iOS |
