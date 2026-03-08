# iOS Test Mimarisi — Her Problemi Bulan Sistem

> AI-Driven Geliştirme İçin Kapsamlı Test Rehberi
> Unit → Static Analysis → Mutation → Contract → Integration → UI → Performance → Security → Accessibility
> Mart 2026

---

## 1. Test Piramidi: Genel Bakış

| Katman | Oran | Hız | Yakaladığı Hatalar |
|--------|------|-----|-------------------|
| Unit Test | %60-70 | Milisaniye | Logic hataları, edge case, hesaplama |
| Integration Test | %15-20 | Saniye | Modül arası iletişim, API uyumu |
| UI / E2E Test | %10-15 | Dakika | Kullanıcı akışı kırılmaları, UI regression |
| Performance Test | %3-5 | Dakika | Memory leak, ANR, yavaş ekran |
| Security Test | %2-3 | Dakika | Data sızdırma, MITM, Keychain |
| Accessibility Test | %1-2 | Saniye | VoiceOver, Dynamic Type, kontrast |

**Altın Kural:** Her katman bağımsız çalışabilmeli. CI/CD'de her PR'da otomatik koşmalı. Flaky test = yok sayılan test — ya fix'le ya sil.

---

## 2. Unit Test Katmanı

### 2.1 XCTest — Temel Yapı

```swift
import XCTest
@testable import MyApp

final class PaymentCalculatorTests: XCTestCase {
    private var sut: PaymentCalculator!

    override func setUp() {
        super.setUp()
        sut = PaymentCalculator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_calculateTotal_withDiscount_returnsCorrectAmount() {
        let result = sut.calculateTotal(price: 100, discount: 0.2)
        XCTAssertEqual(result, 80.0, accuracy: 0.01)
    }

    func test_calculateTotal_withNegativePrice_throwsError() {
        XCTAssertThrowsError(try sut.calculateTotal(price: -10))
    }
}
```

### 2.2 Neyi Test Etmeli?

- Tüm public fonksiyonlar (happy path + edge case)
- Boundary değerler: `nil`, boş string, `0`, negatif, `Int.max`
- Error handling: her `throws` fonksiyon için hata senaryoları
- ViewModel logic: state değişiklikleri, computed property'ler
- Utility fonksiyonlar: tarih formatlama, string parse, para hesaplama
- Model mapping: JSON decode/encode, DTO dönüşümleri

### 2.3 Mocking — Protocol-Based

```swift
protocol NetworkServiceProtocol {
    func fetchUser(id: String) async throws -> User
}

class MockNetworkService: NetworkServiceProtocol {
    var fetchUserResult: Result<User, Error> = .failure(NSError())
    var fetchUserCallCount = 0
    var capturedUserIds: [String] = []

    func fetchUser(id: String) async throws -> User {
        fetchUserCallCount += 1
        capturedUserIds.append(id)
        return try fetchUserResult.get()
    }
}
```

**Test'te kullanım:**

```swift
func test_loadProfile_success_updatesState() async {
    let mockService = MockNetworkService()
    mockService.fetchUserResult = .success(User.mock)
    let vm = ProfileViewModel(service: mockService)

    await vm.loadProfile(id: "123")

    XCTAssertEqual(vm.state, .loaded)
    XCTAssertEqual(mockService.fetchUserCallCount, 1)
    XCTAssertEqual(mockService.capturedUserIds, ["123"])
}

func test_loadProfile_failure_showsError() async {
    let mockService = MockNetworkService()
    mockService.fetchUserResult = .failure(NetworkError.timeout)
    let vm = ProfileViewModel(service: mockService)

    await vm.loadProfile(id: "123")

    XCTAssertEqual(vm.state, .error("Bağlantı zaman aşımına uğradı"))
}
```

**Mock Best Practices:**
- Her external dependency için protocol tanımla
- Mock'larda call count tut → fonksiyon kaç kez çağrıldı doğrula
- Captured arguments kaydet → doğru parametrelerle mi çağrıldı kontrol et
- 3. parti framework yerine protocol-based mocking tercih et

### 2.4 Async/Await Test Patterns

```swift
// Async fonksiyon testi
func test_fetchData_returnsExpectedItems() async throws {
    let items = try await sut.fetchData()
    XCTAssertEqual(items.count, 10)
}

// Combine publisher testi
func test_publisher_emitsCorrectValues() {
    let expectation = expectation(description: "values received")
    var received: [Int] = []

    sut.numbersPublisher
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { received.append($0) }
        )
        .store(in: &cancellables)

    sut.startEmitting()

    wait(for: [expectation], timeout: 2.0)
    XCTAssertEqual(received, [1, 2, 3])
}
```

### 2.5 Code Coverage Hedefleri

| Modül Tipi | Minimum | Hedef |
|------------|---------|-------|
| Business Logic / ViewModel | %80 | %90+ |
| Utility / Helper | %90 | %95+ |
| Network Layer | %70 | %85+ |
| UI Components | %50 | %70+ |
| Extensions | %85 | %95+ |

Coverage'ı aktifleştir: **Edit Scheme → Test → Options → Code Coverage**

---

## 3. Snapshot (Görsel Regresyon) Testleri

Gözle görülemeyecek UI değişikliklerini otomatik yakalar: 1px kayma, font değişikliği, renk farkı, padding bozulması.

### 3.1 swift-snapshot-testing (Point-Free)

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0")
]
```

```swift
import SnapshotTesting
import XCTest
@testable import MyApp

final class LoginScreenSnapshotTests: XCTestCase {

    // isRecording = true  → baseline oluşturur (ilk sefer)
    // isRecording = false → karşılaştırma yapar (CI'da)

    func test_loginScreen_defaultState() {
        let vc = LoginViewController()
        vc.loadViewIfNeeded()
        assertSnapshot(of: vc, as: .image(on: .iPhone13))
    }

    func test_loginScreen_errorState() {
        let vc = LoginViewController()
        vc.loadViewIfNeeded()
        vc.showError("Hatalı şifre")
        assertSnapshot(of: vc, as: .image(on: .iPhone13))
    }

    func test_loginScreen_darkMode() {
        let vc = LoginViewController()
        vc.overrideUserInterfaceStyle = .dark
        vc.loadViewIfNeeded()
        assertSnapshot(of: vc, as: .image(on: .iPhone13))
    }

    func test_loginScreen_largeFont() {
        let vc = LoginViewController()
        vc.loadViewIfNeeded()
        let traits = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge)
        assertSnapshot(of: vc, as: .image(on: .iPhone13, traits: traits))
    }

    func test_loginScreen_iPad() {
        let vc = LoginViewController()
        vc.loadViewIfNeeded()
        assertSnapshot(of: vc, as: .image(on: .iPadPro12_9))
    }
}
```

### 3.2 Her Ekran İçin Test Edilmesi Gereken State'ler

1. Default / Empty State
2. Loading State
3. Loaded / Success State (data ile)
4. Error State
5. Dark Mode
6. Dynamic Type (büyük font)
7. RTL Layout (Arapça/İbranice)
8. Landscape (destekleniyorsa)
9. iPad (Universal app ise)

### 3.3 SwiftUI Preview + Snapshot

```swift
func test_profileCard_allVariants() {
    let card = ProfileCardView(user: .mock)

    // Light mode
    assertSnapshot(of: card, as: .image(layout: .device(config: .iPhone13)))

    // Dark mode
    assertSnapshot(
        of: card.environment(\.colorScheme, .dark),
        as: .image(layout: .device(config: .iPhone13)),
        named: "dark"
    )
}
```

**Strateji:** Snapshot dosyalarını git'e commit'le → PR review'da görsel değişiklikleri gör.

---

## 4. Integration Test Katmanı

Modüllerin birlikte doğru çalıştığını doğrular. Unit test'ten farklı olarak gerçek bağımlılıklar (database, local cache) kullanılır.

### 4.1 Network Integration — URLProtocol ile Stub'lama

```swift
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("requestHandler set edilmedi")
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
```

**Test'te kullanım:**

```swift
func test_fetchUsers_decodesCorrectly() async throws {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)
    let apiClient = APIClient(session: session)

    let mockJSON = """
    [{"id": 1, "name": "Ali"}, {"id": 2, "name": "Ayşe"}]
    """.data(using: .utf8)!

    MockURLProtocol.requestHandler = { request in
        XCTAssertEqual(request.url?.path, "/api/users")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, mockJSON)
    }

    let users = try await apiClient.fetchUsers()
    XCTAssertEqual(users.count, 2)
    XCTAssertEqual(users[0].name, "Ali")
}
```

### 4.2 Database Integration — Core Data In-Memory

```swift
func makeInMemoryContainer() -> NSPersistentContainer {
    let container = NSPersistentContainer(name: "MyApp")
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { _, error in
        XCTAssertNil(error)
    }
    return container
}

