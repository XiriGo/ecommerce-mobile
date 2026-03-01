# Push Notifications Guide

**Scope**: XiriGo Ecommerce Mobile Buyer App — Android + iOS
**Last Updated**: 2026-02-20

This guide covers the complete push notification infrastructure for the XiriGo Ecommerce mobile buyer app. Firebase Cloud Messaging (FCM) handles delivery for both platforms: directly on Android and via APNs relay on iOS.

---

## 1. Architecture Overview

```
Backend (Medusa)
       │
       ▼
Firebase Cloud Messaging (FCM)
       │
       ├──────────────────────┐
       ▼                      ▼
Android Device           APNs (Apple Push
(direct FCM)             Notification service)
                               │
                               ▼
                          iOS Device
```

### Token Registration Flow

```
App Launch / Login
       │
       ▼
FCM SDK generates token
       │
       ▼
App sends token to backend
  POST /store/customers/me/push-token
  { "token": "fcm_token_string", "platform": "android" | "ios" }
       │
       ▼
Backend stores token per device
(multiple tokens per customer — all devices active)
```

### Token Refresh Flow

When FCM rotates the device token (OS security rotation, app reinstall, factory reset), the SDK delivers the new token via a callback. The app must re-register with the backend immediately.

### Multi-Device Policy

Each device has its own FCM token. The backend stores all active tokens per customer. A single order status change triggers a notification to every registered device for that customer. No session limit is enforced — see `CLAUDE.md` Session Management section.

---

## 2. Android FCM Setup

### Dependency

`firebase-messaging-ktx` is already declared in the Firebase BOM block in `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/app/build.gradle.kts`:

```kotlin
implementation(platform(libs.firebase.bom))   // BOM: 33.8.0
implementation(libs.firebase.messaging)        // firebase-messaging-ktx
```

### Service Class

Create `XGFirebaseMessagingService` extending `FirebaseMessagingService`:

**File**: `android/app/src/main/java/com/xirigo/ecommerce/core/notification/XGFirebaseMessagingService.kt`

```kotlin
package com.xirigo.ecommerce.core.notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.xirigo.ecommerce.MainActivity
import com.xirigo.ecommerce.R
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class XGFirebaseMessagingService : FirebaseMessagingService() {

    @Inject
    lateinit var pushTokenRepository: PushTokenRepository

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Timber.d("FCM token refreshed")
        // Re-register token with backend — fire-and-forget via coroutine scope
        pushTokenRepository.registerToken(token)
    }

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        Timber.d("FCM message received: type=${message.data["type"]}")

        val title = message.notification?.title ?: message.data["title"] ?: return
        val body = message.notification?.body ?: message.data["body"] ?: return
        val deepLink = message.data["deep_link"]
        val type = message.data["type"] ?: NotificationType.ORDER_STATUS

        showNotification(
            title = title,
            body = body,
            deepLink = deepLink,
            channelId = resolveChannelId(type),
        )
    }

    private fun resolveChannelId(type: String): String = when (type) {
        NotificationType.ORDER_STATUS -> NotificationChannels.ORDER_UPDATES
        NotificationType.PROMOTION -> NotificationChannels.PROMOTIONS
        NotificationType.PRICE_ALERT -> NotificationChannels.PROMOTIONS
        else -> NotificationChannels.ORDER_UPDATES
    }

    private fun showNotification(
        title: String,
        body: String,
        deepLink: String?,
        channelId: String,
    ) {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
            deepLink?.let { putExtra(EXTRA_DEEP_LINK, it) }
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setPriority(
                if (channelId == NotificationChannels.ORDER_UPDATES)
                    NotificationCompat.PRIORITY_HIGH
                else
                    NotificationCompat.PRIORITY_DEFAULT
            )
            .build()

        NotificationManagerCompat.from(this)
            .notify(System.currentTimeMillis().toInt(), notification)
    }

    companion object {
        const val EXTRA_DEEP_LINK = "deep_link"
    }
}

object NotificationType {
    const val ORDER_STATUS = "order_status"
    const val PROMOTION = "promotion"
    const val PRICE_ALERT = "price_alert"
}
```

### Notification Channels

Create channels at app startup (safe to call multiple times — no-op if already created):

**File**: `android/app/src/main/java/com/xirigo/ecommerce/core/notification/NotificationChannels.kt`

