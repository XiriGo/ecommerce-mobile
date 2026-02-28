# Local Storage Guide

**Scope**: XiriGo Ecommerce Mobile Buyer App — Android + iOS
**Last Updated**: 2026-02-20

This guide covers every storage layer used in the XiriGo Ecommerce mobile app. It is a platform infrastructure reference for developers implementing any feature that reads from or writes to local storage.

---

## 1. Storage Layers Overview

The app uses four distinct storage layers. Each has a specific purpose and must not be misused (e.g., do not store auth tokens in UserDefaults, do not store preferences in Room).

| Layer | Android | iOS | Use Case |
|-------|---------|-----|----------|
| Key-Value | Proto DataStore | UserDefaults | App preferences: theme, onboarding seen, notification opt-in |
| Encrypted K-V | Proto DataStore + Google Tink | KeychainAccess | Auth tokens: access token, refresh token, token expiry |
| Structured DB | Room 2.7.1 | SwiftData | Cart, wishlist, recent searches, recently viewed |
| HTTP Cache | OkHttp Cache (10 MB) | URLCache (10 MB mem / 50 MB disk) | API response caching for product lists, categories |

### Library Versions

| Library | Android | iOS |
|---------|---------|-----|
| DataStore | `1.1.4` | — |
| Google Tink | `1.16.0` | — |
| Room | `2.7.1` | — |
| KeychainAccess | — | `4.2.2` (SPM) |
| SwiftData | — | Built-in (iOS 17+) |
| OkHttp | `5.0.0-alpha.14` | — |
| URLCache | — | Built-in (Foundation) |

Declared in:
- Android: `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/gradle/libs.versions.toml`
- iOS: `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/Core/DI/Container+Extensions.swift`

---

## 2. Room Schema (Android)

### Database Configuration

Room is configured with a single `AppDatabase` class. Use `fallbackToDestructiveMigration()` during development; replace with explicit `Migration` classes before the first public release (see Section 8).

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/database/AppDatabase.kt
@Database(
    entities = [
        CartItemEntity::class,
        WishlistItemEntity::class,
        RecentSearchEntity::class,
        RecentlyViewedEntity::class,
    ],
    version = 1,
    exportSchema = true,
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun cartItemDao(): CartItemDao
    abstract fun wishlistItemDao(): WishlistItemDao
    abstract fun recentSearchDao(): RecentSearchDao
    abstract fun recentlyViewedDao(): RecentlyViewedDao
}
```

Database location: internal storage under the app's data directory, not accessible to other apps.

### Entity Definitions

#### CartItemEntity

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/database/entity/CartItemEntity.kt
@Entity(tableName = "cart_items")
data class CartItemEntity(
    @PrimaryKey val id: String,               // Medusa line item ID
    val productId: String,
    val variantId: String,
    val title: String,
    val thumbnail: String?,
    val quantity: Int,
    val unitPrice: Long,                      // Amount in cents (EUR)
    val createdAt: Long,                      // Unix epoch milliseconds
)
```

#### WishlistItemEntity

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/database/entity/WishlistItemEntity.kt
@Entity(tableName = "wishlist_items")
data class WishlistItemEntity(
    @PrimaryKey val id: String,               // Local UUID (no backend)
    val productId: String,
    val title: String,
    val thumbnail: String?,
    val price: Long,                          // Amount in cents (EUR)
    val vendorName: String?,
    val addedAt: Long,                        // Unix epoch milliseconds
)
```

#### RecentSearchEntity

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/database/entity/RecentSearchEntity.kt
@Entity(tableName = "recent_searches")
data class RecentSearchEntity(
    @PrimaryKey val id: String,               // Local UUID
    val query: String,
    val timestamp: Long,                      // Unix epoch milliseconds
)
```