func test_saveAndFetchUser() throws {
    let container = makeInMemoryContainer()
    let context = container.viewContext
    let repo = UserRepository(context: context)

    try repo.save(User(name: "Ali", email: "ali@test.com"))

    let fetched = try repo.fetchAll()
    XCTAssertEqual(fetched.count, 1)
    XCTAssertEqual(fetched[0].name, "Ali")
}
```

### 4.3 Test Edilmesi Gereken Entegrasyon Noktaları

- API client → JSON decode → Model mapping zinciri
- Local cache (UserDefaults, Keychain, Core Data) okuma/yazma
- Deep link routing: URL → doğru ekrana yönlendirme
- Push notification payload → doğru aksiyon
- Analytics event'leri: doğru parametrelerle doğru zamanda tetikleniyor mu
- Feature flag'ler: flag değişince UI doğru güncelleniyor mu
- Auth token refresh: expired token → refresh → retry zinciri
- Migration: eski versiyon data'sı → yeni versiyon'a dönüşüm

---

## 5. UI / End-to-End (E2E) Test Katmanı

Gerçek kullanıcı gibi uygulamayı kullanarak kritik akışları test eder.

### 5.1 XCUITest (Apple Native)

```swift
final class LoginUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launchEnvironment = ["MOCK_API": "true"]
        app.launch()
    }

    func test_loginFlow_withValidCredentials_showsHome() {
        // Email gir
        let emailField = app.textFields["emailTextField"]
        emailField.tap()
        emailField.typeText("test@example.com")

        // Şifre gir
        let passField = app.secureTextFields["passwordTextField"]
        passField.tap()
        passField.typeText("password123")

        // Login butonuna bas
        app.buttons["loginButton"].tap()

        // Home ekranı göründü mü?
        let welcomeLabel = app.staticTexts["welcomeLabel"]
        XCTAssertTrue(welcomeLabel.waitForExistence(timeout: 5))
    }

    func test_loginFlow_withInvalidCredentials_showsError() {
        app.textFields["emailTextField"].tap()
        app.textFields["emailTextField"].typeText("wrong@email.com")
        app.secureTextFields["passwordTextField"].tap()
        app.secureTextFields["passwordTextField"].typeText("wrongpass")
        app.buttons["loginButton"].tap()

        XCTAssertTrue(app.staticTexts["errorLabel"].waitForExistence(timeout: 5))
    }

    func test_loginFlow_emptyFields_showsValidation() {
        app.buttons["loginButton"].tap()

        XCTAssertTrue(app.staticTexts["E-posta gerekli"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Şifre gerekli"].waitForExistence(timeout: 2))
    }
}
```

### 5.2 Maestro — Hızlı E2E Alternatifi

YAML tabanlı, kod bilmeden test yazılabilir. Kurulumu 10 dakika.

```yaml
# login_flow.yaml
appId: com.myapp.ios
---
- launchApp
- tapOn: "E-posta"
- inputText: "test@example.com"
- tapOn: "Şifre"
- inputText: "password123"
- tapOn: "Giriş Yap"
- assertVisible: "Hoşgeldiniz"
- takeScreenshot: login_success
```

```yaml
# purchase_flow.yaml
appId: com.myapp.ios
---
- launchApp
- tapOn: "Ürünler"
- tapOn:
    id: "product_cell_0"
- tapOn: "Sepete Ekle"
- tapOn: "Sepetim"
- assertVisible: "1 ürün"
- tapOn: "Ödemeye Geç"
- assertVisible: "Ödeme Bilgileri"
- takeScreenshot: checkout_screen
```

**Maestro CLI:**

```bash
# Tek test çalıştır
maestro test login_flow.yaml

# Tüm testleri çalıştır
maestro test flows/

# Belirli cihazda çalıştır
maestro test --device "iPhone 15" login_flow.yaml
```

### 5.3 XCUITest vs Maestro Karşılaştırma

| Özellik | XCUITest | Maestro |
|---------|----------|---------|
| Dil | Swift | YAML |
| Kurulum | Xcode entegre | CLI kurulum |
| Hız | Orta | Hızlı |
| Flaky test oranı | Düşük | Çok düşük |
| CI entegrasyonu | Doğal | Kolay |
| Cross-platform | Hayır | Evet (Android da) |
| Debugging | Xcode debugger | Maestro Studio |
| Öğrenme eğrisi | Orta | Çok düşük |
| Accessibility ID gerekli mi? | Evet | Hayır (text ile bulur) |

**Öneri:** İkisini birlikte kullan. Maestro → hızlı smoke test. XCUITest → detaylı, complex senaryolar.

### 5.4 Kritik E2E Akışları — Mutlaka Test Et

| Akış | Senaryo Sayısı | Öncelik |
|------|---------------|---------|
| Kayıt / Onboarding | 3-5 | P0 - Kritik |
| Login / Logout | 4-6 | P0 - Kritik |
| Ana akış (core feature) | 5-10 | P0 - Kritik |
| Satın alma / Ödeme | 4-6 | P0 - Kritik |
| Profil düzenleme | 3-4 | P1 - Yüksek |
| Arama / Filtreleme | 3-5 | P1 - Yüksek |
| Push notification etkileşimi | 2-3 | P2 - Orta |
| Deep link | 3-4 | P2 - Orta |
| Offline mode | 2-3 | P1 - Yüksek |
| Error recovery | 3-4 | P1 - Yüksek |

### 5.5 Page Object Pattern (UI Test'leri Temiz Tutma)

```swift
// Page Objects
struct LoginPage {
    let app: XCUIApplication

    var emailField: XCUIElement { app.textFields["emailTextField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordTextField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }
    var errorLabel: XCUIElement { app.staticTexts["errorLabel"] }

    func login(email: String, password: String) {
        emailField.tap()
        emailField.typeText(email)
        passwordField.tap()
        passwordField.typeText(password)
        loginButton.tap()
    }
}

struct HomePage {
    let app: XCUIApplication

    var welcomeLabel: XCUIElement { app.staticTexts["welcomeLabel"] }
    var isVisible: Bool { welcomeLabel.waitForExistence(timeout: 5) }
}

// Test — çok daha okunabilir
func test_loginFlow() {
    let loginPage = LoginPage(app: app)
    let homePage = HomePage(app: app)

    loginPage.login(email: "test@example.com", password: "pass123")
    XCTAssertTrue(homePage.isVisible)
}
```

---

## 6. Performance Test Katmanı

### 6.1 XCTest Performance Metrics

```swift
func test_feedLoading_performance() {
    let options = XCTMeasureOptions()
    options.iterationCount = 10

    measure(metrics: [
        XCTClockMetric(),           // Süre
        XCTMemoryMetric(),          // Bellek kullanımı
        XCTCPUMetric(),             // CPU kullanımı
        XCTStorageMetric(),         // Disk I/O
    ], options: options) {
        sut.loadFeed()
    }
}

func test_imageProcessing_underBaseline() {
    measure(metrics: [XCTClockMetric()]) {
        let _ = ImageProcessor.resize(image: testImage, to: CGSize(width: 200, height: 200))
    }
    // Xcode'da baseline set et → aşılırsa test fail olur
}
```

### 6.2 Memory Leak Detection

```swift
// Her ViewController için yaz
func test_viewController_deallocation() {
    var vc: ProfileViewController? = ProfileViewController()
    weak var weakVC = vc

    vc?.loadViewIfNeeded()
    vc?.viewDidAppear(false)
    vc?.viewDidDisappear(false)
    vc = nil

    // weakVC nil değilse MEMORY LEAK var!
    XCTAssertNil(weakVC, "ProfileViewController deallocate edilemedi — memory leak!")
}

// Generic helper
func assertNoMemoryLeak(
    _ instance: AnyObject,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    addTeardownBlock { [weak instance] in
        XCTAssertNil(
            instance,
            "Potansiyel memory leak: \(String(describing: instance))",
            file: file,
            line: line
        )
    }
}

// Kullanım
func test_viewModel_noLeak() {
    let vm = ProfileViewModel(service: MockNetworkService())
    assertNoMemoryLeak(vm)
    // ... test logic
}
```

### 6.3 App Launch Time Testi

```swift
func test_appLaunchPerformance() throws {
    measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
    }
}

// Pre-main time dahil (dylib loading, static initializers)
func test_appLaunchPerformance_includePreMain() throws {
    measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
        XCUIApplication().launch()
    }
}
```

### 6.4 Performance Baselines

| Metrik | Kabul Edilebilir | Uyarı | Kritik |
|--------|-----------------|-------|--------|
| App Launch (cold) | < 2 saniye | 2-4 saniye | > 4 saniye |
| Ekran geçişi | < 300ms | 300-800ms | > 800ms |
| API response + render | < 1 saniye | 1-3 saniye | > 3 saniye |
| Bellek kullanımı | < 100MB | 100-200MB | > 200MB |
| Scroll FPS | > 58 FPS | 50-58 FPS | < 50 FPS |
| Battery (1 saat) | < %5 | %5-10 | > %10 |
| Binary boyutu | < 50MB | 50-100MB | > 100MB |

### 6.5 Instruments ile Profiling Checklist

- **Time Profiler:** Hangi fonksiyon ne kadar CPU harcıyor?
- **Allocations:** Memory allocation pattern'leri, büyüyen heap
- **Leaks:** Retain cycle ve memory leak tespiti
- **Network:** API call süreleri, payload boyutları
- **Energy Log:** Battery drain analizi
- **Core Animation:** Offscreen rendering, blending sorunları
- **System Trace:** Thread blocking, main thread ihlalleri

---

## 7. Security Test Katmanı

### 7.1 Otomatik Security Kontrolleri

```swift
// 1. Keychain testi — hassas veri UserDefaults'ta olmamalı
func test_authToken_storedInKeychain_notUserDefaults() {
    authService.saveToken("test-token")

    // UserDefaults'ta OLMAMALI
    XCTAssertNil(UserDefaults.standard.string(forKey: "authToken"))
    XCTAssertNil(UserDefaults.standard.string(forKey: "token"))
    XCTAssertNil(UserDefaults.standard.string(forKey: "access_token"))

    // Keychain'de OLMALI
    let keychainToken = KeychainWrapper.standard.string(forKey: "authToken")
    XCTAssertEqual(keychainToken, "test-token")
}

// 2. HTTPS zorunluluk testi
func test_allEndpoints_useHTTPS() {
    let endpoints = APIEndpoint.allCases
    for endpoint in endpoints {
        XCTAssertTrue(
            endpoint.url.absoluteString.hasPrefix("https://"),
            "\(endpoint) HTTPS kullanmıyor! URL: \(endpoint.url)"
        )
    }
}

// 3. Hassas veri loglama kontrolü
func test_sensitiveData_notLoggedToConsole() {
    let logger = AppLogger.shared
    let sensitiveFields = ["password", "token", "credit_card", "ssn", "cvv"]

    for field in sensitiveFields {
        XCTAssertFalse(
            logger.recentLogs.contains(where: { $0.lowercased().contains(field) }),
            "Hassas veri loglanıyor: \(field)"
        )
    }
}

// 4. Certificate pinning testi
func test_certificatePinning_rejectsInvalidCert() async {
    let config = URLSessionConfiguration.ephemeral
    let session = URLSession(
        configuration: config,
        delegate: CertificatePinningDelegate(validPins: ["INVALID_PIN"]),
        delegateQueue: nil
    )

    do {
        let _ = try await session.data(from: URL(string: "https://api.myapp.com")!)
        XCTFail("Invalid certificate kabul edilmemeli")
    } catch {
        // Beklenen: bağlantı reddedilmeli
    }
}

// 5. Jailbreak detection
func test_jailbreakDetection_works() {
    let detector = JailbreakDetector()

    // Simulator'da false dönmeli
    #if targetEnvironment(simulator)
    XCTAssertFalse(detector.isJailbroken)
    #endif

    // Detection metodları çalışıyor mu?
    XCTAssertNotNil(detector.checkCydia)
    XCTAssertNotNil(detector.checkSuspiciousPaths)
    XCTAssertNotNil(detector.checkFork)
}
```

### 7.2 Info.plist Security Audit

```swift
func test_infoPlist_securitySettings() {
    let plist = Bundle.main.infoDictionary!

    // ATS (App Transport Security) aktif olmalı
    let ats = plist["NSAppTransportSecurity"] as? [String: Any]
    XCTAssertNotEqual(
        ats?["NSAllowsArbitraryLoads"] as? Bool,
        true,
        "NSAllowsArbitraryLoads true olmamalı!"
    )

    // Gereksiz URL scheme açık olmamalı
    let urlSchemes = plist["LSApplicationQueriesSchemes"] as? [String] ?? []
    XCTAssertFalse(urlSchemes.contains("http"), "HTTP scheme açık olmamalı")
}
```

### 7.3 OWASP Mobile Top 10 Checklist

| Risk | Test Yöntemi |
|------|-------------|
| M1: Improper Credential Usage | Keychain audit, hardcoded secret taraması |
| M2: Inadequate Supply Chain | Dependency audit (`pod audit`, SPM vulnerability check) |
| M3: Insecure Auth/Authz | Token expiry, role-based access testi |
| M4: Insufficient Input Validation | Fuzzing, SQL injection, XSS denemeleri |
| M5: Insecure Communication | MITM proxy ile trafik analizi (Charles/Proxyman) |
| M6: Inadequate Privacy Controls | PII loglama kontrolü, analytics audit |
| M7: Insufficient Binary Protection | IPA reverse engineering analizi |
| M8: Security Misconfiguration | Info.plist audit, ATS ayarları |
| M9: Insecure Data Storage | Sandbox dosya sistemi taraması |
| M10: Insufficient Cryptography | Encryption algoritması ve key management audit |

---

## 8. Accessibility Test Katmanı

### 8.1 Otomatik Accessibility Audit (Xcode 15+)

```swift
// Tek satırda tüm accessibility kontrollerini yapar
func test_homeScreen_passesAccessibilityAudit() throws {
    let app = XCUIApplication()
    app.launch()
    try app.performAccessibilityAudit()
}

// Belirli kuralları hariç tutma
func test_settingsScreen_accessibility() throws {
    let app = XCUIApplication()
    app.launch()
    app.tabBars.buttons["Ayarlar"].tap()

    try app.performAccessibilityAudit(for: [
        .dynamicType,
        .contrast,
        .sufficientElementDescription
    ])
}
```

**Bu tek çağrı şunları kontrol eder:**
- VoiceOver label'ları tanımlanmış mı?
- Touch target boyutu yeterli mi? (minimum 44x44 pt)
- Kontrast oranı WCAG standartlarında mı?
- Dynamic Type destekleniyor mu?
- Element description'lar anlamlı mı?

### 8.2 Programatik Accessibility Kontrolleri

```swift
func test_allButtons_haveAccessibilityLabels() {
    let app = XCUIApplication()
    app.launch()

    let buttons = app.buttons.allElementsBoundByIndex
    for button in buttons {
        XCTAssertFalse(
            button.label.isEmpty,
            "Buton accessibility label'ı eksik: \(button.debugDescription)"
        )
    }
}

func test_allImages_haveAccessibilityDescriptions() {
    let app = XCUIApplication()
    app.launch()

    let images = app.images.allElementsBoundByIndex
    for image in images where image.isHittable {
        XCTAssertFalse(
            image.label.isEmpty,
            "Görsel accessibility description eksik: \(image.debugDescription)"
        )
    }
}

func test_touchTargets_meetMinimumSize() {
    let app = XCUIApplication()
    app.launch()

    let interactiveElements = app.buttons.allElementsBoundByIndex +
                               app.switches.allElementsBoundByIndex

    for element in interactiveElements where element.isHittable {
        let frame = element.frame
        XCTAssertTrue(
            frame.width >= 44 && frame.height >= 44,
            "Touch target çok küçük: \(element.label) (\(frame.width)x\(frame.height))"
        )
    }
}
```

### 8.3 Manuel Accessibility Test Checklist

1. VoiceOver ile tam uygulama gezintisi (her ekran, her buton)
2. Switch Control ile navigasyon
3. Dynamic Type: En büyük font boyutunda UI kırılıyor mu?
4. Reduce Motion: Animasyonlar devre dışı bırakılabiliyor mu?
5. Bold Text: Tüm text'ler kalın font'a geçebiliyor mu?
6. Color Blind mode: Sadece renk ile bilgi veriliyor mu?
7. Keyboard navigation (external keyboard): Tab order mantıklı mı?

---

## 9. Network Condition Testing

Gerçek dünya ağ koşullarını simüle et.

### 9.1 Network Link Conditioner

```swift
// XCUITest'te network koşulunu ayarla
func test_slowNetwork_showsLoadingState() {
    let app = XCUIApplication()
    app.launchEnvironment = [
        "SIMULATED_NETWORK": "slow_3g",
        "NETWORK_DELAY_MS": "3000"
    ]
    app.launch()

    app.buttons["loadDataButton"].tap()

    // Loading göstergesi görünmeli
    XCTAssertTrue(app.activityIndicators["loadingIndicator"].waitForExistence(timeout: 1))
}
```

### 9.2 Test Edilecek Network Senaryoları

```swift
enum NetworkCondition: String, CaseIterable {
    case wifi          // Normal: 50ms delay, 0% loss
    case lte           // 4G: 100ms delay, 1% loss
    case threeG        // 3G: 500ms delay, 5% loss
    case edge          // EDGE: 2000ms delay, 10% loss
    case offline       // No connection
    case flaky         // 200ms delay, 30% loss (intermittent)
    case timeout       // 30s+ delay (server unresponsive)
}
```

Her kritik akış (login, ödeme, veri yükleme) bu 7 koşulda test edilmeli.

---

## 10. CI/CD Pipeline Entegrasyonu

### 10.1 Pipeline Aşamaları

| Aşama | İçerik | Süre | Tetikleyici |
|-------|--------|------|-------------|
| 1. Lint + Build | SwiftLint + derleme | 2-3 dk | Her commit |
| 2. Unit Test | XCTest unit testleri | 3-5 dk | Her commit |
| 3. Snapshot Test | Görsel regresyon | 2-4 dk | Her PR |
| 4. Integration Test | API + DB testleri | 5-8 dk | Her PR |
| 5. UI / E2E Test | Kritik akışlar | 10-20 dk | PR merge öncesi |
| 6. Performance Test | Baseline karşılaştırma | 5-10 dk | Günlük (nightly) |
| 7. Security Scan | Dependency + code audit | 3-5 dk | Haftalık |
| 8. Accessibility Audit | Xcode audit + checklist | 5 dk | Her release öncesi |

### 10.2 GitHub Actions — Tam Konfigürasyon

```yaml
name: iOS Test Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint-and-build:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: SwiftLint
        run: swiftlint lint --strict
      - name: Build
        run: |
          xcodebuild build \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15'

  unit-tests:
    needs: lint-and-build
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:MyAppTests \
            -resultBundlePath TestResults/UnitTests.xcresult \
            -enableCodeCoverage YES
      - name: Upload Results
        uses: actions/upload-artifact@v4
        with:
          name: unit-test-results
          path: TestResults/

  snapshot-tests:
    needs: lint-and-build
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Run Snapshot Tests
        run: |
          xcodebuild test \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:MyAppSnapshotTests \
            -resultBundlePath TestResults/SnapshotTests.xcresult
      - name: Upload Snapshot Failures
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: snapshot-failures
          path: "**/Failures/**"

  ui-tests:
    needs: [unit-tests, snapshot-tests]
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Run UI Tests
        run: |
          xcodebuild test \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:MyAppUITests \
            -resultBundlePath TestResults/UITests.xcresult
      - name: Upload Results
        uses: actions/upload-artifact@v4
        with:
          name: ui-test-results
          path: TestResults/
```

### 10.3 Fastlane ile Otomasyon

```ruby
# Fastfile
default_platform(:ios)

platform :ios do
  desc "Tüm testleri çalıştır"
  lane :test_all do
    scan(
      scheme: "MyApp",
      devices: ["iPhone 15"],
      code_coverage: true,
      output_types: "html,junit",
      result_bundle: true
    )
  end

  desc "Snapshot testleri"
  lane :test_snapshots do
    scan(
      scheme: "MyApp",
      only_testing: ["MyAppSnapshotTests"],
      devices: ["iPhone 15", "iPhone SE (3rd generation)", "iPad Pro (12.9-inch)"]
    )
  end

  desc "Nightly performance test"
  lane :test_performance do
    scan(
      scheme: "MyApp",
      only_testing: ["MyAppPerformanceTests"],
      devices: ["iPhone 15"]
    )
    # Slack'e sonuç gönder
    slack(
      message: "Performance test tamamlandı",
      slack_url: ENV["SLACK_WEBHOOK"]
    )
  end
end
```

### 10.4 CI Araçları Karşılaştırma

| Araç | Avantaj | Dezavantaj |
|------|---------|-----------|
| GitHub Actions | Ücretsiz (public repo), kolay setup | macOS runner sınırlı |
| Bitrise | iOS'a özel, hazır step'ler | Ücretli |
| Xcode Cloud | Apple entegrasyonu, TestFlight | Sınırlı dakika |
| CircleCI | Hızlı, paralel job desteği | macOS pahalı |
| Fastlane | Otomasyon aracı (CI değil, her CI ile kullanılır) | Öğrenme eğrisi |

---

## 11. Production Monitoring

Testler her şeyi yakalayamaz. Production'daki hataları yakalamak için monitoring şart.

### 11.1 Crash Reporting Kurulumu

**Firebase Crashlytics (önerilen):**
```swift
// AppDelegate.swift
import FirebaseCrashlytics

func application(_ application: UIApplication, didFinishLaunchingWithOptions ...) -> Bool {
    FirebaseApp.configure()

    // Custom key'ler ile zengin crash context
    Crashlytics.crashlytics().setCustomValue(user.plan, forKey: "subscription_type")
    Crashlytics.crashlytics().setCustomValue(AppConfig.apiVersion, forKey: "api_version")

    return true
}

// Non-fatal error raporlama
func logNonFatalError(_ error: Error, context: [String: Any] = [:]) {
    var userInfo = context
    userInfo["screen"] = currentScreen
    userInfo["timestamp"] = Date().iso8601
    Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
}
```

**Sentry (alternatif — daha detaylı):**
```swift
import Sentry

SentrySDK.start { options in
    options.dsn = "https://your-dsn@sentry.io/project"
    options.tracesSampleRate = 0.2  // Performance monitoring
    options.profilesSampleRate = 0.1  // Profiling
    options.attachScreenshot = true  // Crash anı screenshot
    options.enableAutoSessionTracking = true
}
```

### 11.2 İzlenmesi Gereken Metrikler

| Metrik | Hedef | Alarm Eşiği |
|--------|-------|-------------|
| Crash-free rate | > %99.5 | < %99 |
| ANR (App Not Responding) | < %0.5 | > %1 |
| App launch time (P95) | < 3 saniye | > 5 saniye |
| Network error rate | < %2 | > %5 |
| Memory warning oranı | < %1 | > %3 |
| User retention (D1) | > %40 | < %30 |
| App Store rating | > 4.5 | < 4.0 |

### 11.3 Feature Flag ile Güvenli Release

```swift
// Feature flag sistemi
enum FeatureFlag: String, CaseIterable {
    case newCheckoutFlow
    case redesignedProfile
    case aiRecommendations

    var isEnabled: Bool {
        RemoteConfig.shared.bool(forKey: rawValue)
    }
}

// Kullanım
if FeatureFlag.newCheckoutFlow.isEnabled {
    showNewCheckout()
} else {
    showLegacyCheckout()
}

// Canary release: önce %5 kullanıcıya aç, sorun yoksa %100'e çık
```

---

## 12. Edge Case Master Checklist

Bu liste, iOS uygulamalarında en sık kaçırılan ve production'da patlayan edge case'leri içerir. Her birini en az bir testle kapsa.

### 12.1 Network Edge Cases

- [ ] Yavaş bağlantı (3G simülasyonu)
- [ ] Bağlantı kaybı ortasında işlem
- [ ] Timeout sonrası retry mekanizması
- [ ] Aynı isteği çift gönderme (double tap)
- [ ] Büyük payload (10MB+ response)
- [ ] API 500 hatası → graceful error
- [ ] Malformed JSON response → crash olmamalı
- [ ] Certificate expiry → anlamlı hata mesajı
- [ ] DNS resolution failure
- [ ] Rate limiting (429 response)

### 12.2 Device Edge Cases

- [ ] Düşük bellek durumu (memory warning)
- [ ] Dolu disk alanı
- [ ] Arka plana gitme ve geri dönme (background/foreground)
- [ ] Gelen telefon araması sırasında işlem
- [ ] Split View / Slide Over (iPad)
- [ ] Farklı ekran boyutları (SE, Pro Max, iPad)
- [ ] Farklı iOS versiyonları (minimum desteklenen)
- [ ] Saat dilimi değişikliği
- [ ] Dil değişikliği (runtime)
- [ ] Low Power Mode'da davranış
- [ ] Airplane Mode açma/kapama
- [ ] Ekran döndürme (portrait ↔ landscape)

### 12.3 Data Edge Cases

- [ ] Boş liste / boş state
- [ ] Tek item'lı liste
- [ ] Çok uzun text (1000+ karakter)
- [ ] Özel karakterler: emoji, Arapça, Çince, Japonca
- [ ] nil / null değerler (optional handling)
- [ ] Negatif sayılar, sıfır, `Int.max`, `Double.infinity`
- [ ] Tarih edge case: 29 Şubat, yıl sonu, timezone geçişi
- [ ] Concurrent data erişimi (race condition)
- [ ] Corrupted local cache / database
- [ ] Migration: eski versiyon data'sı → yeni formata dönüşüm
- [ ] Unicode normalization farkları

### 12.4 User Behavior Edge Cases

- [ ] Hızlı art arda buton basma (rapid tapping)
- [ ] Geri tuşu ile mid-flow çıkış
- [ ] Force quit ve tekrar açma
- [ ] Birden fazla hesap arasında geçiş
- [ ] App update sonrası migration
- [ ] İlk açılış vs tekrar açılış farkı
- [ ] Permission red sonrası tekrar isteme
- [ ] Swipe gesture ile dismiss etme
- [ ] Pull-to-refresh sırasında navigasyon
- [ ] Clipboard'dan paste (beklenmedik format)

### 12.5 Concurrency Edge Cases

- [ ] Main thread'de ağır iş → UI donması
- [ ] Race condition: aynı resource'a eş zamanlı erişim
- [ ] Deadlock: birbirini bekleyen thread'ler
- [ ] Background task completion handler
- [ ] `@Sendable` closure güvenliği (Swift Concurrency)

---

## 13. Sektör Devlerinin Test Yaklaşımı

| Şirket | Yaklaşım | Önemli Detay |
|--------|----------|-------------|
| Apple | XCTest + XCUITest + Instruments | Kendi framework'leri, derin OS entegrasyonu |
| Google | XCTest + EarlGrey + Firebase Test Lab | Yüzlerce gerçek cihazda paralel test |
| Meta | FBSnapshotTestCase + custom E2E | Snapshot testing'i onlar icat etti |
| Uber | XCTest + Appium + RIBs architecture | Modüler mimari ile izole test |
| Spotify | XCTest + snapshot + feature flags | Canary release ile kademeli yayınlama |
| Airbnb | XCTest + MavericksTest framework | Custom screenshot testing altyapısı |
| Netflix | XCTest + Maestro + device farm | A/B test ile kalite ölçümü |
| Shopify | XCTest + Tophat (custom tool) | Merchant app için özel test araçları |

---

## 14. AI-Driven Geliştirme İçin Özel Test Stratejisi

AI ile kod yazıyorsan (Claude, Copilot, Cursor vs.), AI'ın ürettiği kodun standart insan kodundan farklı hata profili vardır. 2025 sonundaki araştırmalar AI-authored PR'ların ortalama 10.83 issue içerdiğini, insan PR'larının ise 6.45 olduğunu gösteriyor. Logic hataları %75, security bulguları %57 daha fazla.

### 14.1 AI Kodunun Tipik Hata Profili

| Hata Tipi | Risk Seviyesi | Açıklama |
|-----------|--------------|----------|
| Edge case eksikliği | Yüksek | Happy path çalışır, nil/empty/negatif değerlerde patlar |
| Guard clause atlama | Yüksek | Null check, early return, exception handling yetersiz |
| Context gap | Kritik | AI mevcut codebase kurallarını, business logic'i bilmez |
| Retain cycle | Orta | Closure'larda [weak self] unutulur |
| Thread safety | Yüksek | @MainActor, Sendable uyumsuzlukları |
| Deprecated API kullanımı | Orta | Eski iOS API'larını kullanabilir |
| Hardcoded değerler | Orta | Magic number, hardcoded string, URL |
| Copy-paste hataları | Orta | Benzer fonksiyonlarda kopyala-yapıştır kalıntıları |
| Overengineering | Düşük | Gereksiz abstraction, kullanılmayan protocol |

### 14.2 AI Kodu İçin Zorunlu Test Kuralları

```swift
// KURAL 1: AI her fonksiyon yazdığında, aynı PR'da test de olmalı
// Bu test AI'ın üretmediği edge case'leri de kapsamalı

// KURAL 2: Her AI-generated fonksiyon için minimum test seti:
func test_aiFunction_happyPath() { }        // Normal çalışma
func test_aiFunction_nilInput() { }          // nil/optional
func test_aiFunction_emptyInput() { }        // Boş string/array
func test_aiFunction_boundaryValues() { }    // 0, -1, Int.max
func test_aiFunction_errorCase() { }         // Hata senaryosu
func test_aiFunction_concurrency() { }       // Thread safety

// KURAL 3: AI kodunda retain cycle kontrolü zorunlu
func test_aiViewModel_noRetainCycle() {
    var vm: SomeViewModel? = SomeViewModel()
    weak var weakVM = vm
    vm = nil
    XCTAssertNil(weakVM, "AI-generated ViewModel'da retain cycle!")
}
```

### 14.3 AI Code Review Checklist (Her PR'da Kontrol Et)

- [ ] `[weak self]` closure'larda kullanılmış mı?
- [ ] `@MainActor` UI güncellemelerinde var mı?
- [ ] Guard clause / early return var mı yoksa nested if mi?
- [ ] Force unwrap (`!`) kullanılmış mı? → Kaldır
- [ ] Hardcoded string/URL var mı? → Constant'a taşı
- [ ] Deprecated API kullanılmış mı? → `#available` check ekle
- [ ] Error handling var mı? `try?` ile sessizce yutulmuş mu?
- [ ] Gereksiz `import` var mı?
- [ ] Kullanılmayan değişken/fonksiyon var mı?
- [ ] Business logic doğru mu? (AI context'i bilmez)
- [ ] Mevcut naming convention'a uygun mu?
- [ ] Mevcut architecture pattern'e (MVVM, VIPER vs.) uygun mu?

---

## 15. Static Analysis — Derleme Öncesi Hata Yakalama

AI ile geliştirmede static analysis kritik. Kod derlenmeden önce potansiyel hataları yakalar.

### 15.1 SwiftLint — Stil ve Potansiyel Hata Kontrolü

```yaml
# .swiftlint.yml — AI-driven geliştirme için önerilen kurallar
disabled_rules:
  - todo  # AI bazen TODO bırakır, CI'da engelleme

opt_in_rules:
  - force_unwrapping              # Force unwrap yasak
  - implicitly_unwrapped_optional # Implicit unwrap yasak
  - empty_count                   # .count == 0 yerine .isEmpty
  - closure_body_length           # Uzun closure → ayrı fonksiyon
  - function_body_length          # Uzun fonksiyon → parçala
  - cyclomatic_complexity         # Karmaşık logic → basitleştir
  - unused_import                 # Gereksiz import temizle
  - discouraged_optional_boolean  # Bool? karışıklık yaratır
  - fatal_error_message           # fatalError'a mesaj zorunlu
  - strong_iboutlet               # IBOutlet weak olmalı
  - private_outlet                # IBOutlet private olmalı
  - overridden_super_call         # super çağrısı zorunlu
  - unowned_variable_capture      # unowned yerine weak tercih et
  - unused_closure_parameter      # Kullanılmayan parameter _ olmalı

force_unwrapping:
  severity: error  # warning değil, ERROR — build kırılsın

function_body_length:
  warning: 40
  error: 80

cyclomatic_complexity:
  warning: 10
  error: 20

file_length:
  warning: 400
  error: 600
```

**CI'da çalıştırma:**

```bash
swiftlint lint --strict --reporter json > swiftlint_report.json
# --strict: tüm warning'lar error olur, build kırılır
```

### 15.2 Periphery — Ölü Kod Tespiti

AI sık sık kullanılmayan fonksiyon, protocol ve değişken üretir. Periphery bunları tespit eder.

```bash
# Kurulum
brew install periphery

# Çalıştırma
periphery scan \
  --project MyApp.xcodeproj \
  --schemes MyApp \
  --targets MyApp \
  --format json > periphery_report.json
```

**Periphery'nin yakaladıkları:**
- Hiçbir yerden çağrılmayan fonksiyonlar
- Kullanılmayan protocol'ler ve conformance'lar
- Hiç okunmayan property'ler
- Gereksiz import'lar
- Kullanılmayan fonksiyon parametreleri
- Hiç implement edilmeyen protocol metotları

**CI entegrasyonu:**

```yaml
# GitHub Actions'a ekle
- name: Dead Code Check
  run: |
    periphery scan \
      --project MyApp.xcodeproj \
      --schemes MyApp \
      --format checkstyle > periphery.xml
    # Yeni dead code varsa uyar
```

### 15.3 Swift Compiler Strict Concurrency

```bash
# Swift 6 strict concurrency — data race'leri derleme anında yakala
# Package.swift'e ekle:
swiftSettings: [
    .swiftLanguageMode(.v6)
    // veya kademeli geçiş için:
    // .enableUpcomingFeature("StrictConcurrency")
]
```

### 15.4 Thread Sanitizer (TSan) — Runtime Data Race Tespiti

```bash
# Xcode: Edit Scheme → Test → Diagnostics → Thread Sanitizer ✓

# xcodebuild ile:
xcodebuild test \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableThreadSanitizer YES
```

```swift
// TSan'ın yakalayacağı tipik AI hatası:
class UserCache {
    var users: [String: User] = [:]  // ← RACE CONDITION!

    func getUser(_ id: String) -> User? {
        return users[id]  // Thread A okur
    }

    func setUser(_ user: User) {
        users[user.id] = user  // Thread B yazar → CRASH
    }
}

// Doğrusu:
actor UserCache {
    var users: [String: User] = [:]

    func getUser(_ id: String) -> User? {
        return users[id]
    }

    func setUser(_ user: User) {
        users[user.id] = user
    }
}
```

### 15.5 Address Sanitizer (ASan) — Bellek Hataları

```bash
# Xcode: Edit Scheme → Test → Diagnostics → Address Sanitizer ✓

xcodebuild test \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableAddressSanitizer YES
```

Buffer overflow, use-after-free, stack overflow gibi low-level bellek hatalarını yakalar.

### 15.6 Undefined Behavior Sanitizer (UBSan)

```bash
# Xcode: Edit Scheme → Test → Diagnostics → Undefined Behavior Sanitizer ✓

xcodebuild test \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableUndefinedBehaviorSanitizer YES
```

Integer overflow, misaligned pointer, null reference gibi tanımsız davranışları yakalar.

### 15.7 Static Analysis Tablo Özeti

| Araç | Ne Yakalar | Ne Zaman Koşulur | Süre |
|------|-----------|-------------------|------|
| SwiftLint | Stil ihlali, force unwrap, karmaşıklık | Her commit | 10-30sn |
| Periphery | Ölü kod, kullanılmayan fonksiyon | Haftalık | 2-5dk |
| Swift 6 Strict Concurrency | Data race (compile-time) | Her build | Build süresine dahil |
| Thread Sanitizer | Data race (runtime) | Her test run | Test süresine +%30 |
| Address Sanitizer | Buffer overflow, use-after-free | Haftalık test | Test süresine +%100 |
| UB Sanitizer | Integer overflow, null ref | Haftalık test | Test süresine +%20 |

---

## 16. Mutation Testing — Testlerin Testini Yap

Code coverage %90 olabilir ama testlerin gerçekten bug yakalayıp yakalamadığını ölçmez. Mutation testing, koduna küçük değişiklikler (mutant) yaparak testlerinin bunu yakalayıp yakalamadığını kontrol eder.

**Coverage %100 ama mutation score %4 demek: her satırı çalıştırıyorsun ama hataların %96'sını yakalayamıyorsun.**

### 16.1 Nasıl Çalışır?

```
1. Orijinal kod:  if count > 0 { return items }
2. Mutant:        if count >= 0 { return items }    (> yerine >=)
3. Testleri koş
4. Test fail olursa → Mutant ÖLDÜ (testler çalışıyor ✓)
5. Test pass olursa → Mutant HAYATTA (testler yetersiz ✗)
```

### 16.2 Swift İçin Mutation Testing

```bash
# muter — Swift mutation testing aracı
# https://github.com/muter-mutation-testing/muter

brew install muter

# Konfigürasyon
cat > muter.conf.json << 'EOF'
{
    "xcodeProjectPath": "MyApp.xcodeproj",
    "testCommandArguments": [
        "xcodebuild", "test",
        "-scheme", "MyApp",
        "-destination", "platform=iOS Simulator,name=iPhone 15"
    ],
    "excludeFileList": [
        "AppDelegate.swift",
        "SceneDelegate.swift"
    ]
}
EOF

# Çalıştır
muter --format json > mutation_report.json
```

### 16.3 Mutation Operatörleri

| Operatör | Orijinal | Mutant | Ne Test Eder |
|----------|----------|--------|-------------|
| Relational | `>` | `>=` | Boundary condition |
| Equality | `==` | `!=` | Eşitlik kontrolü |
| Logical | `&&` | `\|\|` | Logic doğruluğu |
| Negate | `true` | `false` | Boolean logic |
| Remove | `guard else { return }` | (silindi) | Guard clause gerekliliği |
| Side effect | `array.append(x)` | (silindi) | Side effect testleri |

### 16.4 Mutation Score Hedefleri

| Modül | Minimum Score | Hedef |
|-------|--------------|-------|
| Business Logic / ViewModel | %70 | %85+ |
| Payment / Auth | %80 | %90+ |
| Utility / Helper | %75 | %90+ |
| UI Logic | %50 | %70+ |

### 16.5 AI + Mutation Testing Feedback Loop

```
1. AI kod yazar
2. AI test yazar (veya sen yazarsın)
3. Mutation testing koş
4. Hayatta kalan mutant'ları incele
5. Eksik testleri yaz
6. Tekrar mutation testing koş
7. Score %80+ olana kadar döngü
```

Bu döngü Meta'nın 2024-2025'te uyguladığı yaklaşım. Privacy test suite'inde mühendisler AI-üretilen testlerin %73'ünü kabul etti.

---

## 17. Contract Testing — API Uyumu Garantisi

Backend değişince iOS patlamasın. Contract testing, frontend ve backend arasındaki anlaşmayı otomatik doğrular.

### 17.1 PactSwift ile Consumer-Driven Contract Testing

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/surpher/PactSwift", from: "1.0.0")
]
```

```swift
import XCTest
import PactSwift

final class UserAPIContractTests: XCTestCase {
    static var mockService = MockService(
        consumer: "iOSApp",
        provider: "UserService"
    )

    func test_getUserById_contract() {
        // Given: Backend şu response'u dönecek
        Self.mockService
            .uponReceiving("a request for user by ID")
            .given("user 123 exists")
            .withRequest(method: .GET, path: "/api/users/123")
            .willRespondWith(
                status: 200,
                headers: ["Content-Type": "application/json"],
                body: [
                    "id": Matcher.SomethingLike(123),
                    "name": Matcher.SomethingLike("Ali"),
                    "email": Matcher.RegexLike(
                        "ali@test.com",
                        regex: "^[\\w.]+@[\\w.]+\\.[a-z]{2,}$"
                    ),
                    "created_at": Matcher.RegexLike(
                        "2026-01-01T00:00:00Z",
                        regex: "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$"
                    )
                ]
            )

        // When: iOS app bu endpoint'i çağırdığında
        Self.mockService.run { baseURL, done in
            let apiClient = APIClient(baseURL: baseURL)

            Task {
                do {
                    let user = try await apiClient.fetchUser(id: "123")

                    // Then: Doğru parse edilmeli
                    XCTAssertEqual(user.id, 123)
                    XCTAssertFalse(user.name.isEmpty)
                    XCTAssertTrue(user.email.contains("@"))
                } catch {
                    XCTFail("Contract test failed: \(error)")
                }
                done()
            }
        }
    }

    func test_getUserById_notFound_contract() {
        Self.mockService
            .uponReceiving("a request for non-existent user")
            .withRequest(method: .GET, path: "/api/users/999")
            .willRespondWith(
                status: 404,
                body: ["error": "User not found"]
            )

        Self.mockService.run { baseURL, done in
            let apiClient = APIClient(baseURL: baseURL)
            Task {
                do {
                    let _ = try await apiClient.fetchUser(id: "999")
                    XCTFail("404 hata fırlatmalıydı")
                } catch let error as APIError {
                    XCTAssertEqual(error, .notFound)
                }
                done()
            }
        }
    }
}
```

### 17.2 Contract Testing Neden Gerekli?

| Sorun | Contract Testing Olmadan | Contract Testing İle |
|-------|------------------------|---------------------|
| Backend field adı değişir | Production'da crash | CI'da fail, merge engellenir |
| Yeni zorunlu field eklenir | JSON decode fail | Contract kırılır, iki taraf bilgilendirilir |
| Response tipi değişir | Sessiz data kaybı | Pact doğrulaması yakalar |
| Endpoint kaldırılır | 404 hataları | Contract kırılması ile erken uyarı |

### 17.3 CI'da Contract Testing

```yaml
# 1. iOS testleri koşulduğunda .pact dosyası üretilir
# 2. Bu dosya Pact Broker'a yüklenir
# 3. Backend CI'da provider verification koşar
# 4. Her iki taraf da uyumlu olana kadar merge engellenir

- name: Run Contract Tests
  run: |
    xcodebuild test \
      -scheme MyApp \
      -only-testing:MyAppContractTests
- name: Publish Pact
  run: |
    pact-broker publish pacts/ \
      --consumer-app-version ${{ github.sha }} \
      --broker-base-url $PACT_BROKER_URL
```

---

## 18. Property-Based Testing — Rastgele Verilerle Hata Bulma

Normal testlerde sen input belirlersin. Property-based testing'de framework rastgele yüzlerce input üretir ve kuralların her seferinde doğru olup olmadığını kontrol eder.

### 18.1 SwiftCheck ile Property-Based Testing

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/typelift/SwiftCheck", from: "0.12.0")
]
```

```swift
import SwiftCheck
import XCTest

final class PropertyBasedTests: XCTestCase {

    // Örnek: JSON encode → decode her zaman orijinali geri vermeli
    func test_userModel_encodeDecode_roundTrip() {
        property("User encode/decode round-trip") <- forAll { (name: String, age: UInt) in
            let user = User(name: name, age: Int(age))
            let data = try! JSONEncoder().encode(user)
            let decoded = try! JSONDecoder().decode(User.self, from: data)
            return user == decoded
        }
    }

    // Örnek: Sıralama her zaman doğru sırada olmalı
    func test_sortAlgorithm_alwaysSorted() {
        property("Sort always produces sorted output") <- forAll { (array: [Int]) in
            let sorted = array.customSort()
            return sorted == array.sorted()
        }
    }

    // Örnek: Para hesaplaması her zaman >= 0 olmalı
    func test_priceCalculation_neverNegative() {
        property("Total price is never negative") <- forAll { (price: UInt, quantity: UInt, discount: UInt) in
            let p = Double(price) / 100.0        // 0.00 - 655.35
            let q = Int(quantity % 100) + 1       // 1 - 100
            let d = Double(discount % 100) / 100  // 0.00 - 0.99

            let total = PriceCalculator.calculate(price: p, quantity: q, discount: d)
            return total >= 0
        }
    }

    // Örnek: String sanitization idempotent olmalı
    func test_sanitization_isIdempotent() {
        property("Sanitizing twice equals sanitizing once") <- forAll { (input: String) in
            let once = InputSanitizer.sanitize(input)
            let twice = InputSanitizer.sanitize(once)
            return once == twice
        }
    }
}
```

### 18.2 Property-Based Testing Ne Zaman Kullan?

- Encode/decode round-trip testleri (JSON, Protobuf, Core Data)
- Matematiksel hesaplamalar (fiyat, vergi, puan)
- String işleme fonksiyonları (sanitize, format, parse)
- Sıralama ve filtreleme algoritmaları
- State machine geçişleri
- Serialization/deserialization

AI-generated kodda özellikle etkili çünkü AI'ın düşünmediği edge case'leri rastgele input'lar bulabilir.

---

## 19. Localization Testing

### 19.1 Otomatik Localization Kontrolleri

```swift
// Tüm localization key'lerinin karşılığı var mı?
func test_allLocalizationKeys_haveValues() {
    let bundle = Bundle.main
    let languages = ["tr", "en", "de", "fr"]

    for lang in languages {
        guard let path = bundle.path(forResource: lang, ofType: "lproj"),
              let langBundle = Bundle(path: path) else {
            XCTFail("\(lang) localization bundle bulunamadı")
            continue
        }

        for key in LocalizationKeys.allCases {
            let value = langBundle.localizedString(forKey: key.rawValue, value: nil, table: nil)
            XCTAssertNotEqual(
                value, key.rawValue,
                "'\(key.rawValue)' key'inin \(lang) çevirisi eksik"
            )
        }
    }
}

// Localized string'lerde format specifier uyuşmazlığı
func test_localizedStrings_formatSpecifiersMatch() {
    let baseStrings = loadStringsFile(language: "en")
    let targetStrings = loadStringsFile(language: "tr")

    for (key, baseValue) in baseStrings {
        guard let targetValue = targetStrings[key] else { continue }

        let baseSpecifiers = extractFormatSpecifiers(baseValue)   // ["%d", "%@"]
        let targetSpecifiers = extractFormatSpecifiers(targetValue)

        XCTAssertEqual(
            baseSpecifiers, targetSpecifiers,
            "Format specifier uyuşmazlığı - key: \(key), en: \(baseSpecifiers), tr: \(targetSpecifiers)"
        )
    }
}
```

### 19.2 Pseudo-Localization ile UI Testi

```swift
// Uzun çeviri simülasyonu — Almanca çeviriler genelde %30 daha uzun
func test_allScreens_handleLongTranslations() {
    let app = XCUIApplication()
    app.launchArguments += ["-AppleLanguages", "(de)"]
    app.launch()

    // Tüm label'ların truncate olmadığını kontrol et
    let labels = app.staticTexts.allElementsBoundByIndex
    for label in labels where label.isHittable {
        XCTAssertFalse(
            label.label.hasSuffix("..."),
            "Text truncated: \(label.label)"
        )
    }
}
```

---

## 20. SwiftUI-Specific Testing

### 20.1 ViewInspector ile SwiftUI Unit Test

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.0")
]
```

```swift
import ViewInspector
import XCTest
@testable import MyApp