```kotlin
package com.xirigo.ecommerce.core.notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

object NotificationChannels {
    const val ORDER_UPDATES = "order_updates"
    const val PROMOTIONS = "promotions"

    fun createAll(context: Context) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as NotificationManager

        NotificationChannel(
            ORDER_UPDATES,
            context.getString(R.string.notification_channel_order_updates_name),
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = context.getString(
                R.string.notification_channel_order_updates_description
            )
            manager.createNotificationChannel(this)
        }

        NotificationChannel(
            PROMOTIONS,
            context.getString(R.string.notification_channel_promotions_name),
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = context.getString(
                R.string.notification_channel_promotions_description
            )
            manager.createNotificationChannel(this)
        }
    }
}
```

Call `NotificationChannels.createAll(this)` from `XGApplication.onCreate()`.

### AndroidManifest.xml Registration

The `POST_NOTIFICATIONS` permission is already declared in `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Add the service inside `<application>`:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<service
    android:name=".core.notification.XGFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>

<!-- Default notification icon and color used by FCM display notifications -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/notification_color" />
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="order_updates" />
```

---

## 3. iOS APNs Setup

### Push Notifications Capability

In Xcode:

1. Select the **XiriGoEcommerce** target.
2. Go to the **Signing & Capabilities** tab.
3. Click **+ Capability** and add **Push Notifications**.
4. Also add **Background Modes** and enable **Remote notifications** (required for silent pushes and background token refresh).

This adds the necessary entitlements to `XiriGoEcommerce.entitlements`.

### SPM Dependency

`FirebaseMessaging` is already declared in `ios/Package.swift` under the Firebase Apple SDK umbrella. No additional package is needed.

### AppDelegate Setup

The app uses SwiftUI `@main`. Add an `AppDelegate` adaptor to handle push notification callbacks:

**File**: `ios/XiriGoEcommerce/AppDelegate.swift`

```swift
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Forward APNs token to FCM SDK — FCM translates it to an FCM token
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // Log but do not crash — push is non-critical on first launch
        print("[Push] APNs registration failed: \(error.localizedDescription)")
    }
}
```

Update `XiriGoEcommerceApp.swift` to attach the delegate:

```swift
// ios/XiriGoEcommerce/XiriGoEcommerceApp.swift
import SwiftUI

@main
struct XiriGoEcommerceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### FCM Token Refresh Delegate

```swift
// ios/XiriGoEcommerce/AppDelegate.swift (extension)
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("[Push] FCM token refreshed")
        // Send updated token to backend
        Task {
            try? await Container.shared.pushTokenRepository().registerToken(token, platform: .ios)
        }
    }
}
```

### Foreground Notification Delegate

```swift
// ios/XiriGoEcommerce/AppDelegate.swift (extension)
extension AppDelegate: UNUserNotificationCenterDelegate {

    // Called when a notification arrives while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let type = notification.request.content.userInfo["type"] as? String
        if type == "order_status" {
            // Show system notification for order updates even when foregrounded
            completionHandler([.banner, .sound, .badge])
        } else {
            // Suppress system notification for promotions — show in-app banner instead
            completionHandler([])
            NotificationCenter.default.post(
                name: .inAppNotificationReceived,
                object: notification.request.content.userInfo
            )
        }
    }

    // Called when the user taps a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let deepLink = userInfo["deep_link"] as? String,
           let url = URL(string: deepLink) {
            DeepLinkParser.handle(url: url)
        }
        completionHandler()
    }
}
```

---

## 4. Permission Request Flow

### Key Principle

Do not request notification permission on first launch. The system prompt appears once — if the user denies it, re-prompting is impossible without a manual trip to Settings. Ask at a moment when the user understands the value.

### Appropriate Moments

| Trigger | Rationale |
|---------|-----------|
| After first order placed | User just transacted — order updates are immediately relevant |
| Order detail screen | User is actively interested in order status |
| Settings screen (opt-in toggle) | Explicit user intent |
| Post-login (not at login) | User is engaged, not just entering credentials |

### Pre-Prompt Dialog

Show an explanation dialog before the OS permission prompt. If the user taps "Not now" on the pre-prompt, skip the OS prompt entirely (it will not be wasted).

**Android**:

```kotlin
// In a Composable or Fragment — show before calling requestPermissionLauncher
@Composable
fun NotificationPermissionRationale(
    onConfirm: () -> Unit,
    onDismiss: () -> Unit,
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(stringResource(R.string.notification_permission_title)) },
        text = { Text(stringResource(R.string.notification_permission_rationale)) },
        confirmButton = {
            XGButton(
                text = stringResource(R.string.notification_permission_enable),
                onClick = onConfirm,
            )
        },
        dismissButton = {
            XGButton(
                text = stringResource(R.string.common_cancel_button),
                onClick = onDismiss,
                style = XGButtonStyle.Text,
            )
        },
    )
}
```

**Android 13+ (API 33) — Runtime Permission**:

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/notification/NotificationPermissionHelper.kt
import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.*
import androidx.core.content.ContextCompat

@Composable
fun rememberNotificationPermissionState(): NotificationPermissionState {
    val context = LocalContext.current
    var hasPermission by remember {
        mutableStateOf(
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.POST_NOTIFICATIONS
                ) == PackageManager.PERMISSION_GRANTED
            } else {
                true // Always granted below API 33
            }
        )
    }

    val launcher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        hasPermission = granted
        if (!granted) {
            // Log that user denied — do not ask again until next session
            Timber.d("Notification permission denied by user")
        }
    }

    return NotificationPermissionState(
        hasPermission = hasPermission,
        requestPermission = {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                launcher.launch(Manifest.permission.POST_NOTIFICATIONS)
            }
        },
    )
}

data class NotificationPermissionState(
    val hasPermission: Boolean,
    val requestPermission: () -> Unit,
)
```