#### RecentlyViewedEntity

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/database/entity/RecentlyViewedEntity.kt
@Entity(tableName = "recently_viewed")
data class RecentlyViewedEntity(
    @PrimaryKey val id: String,               // Local UUID
    val productId: String,
    val title: String,
    val thumbnail: String?,
    val price: Long,                          // Amount in cents (EUR)
    val viewedAt: Long,                       // Unix epoch milliseconds
)
```

### DAO Interfaces

#### CartItemDao

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/database/dao/CartItemDao.kt
@Dao
interface CartItemDao {
    @Query("SELECT * FROM cart_items ORDER BY createdAt ASC")
    fun observeAll(): Flow<List<CartItemEntity>>

    @Query("SELECT * FROM cart_items WHERE id = :id")
    suspend fun findById(id: String): CartItemEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: CartItemEntity)

    @Query("UPDATE cart_items SET quantity = :quantity WHERE id = :id")
    suspend fun updateQuantity(id: String, quantity: Int)

    @Query("DELETE FROM cart_items WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("DELETE FROM cart_items")
    suspend fun deleteAll()

    @Query("SELECT SUM(quantity * unitPrice) FROM cart_items")
    fun observeTotal(): Flow<Long?>
}
```

#### WishlistItemDao

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/database/dao/WishlistItemDao.kt
@Dao
interface WishlistItemDao {
    @Query("SELECT * FROM wishlist_items ORDER BY addedAt DESC")
    fun observeAll(): Flow<List<WishlistItemEntity>>

    @Query("SELECT EXISTS(SELECT 1 FROM wishlist_items WHERE productId = :productId)")
    fun observeIsWishlisted(productId: String): Flow<Boolean>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(item: WishlistItemEntity)

    @Query("DELETE FROM wishlist_items WHERE productId = :productId")
    suspend fun deleteByProductId(productId: String)

    @Query("DELETE FROM wishlist_items")
    suspend fun deleteAll()
}
```

#### RecentSearchDao

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/database/dao/RecentSearchDao.kt
@Dao
interface RecentSearchDao {
    @Query("SELECT * FROM recent_searches ORDER BY timestamp DESC LIMIT 10")
    fun observeAll(): Flow<List<RecentSearchEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(item: RecentSearchEntity)

    @Query("DELETE FROM recent_searches WHERE id NOT IN (SELECT id FROM recent_searches ORDER BY timestamp DESC LIMIT 10)")
    suspend fun trimToLimit()

    @Query("DELETE FROM recent_searches WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("DELETE FROM recent_searches")
    suspend fun deleteAll()
}
```

#### RecentlyViewedDao

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/database/dao/RecentlyViewedDao.kt
@Dao
interface RecentlyViewedDao {
    @Query("SELECT * FROM recently_viewed ORDER BY viewedAt DESC LIMIT 50")
    fun observeAll(): Flow<List<RecentlyViewedEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: RecentlyViewedEntity)

    @Query("DELETE FROM recently_viewed WHERE id NOT IN (SELECT id FROM recently_viewed ORDER BY viewedAt DESC LIMIT 50)")
    suspend fun trimToLimit()

    @Query("DELETE FROM recently_viewed WHERE viewedAt < :cutoffMillis")
    suspend fun deleteOlderThan(cutoffMillis: Long)

    @Query("DELETE FROM recently_viewed")
    suspend fun deleteAll()
}
```

### Hilt Module

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/di/DatabaseModule.kt
@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideAppDatabase(@ApplicationContext context: Context): AppDatabase =
        Room.databaseBuilder(context, AppDatabase::class.java, "xg_ecommerce.db")
            .fallbackToDestructiveMigration()   // development only — replace before release
            .build()

    @Provides fun provideCartItemDao(db: AppDatabase): CartItemDao = db.cartItemDao()
    @Provides fun provideWishlistItemDao(db: AppDatabase): WishlistItemDao = db.wishlistItemDao()
    @Provides fun provideRecentSearchDao(db: AppDatabase): RecentSearchDao = db.recentSearchDao()
    @Provides fun provideRecentlyViewedDao(db: AppDatabase): RecentlyViewedDao = db.recentlyViewedDao()
}
```

---

## 3. SwiftData Schema (iOS)

### ModelContainer Configuration

Configure the container once at the app entry point. All models are registered together.

```swift
// ios/XiriGoEcommerce/XiriGoEcommerceApp.swift
import SwiftUI
import SwiftData

@main
struct XiriGoEcommerceApp: App {

    private let modelContainer: ModelContainer = {
        let schema = Schema([
            CartItem.self,
            WishlistItem.self,
            RecentSearch.self,
            RecentlyViewed.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // In development: crash early to surface schema errors.
            // In production: fall back to in-memory store to avoid blocking the user.
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
```