final class ProfileViewTests: XCTestCase {

    func test_profileView_displaysUserName() throws {
        let view = ProfileView(user: User.mock)
        let text = try view.inspect().find(text: "Ali Yılmaz")
        XCTAssertNotNil(text)
    }

    func test_profileView_editButton_exists() throws {
        let view = ProfileView(user: User.mock)
        let button = try view.inspect().find(button: "Düzenle")
        XCTAssertNotNil(button)
    }

    func test_loginView_disablesButton_whenFieldsEmpty() throws {
        let view = LoginView()
        let button = try view.inspect().find(ViewType.Button.self)
        XCTAssertTrue(try button.isDisabled())
    }
}
```

### 20.2 SwiftUI + @Observable Testing (iOS 17+)

```swift
@Observable
class CounterViewModel {
    var count = 0
    var isLoading = false

    func increment() {
        count += 1
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        // ... async work
    }
}

// Test
func test_counter_increment() {
    let vm = CounterViewModel()
    XCTAssertEqual(vm.count, 0)

    vm.increment()
    XCTAssertEqual(vm.count, 1)

    vm.increment()
    XCTAssertEqual(vm.count, 2)
}

func test_counter_loadData_setsLoading() async {
    let vm = CounterViewModel()
    XCTAssertFalse(vm.isLoading)

    // isLoading true olmalı (async sırasında)
    let task = Task { await vm.loadData() }
    // Kısa bekle
    try? await Task.sleep(nanoseconds: 100_000_000)
    // Task bitince isLoading false olmalı
    await task.value
    XCTAssertFalse(vm.isLoading)
}
```

---

## 21. Dependency Vulnerability Scanning

### 21.1 SPM Dependency Audit

```bash
# Swift Package dependency'lerini kontrol et
# Henüz native "spm audit" yok, ama şu araçlar kullanılabilir:

