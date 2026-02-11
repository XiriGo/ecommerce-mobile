# MCP Servers — Molt Mobile

Bu doküman, projede kullanılan MCP (Model Context Protocol) sunucularını ve her birinin hangi teknoloji/kütüphane için kullanılacağını açıklar.

## Yapılandırma

Tüm MCP sunucuları `.mcp.json` dosyasında tanımlıdır. Claude Code oturum başlatıldığında otomatik olarak yüklenir.

## Sunucu Listesi

### 1. XcodeBuildMCP (`xcode-build`)
- **Paket**: `xcodebuildmcp`
- **Kapsam**: iOS geliştirme
- **Kullanım**: Xcode projesi build, test, run, simulator yönetimi
- **Araçlar**: Build project, run tests, launch simulator, take screenshots, manage schemes
- **Teknolojiler**: Xcode, Swift, SwiftUI, SPM, iOS Simulator
- **Auth**: Gerekmez (yerel)
- **GitHub**: https://github.com/cameroncooke/XcodeBuildMCP

### 2. Apple Developer Docs (`apple-docs`)
- **Paket**: `apple-doc-mcp-server`
- **Kapsam**: iOS geliştirme
- **Kullanım**: Apple geliştirici dökümanlarında arama
- **Araçlar**: discover_technologies, choose_technology, search_symbols, get_documentation
- **Teknolojiler**: SwiftUI, UIKit, Foundation, Combine, SwiftData, LocalAuthentication, MapKit
- **Auth**: Gerekmez
- **GitHub**: https://github.com/MightyDillah/apple-doc-mcp

### 3. Apple Docs Full (`apple-docs-full`)
- **Paket**: `@kimsungwhee/apple-docs-mcp`
- **Kapsam**: iOS geliştirme (kapsamlı)
- **Kullanım**: WWDC oturumları, HIG, tüm framework'ler dahil geniş Apple doküman arama
- **Araçlar**: search_documentation, get_documentation, search_wwdc
- **Teknolojiler**: Tüm Apple framework'leri, Human Interface Guidelines, WWDC
- **Auth**: Gerekmez
- **GitHub**: https://github.com/kimsungwhee/apple-docs-mcp

### 4. Material Design 3 (`material3`)
- **Paket**: `@weppa-cloud/material3-mcp-server`
- **Kapsam**: Android geliştirme + Tasarım
- **Kullanım**: Material 3 bileşenleri, tasarım token'ları, ikonlar, erişilebilirlik kuralları
- **Araçlar**: get_component, get_design_tokens, search_icons, get_accessibility_guidelines
- **Teknolojiler**: Material 3, Jetpack Compose, Android theming
- **Auth**: Gerekmez
- **GitHub**: https://github.com/weppa-cloud/material3-mcp-server

### 5. iOS Simulator (`ios-simulator`)
- **Paket**: `ios-simulator-mcp`
- **Kapsam**: iOS test & debug
- **Kullanım**: iOS Simulator etkileşimi — ekran görüntüsü, UI inceleme, otomasyon
- **Araçlar**: get_simulators, boot_simulator, screenshot, tap, swipe, inspect_ui
- **Teknolojiler**: iOS Simulator, XCUITest, UI Automation
- **Auth**: Gerekmez (yerel)
- **GitHub**: https://github.com/joshuayoes/ios-simulator-mcp

### 6. Mobile Automation (`mobile-automation`)
- **Paket**: `mobile-mcp`
- **Kapsam**: Çapraz platform (Android + iOS)
- **Kullanım**: Her iki platformda mobil otomasyon
- **Araçlar**: ADB komutları (Android), simctl komutları (iOS), ekran görüntüsü, dokunma
- **Teknolojiler**: Android ADB, iOS Simulator, Emülatör
- **Auth**: Gerekmez (yerel)
- **GitHub**: https://github.com/mobile-next/mobile-mcp

### 7. Context7 — Kütüphane Dökümantasyonu (`context7`)
- **Paket**: `@upstash/context7-mcp`
- **Kapsam**: Tüm teknolojiler
- **Kullanım**: Herhangi bir kütüphanenin güncel dökümantasyonunu arama
- **Araçlar**: resolve-library-id, get-library-docs
- **Teknolojiler**: Kotlin, Swift, Jetpack Compose, SwiftUI, Retrofit, OkHttp, Hilt, Coil, Room, Paging, Factory, Nuke, KeychainAccess, Stripe SDK, Firebase SDK, Timber, Sentry, MockK, Turbine, ViewInspector, swift-snapshot-testing, ktlint, detekt, SwiftLint, SwiftFormat
- **Auth**: Gerekmez
- **Not**: Tüm kütüphanelerin en güncel dökümantasyonuna erişim sağlar

### 8. Sentry (`sentry`)
- **Paket**: `@sentry/mcp-server`
- **Kapsam**: Hata takibi (iOS — Sentry kullanıyor)
- **Kullanım**: Crash raporları analizi, issue araştırma, kök neden analizi
- **Araçlar**: search_issues, get_issue_details, get_event, seer_analysis
- **Teknolojiler**: Sentry, iOS crash reporting
- **Auth**: Sentry OAuth (ilk kullanımda yapılandır)
- **GitHub**: https://github.com/getsentry/sentry-mcp

