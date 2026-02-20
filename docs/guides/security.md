# Security Guide

**Scope**: Molt Marketplace Mobile Buyer App — Android + iOS
**Last Updated**: 2026-02-20

This guide covers the platform security measures implemented in the Molt Marketplace mobile buyer app. It is a reference for developers implementing any feature that touches storage, network, or sensitive data.

---

## 1. Token Security

Full implementation details are in `shared/feature-specs/auth-infrastructure.md`. This section summarizes the storage strategy.

### Storage Locations

| Token | Android | iOS |
|-------|---------|-----|
| Access token | Proto DataStore encrypted with Google Tink (AES256-GCM, Android Keystore-backed key) | KeychainAccess (`.afterFirstUnlock`) |
| Refresh token | Same encrypted DataStore file (`auth_tokens.pb.enc`) | Same Keychain service (`com.molt.marketplace`) |
| Token expiry | Stored alongside tokens in same encrypted location | `access_token_expiry` key in Keychain |

### Rules

- Never log tokens. Timber and `os.Logger` must not print access or refresh token values.
- Never store tokens in `SharedPreferences`, `UserDefaults`, plain files, or Room/SwiftData.
- `EncryptedSharedPreferences` is deprecated — the project uses Tink instead.
- Auto-clear all tokens on logout regardless of whether the logout API call succeeds.
- On Android, the Tink AES256-GCM key lives in Android Keystore under the alias `molt_master_key` and is never exported.
- On iOS, `.afterFirstUnlock` means the token is available after the first device unlock post-boot, unavailable before that, and excluded from iCloud backup automatically.

### Logout Guarantee

Logout always clears local token state. API failure must not block the user from logging out.

```kotlin
// Android — clear regardless of API result
suspend fun logout() {
    try { authApi.destroySession() } catch (_: Exception) { /* fire and forget */ }
    authTokensDataStore.updateData { AuthTokens.getDefaultInstance() }
    authStateManager.setGuest()
}
```

```swift
// iOS — clear regardless of API result
func logout() async {
    try? await authEndpoint.destroySession()
    authTokenStorage.clear()
    authStateManager.setGuest()
}
```

---

## 2. ProGuard / R8 Rules (Android)

### Configuration

R8 is enabled in release builds. The `build.gradle.kts` release build type sets:

```kotlin
// android/app/build.gradle.kts
release {
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
    )
}
```

Debug and staging builds have `isMinifyEnabled = false` — no obfuscation during development.

### Current Rules (`android/app/proguard-rules.pro`)

The following rules are present in the project:

```proguard
# Retrofit — keep generic signatures (required for R8 full mode)
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

# Kotlinx Serialization — keep serializer companions and annotations
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Project-specific serializable classes
-keep,includedescriptorclasses class com.molt.marketplace.**$$serializer { *; }
-keepclassmembers class com.molt.marketplace.** {
    *** Companion;
}
-keepclasseswithmembers class com.molt.marketplace.** {
    kotlinx.serialization.KSerializer serializer(...);
}
```

### Additional Rules to Add as Features Are Implemented

#### Room

```proguard
# Room — keep entity and DAO classes
-keep class com.molt.marketplace.core.database.** { *; }
-keepclassmembers class * {
    @androidx.room.* <methods>;
}
```

#### Firebase

```proguard
# Firebase — SDK uses reflection internally
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
```

#### Hilt

Hilt generates code at compile time; R8 handles it correctly without custom rules when the Hilt Gradle plugin is applied. No manual keep rules are needed.

#### Google Tink

```proguard
# Tink — cryptographic primitives use reflection
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**
```

### Validation

After adding or modifying rules, verify the release build works end-to-end:

```bash
cd android
./gradlew assembleRelease
```

Install the APK on a physical device or emulator and exercise the critical path: login, product list, add to cart, checkout. Missing keep rules surface as `ClassNotFoundException` or `NoSuchMethodException` at runtime.

---

## 3. App Transport Security (iOS)

### Default Enforcement

iOS enforces ATS by default. All network connections from the app must use HTTPS. The project does not add `NSAllowsArbitraryLoads` to `Info.plist`.

All three API environments use HTTPS:

| Environment | Base URL |
|-------------|---------|
| Debug | `https://api-dev.molt.mt` |
| Staging | `https://api-staging.molt.mt` |
| Release | `https://api.molt.mt` |

These are defined in `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Config.swift`.

### Local Development Exception