# 1. Trivy — container + dependency scanner
brew install trivy
trivy fs --scanners vuln --severity HIGH,CRITICAL .

# 2. Snyk — SCA (Software Composition Analysis)
snyk test --all-projects

# 3. GitHub Dependabot — otomatik PR açar
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "swift"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
```

### 21.2 CI'da Otomatik Vulnerability Check

```yaml
# GitHub Actions
- name: Security Scan
  run: |
    trivy fs --scanners vuln --severity HIGH,CRITICAL \
      --exit-code 1 --format table .
    # HIGH veya CRITICAL vulnerability varsa build kırılır
```

### 21.3 Hardcoded Secret Taraması

```bash
# gitleaks — repo'da sızan secret'ları bulur
brew install gitleaks

gitleaks detect --source . --report-format json --report-path leaks.json
# API key, token, password, private key gibi sızıntıları bulur
```

```yaml
# CI'da
- name: Secret Scan
  run: |
    gitleaks detect --source . --exit-code 1
    # Secret bulursa build kırılır
```

---

## 22. Self-Hosted Runner ile Sıfır Maliyet CI/CD

MacBook Pro'nu GitHub Actions runner olarak kullanarak tamamen ücretsiz CI/CD:

### 22.1 Runner Kurulumu

```bash
# 1. GitHub repo → Settings → Actions → Runners → New self-hosted runner