### Model Definitions

#### CartItem

```swift
// ios/XiriGoEcommerce/Core/Database/CartItem.swift
import SwiftData
import Foundation

@Model
final class CartItem {
    @Attribute(.unique) var id: String      // Medusa line item ID
    var productId: String
    var variantId: String
    var title: String
    var thumbnail: String?
    var quantity: Int
    var unitPrice: Int                      // Amount in cents (EUR)
    var createdAt: Date

    init(
        id: String,
        productId: String,
        variantId: String,
        title: String,
        thumbnail: String? = nil,
        quantity: Int,
        unitPrice: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.productId = productId
        self.variantId = variantId
        self.title = title
        self.thumbnail = thumbnail
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.createdAt = createdAt
    }
}
```

#### WishlistItem

```swift
// ios/XiriGoEcommerce/Core/Database/WishlistItem.swift
import SwiftData
import Foundation

@Model
final class WishlistItem {
    @Attribute(.unique) var id: String      // Local UUID (no backend)
    @Attribute(.unique) var productId: String
    var title: String
    var thumbnail: String?
    var price: Int                          // Amount in cents (EUR)
    var vendorName: String?
    var addedAt: Date

    init(
        id: String = UUID().uuidString,
        productId: String,
        title: String,
        thumbnail: String? = nil,
        price: Int,
        vendorName: String? = nil,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.productId = productId
        self.title = title
        self.thumbnail = thumbnail
        self.price = price
        self.vendorName = vendorName
        self.addedAt = addedAt
    }
}
```

#### RecentSearch

```swift
// ios/XiriGoEcommerce/Core/Database/RecentSearch.swift
import SwiftData
import Foundation

@Model
final class RecentSearch {
    @Attribute(.unique) var id: String      // Local UUID
    var query: String
    var timestamp: Date

    init(id: String = UUID().uuidString, query: String, timestamp: Date = Date()) {
        self.id = id
        self.query = query
        self.timestamp = timestamp
    }
}
```

#### RecentlyViewed

```swift
// ios/XiriGoEcommerce/Core/Database/RecentlyViewed.swift
import SwiftData
import Foundation

@Model
final class RecentlyViewed {
    @Attribute(.unique) var id: String      // Local UUID
    @Attribute(.unique) var productId: String
    var title: String
    var thumbnail: String?
    var price: Int                          // Amount in cents (EUR)
    var viewedAt: Date

    init(
        id: String = UUID().uuidString,
        productId: String,
        title: String,
        thumbnail: String? = nil,
        price: Int,
        viewedAt: Date = Date()
    ) {
        self.id = id
        self.productId = productId
        self.title = title
        self.thumbnail = thumbnail
        self.price = price
        self.viewedAt = viewedAt
    }
}
```

### Querying SwiftData Models

Use `@Query` in SwiftUI views or `ModelContext` in repositories. All database access must happen on the main actor or via a background `ModelContext`.

```swift
// In a SwiftUI view
@Query(sort: \CartItem.createdAt) private var cartItems: [CartItem]

// In a repository (background context)
@MainActor
func fetchCart(context: ModelContext) throws -> [CartItem] {
    let descriptor = FetchDescriptor<CartItem>(
        sortBy: [SortDescriptor(\.createdAt)]
    )
    return try context.fetch(descriptor)
}
```

---

## 4. Key-Value Storage Patterns

### Proto DataStore (Android)

Proto DataStore is type-safe and async. It replaces `SharedPreferences` for all preference storage. The `datastore` artifact (`1.1.4`) is already declared in `libs.versions.toml`.

**Do not use** `DataStore<Preferences>` (`datastore-preferences`) for anything that deserves a strongly-typed schema. Use the typed Proto DataStore instead.

#### Proto Schema

```protobuf
// android/app/src/main/proto/app_preferences.proto
syntax = "proto3";

option java_package = "com.xirigo.ecommerce.core.datastore";
option java_multiple_files = true;

message AppPreferences {
    bool onboarding_completed = 1;
    bool notifications_enabled = 2;
    string theme_preference = 3;     // "system" | "light" | "dark"
}
```