If a developer needs to connect to a local Medusa instance over HTTP, add a scoped exception for `localhost` only — never a blanket exception:

```xml
<!-- ios/MoltMarketplace/Resources/Info.plist (debug builds only) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

This exception must never appear in staging or release `Info.plist`. Use xcconfig-based `Info.plist` substitution to restrict it to the Debug configuration.

---

## 4. Certificate Pinning (Production)

Certificate pinning prevents man-in-the-middle attacks even when a malicious CA is trusted by the OS. Pinning is enabled in production builds only — it must remain disabled in debug so developers can inspect traffic with Proxyman or Charles.

### Android — Network Security Configuration

The existing `network_security_config.xml` enforces HTTPS and trusts only system CAs. Add a `<domain-config>` block with SHA-256 pins for the production API domain:

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Default: HTTPS only, system CAs -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>

    <!-- Production domain — pin primary + backup certificates -->
    <domain-config>
        <domain includeSubdomains="true">api.molt.mt</domain>
        <pin-set expiration="2027-01-01">
            <!-- Primary certificate SHA-256 pin -->
            <pin digest="SHA-256">AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=</pin>
            <!-- Backup certificate SHA-256 pin (for rotation) -->
            <pin digest="SHA-256">BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=</pin>
        </pin-set>
    </domain-config>

    <!-- Debug: allow user-installed CAs (Proxyman, Charles) -->
    <debug-overrides>
        <trust-anchors>
            <certificates src="user" />
        </trust-anchors>
    </debug-overrides>
</network-security-config>
```

To obtain the SHA-256 pin for a domain:

```bash
openssl s_client -connect api.molt.mt:443 -servername api.molt.mt 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary \
  | base64
```

Replace the placeholder pin values with the real output before shipping.

### iOS — URLSessionDelegate Pin Validation

iOS does not support declarative pinning in a config file. Implement pinning via `URLSessionDelegate`:

```swift
// ios/MoltMarketplace/Core/Network/PinningDelegate.swift
import Foundation
import CryptoKit

final class PinningDelegate: NSObject, URLSessionDelegate {
    // SHA-256 pins for api.molt.mt — update before certificate expiry
    private let pinnedHashes: Set<String> = [
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=", // primary
        "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=", // backup
    ]

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust,
            let certificate = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
            let leaf = certificate.first
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Extract public key hash
        guard let publicKey = SecCertificateCopyKey(leaf),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let hash = SHA256.hash(data: publicKeyData)
        let hashBase64 = Data(hash).base64EncodedString()

        if pinnedHashes.contains(hashBase64) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

Inject this delegate when creating the production `URLSession`:

```swift
// ios/MoltMarketplace/Core/Network/APIClient.swift (production builds)
#if !DEBUG
let session = URLSession(
    configuration: .appDefault,
    delegate: PinningDelegate(),
    delegateQueue: nil
)
#else
let session = URLSession(configuration: .appDefault)
#endif
```

### Pin Rotation Plan

1. Before the current certificate expires, obtain the SHA-256 of the replacement certificate.
2. Add it as the backup pin in both `network_security_config.xml` and `PinningDelegate.swift`.
3. Ship an app update with both old + new pins. Both will work during the transition.
4. After the old certificate expires, remove the old pin in the next release.
5. Update the `expiration` attribute in `network_security_config.xml` to reflect the new certificate expiry.

---

## 5. Sensitive Data Handling

### Log Redaction

Never log PII or credentials. This applies to all log statements in every layer.

**Patterns to never log**: email addresses, passwords, access tokens, refresh tokens, card numbers, order IDs containing PII.

#### Android (Timber)

Timber is the logging library (`timber:5.0.1`). In release builds, no Timber trees are planted — all `Timber.*` calls are no-ops. In debug builds, a `DebugTree` is planted in `MoltApplication`.

For additional safety, implement a redacting tree for staging builds:

```kotlin
// android/app/src/main/java/com/molt/marketplace/MoltApplication.kt
class RedactingTree : Timber.DebugTree() {
    private val sensitivePatterns = listOf(
        Regex("""(access_token|refresh_token|password|Authorization)["\s:=]+[^\s"&,}]+"""),
        Regex("""[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}"""), // email
    )