# 2. Kurulum (macOS ARM)
mkdir ~/actions-runner && cd ~/actions-runner
curl -o actions-runner-osx-arm64.tar.gz -L \
  https://github.com/actions/runner/releases/latest/download/actions-runner-osx-arm64-2.x.x.tar.gz
tar xzf ./actions-runner-osx-arm64.tar.gz

# 3. Konfigüre et
./config.sh --url https://github.com/KULLANICI/REPO --token XXXXX

# 4. Servis olarak çalıştır (restart sonrası da açılır)
./svc.sh install
./svc.sh start
```

### 22.2 Tam Pipeline — Self-Hosted + Ücretsiz

```yaml
name: iOS Full Test Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # ━━━ AŞAMA 1: Lint + Build ━━━
  lint-and-build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4

      - name: SwiftLint
        run: swiftlint lint --strict

      - name: Build
        run: |
          xcodebuild build \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            CODE_SIGNING_ALLOWED=NO

  # ━━━ AŞAMA 2: Unit + Snapshot (paralel) ━━━
  unit-tests:
    needs: lint-and-build
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Unit Tests + Coverage
        run: |
          xcodebuild test \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:MyAppTests \
            -resultBundlePath TestResults/Unit.xcresult \
            -enableCodeCoverage YES \
            -enableThreadSanitizer YES
      - name: Coverage Report
        run: |
          xcrun xccov view --report TestResults/Unit.xcresult \
            --json > coverage.json

  snapshot-tests:
    needs: lint-and-build
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Snapshot Tests
        run: |
          xcodebuild test \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:MyAppSnapshotTests
      - name: Upload Failures
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: snapshot-failures
          path: "**/Failures/**"

  # ━━━ AŞAMA 3: Integration + Contract ━━━
  integration-tests:
    needs: [unit-tests, snapshot-tests]
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Integration + Contract Tests
        run: |
          xcodebuild test \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:MyAppIntegrationTests \
            -only-testing:MyAppContractTests

  # ━━━ AŞAMA 4: UI / E2E ━━━
  ui-tests:
    needs: integration-tests
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: E2E Tests
        run: |
          xcodebuild test \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:MyAppUITests \
            -resultBundlePath TestResults/UI.xcresult
      - name: Upload Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ui-test-results
          path: TestResults/

  # ━━━ AŞAMA 5: Security ━━━
  security-scan:
    needs: lint-and-build
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Dependency Vulnerability Scan
        run: trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 .
      - name: Secret Leak Scan
        run: gitleaks detect --source . --exit-code 1
      - name: Dead Code Check
        run: periphery scan --project MyApp.xcodeproj --schemes MyApp --format xcode

  # ━━━ NIGHTLY: Performance + Mutation ━━━
  nightly-deep-tests:
    if: github.event_name == 'schedule'
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Performance Tests
        run: |
          xcodebuild test \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -only-testing:MyAppPerformanceTests
      - name: Address Sanitizer Run
        run: |
          xcodebuild test \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -enableAddressSanitizer YES
      - name: Mutation Testing
        run: muter --format json > mutation_report.json
