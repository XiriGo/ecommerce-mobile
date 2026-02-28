# XiriGo Mobile — Tüm Pipeline Komutları

Bu dosyadaki komutları **ecommerce-mobile dizininde** Claude Code'a yapıştır.
Her komut bir Agent Team pipeline başlatır.

> **Not**: `android/` ve `ios/` dizinleri boş scaffold. İlk olarak M0-01 çalıştırılmalı.

---

## 0. Proje Setup (Batch 1'den ÖNCE — tek seferlik)

Bu komutlar projelerin henüz oluşturulmadığı durumda çalıştırılır.
M0-01 pipeline'ı bunları yapacak, ama eğer manuel yapmak istersen:

### Android Project Setup
```
Android projesini oluştur:

1. android/build.gradle.kts (root) — Kotlin 2.3.10, Compose BOM 2026.01.01, Hilt plugin
2. android/app/build.gradle.kts — minSdk 26, targetSdk 35, compileSdk 35, Compose enabled, tüm dependency'ler
3. android/gradle/libs.versions.toml — version catalog (Retrofit 3.0, OkHttp, Coil, Room, Paging 3.4.0, Hilt, Timber, Tink, DataStore, Firebase, Stripe, BiometricPrompt, Compose BOM, Material 3, Navigation, Lifecycle, Truth, MockK, Turbine, ktlint, detekt)
4. android/settings.gradle.kts — plugin management, dependency resolution
5. android/gradle.properties — Kotlin, Compose, AndroidX flags
6. android/gradle/wrapper/gradle-wrapper.properties — Gradle 8.x
7. android/app/src/main/AndroidManifest.xml — Internet permission, Application class
8. android/app/src/main/java/com/xirigo/ecommerce/MoltApp.kt — @HiltAndroidApp Application class
9. android/app/src/main/java/com/xirigo/ecommerce/MainActivity.kt — @AndroidEntryPoint, setContent with XGTheme
10. android/app/proguard-rules.pro — R8 rules

CLAUDE.md'deki Android dependency listesine uy. Tüm versiyon numaralarını version catalog'a koy.
```

### iOS Project Setup
```
iOS projesini oluştur:

1. ios/XiriGoEcommerce.xcodeproj veya ios/Package.swift — Swift 6.2, min iOS 17.0, target iOS 18.0
2. ios/XiriGoEcommerce/App/XiriGoEcommerceApp.swift — @main App struct
3. ios/XiriGoEcommerce/App/ContentView.swift — Root TabView
4. ios/XiriGoEcommerce/App/Assets.xcassets — AppIcon, AccentColor
5. ios/XiriGoEcommerce/App/Info.plist — CFBundleDisplayName, NSAppTransportSecurity
6. SPM Dependencies: Factory, Nuke (NukeUI), KeychainAccess, SwiftLint, SwiftFormat, Sentry, Firebase (Analytics, Crashlytics, RemoteConfig, Messaging), Stripe (StripePaymentSheet), GooglePlaces
7. Test targets: XiriGoEcommerceTests, XiriGoEcommerceUITests
8. SPM Test Dependencies: ViewInspector, swift-snapshot-testing

CLAUDE.md'deki iOS dependency listesine uy.
```

---

## Batch 1 — M0 Foundation (5 paralel)

> **ÖNEMLİ**: Tüm 5'i paralel başlat. Birbirinden bağımsız.
> Proje dosyaları henüz yok, M0-01 ilk çalışmalı. Diğer 4'ü M0-01 bittikten sonra başlat.

### M0-01 app-scaffold (İLK ÇALIŞTIR)
```
/pipeline-run M0-01 app-scaffold
```

### M0-02 design-system (M0-01 sonrası)
```
/pipeline-run M0-02 design-system
```

### M0-03 network-layer (M0-01 sonrası)
```
/pipeline-run M0-03 network-layer
```

### M0-04 navigation (M0-01 sonrası)
```
/pipeline-run M0-04 navigation
```

### M0-05 di-setup (M0-01 sonrası)
```
/pipeline-run M0-05 di-setup
```

---

## Batch 2 — M0 Auth Infrastructure (Batch 1 tamamlanınca)

> M0-03 (network) ve M0-05 (DI) tamamlanmış olmalı.

### M0-06 auth-infrastructure
```
/pipeline-run M0-06 auth-infrastructure
```

---

## Batch 3 — M1 Auth Screens + Home (4 paralel)

> M0-06 (auth), M0-04 (navigation), M0-02 (design) tamamlanmış olmalı.

### M1-01 login-screen
```
/pipeline-run M1-01 login-screen
```

### M1-02 register-screen
```
/pipeline-run M1-02 register-screen
```

### M1-03 forgot-password
```
/pipeline-run M1-03 forgot-password
```

### M1-04 home-screen
```
/pipeline-run M1-04 home-screen
```

---

## Batch 4 — M1 Browsing (2 paralel)

> M1-04 (home) tamamlanmış olmalı.

### M1-05 category-browsing
```
/pipeline-run M1-05 category-browsing
```

### M1-06 product-list
```
/pipeline-run M1-06 product-list
```

---

## Batch 5 — M1 Detail + Search (2 paralel)

> M1-06 (product-list) tamamlanmış olmalı.

### M1-07 product-detail
```
/pipeline-run M1-07 product-detail
```

### M1-08 product-search
```
/pipeline-run M1-08 product-search
```

---

## Batch 6 — M2 Commerce (3 paralel)

> M1-07 (product-detail) tamamlanmış olmalı. M2-03 sadece M1-01'e bağlı.

### M2-01 cart
```
/pipeline-run M2-01 cart
```

### M2-02 wishlist
```
/pipeline-run M2-02 wishlist
```

### M2-03 address-management
```
/pipeline-run M2-03 address-management
```