**iOS**:

```swift
// ios/XiriGoEcommerce/Core/Notification/NotificationPermissionManager.swift
import UserNotifications
import UIKit

@MainActor
final class NotificationPermissionManager {

    static let shared = NotificationPermissionManager()
    private init() {}

    var hasPermission: Bool {
        get async {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            return settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
        }
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            return granted
        } catch {
            return false
        }
    }

    /// Open iOS Settings for the app so the user can manually enable notifications.
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
```

### Handling Denial

- Do not show the permission request again in the same session after a denial.
- Show a non-blocking settings prompt: "Enable notifications in Settings to get order updates." with a "Open Settings" button.
- **Android**: Use `shouldShowRequestPermissionRationale()` to detect permanent denial (user tapped "Don't ask again"). If `true`, skip the OS prompt and show the settings deep link instead.
- **iOS**: After denial, `requestAuthorization` returns `false`. Show the settings link.

---

## 5. Notification Payload Schema

The backend sends a mixed notification + data payload. Both `notification` and `data` fields are always present. This ensures FCM displays a system notification when the app is killed (using `notification`) while the app can also access structured data for navigation (using `data`).

```json
{
  "notification": {
    "title": "Order Shipped!",
    "body": "Your order #1234 has been shipped."
  },
  "data": {
    "type": "order_status",
    "order_id": "ord_abc123",
    "deep_link": "xirigo://order/ord_abc123"
  }
}
```

### Field Definitions

| Field | Required | Description |
|-------|----------|-------------|
| `notification.title` | Yes | Displayed in system notification |
| `notification.body` | Yes | Displayed in system notification |
| `data.type` | Yes | One of `order_status`, `promotion`, `price_alert` |
| `data.order_id` | Conditional | Present when `type` = `order_status` |
| `data.deep_link` | Yes | Deep link URI for tap navigation |

---

## 6. Notification Types

| Type | Channel (Android) | Title Example | Body Example | Deep Link |
|------|-------------------|--------------|--------------|-----------|
| `order_status` | `order_updates` | "Order Confirmed" | "Your order #1234 has been confirmed." | `xirigo://order/{order_id}` |
| `order_status` | `order_updates` | "Order Shipped!" | "Your order #1234 has been shipped." | `xirigo://order/{order_id}` |
| `order_status` | `order_updates` | "Order Delivered" | "Your order #1234 has been delivered." | `xirigo://order/{order_id}` |
| `promotion` | `promotions` | "Flash Sale!" | "50% off all electronics today." | `xirigo://category/{category_id}` |
| `price_alert` | `promotions` | "Price Drop!" | "Product X is now EUR 29.99" | `xirigo://product/{product_id}` |

### Order Status Progression

```
order_placed → order_confirmed → payment_captured → fulfillment_created
    → shipment_created → delivered → (optionally) return_requested
```

Each step except `order_placed` (handled in-app after checkout) triggers a push notification.

---

## 7. Deep Link Integration

Notification tap extracts `deep_link` from the data payload and routes to the appropriate screen using the navigation infrastructure defined in M0-04.

### Deep Link Scheme

| Scheme | Example | Target Screen |
|--------|---------|---------------|
| `xirigo://order/{order_id}` | `xirigo://order/ord_abc123` | Order Detail |
| `xirigo://product/{product_id}` | `xirigo://product/prod_xyz` | Product Detail |
| `xirigo://category/{category_id}` | `xirigo://category/electronics` | Category / Product List |
| `xirigo://home` | `xirigo://home` | Home tab |