```

### 22.3 Maliyet Karşılaştırma

| Setup | Aylık Maliyet | Dakika Sınırı | Hız |
|-------|--------------|---------------|-----|
| GitHub Actions (hosted macOS) | ~$80-200 | 3000 dk/ay | Orta |
| Bitrise | $90-270 | Plan'a göre | İyi |
| Xcode Cloud | $25-100 | 25-1000 saat | Orta |
| **Self-hosted MacBook Pro** | **$0** | **Sınırsız** | **En hızlı** |

---

## 23. Sıfırdan Başlama Planı (AI-Driven Geliştirme İçin)

### Hafta 1-2: Temel Altyapı
1. XCTest projesi oluştur, ilk unit testleri yaz (ViewModel + Utility)
2. SwiftLint ekle, AI-optimized kural seti konfigüre et (Bölüm 15.1)
3. Self-hosted runner kur (MacBook Pro) + GitHub Actions pipeline
4. Code coverage raporlamasını aktifleştir
5. Thread Sanitizer'ı varsayılan olarak aç

### Hafta 3-4: Genişleme
1. swift-snapshot-testing ekle, her ekran için baseline oluştur
2. Mock layer'ı kur (protocol-based DI)
3. Integration testleri yaz (API + DB)
4. Periphery ekle — haftalık dead code taraması

### Hafta 5-6: E2E ve Contract
1. XCUITest veya Maestro ile kritik 5 akışı test et
2. PactSwift ile contract testleri yaz (backend uyumunu garanti et)
3. Property-based testleri kritik hesaplama fonksiyonlarına ekle
4. Localization testleri

### Hafta 7-8: Performance ve Security
1. Performance baseline'ları oluştur + memory leak testleri
2. Firebase Crashlytics entegrasyonu
3. Security testleri (Keychain audit, HTTPS, gitleaks, trivy)
4. Accessibility audit entegrasyonu

### Hafta 9-10: Derinleştirme
1. Mutation testing kur — testlerin kalitesini ölç
2. Edge case testleri (Bölüm 12 checklist'inden)
3. Nightly pipeline: performance + ASan + mutation
4. AI Code Review Checklist'i PR template'ine ekle (Bölüm 14.3)
5. SwiftUI ViewInspector testleri

### Sürekli (Ongoing)
- Her AI-generated PR'da: lint → unit → snapshot → integration → contract → E2E
- Haftalık: dead code scan + dependency vulnerability scan + secret scan
- Nightly: performance + address sanitizer + mutation testing
- Her release öncesi: accessibility audit + security audit + full regression

---

## Sonuç

Bu rehber 13 test katmanını kapsıyor:

1. **Unit Test** — Logic doğruluğu
2. **Snapshot Test** — Görsel regresyon
3. **Integration Test** — Modül uyumu
4. **UI / E2E Test** — Kullanıcı akışları
5. **Performance Test** — Hız ve bellek
6. **Security Test** — Veri güvenliği
7. **Accessibility Test** — Erişilebilirlik
8. **Static Analysis** — Derleme öncesi hata tespiti
9. **Mutation Testing** — Test kalitesi ölçümü
10. **Contract Testing** — API uyumu
11. **Property-Based Testing** — Rastgele edge case bulma
12. **Localization Testing** — Çeviri doğruluğu
13. **Production Monitoring** — Canlı hata takibi

AI-driven geliştirmede bu katmanların tamamı kritik. AI kodu daha fazla edge case hatası, daha fazla security açığı ve daha fazla context gap içerir. **Coverage değil, mutation score ölç. Stil değil, güvenlik kontrol et. Happy path değil, edge case'leri test et.**

Tamamını uyguladığında hataların **%97+'sini** production öncesi yakalarsın. Kalan %3 için production monitoring + feature flags + canary release kombinasyonu kullan.

**Her 1 saat test yazma = 10+ saat debug zamanı tasarrufu.**
**AI ile 10x hızlı kod yaz, bu rehber ile 10x güvenli gönder.**