#### DataStore Singleton

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/datastore/AppPreferencesSerializer.kt
object AppPreferencesSerializer : Serializer<AppPreferences> {
    override val defaultValue: AppPreferences = AppPreferences.getDefaultInstance()
    override suspend fun readFrom(input: InputStream): AppPreferences =
        AppPreferences.parseFrom(input)
    override suspend fun writeTo(t: AppPreferences, output: OutputStream) =
        t.writeTo(output)
}

// android/app/src/main/java/com/xirigo/ecommerce/core/di/DataStoreModule.kt
@Module
@InstallIn(SingletonComponent::class)
object DataStoreModule {
    @Provides
    @Singleton
    fun provideAppPreferencesDataStore(
        @ApplicationContext context: Context,
    ): DataStore<AppPreferences> =
        DataStoreFactory.create(
            serializer = AppPreferencesSerializer,
            produceFile = { context.dataStoreFile("app_preferences.pb") },
        )
}
```

#### Reading and Writing

```kotlin
// Read — collect as Flow
val onboardingCompleted: Flow<Boolean> = dataStore.data
    .map { preferences -> preferences.onboardingCompleted }

// Write — update in a coroutine
suspend fun setOnboardingCompleted() {
    dataStore.updateData { current ->
        current.toBuilder().setOnboardingCompleted(true).build()
    }
}

// Write — theme preference
suspend fun setTheme(theme: String) {
    dataStore.updateData { current ->
        current.toBuilder().setThemePreference(theme).build()
    }
}
```

### UserDefaults (iOS)

Use `@AppStorage` for SwiftUI-bound values and `UserDefaults.standard` with a typed wrapper for non-SwiftUI access.

#### Settings Keys

```swift
// ios/XiriGoEcommerce/Core/Storage/AppStorageKeys.swift
enum AppStorageKey {
    static let onboardingCompleted = "onboarding_completed"
    static let notificationsEnabled = "notifications_enabled"
    static let themePreference = "theme_preference"      // "system" | "light" | "dark"
}
```

#### @AppStorage in SwiftUI

```swift
// In a SwiftUI view or @Observable ViewModel
@AppStorage(AppStorageKey.onboardingCompleted) var onboardingCompleted: Bool = false
@AppStorage(AppStorageKey.themePreference) var themePreference: String = "system"
```

#### Typed Wrapper for Non-SwiftUI Access

```swift
// ios/XiriGoEcommerce/Core/Storage/AppPreferences.swift
final class AppPreferences {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var onboardingCompleted: Bool {
        get { defaults.bool(forKey: AppStorageKey.onboardingCompleted) }
        set { defaults.set(newValue, forKey: AppStorageKey.onboardingCompleted) }
    }

    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: AppStorageKey.notificationsEnabled) }
        set { defaults.set(newValue, forKey: AppStorageKey.notificationsEnabled) }
    }

    var themePreference: String {
        get { defaults.string(forKey: AppStorageKey.themePreference) ?? "system" }
        set { defaults.set(newValue, forKey: AppStorageKey.themePreference) }
    }
}
```

---

## 5. Encrypted Storage

### Android: Proto DataStore + Google Tink

`EncryptedSharedPreferences` is deprecated as of API 23. The project uses **Google Tink** (`tink-android:1.16.0`) with Proto DataStore for auth token storage.

Tink provides AEAD (Authenticated Encryption with Associated Data) — the token bytes are both encrypted and integrity-protected.

```kotlin
// android/app/src/main/proto/auth_tokens.proto
syntax = "proto3";

option java_package = "com.xirigo.ecommerce.core.datastore";
option java_multiple_files = true;