    override fun log(priority: Int, tag: String?, message: String, t: Throwable?) {
        var redacted = message
        sensitivePatterns.forEach { pattern ->
            redacted = pattern.replace(redacted, "[REDACTED]")
        }
        super.log(priority, tag, redacted, t)
    }
}
```

Plant in staging:

```kotlin
if (BuildConfig.DEBUG) Timber.plant(Timber.DebugTree())
// staging: plant RedactingTree instead of DebugTree
```

#### iOS (os.Logger)

Use `os.Logger` with `.private` privacy level for any value that could contain PII:

```swift
import os

private let logger = Logger(subsystem: "com.molt.marketplace", category: "Network")

// Mark user-controlled values as private — they appear as <private> in Console
logger.debug("Login attempt for: \(userEmail, privacy: .private)")
logger.error("Token refresh failed: \(error.localizedDescription, privacy: .private)")

// Non-sensitive values can use .public (visible in Console without a device attached)
logger.info("Screen appeared: \(screenName, privacy: .public)")
```

In release builds, `.private` values are always redacted in system logs even with a device attached. In debug builds, connect a device and open the Console app with the correct subsystem filter to see the private values.

### Clipboard Blocking

Disable the paste menu for password fields to prevent accidental exposure via clipboard history managers.

**Android**:

```kotlin
// Disable long-press paste context menu on password TextField
TextField(
    value = password,
    onValueChange = { password = it },
    visualTransformation = PasswordVisualTransformation(),
    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
    modifier = Modifier.disableSystemGestures() // optional — see platform limitations
)
```

Note: Android does not provide a direct API to disable paste for `TextField`. If this requirement becomes critical, use a custom `VisualTransformation` or wrap with `AndroidView` using an `EditText` with `setTextIsSelectable(false)`.

**iOS**:

```swift
// Disable paste in SecureField via UITextView subclassing if needed
// For standard SecureField, iOS 16+ clips clipboard automatically on password fields
SecureField("Password", text: $password)
    .textContentType(.password)
```

### Screenshot Prevention

Screenshot prevention is not implemented. Molt Marketplace is an e-commerce app; no page contains sensitive financial data beyond the Stripe PaymentSheet (which Stripe's SDK already protects). Adding `FLAG_SECURE` (Android) or setting `allowsScreenshots = false` (iOS) would harm usability without material security benefit.

---

## 6. Backup Exclusion

### Android Auto-Backup

Android Auto-Backup sends app data to the user's Google Drive. Auth tokens must be excluded; they are device-specific and invalid on a restored device.

Create backup rules XML files:

```xml
<!-- android/app/src/main/res/xml/backup_rules.xml (API 30 and below) -->
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <!-- Exclude encrypted token file — device-specific credential -->
    <exclude domain="file" path="datastore/auth_tokens.pb.enc" />
    <!-- Exclude HTTP response cache — large and easily refreshed -->
    <exclude domain="cache" path="http_cache" />
    <!-- Room database (cart, wishlist) is included — intentional, not sensitive -->
</full-backup-content>
```

```xml
<!-- android/app/src/main/res/xml/data_extraction_rules.xml (API 31+) -->
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="file" path="datastore/auth_tokens.pb.enc" />
        <exclude domain="cache" path="http_cache" />
    </cloud-backup>
    <device-transfer>
        <exclude domain="file" path="datastore/auth_tokens.pb.enc" />
    </device-transfer>
</data-extraction-rules>
```

Reference both in `AndroidManifest.xml`:

```xml
<application
    android:allowBackup="true"
    android:fullBackupContent="@xml/backup_rules"
    android:dataExtractionRules="@xml/data_extraction_rules"
    ... >
```

The manifest already has `android:allowBackup="true"` at `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/AndroidManifest.xml`. The XML rule files need to be created and referenced.

**What is backed up**: `molt_marketplace.db` (cart, wishlist, recent searches), `app_preferences.pb` (theme, onboarding flag — non-sensitive).

**What is excluded**: `auth_tokens.pb.enc`, `http_cache/`.

### iOS Keychain iCloud Backup

Keychain items stored with `.afterFirstUnlock` accessibility are excluded from iCloud Backup by default. Auth tokens use this accessibility level in `AuthTokenStorage`:

```swift
// ios/MoltMarketplace/Core/Storage/AuthTokenStorage.swift
Keychain(service: "com.molt.marketplace")
    .accessibility(.afterFirstUnlock)  // not synchronized to iCloud — correct