### Android — Handling Tap (Cold Start + Warm Start)

FCM delivers the tap intent to `MainActivity`. Extract the deep link from the intent extras:

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/MainActivity.kt
override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    handleNotificationDeepLink(intent)
}

override fun onCreate(savedInstanceState: Bundle?) {
    // ... existing setup ...
    handleNotificationDeepLink(intent)
}

private fun handleNotificationDeepLink(intent: Intent) {
    val deepLink = intent.getStringExtra(XGFirebaseMessagingService.EXTRA_DEEP_LINK)
        ?: return
    val url = Uri.parse(deepLink)
    // Pass to DeepLinkParser — defined in core/navigation/ per M0-04 spec
    val route = DeepLinkParser.parse(url) ?: return
    navController.navigate(route)
}
```

**Cold start** (app killed): The `PendingIntent` in `XGFirebaseMessagingService` launches `MainActivity` with the deep link extra. `onCreate` picks it up.

**Warm start** (app backgrounded): `onNewIntent` is called. The activity is reused due to `FLAG_ACTIVITY_SINGLE_TOP`.

### iOS — Handling Tap

The `UNUserNotificationCenterDelegate.didReceive` callback (in `AppDelegate`) calls `DeepLinkParser.handle(url:)` which posts a URL to `AppRouter` (defined in `Core/Navigation/` per M0-04 spec):

```swift
// ios/XiriGoEcommerce/Core/Navigation/DeepLinkParser.swift
enum DeepLinkParser {
    static func handle(url: URL) {
        guard url.scheme == "xirigo" else { return }
        NotificationCenter.default.post(
            name: .deepLinkReceived,
            object: url
        )
    }
}
```

`AppRouter` (M0-04) observes `deepLinkReceived` and calls `navigate(to:)` on the appropriate tab's `NavigationPath`.

**Cold start** (app killed via notification tap): `UIApplication.open(_:options:completionHandler:)` is called before `didReceive`. `AppRouter` observes the URL after `body` is set up.

---

## 8. Foreground vs. Background Handling

| App State | Android | iOS |
|-----------|---------|-----|
| **Foreground** | `onMessageReceived` called. Show in-app banner for `promotion` / `price_alert`. Show system notification for `order_status`. | `willPresent` delegate called. Present system notification for `order_status`. Post `inAppNotificationReceived` for others. |
| **Background** | FCM SDK shows system notification automatically using `notification` payload. `onMessageReceived` is NOT called for display messages. | APNs shows system notification automatically. No app code runs. |
| **Killed** | FCM SDK shows system notification automatically. On tap, `MainActivity.onCreate` called with deep link in intent. | APNs shows system notification automatically. On tap, `AppDelegate.didReceive` called with deep link. |

### In-App Banner

For foreground promotional notifications, show a non-disruptive in-app banner using `XGBadge` or a custom overlay. The banner appears at the top of the current screen for ~3 seconds and taps through to the deep link.

```kotlin
// Android — collect in a LaunchedEffect at the root composable level
LaunchedEffect(Unit) {
    inAppNotificationFlow.collect { notification ->
        // Show snackbar or custom banner with notification.title
    }
}
```

```swift
// iOS — observe NSNotification posted by AppDelegate
.onReceive(NotificationCenter.default.publisher(for: .inAppNotificationReceived)) { note in
    guard let userInfo = note.object as? [AnyHashable: Any] else { return }
    // Show in-app banner with userInfo["title"]
}
```

---

## 9. In-App Badge Management

### Badge Count Storage

The unread notification count is stored locally on device:

- **Android**: `DataStore<Preferences>` (key: `notification_unread_count`)
- **iOS**: `UserDefaults` (key: `notification_unread_count`)

### Badge Display

The count is shown on the Profile tab using `XGBadge`:

```kotlin
// Android — Profile tab in XGBottomBar
XGBadge(count = notificationUnreadCount) {
    Icon(Icons.Outlined.Person, contentDescription = null)
}
```

```swift
// iOS — Profile tab in MainTabView (M0-04)
.badge(notificationUnreadCount)
```

### Increment / Clear Rules

| Event | Action |
|-------|--------|
| New notification received (foreground or background tap) | Increment local count by 1 |
| Profile tab becomes visible | Clear local count to 0 |
| Notification center screen opened | Clear local count to 0 |
| Logout | Clear local count to 0 |

### iOS App Badge Number

Sync the app icon badge number with the local count:

```swift
// ios/XiriGoEcommerce/Core/Notification/BadgeManager.swift
import UIKit
import UserNotifications