message AuthTokens {
    string access_token = 1;
    string refresh_token = 2;
    int64 access_token_expiry_ms = 3;     // Unix epoch milliseconds
}
```

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/datastore/AuthTokenSerializer.kt
class AuthTokenSerializer(
    private val tinkEncryptor: TinkEncryptor,
) : Serializer<AuthTokens> {
    override val defaultValue: AuthTokens = AuthTokens.getDefaultInstance()

    override suspend fun readFrom(input: InputStream): AuthTokens {
        return try {
            val encryptedBytes = input.readBytes()
            val decryptedBytes = tinkEncryptor.decrypt(encryptedBytes)
            AuthTokens.parseFrom(decryptedBytes)
        } catch (e: Exception) {
            defaultValue
        }
    }

    override suspend fun writeTo(t: AuthTokens, output: OutputStream) {
        val plainBytes = t.toByteArray()
        val encryptedBytes = tinkEncryptor.encrypt(plainBytes)
        output.write(encryptedBytes)
    }
}

// android/app/src/main/java/com/xirigo/ecommerce/core/di/SecurityModule.kt
@Module
@InstallIn(SingletonComponent::class)
object SecurityModule {

    @Provides
    @Singleton
    fun provideTinkEncryptor(@ApplicationContext context: Context): TinkEncryptor {
        // Tink AES256-GCM key stored in Android Keystore
        val keysetHandle = AndroidKeysetManager.Builder()
            .withSharedPref(context, "xg_tink_keyset", "xg_tink_prefs")
            .withKeyTemplate(AeadKeyTemplates.AES256_GCM)
            .withMasterKeyUri("android-keystore://xg_master_key")
            .build()
            .keysetHandle
        val aead = keysetHandle.getPrimitive(Aead::class.java)
        return TinkEncryptor(aead)
    }

    @Provides
    @Singleton
    fun provideAuthTokensDataStore(
        @ApplicationContext context: Context,
        tinkEncryptor: TinkEncryptor,
    ): DataStore<AuthTokens> =
        DataStoreFactory.create(
            serializer = AuthTokenSerializer(tinkEncryptor),
            produceFile = { context.dataStoreFile("auth_tokens.pb.enc") },
        )
}
```

#### Reading and Writing Auth Tokens

```kotlin
// Read
val accessToken: Flow<String> = authTokensDataStore.data
    .map { tokens -> tokens.accessToken }

// Write (after successful login)
suspend fun saveTokens(accessToken: String, refreshToken: String, expiryMs: Long) {
    authTokensDataStore.updateData { current ->
        current.toBuilder()
            .setAccessToken(accessToken)
            .setRefreshToken(refreshToken)
            .setAccessTokenExpiryMs(expiryMs)
            .build()
    }
}

// Clear (on logout)
suspend fun clearTokens() {
    authTokensDataStore.updateData { AuthTokens.getDefaultInstance() }
}
```

### iOS: KeychainAccess

`KeychainAccess 4.2.2` wraps Apple's Keychain Services. It is declared as an SPM dependency in the iOS project.

```swift
// ios/XiriGoEcommerce/Core/Storage/AuthTokenStorage.swift
import KeychainAccess

final class AuthTokenStorage {
    private let keychain: Keychain

    // Keys
    private enum Key {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let accessTokenExpiry = "access_token_expiry"
    }

    init(service: String = "com.xirigo.ecommerce") {
        self.keychain = Keychain(service: service)
            .accessibility(.afterFirstUnlock)           // survives device reboot, excluded from iCloud backup
    }

    // MARK: - Access Token

    var accessToken: String? {
        get { try? keychain.get(Key.accessToken) }
        set {
            if let value = newValue {
                try? keychain.set(value, key: Key.accessToken)
            } else {
                try? keychain.remove(Key.accessToken)
            }
        }
    }

    // MARK: - Refresh Token

    var refreshToken: String? {
        get { try? keychain.get(Key.refreshToken) }
        set {
            if let value = newValue {
                try? keychain.set(value, key: Key.refreshToken)
            } else {
                try? keychain.remove(Key.refreshToken)
            }
        }
    }

    // MARK: - Token Expiry

    var accessTokenExpiry: Date? {
        get {
            guard let raw = try? keychain.get(Key.accessTokenExpiry),
                  let interval = TimeInterval(raw) else { return nil }
            return Date(timeIntervalSince1970: interval)
        }
        set {
            if let date = newValue {
                try? keychain.set(String(date.timeIntervalSince1970), key: Key.accessTokenExpiry)
            } else {
                try? keychain.remove(Key.accessTokenExpiry)
            }
        }
    }

    // MARK: - Convenience

    var hasValidToken: Bool {
        guard accessToken != nil,
              let expiry = accessTokenExpiry else { return false }
        return expiry > Date()
    }

    func clear() {
        try? keychain.removeAll()
    }
}
```

#### Factory Registration (iOS DI)

```swift
// ios/XiriGoEcommerce/Core/DI/Container+Extensions.swift
extension Container {
    var authTokenStorage: Factory<AuthTokenStorage> {
        self { AuthTokenStorage(service: "com.xirigo.ecommerce") }
            .singleton
    }
}
```