```

Do not add `.synchronizable(true)` — that would push tokens to iCloud Keychain, making them accessible from other devices.

SwiftData and UserDefaults files are included in iCloud Backup. This is intentional — cart and preferences are non-sensitive and provide a better UX after a device restore.

---

## 7. App Size Monitoring

### Target and Thresholds

| Metric | Warning | Failure |
|--------|---------|---------|
| Android APK size | > 25 MB | > 30 MB |
| iOS IPA size | > 25 MB | > 30 MB |

### Android Optimization

R8 (`isMinifyEnabled = true`) and resource shrinking (`isShrinkResources = true`) are both enabled in release builds. These reduce APK size by removing unused code and resources.

Additional optimizations:

- Use WebP for all image assets in `res/drawable`. Convert with Android Studio's built-in converter (right-click drawable → Convert to WebP).
- Avoid bundling large font files — use Google Fonts or system fonts where possible.
- Check APK size after each significant dependency addition:

```bash
cd android
./gradlew assembleRelease
# Check: android/app/build/outputs/apk/release/app-release.apk
ls -lh android/app/build/outputs/apk/release/app-release.apk
```

### iOS Optimization

App thinning (slicing, bitcode, on-demand resources) is handled by App Store Connect automatically at distribution time. The IPA downloaded by a specific device is smaller than the archive.

For local size estimates:

```bash
cd ios
xcodebuild archive \
  -project MoltMarketplace.xcodeproj \
  -scheme MoltMarketplace \
  -configuration Release \
  -archivePath build/MoltMarketplace.xcarchive
# Check the .ipa produced from the archive
```

Image assets must use HEIC or asset catalog vector formats. Avoid PNG for large illustrations — use PDF vectors in the asset catalog.

### CI Size Check (Future)

Add a size check step to `.github/workflows/android-ci.yml` and `.github/workflows/ios-ci.yml` after the build job:

```yaml
# Android — warn if APK > 25 MB, fail if > 30 MB
- name: Check APK size
  run: |
    SIZE=$(stat -c%s android/app/build/outputs/apk/release/app-release.apk)
    echo "APK size: $((SIZE / 1024 / 1024)) MB"
    if [ $SIZE -gt 31457280 ]; then echo "FAIL: APK exceeds 30 MB" && exit 1; fi
    if [ $SIZE -gt 26214400 ]; then echo "WARN: APK exceeds 25 MB"; fi
```

---

## 8. Dependency Security

### Dependency Update Policy

| Update type | Policy |
|-------------|--------|
| Patch (x.y.Z) | Apply immediately — no changelog review required |
| Minor (x.Y.z) | Apply after reviewing "What's New" in release notes |
| Major (X.y.z) | Review changelog and migration guide; test thoroughly |

Pin major versions in `libs.versions.toml` (Android) and `Package.resolved` (iOS). Allow minor and patch updates to flow in via automated PRs (Dependabot or Renovate).

### Vulnerability Scanning

Enable Dependabot for the repository in GitHub Settings > Security > Dependabot. It will open PRs for known CVEs in direct and transitive dependencies.

For manual checks:

```bash
# Android — check for known vulnerabilities using OWASP Dependency Check
cd android
./gradlew dependencyCheckAnalyze

# iOS — check for vulnerabilities in SPM packages
# (No built-in tool — rely on GitHub Advisory Database via Dependabot)
```

### Reviewing Dependency Changes

Before merging a dependency update PR:

1. Read the library changelog for the upgraded range.
2. Check that the library has not changed its data collection or permissions.
3. Verify no new `android.permission.*` entries appear in the merged manifest after the update.
4. Run the full test suite and a manual smoke test on both platforms.

---

## Related Files

| File | Purpose |
|------|---------|
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/build.gradle.kts` | R8 config: `isMinifyEnabled`, `isShrinkResources`, `proguardFiles` |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/proguard-rules.pro` | Current ProGuard/R8 keep rules |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/res/xml/network_security_config.xml` | HTTPS enforcement, debug user CAs |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/app/src/main/AndroidManifest.xml` | `networkSecurityConfig`, `allowBackup`, `dataExtractionRules` attributes |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/android/gradle/libs.versions.toml` | `tink = "1.16.0"`, `datastore = "1.1.4"`, `timber = "5.0.1"` |
| `/Users/atakan/Documents/GitHub/atknatk/molt-mobile/ios/MoltMarketplace/Config.swift` | API base URLs per environment |
| `shared/feature-specs/auth-infrastructure.md` | Full auth token storage specification |
| `docs/guides/local-storage.md` | Encrypted DataStore + Keychain implementation details |