@MainActor
final class BadgeManager {
    static let shared = BadgeManager()

    func set(count: Int) {
        UserDefaults.standard.set(count, forKey: "notification_unread_count")
        UNUserNotificationCenter.current().setBadgeCount(count) { _ in }
    }

    func clear() { set(count: 0) }
    func increment() { set(count: current + 1) }

    var current: Int {
        UserDefaults.standard.integer(forKey: "notification_unread_count")
    }
}
```

---

## 10. Token Lifecycle

### Registration Flow

```
Login success
    │
    ▼
FirebaseMessaging.getInstance().token (Android)
Messaging.messaging().token (iOS)
    │
    ▼
POST /store/customers/me/push-token
{ "token": "...", "platform": "android" | "ios" }
```

**Android**:

```kotlin
// Called after login success — in AuthViewModel or SessionRepository
FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
    if (task.isSuccessful) {
        val token = task.result
        pushTokenRepository.registerToken(token)
    }
}
```

**iOS**:

```swift
// Called after login success — in AuthViewModel or SessionRepository
let token = try await Messaging.messaging().token()
try await pushTokenRepository.registerToken(token, platform: .ios)
```

### Token Refresh

The SDK calls `onNewToken` (Android) / `messaging(_:didReceiveRegistrationToken:)` (iOS) when the token changes. These callbacks call `pushTokenRepository.registerToken()` automatically — no additional code needed in feature modules.

### Logout

On logout, remove the token from the backend and optionally unsubscribe from all FCM topics:

**Android**:

```kotlin
// In LogoutUseCase or AuthRepositoryImpl
suspend fun logout() {
    pushTokenRepository.deleteToken()          // DELETE /store/customers/me/push-token
    FirebaseMessaging.getInstance().deleteToken().await()  // Invalidate local token
    // clear auth tokens from DataStore ...
}
```

**iOS**:

```swift
// In LogoutUseCase or AuthRepositoryImpl
func logout() async throws {
    try await pushTokenRepository.deleteToken()  // DELETE /store/customers/me/push-token
    Messaging.messaging().deleteToken { _ in }   // Invalidate local token
    // clear auth tokens from Keychain ...
}
```

### Backend API Endpoints

| Method | Path | Body | Purpose |
|--------|------|------|---------|
| `POST` | `/store/customers/me/push-token` | `{ "token": "...", "platform": "android"\|"ios" }` | Register or update token |
| `DELETE` | `/store/customers/me/push-token` | `{ "token": "..." }` | Remove token on logout |

These endpoints require an authenticated customer session (Bearer token in Authorization header).

### Token Storage on Backend

The backend stores `(customer_id, token, platform, updated_at)`. On sending a notification, it fans out to all active tokens for the customer. Stale tokens (returning FCM `Registration-Id-Not-Found` errors) are removed automatically.

---

## 11. Related Files

| File | Purpose |
|------|---------|
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/app/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS` permission (already present), service registration |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/app/build.gradle.kts` | `firebase-messaging-ktx` dependency (already present) |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/gradle/libs.versions.toml` | Firebase BOM `33.8.0`, messaging artifact alias |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/app/src/main/java/com/xirigo/ecommerce/MainActivity.kt` | Deep link handling on notification tap |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/XiriGoEcommerceApp.swift` | `@UIApplicationDelegateAdaptor(AppDelegate.self)` attachment |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/Config.swift` | `bundleVersion` used in force-update checks |
| `ios/XiriGoEcommerce/AppDelegate.swift` | APNs / FCM delegate setup (to be created) |
| `android/app/src/main/java/com/xirigo/ecommerce/core/notification/XGFirebaseMessagingService.kt` | FCM service (to be created) |
| `android/app/src/main/java/com/xirigo/ecommerce/core/notification/NotificationChannels.kt` | Channel creation (to be created) |
| `ios/XiriGoEcommerce/Core/Notification/NotificationPermissionManager.swift` | Permission request logic (to be created) |
| `ios/XiriGoEcommerce/Core/Notification/BadgeManager.swift` | Badge count management (to be created) |

### Related Guides

| Guide | Path |
|-------|------|
| Firebase Setup | `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/docs/guides/firebase-setup.md` |
| Device Support | `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/docs/guides/device-support.md` |
| Navigation Spec | `shared/feature-specs/navigation.md` (M0-04) |