#### Keychain Accessibility Choice

`.afterFirstUnlock` is the correct accessibility level for auth tokens:
- Token is not available until the device is unlocked once after boot (prevents background-process abuse)
- Token remains available after the first unlock even when the screen is locked (required for background token refresh)
- Token is NOT included in iCloud backup (avoids token leakage across devices)

Do not use `.always` (no device-lock protection) or `.whenUnlocked` (breaks background token refresh).

---

## 6. Offline-First Patterns

All features that display data must function without a network connection by serving locally cached data.

| Feature | Strategy | Sync Behavior |
|---------|----------|---------------|
| Cart | Local-first; Room / SwiftData is the source of truth | POST changes to backend when network available |
| Wishlist | Local-only; no backend endpoint | No sync |
| Recent Searches | Local-only; cap at 10 items (FIFO) | No sync |
| Recently Viewed | Local-only; cap at 50 items, 30-day TTL | No sync |
| Product List | Network-first; OkHttp / URLCache serves stale data offline | Automatic via HTTP cache headers |
| Categories | Network-first; served from HTTP cache offline | Automatic via HTTP cache headers |

### Cart: Local-First with Backend Sync

The cart DAO is the single source of truth. The UI always reads from Room / SwiftData. Network calls run in the background and reconcile on success.

```
User Action (add/remove/update quantity)
    │
    ▼
Write to Room / SwiftData immediately
    │
    ▼
Emit updated cart state to UI
    │
    ▼
[Background] POST to backend
    ├── Success: update local cart item ID if backend assigns a new one
    └── Failure: keep local state, retry on next network availability
```

### HTTP Cache Configuration

#### Android (OkHttp)

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/network/NetworkModule.kt
val cacheDir = File(context.cacheDir, "http_cache")
val cache = Cache(cacheDir, maxSize = 10L * 1024L * 1024L) // 10 MB

OkHttpClient.Builder()
    .cache(cache)
    // Serve stale cache when offline (requires "Cache-Control: max-age" from backend)
    .addInterceptor { chain ->
        val request = if (isNetworkAvailable(context)) {
            chain.request()
        } else {
            chain.request().newBuilder()
                .header("Cache-Control", "public, only-if-cached, max-stale=${60 * 60 * 24}")
                .build()
        }
        chain.proceed(request)
    }
    .build()
```

#### iOS (URLCache)

```swift
// ios/XiriGoEcommerce/Core/Network/URLSessionConfiguration+App.swift
extension URLSessionConfiguration {
    static var appDefault: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,   // 10 MB memory
            diskCapacity: 50 * 1024 * 1024,      // 50 MB disk
            diskPath: "http_cache"
        )
        config.requestCachePolicy = .useProtocolCachePolicy
        return config
    }
}
```

Both platforms rely on `Cache-Control` headers from the Medusa backend to set TTL:
- Product lists: `Cache-Control: public, max-age=300` (5 minutes)
- Category lists: `Cache-Control: public, max-age=3600` (1 hour)

---

## 7. Data Retention and Cleanup

Cleanup runs at app launch and when items are written. Do not run cleanup on every read.

| Data | Retention Rule | Trigger |
|------|---------------|---------|
| Recent Searches | Max 10 items; oldest trimmed when 11th is inserted | After `insert()` |
| Recently Viewed | Max 50 items; items older than 30 days deleted | App launch + after `upsert()` |
| Cart | No time limit; persists until checkout or explicit clear | User action |
| Wishlist | No time limit; local-only | User action |
| HTTP Cache | 10 MB limit; LRU eviction by OkHttp / URLCache | Automatic |

### Android: Cleanup Helpers

```kotlin
// Trim recent searches to 10 items (call after insert)
recentSearchDao.trimToLimit()

// Delete recently viewed items older than 30 days (call on app launch)
val thirtyDaysAgo = System.currentTimeMillis() - (30L * 24 * 60 * 60 * 1000)
recentlyViewedDao.deleteOlderThan(thirtyDaysAgo)