### 9. GitHub (`github`)
- **Paket**: `@modelcontextprotocol/server-github`
- **Kapsam**: Proje yönetimi
- **Kullanım**: GitHub API — issue, PR, branch, release yönetimi
- **Araçlar**: create_issue, create_pull_request, search_code, list_branches, get_file_contents
- **Teknolojiler**: GitHub API
- **Auth**: `GITHUB_TOKEN` ortam değişkeni gerekli
- **Kurulum**:
  ```bash
  export GITHUB_TOKEN="ghp_your_token_here"
  ```

### 10. Figma (`figma`)
- **Paket**: `figma-developer-mcp`
- **Kapsam**: Tasarım → Kod
- **Kullanım**: Figma tasarımlarından layout, token, bileşen bilgisi çıkarma
- **Araçlar**: get_file, get_selection, get_styles, get_components
- **Teknolojiler**: Figma, Design Tokens
- **Auth**: `FIGMA_API_KEY` ortam değişkeni gerekli
- **Kurulum**:
  ```bash
  export FIGMA_API_KEY="figd_your_key_here"
  ```

### 11. Stripe (`stripe`)
- **Tür**: Remote (URL-based)
- **URL**: `https://mcp.stripe.com`
- **Kapsam**: Ödeme entegrasyonu
- **Kullanım**: Stripe API — müşteri, ödeme, iade yönetimi
- **Araçlar**: create_customer, create_payment_intent, list_charges, create_refund
- **Teknolojiler**: Stripe Android SDK, Stripe iOS SDK, PaymentSheet
- **Auth**: Stripe OAuth (ilk kullanımda yapılandır)

### 12. Firebase (`firebase`)
- **Tür**: Local URL
- **URL**: `http://127.0.0.1:3845/mcp`
- **Kapsam**: Firebase servisleri
- **Kullanım**: Analytics, Crashlytics, FCM, Remote Config
- **Araçlar**: get_crashlytics_issues, get_analytics, manage_remote_config
- **Teknolojiler**: Firebase Analytics, Firebase Crashlytics, Firebase Cloud Messaging, Firebase Remote Config
- **Auth**: Firebase CLI giriş gerekli
- **Kurulum**:
  ```bash
  npm install -g firebase-tools
  firebase login
  firebase init
  # MCP server otomatik başlar: http://127.0.0.1:3845/mcp
  ```

## Teknoloji → MCP Eşleştirme Tablosu

| Teknoloji | MCP Server(lar) |
|-----------|-----------------|
| **Swift / SwiftUI** | apple-docs, apple-docs-full, context7 |
| **Xcode / SPM** | xcode-build, apple-docs |
| **iOS Simulator** | ios-simulator, mobile-automation |
| **Kotlin / Coroutines** | context7 |
| **Jetpack Compose** | material3, context7 |
| **Material Design 3** | material3 |
| **Gradle** | context7 |
| **Retrofit / OkHttp** | context7 |
| **Hilt (DI)** | context7 |
| **Room** | context7 |
| **Coil** | context7 |
| **Paging 3** | context7 |
| **Factory (iOS DI)** | context7 |
| **Nuke (iOS images)** | context7 |
| **KeychainAccess** | context7, apple-docs |
| **SwiftData** | context7, apple-docs |
| **Stripe SDK** | stripe, context7 |
| **Firebase (Analytics/Crashlytics/FCM)** | firebase, context7 |
| **Sentry** | sentry, context7 |
| **Timber / os.Logger** | context7 |
| **BiometricPrompt / LocalAuth** | context7, apple-docs |
| **Figma (Tasarım)** | figma |
| **GitHub (Proje)** | github |
| **JUnit / MockK / Turbine** | context7 |
| **Swift Testing / ViewInspector** | context7, apple-docs |
| **ktlint / detekt** | context7 |
| **SwiftLint / SwiftFormat** | context7 |
| **Proto DataStore / Tink** | context7 |
| **Android ADB** | mobile-automation |
| **Google Places SDK** | context7 |

## Agent'lar İçin Kullanım Kılavuzu

### Architect Agent
- `apple-docs` + `apple-docs-full` → iOS API araştırması
- `material3` → Android UI bileşen araştırması
- `context7` → Kütüphane API referansı

### Android Dev Agent
- `material3` → Compose bileşen kullanımı
- `context7` → Retrofit, Hilt, Room, Paging, Coil API'leri
- `mobile-automation` → Test ve debug

### iOS Dev Agent
- `apple-docs` → SwiftUI, Foundation API'leri
- `xcode-build` → Build, test, run
- `ios-simulator` → Simulator yönetimi
- `context7` → Nuke, Factory, KeychainAccess API'leri

### Tester Agents
- `xcode-build` → iOS test çalıştırma
- `ios-simulator` → UI test otomasyon
- `mobile-automation` → Android test otomasyon
- `context7` → Test framework API'leri (MockK, Turbine, ViewInspector)

### Review Agent
- Tüm sunucular → Kod kalite kontrolü için referans

## Ortam Değişkenleri

Aşağıdaki ortam değişkenlerini `.env` veya shell profile'a ekleyin:

```bash
# GitHub — PR, issue yönetimi için
export GITHUB_TOKEN="ghp_..."

# Figma — tasarım-to-kod için
export FIGMA_API_KEY="figd_..."

# Firebase — firebase-tools kurulumundan sonra otomatik
# firebase login

# Sentry — ilk bağlantıda OAuth ile
# Otomatik yapılandırılır

# Stripe — ilk bağlantıda OAuth ile
# Otomatik yapılandırılır
```