---

## Batch 7 — M2 Checkout (sıralı chain)

> Sırayla çalıştır. Her biri bir öncekine bağlı.

### M2-04 checkout-address (M2-01 + M2-03 sonrası)
```
/pipeline-run M2-04 checkout-address
```

### M2-05 checkout-shipping (M2-04 sonrası)
```
/pipeline-run M2-05 checkout-shipping
```

### M2-06 checkout-payment (M2-05 sonrası)
```
/pipeline-run M2-06 checkout-payment
```

### M2-07 order-confirmation (M2-06 sonrası)
```
/pipeline-run M2-07 order-confirmation
```

---

## Batch 8 — M3 Post-Purchase (4 paralel)

> M1-01 (login) tamamlanmış olmalı. M3-08 ayrıca M1-07'ye bağlı.

### M3-01 order-list
```
/pipeline-run M3-01 order-list
```

### M3-03 user-profile
```
/pipeline-run M3-03 user-profile
```

### M3-06 settings
```
/pipeline-run M3-06 settings
```

### M3-08 vendor-store-page
```
/pipeline-run M3-08 vendor-store-page
```

---

## Batch 9 — M3 Order Detail (sıralı)

> M3-01 (order-list) tamamlanmış olmalı.

### M3-02 order-detail
```
/pipeline-run M3-02 order-detail
```

---

## Batch 10 — M4 Local Features (3 paralel)

> M1-07 (product-detail) veya M0-04 (navigation) tamamlanmış olmalı.

### M4-02 recently-viewed
```
/pipeline-run M4-02 recently-viewed
```

### M4-04 share-product
```
/pipeline-run M4-04 share-product
```

### M4-05 app-onboarding
```
/pipeline-run M4-05 app-onboarding
```

---

## BEKLEMEDE — Backend Gerekli

Bu komutlar xirigo backend'de ilgili modüller tamamlanınca çalıştırılır:

### M3-04 payment-methods (Stripe provider setup gerekli)
```
/pipeline-run M3-04 payment-methods
```

### M3-05 notifications (Notification modülü gerekli)
```
/pipeline-run M3-05 notifications
```

### M3-07 product-reviews (Review modülü gerekli)
```
/pipeline-run M3-07 product-reviews
```

### M4-01 product-qna (Q&A modülü gerekli)
```
/pipeline-run M4-01 product-qna
```

### M4-03 price-alerts (Price Alert modülü gerekli)
```
/pipeline-run M4-03 price-alerts
```

---

## Hızlı Referans — Çalıştırma Sırası

```
# ═══ BATCH 1: Foundation (M0-01 önce, sonra diğer 4 paralel) ═══
/pipeline-run M0-01 app-scaffold
# ... M0-01 bittikten sonra:
/pipeline-run M0-02 design-system
/pipeline-run M0-03 network-layer
/pipeline-run M0-04 navigation
/pipeline-run M0-05 di-setup

# ═══ BATCH 2: Auth Infra ═══
/pipeline-run M0-06 auth-infrastructure

# ═══ BATCH 3: Auth + Home (paralel) ═══
/pipeline-run M1-01 login-screen
/pipeline-run M1-02 register-screen
/pipeline-run M1-03 forgot-password
/pipeline-run M1-04 home-screen

# ═══ BATCH 4: Browse (paralel) ═══
/pipeline-run M1-05 category-browsing
/pipeline-run M1-06 product-list

# ═══ BATCH 5: Detail (paralel) ═══
/pipeline-run M1-07 product-detail
/pipeline-run M1-08 product-search

# ═══ BATCH 6: Commerce (paralel) ═══
/pipeline-run M2-01 cart
/pipeline-run M2-02 wishlist
/pipeline-run M2-03 address-management

# ═══ BATCH 7: Checkout (sıralı) ═══
/pipeline-run M2-04 checkout-address
/pipeline-run M2-05 checkout-shipping
/pipeline-run M2-06 checkout-payment
/pipeline-run M2-07 order-confirmation

# ═══ BATCH 8: Post-Purchase (paralel) ═══
/pipeline-run M3-01 order-list
/pipeline-run M3-03 user-profile
/pipeline-run M3-06 settings
/pipeline-run M3-08 vendor-store-page

# ═══ BATCH 9: Order Detail ═══
/pipeline-run M3-02 order-detail

# ═══ BATCH 10: Local Features (paralel) ═══
/pipeline-run M4-02 recently-viewed
/pipeline-run M4-04 share-product
/pipeline-run M4-05 app-onboarding

# ═══ BEKLEMEDE (backend gerekli) ═══
# /pipeline-run M3-04 payment-methods
# /pipeline-run M3-05 notifications
# /pipeline-run M3-07 product-reviews
# /pipeline-run M4-01 product-qna
# /pipeline-run M4-03 price-alerts
```

---

## Toplam: 30 feature (+ 5 beklemede)

| Batch | Sayı | Mod | Bağımlılık |
|-------|------|-----|------------|
| 1 | 5 | M0-01 önce, sonra 4 paralel | Yok |
| 2 | 1 | Sıralı | Batch 1 |
| 3 | 4 | Paralel | Batch 2 |
| 4 | 2 | Paralel | Batch 3 (M1-04) |
| 5 | 2 | Paralel | Batch 4 (M1-06) |
| 6 | 3 | Paralel | Batch 5 (M1-07) |
| 7 | 4 | Sıralı chain | Batch 6 |
| 8 | 4 | Paralel | Batch 3 (M1-01) |
| 9 | 1 | Sıralı | Batch 8 (M3-01) |
| 10 | 3 | Paralel | Batch 5 (M1-07) / Batch 1 (M0-04) |
| Beklemede | 5 | — | Backend modülleri |