// Trim recently viewed to 50 items (call after upsert)
recentlyViewedDao.trimToLimit()
```

### iOS: Cleanup Helpers

```swift
// Trim recent searches to 10 items
func trimRecentSearches(context: ModelContext) throws {
    let descriptor = FetchDescriptor<RecentSearch>(
        sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
    )
    let all = try context.fetch(descriptor)
    if all.count > 10 {
        all.dropFirst(10).forEach { context.delete($0) }
    }
}

// Delete recently viewed older than 30 days and trim to 50 items
func pruneRecentlyViewed(context: ModelContext) throws {
    let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    let descriptor = FetchDescriptor<RecentlyViewed>(
        sortBy: [SortDescriptor(\.viewedAt, order: .reverse)]
    )
    let all = try context.fetch(descriptor)
    for item in all {
        if item.viewedAt < cutoff { context.delete(item) }
    }
    let remaining = try context.fetch(descriptor)
    if remaining.count > 50 {
        remaining.dropFirst(50).forEach { context.delete($0) }
    }
}
```

---

## 8. Migration Strategy

### Development Phase (Current)

Both platforms use destructive migration during development (schema version 1). This drops and recreates the database on any schema change. Acceptable while the app is pre-release.

**Android**:
```kotlin
Room.databaseBuilder(context, AppDatabase::class.java, "xg_ecommerce.db")
    .fallbackToDestructiveMigration()   // drops all tables on version bump
    .build()
```

**iOS**:
```swift
// SwiftData destroys and recreates the store when schema changes are detected.
// This is the default behavior during development.
// No explicit migration plan needed until the schema is stable.
let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
```

### After First Public Release

Once the app ships, destructive migration is not acceptable — users would lose their cart and wishlist data.

**Android — Explicit Room Migrations**:

```kotlin
// android/app/src/main/java/com/xirigo/ecommerce/core/database/AppDatabase.kt
@Database(entities = [...], version = 2)  // increment version on every change
abstract class AppDatabase : RoomDatabase() { ... }

// android/app/src/main/java/com/xirigo/ecommerce/core/database/migrations/Migration1To2.kt
val MIGRATION_1_TO_2 = object : Migration(1, 2) {
    override fun migrate(db: SupportSQLiteDatabase) {
        // Example: add a column to recently_viewed
        db.execSQL("ALTER TABLE recently_viewed ADD COLUMN vendorName TEXT")
    }
}

// Registration
Room.databaseBuilder(...)
    .addMigrations(MIGRATION_1_TO_2)
    // Remove fallbackToDestructiveMigration()
    .build()
```

Export Room schemas to JSON by setting `room.schemaLocation` in `build.gradle.kts`. Commit schema files to version control as a migration audit trail.

```kotlin
// android/app/build.gradle.kts
ksp {
    arg("room.schemaLocation", "$projectDir/schemas")
    arg("room.incremental", "true")
}
```

**iOS — SwiftData VersionedSchema + MigrationPlan**:

```swift
// ios/XiriGoEcommerce/Core/Database/AppSchema.swift
enum AppSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] = [
        CartItem.self, WishlistItem.self, RecentSearch.self, RecentlyViewed.self,
    ]
}

enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [AppSchemaV1.self]
    static var stages: [MigrationStage] = []  // add lightweight/custom stages here
}

// ModelContainer setup with migration plan
let container = try ModelContainer(
    for: schema,
    migrationPlan: AppMigrationPlan.self,
    configurations: [config]
)
```

### Schema Versioning Rules

1. Start at version 1. Increment by 1 on every schema change.
2. Never change a column type in-place — add a new column and migrate data.
3. Write a migration test for every `Migration` class (Android) or `MigrationStage` (iOS).
4. Never ship a version bump without a corresponding migration.
5. Cart and wishlist data must be preserved across all migrations.

---

## 9. Backup and Security Considerations

### Android Auto-Backup

Android Auto-Backup (API 23+) automatically backs up app data to Google Drive. Room databases and DataStore files are included by default. Apply explicit exclude rules to prevent sensitive or transient data from leaking into cloud backups.

```xml
<!-- android/app/src/main/res/xml/backup_rules.xml -->
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <!-- Exclude encrypted token store — tokens are device-specific credentials -->
    <exclude domain="file" path="datastore/auth_tokens.pb.enc" />
    <!-- Exclude HTTP cache — large, easily refreshed -->
    <exclude domain="cache" path="http_cache" />
    <!-- Room database is included (cart, wishlist data) — this is intentional -->
</full-backup-content>
```

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:allowBackup="true"
    android:dataExtractionRules="@xml/data_extraction_rules"
    android:fullBackupContent="@xml/backup_rules"
    ...>
```

For API 31+ (Android 12), also create `data_extraction_rules.xml` with equivalent `<exclude>` entries under `<cloud-backup>` and `<device-transfer>` blocks.

**What is backed up**: `xg_ecommerce.db` (cart, wishlist, recent searches, recently viewed), `app_preferences.pb` (non-sensitive settings).

**What is excluded**: `auth_tokens.pb.enc` (device-specific encrypted tokens), `http_cache/` (transient network data).

### iOS Keychain iCloud Backup

All Keychain items stored with `.afterFirstUnlock` accessibility are automatically excluded from iCloud Backup. This is the correct behavior for auth tokens — tokens are device-specific and would be invalid if restored to a different device.

Verify the exclude flag is not overridden anywhere:

```swift
// Correct — iCloud backup excluded by default with .afterFirstUnlock
Keychain(service: "com.xirigo.ecommerce")
    .accessibility(.afterFirstUnlock)

// Never do this — would include tokens in iCloud backup
Keychain(service: "com.xirigo.ecommerce")
    .accessibility(.afterFirstUnlockThisDeviceOnly)  // device-only is fine too
    // Do not set .synchronizable(true) — this would sync to iCloud
```

### Database Encryption

The Room database (`xg_ecommerce.db`) and the SwiftData store do not use database-level encryption. This is an intentional design choice:

- Cart and wishlist data are non-sensitive (product titles, prices, thumbnails)
- The data directory is already protected by the OS sandbox (Android: AES-256 file-system encryption on API 23+; iOS: Data Protection class `NSFileProtectionComplete`)
- Adding database encryption (SQLCipher or similar) would add significant complexity and performance overhead for no material security benefit

Auth tokens are the only truly sensitive data, and they are stored in a separate, Tink-encrypted DataStore (Android) or the Keychain (iOS).

---

## Related Files

| File | Purpose |
|------|---------|
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/gradle/libs.versions.toml` | `datastore = "1.1.4"`, `tink = "1.16.0"`, `room = "2.7.1"` |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/android/app/build.gradle.kts` | Storage dependency declarations |
| `android/app/src/main/java/com/xirigo/ecommerce/core/database/AppDatabase.kt` | Room database class (to be created) |
| `android/app/src/main/java/com/xirigo/ecommerce/core/di/DatabaseModule.kt` | Hilt Room module (to be created) |
| `android/app/src/main/java/com/xirigo/ecommerce/core/di/DataStoreModule.kt` | Hilt DataStore module (to be created) |
| `android/app/src/main/java/com/xirigo/ecommerce/core/di/SecurityModule.kt` | Hilt Tink module (to be created) |
| `android/app/src/main/proto/app_preferences.proto` | AppPreferences proto schema (to be created) |
| `android/app/src/main/proto/auth_tokens.proto` | AuthTokens proto schema (to be created) |
| `android/app/src/main/res/xml/backup_rules.xml` | Auto-backup exclusion rules (to be created) |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/XiriGoEcommerceApp.swift` | Add `ModelContainer` configuration here |
| `/Users/atakan/Documents/GitHub/XiriGo/ecommerce-mobile/ios/XiriGoEcommerce/Core/DI/Container+Extensions.swift` | Register `AuthTokenStorage` singleton |
| `ios/XiriGoEcommerce/Core/Database/CartItem.swift` | CartItem SwiftData model (to be created) |
| `ios/XiriGoEcommerce/Core/Database/WishlistItem.swift` | WishlistItem SwiftData model (to be created) |
| `ios/XiriGoEcommerce/Core/Database/RecentSearch.swift` | RecentSearch SwiftData model (to be created) |
| `ios/XiriGoEcommerce/Core/Database/RecentlyViewed.swift` | RecentlyViewed SwiftData model (to be created) |
| `ios/XiriGoEcommerce/Core/Storage/AuthTokenStorage.swift` | Keychain token storage (to be created) |
| `ios/XiriGoEcommerce/Core/Storage/AppPreferences.swift` | UserDefaults wrapper (to be created) |
