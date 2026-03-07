# Android Test Mimarisi — Her Problemi Bulan Sistem

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
| Performance Test | %3-5 | Dakika | Memory leak, ANR, jank |
| Security Test | %2-3 | Dakika | Data sızdırma, MITM, insecure storage |
| Accessibility Test | %1-2 | Saniye | TalkBack, content description, kontrast |

**Altın Kural:** Her katman bağımsız çalışabilmeli. CI/CD'de her PR'da otomatik koşmalı. Flaky test = yok sayılan test — ya fix'le ya sil.

---

## 2. Unit Test Katmanı

### 2.1 JUnit 5 + MockK — Temel Yapı

```kotlin
import io.mockk.*
import org.junit.jupiter.api.*
import org.junit.jupiter.api.Assertions.*

class PaymentCalculatorTest {
    private lateinit var sut: PaymentCalculator

    @BeforeEach
    fun setUp() {
        sut = PaymentCalculator()
    }

    @Test
    fun `calculateTotal with discount returns correct amount`() {
        val result = sut.calculateTotal(price = 100.0, discount = 0.2)
        assertEquals(80.0, result, 0.01)
    }

    @Test
    fun `calculateTotal with negative price throws exception`() {
        assertThrows<IllegalArgumentException> {
            sut.calculateTotal(price = -10.0, discount = 0.0)
        }
    }

    @Test
    fun `calculateTotal with zero price returns zero`() {
        val result = sut.calculateTotal(price = 0.0, discount = 0.5)
        assertEquals(0.0, result, 0.01)
    }

    @Test
    fun `calculateTotal with 100% discount returns zero`() {
        val result = sut.calculateTotal(price = 100.0, discount = 1.0)
        assertEquals(0.0, result, 0.01)
    }
}
```

### 2.2 Neyi Test Etmeli?

- Tüm public fonksiyonlar (happy path + edge case)
- Boundary değerler: `null`, boş string, `0`, negatif, `Int.MAX_VALUE`
- Error handling: her exception senaryosu
- ViewModel logic: state değişiklikleri, LiveData/StateFlow emit'leri
- UseCase / Repository katmanları
- Model mapping: JSON parse, DTO dönüşümleri
- Utility fonksiyonlar: tarih formatlama, string parse, para hesaplama

### 2.3 MockK ile Mocking

```kotlin
// Interface tanımı
interface UserRepository {
    suspend fun getUser(id: String): User
    suspend fun saveUser(user: User)
}

// Test
class ProfileViewModelTest {
    private val mockRepo = mockk<UserRepository>()
    private lateinit var viewModel: ProfileViewModel

    @BeforeEach
    fun setUp() {
        viewModel = ProfileViewModel(mockRepo)
    }

    @Test
    fun `loadProfile success updates state to loaded`() = runTest {
        // Given
        val mockUser = User(id = "123", name = "Ali")
        coEvery { mockRepo.getUser("123") } returns mockUser

        // When
        viewModel.loadProfile("123")

        // Then
        assertEquals(UiState.Loaded(mockUser), viewModel.state.value)
        coVerify(exactly = 1) { mockRepo.getUser("123") }
    }

    @Test
    fun `loadProfile failure updates state to error`() = runTest {
        // Given
        coEvery { mockRepo.getUser(any()) } throws NetworkException("Timeout")

        // When
        viewModel.loadProfile("123")

        // Then
        assertTrue(viewModel.state.value is UiState.Error)
    }

    @Test
    fun `loadProfile captures correct user id`() = runTest {
        val slot = slot<String>()
        coEvery { mockRepo.getUser(capture(slot)) } returns User.MOCK

        viewModel.loadProfile("456")

        assertEquals("456", slot.captured)
    }
}
```

### 2.4 Coroutine Testing (Turbine + runTest)

```kotlin
// build.gradle.kts
testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.8.1")
testImplementation("app.cash.turbine:turbine:1.1.0")

// StateFlow testi — Turbine ile
@Test
fun `counter increments correctly`() = runTest {
    val viewModel = CounterViewModel()

    viewModel.state.test {
        assertEquals(0, awaitItem())  // initial state

        viewModel.increment()
        assertEquals(1, awaitItem())

        viewModel.increment()
        assertEquals(2, awaitItem())

        cancelAndIgnoreRemainingEvents()
    }
}

// SharedFlow (event) testi
@Test
fun `login emits navigation event on success`() = runTest {
    val viewModel = LoginViewModel(mockAuthRepo)
    coEvery { mockAuthRepo.login(any(), any()) } returns AuthResult.Success

    viewModel.events.test {
        viewModel.login("user@test.com", "pass123")

        val event = awaitItem()
        assertTrue(event is NavigationEvent.GoToHome)

        cancelAndIgnoreRemainingEvents()
    }
}
```

### 2.5 Robolectric — Android Framework Testleri JVM'de

```kotlin
// build.gradle.kts
testImplementation("org.robolectric:robolectric:4.12")

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SharedPreferencesManagerTest {

    private lateinit var context: Context
    private lateinit var prefsManager: SharedPreferencesManager

    @Before
    fun setUp() {
        context = ApplicationProvider.getApplicationContext()
        prefsManager = SharedPreferencesManager(context)
    }

    @Test
    fun `saveToken stores in encrypted prefs`() {
        prefsManager.saveToken("test-token")

        val stored = prefsManager.getToken()
        assertEquals("test-token", stored)
    }

    @Test
    fun `clearAll removes all data`() {
        prefsManager.saveToken("token")
        prefsManager.saveUserId("123")

        prefsManager.clearAll()

        assertNull(prefsManager.getToken())
        assertNull(prefsManager.getUserId())
    }
}
```

### 2.6 Code Coverage Hedefleri

| Modül Tipi | Minimum | Hedef |
|------------|---------|-------|
| Business Logic / ViewModel | %80 | %90+ |
| UseCase / Repository | %85 | %95+ |
| Utility / Helper | %90 | %95+ |
| Network Layer | %70 | %85+ |
| UI Components | %50 | %70+ |

```kotlin
// build.gradle.kts — JaCoCo konfigürasyonu
plugins {
    id("jacoco")
}

tasks.withType<Test> {
    finalizedBy(tasks.jacocoTestReport)
}

tasks.jacocoTestReport {
    reports {
        xml.required.set(true)  // CI için
        html.required.set(true) // İnsan için
    }
}
```

---

## 3. Snapshot (Görsel Regresyon) Testleri

### 3.1 Paparazzi (Cash App) — JVM'de Çalışan Screenshot Test

Emulator gerektirmez, JVM'de çalışır, çok hızlıdır.

```kotlin
// build.gradle.kts
plugins {
    id("app.cash.paparazzi") version "1.3.4"
}
```

```kotlin
import app.cash.paparazzi.Paparazzi
import org.junit.Rule
import org.junit.Test

class LoginScreenSnapshotTest {
    @get:Rule
    val paparazzi = Paparazzi(
        deviceConfig = DeviceConfig.PIXEL_6,
        theme = "Theme.MyApp"
    )

    @Test
    fun `login screen default state`() {
        paparazzi.snapshot {
            LoginScreen(
                state = LoginUiState.Initial,
                onLogin = {},
                onForgotPassword = {}
            )
        }
    }

    @Test
    fun `login screen error state`() {
        paparazzi.snapshot {
            LoginScreen(
                state = LoginUiState.Error("Hatalı şifre"),
                onLogin = {},
                onForgotPassword = {}
            )
        }
    }

    @Test
    fun `login screen loading state`() {
        paparazzi.snapshot {
            LoginScreen(
                state = LoginUiState.Loading,
                onLogin = {},
                onForgotPassword = {}
            )
        }
    }

    @Test
    fun `login screen dark mode`() {
        paparazzi.snapshot {
            MyAppTheme(darkTheme = true) {
                LoginScreen(
                    state = LoginUiState.Initial,
                    onLogin = {},
                    onForgotPassword = {}
                )
            }
        }
    }

    @Test
    fun `login screen large font`() {
        paparazzi.snapshot(
            deviceConfig = DeviceConfig.PIXEL_6.copy(fontScale = 2.0f)
        ) {
            LoginScreen(
                state = LoginUiState.Initial,
                onLogin = {},
                onForgotPassword = {}
            )
        }
    }
}
```

### 3.2 Her Ekran İçin Test Edilmesi Gereken State'ler

1. Default / Empty State
2. Loading State
3. Loaded / Success State (data ile)
4. Error State
5. Dark Mode
6. Large Font (fontScale = 2.0)
7. RTL Layout (Arapça/İbranice)
8. Landscape (destekleniyorsa)
9. Tablet (multi-window ise)
10. Material You dynamic color (API 31+)

### 3.3 Roborazzi (Alternatif)

```kotlin
// build.gradle.kts
plugins {
    id("io.github.takahirom.roborazzi") version "1.20.0"
}

// Robolectric tabanlı, Activity/Fragment ile de çalışır
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class ProfileScreenRoborazziTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun captureProfileScreen() {
        composeTestRule.setContent {
            ProfileScreen(user = User.MOCK)
        }
        composeTestRule.onRoot().captureRoboImage()
    }
}
```

**Strateji:** Snapshot dosyalarını git'e commit'le → PR review'da görsel değişiklikleri gör.

---

## 4. Integration Test Katmanı

### 4.1 Network Integration — MockWebServer

```kotlin
// build.gradle.kts
testImplementation("com.squareup.okhttp3:mockwebserver:4.12.0")
```

```kotlin
class UserApiIntegrationTest {
    private lateinit var mockWebServer: MockWebServer
    private lateinit var apiService: UserApiService

    @BeforeEach
    fun setUp() {
        mockWebServer = MockWebServer()
        mockWebServer.start()

        val retrofit = Retrofit.Builder()
            .baseUrl(mockWebServer.url("/"))
            .addConverterFactory(MoshiConverterFactory.create())
            .build()

        apiService = retrofit.create(UserApiService::class.java)
    }

    @AfterEach
    fun tearDown() {
        mockWebServer.shutdown()
    }

    @Test
    fun `fetchUsers returns correctly parsed list`() = runTest {
        // Given
        val mockResponse = """
            [{"id": 1, "name": "Ali"}, {"id": 2, "name": "Ayşe"}]
        """.trimIndent()

        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setHeader("Content-Type", "application/json")
                .setBody(mockResponse)
        )

        // When
        val users = apiService.getUsers()

        // Then
        assertEquals(2, users.size)
        assertEquals("Ali", users[0].name)

        // Request doğrulama
        val request = mockWebServer.takeRequest()
        assertEquals("GET", request.method)
        assertEquals("/api/users", request.path)
    }

    @Test
    fun `fetchUsers handles 500 error gracefully`() = runTest {
        mockWebServer.enqueue(MockResponse().setResponseCode(500))

        assertThrows<HttpException> {
            apiService.getUsers()
        }
    }

    @Test
    fun `fetchUsers handles malformed json`() = runTest {
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody("not valid json{{{")
        )

        assertThrows<JsonDataException> {
            apiService.getUsers()
        }
    }
}
```

### 4.2 Room Database Integration

```kotlin
@RunWith(RobolectricTestRunner::class)
class UserDaoTest {
    private lateinit var database: AppDatabase
    private lateinit var userDao: UserDao

    @Before
    fun setUp() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        database = Room.inMemoryDatabaseBuilder(context, AppDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        userDao = database.userDao()
    }

    @After
    fun tearDown() {
        database.close()
    }

    @Test
    fun `insert and retrieve user`() = runTest {
        val user = UserEntity(id = "1", name = "Ali", email = "ali@test.com")
        userDao.insert(user)

        val retrieved = userDao.getUserById("1")
        assertEquals("Ali", retrieved?.name)
    }

    @Test
    fun `update user replaces existing`() = runTest {
        val user = UserEntity(id = "1", name = "Ali", email = "ali@test.com")
        userDao.insert(user)

        val updated = user.copy(name = "Ali Yılmaz")
        userDao.update(updated)

        val retrieved = userDao.getUserById("1")
        assertEquals("Ali Yılmaz", retrieved?.name)
    }

    @Test
    fun `delete user removes from database`() = runTest {
        val user = UserEntity(id = "1", name = "Ali", email = "ali@test.com")
        userDao.insert(user)
        userDao.delete(user)

        val retrieved = userDao.getUserById("1")
        assertNull(retrieved)
    }

    @Test
    fun `getAllUsers returns flow of users`() = runTest {
        userDao.getAllUsers().test {
            assertEquals(emptyList<UserEntity>(), awaitItem())

            userDao.insert(UserEntity("1", "Ali", "ali@test.com"))
            assertEquals(1, awaitItem().size)

            cancelAndIgnoreRemainingEvents()
        }
    }
}
```

### 4.3 Test Edilmesi Gereken Entegrasyon Noktaları

- API client → JSON parse → Model mapping zinciri
- Room database CRUD operasyonları + migration
- DataStore / SharedPreferences okuma/yazma
- Deep link routing: URI → doğru ekrana yönlendirme
- Push notification (FCM) payload → doğru aksiyon
- Analytics event'leri: doğru parametrelerle doğru zamanda
- Feature flag'ler: flag değişince UI güncellenmesi
- Auth token refresh: expired → refresh → retry zinciri
- WorkManager job'ları: doğru koşullarda tetikleniyor mu

---

## 5. UI / End-to-End (E2E) Test Katmanı

### 5.1 Jetpack Compose Testing

```kotlin
// build.gradle.kts
androidTestImplementation("androidx.compose.ui:ui-test-junit4:1.7.4")
debugImplementation("androidx.compose.ui:ui-test-manifest:1.7.4")
```

```kotlin
class LoginScreenTest {
    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun loginFlow_withValidCredentials_showsHome() {
        composeTestRule.setContent {
            MyAppTheme {
                LoginScreen(
                    onLoginSuccess = { /* navigate to home */ }
                )
            }
        }

        // Email gir
        composeTestRule
            .onNodeWithTag("emailTextField")
            .performTextInput("test@example.com")

        // Şifre gir
        composeTestRule
            .onNodeWithTag("passwordTextField")
            .performTextInput("password123")

        // Login butonuna bas
        composeTestRule
            .onNodeWithText("Giriş Yap")
            .performClick()

        // Başarılı giriş mesajı
        composeTestRule
            .onNodeWithText("Hoşgeldiniz")
            .assertIsDisplayed()
    }

    @Test
    fun loginFlow_emptyFields_showsValidation() {
        composeTestRule.setContent {
            MyAppTheme { LoginScreen(onLoginSuccess = {}) }
        }

        composeTestRule
            .onNodeWithText("Giriş Yap")
            .performClick()

        composeTestRule
            .onNodeWithText("E-posta gerekli")
            .assertIsDisplayed()
    }

    @Test
    fun loginButton_isDisabled_whenFieldsEmpty() {
        composeTestRule.setContent {
            MyAppTheme { LoginScreen(onLoginSuccess = {}) }
        }

        composeTestRule
            .onNodeWithText("Giriş Yap")
            .assertIsNotEnabled()
    }
}
```

### 5.2 Espresso (View-Based UI için)

```kotlin
@RunWith(AndroidJUnit4::class)
class LoginActivityTest {

    @get:Rule
    val activityRule = ActivityScenarioRule(LoginActivity::class.java)

    @Test
    fun loginFlow_withValidCredentials_navigatesToHome() {
        // Email gir
        onView(withId(R.id.emailEditText))
            .perform(typeText("test@example.com"), closeSoftKeyboard())

        // Şifre gir
        onView(withId(R.id.passwordEditText))
            .perform(typeText("password123"), closeSoftKeyboard())

        // Login butonuna bas
        onView(withId(R.id.loginButton))
            .perform(click())

        // Home ekranı göründü mü?
        onView(withId(R.id.welcomeText))
            .check(matches(isDisplayed()))
    }
}
```

### 5.3 Maestro — Hızlı E2E Alternatifi

```yaml
# login_flow.yaml
appId: com.myapp.android
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
appId: com.myapp.android
---
- launchApp
- tapOn: "Ürünler"
- tapOn:
    id: "product_card_0"
- tapOn: "Sepete Ekle"
- tapOn: "Sepetim"
- assertVisible: "1 ürün"
- tapOn: "Ödemeye Geç"
- assertVisible: "Ödeme Bilgileri"
- takeScreenshot: checkout_screen
```

```bash
# Maestro CLI
maestro test login_flow.yaml
maestro test flows/
maestro test --device "Pixel 7" login_flow.yaml
```

### 5.4 Compose Test vs Espresso vs Maestro

| Özellik | Compose Test | Espresso | Maestro |
|---------|-------------|----------|---------|
| UI Framework | Compose | View-based | Her ikisi |
| Dil | Kotlin | Kotlin | YAML |
| Hız | Hızlı | Orta | Hızlı |
| Flaky test oranı | Düşük | Orta | Çok düşük |
| Cross-platform | Hayır | Hayır | Evet (iOS da) |
| Emulator gerekli mi? | Evet (androidTest) | Evet | Evet |
| Debugging | Semantic tree | View hierarchy | Maestro Studio |

**Öneri:** Compose Test → component-level UI test. Maestro → kritik akış E2E. Espresso → legacy View-based kod.

### 5.5 Kritik E2E Akışları — Mutlaka Test Et

| Akış | Senaryo Sayısı | Öncelik |
|------|---------------|---------|
| Kayıt / Onboarding | 3-5 | P0 - Kritik |
| Login / Logout | 4-6 | P0 - Kritik |
| Ana akış (core feature) | 5-10 | P0 - Kritik |
| Satın alma / Ödeme (Google Play Billing) | 4-6 | P0 - Kritik |
| Profil düzenleme | 3-4 | P1 - Yüksek |
| Arama / Filtreleme | 3-5 | P1 - Yüksek |
| Push notification etkileşimi | 2-3 | P2 - Orta |
| Deep link | 3-4 | P2 - Orta |
| Offline mode | 2-3 | P1 - Yüksek |
| Error recovery | 3-4 | P1 - Yüksek |

### 5.6 Robot Pattern (UI Test'leri Temiz Tutma)

```kotlin
// Robot tanımı
class LoginRobot(private val rule: ComposeTestRule) {
    fun enterEmail(email: String) = apply {
        rule.onNodeWithTag("emailTextField").performTextInput(email)
    }
    fun enterPassword(password: String) = apply {
        rule.onNodeWithTag("passwordTextField").performTextInput(password)
    }
    fun clickLogin() = apply {
        rule.onNodeWithText("Giriş Yap").performClick()
    }
    fun assertWelcomeVisible() {
        rule.onNodeWithText("Hoşgeldiniz").assertIsDisplayed()
    }
    fun assertErrorVisible(message: String) {
        rule.onNodeWithText(message).assertIsDisplayed()
    }
}

// Test — çok daha okunabilir
@Test
fun loginFlow_success() {
    LoginRobot(composeTestRule)
        .enterEmail("test@example.com")
        .enterPassword("pass123")
        .clickLogin()
        .assertWelcomeVisible()
}

@Test
fun loginFlow_invalidCredentials() {
    LoginRobot(composeTestRule)
        .enterEmail("wrong@email.com")
        .enterPassword("wrong")
        .clickLogin()
        .assertErrorVisible("Hatalı şifre")
}
```

---

## 6. Performance Test Katmanı

### 6.1 Macrobenchmark — App Launch ve UI Performance

```kotlin
// benchmark module: build.gradle.kts
plugins {
    id("com.android.test")
    id("androidx.benchmark")
}

dependencies {
    implementation("androidx.benchmark:benchmark-macro-junit4:1.3.3")
}
```

```kotlin
@RunWith(AndroidJUnit4::class)
class AppStartupBenchmark {
    @get:Rule
    val benchmarkRule = MacrobenchmarkRule()

    @Test
    fun startupColdCompilation() = benchmarkRule.measureRepeated(
        packageName = "com.myapp.android",
        metrics = listOf(StartupTimingMetric()),
        iterations = 10,
        startupMode = StartupMode.COLD,
        setupBlock = { pressHome() }
    ) {
        startActivityAndWait()
    }

    @Test
    fun scrollFeedPerformance() = benchmarkRule.measureRepeated(
        packageName = "com.myapp.android",
        metrics = listOf(FrameTimingMetric()),
        iterations = 5,
        startupMode = StartupMode.WARM
    ) {
        startActivityAndWait()
        // Feed ekranında scroll
        val feedList = device.findObject(By.res("feedList"))
        feedList.setGestureMargin(device.displayWidth / 5)
        repeat(3) {
            feedList.fling(Direction.DOWN)
            device.waitForIdle()
        }
    }
}
```

### 6.2 Microbenchmark — Fonksiyon Seviyesi

```kotlin
@RunWith(AndroidJUnit4::class)
class JsonParsingBenchmark {
    @get:Rule
    val benchmarkRule = BenchmarkRule()

    @Test
    fun parseUserListFromJson() {
        benchmarkRule.measureRepeated {
            val result = runWithTimingDisabled {
                loadJsonFromAssets("users_100.json")
            }
            MoshiParser.parseUserList(result)
        }
    }

    @Test
    fun imageResizingPerformance() {
        benchmarkRule.measureRepeated {
            val bitmap = runWithTimingDisabled {
                loadBitmapFromAssets("large_image.jpg")
            }
            ImageProcessor.resize(bitmap, 200, 200)
        }
    }
}
```

### 6.3 Memory Leak Detection — LeakCanary

```kotlin
// build.gradle.kts
debugImplementation("com.squareup.leakcanary:leakcanary-android:2.14")

// Otomatik çalışır, debug build'de:
// - Activity/Fragment/ViewModel leak'lerini yakalar
// - Notification ile bildirir
// - Heap dump analizi yapar

// CI'da kullanım:
androidTestImplementation("com.squareup.leakcanary:leakcanary-android-instrumentation:2.14")
```

```kotlin
// Test'te leak kontrolü
@RunWith(AndroidJUnit4::class)
class LeakTest {
    @get:Rule
    val rule = LeakAssertions.none()

    @Test
    fun profileScreen_noLeaks() {
        val scenario = launchActivity<ProfileActivity>()
        scenario.moveToState(Lifecycle.State.DESTROYED)
        // LeakCanary otomatik kontrol eder
    }
}
```

### 6.4 Strict Mode — Runtime Performance Uyarıları

```kotlin
// Application.onCreate() içinde (debug build):
if (BuildConfig.DEBUG) {
    StrictMode.setThreadPolicy(
        StrictMode.ThreadPolicy.Builder()
            .detectDiskReads()
            .detectDiskWrites()
            .detectNetwork()       // Main thread'de network!
            .detectCustomSlowCalls()
            .penaltyLog()
            .penaltyDeath()        // Crash yap — görmezden gelme
            .build()
    )
    StrictMode.setVmPolicy(
        StrictMode.VmPolicy.Builder()
            .detectLeakedSqlLiteObjects()
            .detectLeakedClosableObjects()
            .detectActivityLeaks()
            .detectFileUriExposure()
            .penaltyLog()
            .build()
    )
}
```

### 6.5 Performance Baselines

| Metrik | Kabul Edilebilir | Uyarı | Kritik |
|--------|-----------------|-------|--------|
| App Launch (cold) | < 2 saniye | 2-4 saniye | > 4 saniye |
| Ekran geçişi | < 300ms | 300-800ms | > 800ms |
| API response + render | < 1 saniye | 1-3 saniye | > 3 saniye |
| Bellek kullanımı | < 150MB | 150-300MB | > 300MB |
| Scroll jank (dropped frames) | < %1 | %1-5 | > %5 |
| APK boyutu | < 30MB | 30-80MB | > 80MB |
| Battery (1 saat) | < %5 | %5-10 | > %10 |

### 6.6 Android Profiler Checklist

- **CPU Profiler:** Hangi fonksiyon ne kadar CPU harcıyor?
- **Memory Profiler:** Heap dump, allocation tracking, leak tespiti
- **Network Profiler:** API call süreleri, payload boyutları
- **Energy Profiler:** Battery drain analizi, WakeLock kullanımı
- **Compose Recomposition Count:** Gereksiz recomposition var mı?

---

## 7. Security Test Katmanı

### 7.1 Otomatik Security Kontrolleri

```kotlin
// 1. EncryptedSharedPreferences testi
@Test
fun `auth token stored in encrypted prefs not plain prefs`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    authService.saveToken("test-token")

    // Plain SharedPreferences'ta OLMAMALI
    val plainPrefs = context.getSharedPreferences("prefs", Context.MODE_PRIVATE)
    assertNull(plainPrefs.getString("auth_token", null))
    assertNull(plainPrefs.getString("token", null))
    assertNull(plainPrefs.getString("access_token", null))

    // EncryptedSharedPreferences'ta OLMALI
    val token = authService.getToken()
    assertEquals("test-token", token)
}

// 2. HTTPS zorunluluk testi
@Test
fun `all endpoints use HTTPS`() {
    val endpoints = ApiEndpoint.entries
    for (endpoint in endpoints) {
        assertTrue(
            endpoint.url.startsWith("https://"),
            "${endpoint.name} HTTPS kullanmıyor! URL: ${endpoint.url}"
        )
    }
}

// 3. Network Security Config doğrulama
@Test
fun `network security config disables cleartext`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val info = context.packageManager.getApplicationInfo(
        context.packageName, PackageManager.GET_META_DATA
    )
    // android:usesCleartextTraffic="false" olmalı
    assertFalse((info.flags and ApplicationInfo.FLAG_USES_CLEARTEXT_TRAFFIC) != 0)
}

// 4. Hassas veri loglama kontrolü
@Test
fun `sensitive data not in logs`() {
    val sensitivePatterns = listOf("password", "token", "credit_card", "ssn", "cvv")
    val logOutput = captureLogOutput {
        authService.login("test@test.com", "secret123")
    }
    for (pattern in sensitivePatterns) {
        assertFalse(
            logOutput.lowercase().contains(pattern),
            "Hassas veri loglanıyor: $pattern"
        )
    }
}

// 5. Root detection
@Test
fun `root detection works on emulator`() {
    val detector = RootDetector()
    // Emulator'da çoğu root check false dönmeli
    assertNotNull(detector.checkSuperUser)
    assertNotNull(detector.checkBusyBox)
    assertNotNull(detector.checkSuBinary)
}

// 6. ProGuard/R8 obfuscation kontrolü (CI'da çalıştırılır)
// Not: Bu kontrol build pipeline'da yapılır, unit test olarak değil.
// Bölüm 29'daki R8/ProGuard Test bölümüne bakınız.
```

### 7.2 AndroidManifest Security Audit

```kotlin
@Test
fun `manifest security settings`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val appInfo = context.packageManager.getApplicationInfo(
        context.packageName, PackageManager.GET_META_DATA
    )

    // debuggable false olmalı (release)
    if (!BuildConfig.DEBUG) {
        assertFalse(
            (appInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0,
            "Release build debuggable olmamalı!"
        )
    }

    // allowBackup false olmalı (hassas veri koruma)
    assertFalse(
        (appInfo.flags and ApplicationInfo.FLAG_ALLOW_BACKUP) != 0,
        "allowBackup true olmamalı — hassas veriler yedeklenir!"
    )
}
```

### 7.3 OWASP Mobile Top 10 Checklist (Android)

| Risk | Test Yöntemi |
|------|-------------|
| M1: Improper Credential Usage | EncryptedSharedPreferences audit, hardcoded secret taraması |
| M2: Inadequate Supply Chain | `./gradlew dependencyCheckAnalyze` (OWASP Dependency Check) |
| M3: Insecure Auth/Authz | Token expiry, biometric auth testi |
| M4: Insufficient Input Validation | Fuzzing, SQL injection, WebView XSS |
| M5: Insecure Communication | MITM proxy (Charles/Proxyman), certificate pinning |
| M6: Inadequate Privacy Controls | PII loglama kontrolü, analytics audit |
| M7: Insufficient Binary Protection | APK decompile analizi (jadx), ProGuard/R8 |
| M8: Security Misconfiguration | AndroidManifest audit, network_security_config |
| M9: Insecure Data Storage | Internal storage taraması, encrypted database |
| M10: Insufficient Cryptography | Encryption algoritması audit, KeyStore kullanımı |

---

## 8. Accessibility Test Katmanı

### 8.1 Compose Accessibility Testing

```kotlin
@Test
fun `all buttons have content descriptions`() {
    composeTestRule.setContent {
        MyAppTheme { HomeScreen() }
    }

    // Tüm clickable node'ların content description'ı olmalı
    composeTestRule
        .onAllNodes(hasClickAction())
        .fetchSemanticsNodes()
        .forEach { node ->
            val contentDesc = node.config.getOrElse(SemanticsProperties.ContentDescription) { null }
            val text = node.config.getOrElse(SemanticsProperties.Text) { null }
            assertTrue(
                contentDesc != null || text != null,
                "Clickable element'in description'ı eksik: $node"
            )
        }
}

@Test
fun `touch targets meet minimum size`() {
    composeTestRule.setContent {
        MyAppTheme { HomeScreen() }
    }

    val density = composeTestRule.density
    val minSizePx = with(density) { 48.dp.toPx() }

    composeTestRule
        .onAllNodes(hasClickAction())
        .fetchSemanticsNodes()
        .forEach { node ->
            val bounds = node.boundsInRoot
            val width = bounds.width
            val height = bounds.height
            assertTrue(
                width >= minSizePx && height >= minSizePx,
                "Touch target çok küçük: ${width}x${height}px (min: ${minSizePx}px = 48dp)"
            )
        }
}
```

### 8.2 Accessibility Scanner (Google)

```kotlin
// build.gradle.kts
androidTestImplementation("com.google.android.apps.common.testing.accessibility.framework:accessibility-test-framework:4.1.0")

@RunWith(AndroidJUnit4::class)
class AccessibilityTest {
    @get:Rule
    val activityRule = ActivityScenarioRule(MainActivity::class.java)

    @Test
    fun homeScreen_passesAccessibilityChecks() {
        activityRule.scenario.onActivity { activity ->
            val rootView = activity.window.decorView.rootView
            val result = AccessibilityCheckResultUtils.getResultsForView(rootView)
            assertTrue(result.none { it.type == AccessibilityCheckResult.AccessibilityCheckResultType.ERROR })
        }
    }
}
```

### 8.3 Manuel Accessibility Test Checklist

1. TalkBack ile tam uygulama gezintisi (her ekran, her buton)
2. Switch Access ile navigasyon
3. Font boyutu: En büyük boyutta UI kırılıyor mu?
4. Display size: En büyük boyutta overflow var mı?
5. High contrast mode: Tüm text'ler okunabiliyor mu?
6. Color inversion: UI mantıklı mı?
7. Keyboard navigation: Tab order mantıklı mı?
8. RTL layout: Arapça/İbranice düzgün mü?

---

## 9. Network Condition Testing

### 9.1 Test Edilecek Network Senaryoları

```kotlin
enum class NetworkCondition(val delayMs: Long, val lossPercent: Int) {
    WIFI(50, 0),
    LTE(100, 1),
    THREE_G(500, 5),
    EDGE(2000, 10),
    OFFLINE(0, 100),
    FLAKY(200, 30),
    TIMEOUT(30000, 0)
}
```

### 9.2 MockWebServer ile Network Simülasyonu

```kotlin
@Test
fun `slow network shows loading state`() = runTest {
    mockWebServer.enqueue(
        MockResponse()
            .setResponseCode(200)
            .setBody(mockJson)
            .throttleBody(1024, 1, TimeUnit.SECONDS)  // 1KB/sn — yavaş
    )

    viewModel.loadData()

    // Loading state göründü mü?
    assertEquals(UiState.Loading, viewModel.state.value)
}

@Test
fun `timeout shows error with retry option`() = runTest {
    mockWebServer.enqueue(
        MockResponse()
            .setResponseCode(200)
            .setBodyDelay(35, TimeUnit.SECONDS)  // Timeout
    )

    viewModel.loadData()

    assertTrue(viewModel.state.value is UiState.Error)
}
```

Her kritik akış (login, ödeme, veri yükleme) bu 7 koşulda test edilmeli.

---

## 10. CI/CD Pipeline Entegrasyonu

### 10.1 Pipeline Aşamaları

| Aşama | İçerik | Süre | Tetikleyici |
|-------|--------|------|-------------|
| 1. Lint + Build | ktlint/detekt + derleme | 2-4 dk | Her commit |
| 2. Unit Test | JUnit 5 + MockK | 2-5 dk | Her commit |
| 3. Snapshot Test | Paparazzi / Roborazzi | 2-4 dk | Her PR |
| 4. Integration Test | MockWebServer + Room | 5-8 dk | Her PR |
| 5. UI / E2E Test | Compose Test + Maestro | 10-20 dk | PR merge öncesi |
| 6. Performance Test | Macrobenchmark | 10-15 dk | Günlük (nightly) |
| 7. Security Scan | OWASP Dep Check + detekt | 3-5 dk | Haftalık |
| 8. Accessibility Audit | A11y framework | 5 dk | Her release öncesi |

### 10.2 GitHub Actions — Self-Hosted Runner

```yaml
name: Android Full Test Pipeline

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

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}

      - name: Lint
        run: ./gradlew detekt ktlintCheck

      - name: Build
        run: ./gradlew assembleDebug

  # ━━━ AŞAMA 2: Unit + Snapshot (paralel) ━━━
  unit-tests:
    needs: lint-and-build
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Unit Tests + Coverage
        run: ./gradlew testDebugUnitTest jacocoTestReport
      - name: Upload Coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: app/build/reports/jacoco/

  snapshot-tests:
    needs: lint-and-build
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Paparazzi Snapshot Tests
        run: ./gradlew verifyPaparazziDebug
      - name: Upload Failures
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: snapshot-failures
          path: "**/out/failures/**"

  # ━━━ AŞAMA 3: Instrumented Tests ━━━
  instrumented-tests:
    needs: [unit-tests, snapshot-tests]
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Start Emulator
        run: |
          $ANDROID_HOME/emulator/emulator -avd Pixel_7_API_34 \
            -no-window -no-audio -no-boot-anim &
          adb wait-for-device
          adb shell input keyevent 82
      - name: Run Instrumented Tests
        run: ./gradlew connectedDebugAndroidTest
      - name: Stop Emulator
        if: always()
        run: adb -s emulator-5554 emu kill

  # ━━━ AŞAMA 4: Security ━━━
  security-scan:
    needs: lint-and-build
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: OWASP Dependency Check
        run: ./gradlew dependencyCheckAnalyze
      - name: Secret Leak Scan
        run: gitleaks detect --source . --exit-code 1

  # ━━━ NIGHTLY: Performance + Mutation ━━━
  nightly-deep-tests:
    if: github.event_name == 'schedule'
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Start Emulator
        run: |
          $ANDROID_HOME/emulator/emulator -avd Pixel_7_API_34 \
            -no-window -no-audio -no-boot-anim &
          adb wait-for-device
      - name: Macrobenchmark
        run: ./gradlew :benchmark:connectedBenchmarkAndroidTest
      - name: Mutation Testing
        run: ./gradlew pitest
```

### 10.3 Maliyet Karşılaştırma

| Setup | Aylık Maliyet | Dakika Sınırı | Hız |
|-------|--------------|---------------|-----|
| GitHub Actions (hosted Linux) | $0 (2000dk) | 2000 dk/ay | İyi |
| GitHub Actions (self-hosted) | $0 | Sınırsız | En hızlı |
| Bitrise | $90-270 | Plan'a göre | İyi |
| Firebase Test Lab | $0 (günlük 15 test) | Sınırlı | Gerçek cihaz |

**Not:** Android testleri Linux runner'da çalışır (macOS gerekmez), bu yüzden GitHub hosted runner'da bile ücretsiz kotanız var. Ama self-hosted hâlâ en hızlısı.

---

## 11. Production Monitoring

### 11.1 Crash Reporting

**Firebase Crashlytics:**
```kotlin
// build.gradle.kts (app)
implementation(platform("com.google.firebase:firebase-bom:33.0.0"))
implementation("com.google.firebase:firebase-crashlytics")

// Custom key'ler
Firebase.crashlytics.setCustomKey("subscription_type", user.plan)
Firebase.crashlytics.setCustomKey("api_version", BuildConfig.API_VERSION)
Firebase.crashlytics.setUserId(user.id)

// Non-fatal error
Firebase.crashlytics.recordException(exception)
```

**Sentry:**
```kotlin
SentryAndroid.init(this) { options ->
    options.dsn = "https://your-dsn@sentry.io/project"
    options.tracesSampleRate = 0.2
    options.profilesSampleRate = 0.1
    options.isAttachScreenshot = true
    options.isEnableAutoSessionTracking = true
}
```

### 11.2 İzlenmesi Gereken Metrikler

| Metrik | Hedef | Alarm Eşiği |
|--------|-------|-------------|
| Crash-free rate | > %99.5 | < %99 |
| ANR rate | < %0.5 | > %1 |
| App launch time (P95) | < 3 saniye | > 5 saniye |
| Network error rate | < %2 | > %5 |
| Google Play rating | > 4.5 | < 4.0 |
| Uninstall rate | < %3 | > %5 |

### 11.3 Android Vitals (Google Play Console)

Google Play Console otomatik olarak şunları izler:
- ANR rate
- Crash rate
- Excessive wake-ups
- Stuck partial wake locks
- Excessive background Wi-Fi scans

Eşik aşılırsa uygulamanın Play Store sıralaması düşer.

### 11.4 Feature Flag ile Güvenli Release

```kotlin
// Firebase Remote Config
val remoteConfig = Firebase.remoteConfig
remoteConfig.setDefaultsAsync(R.xml.remote_config_defaults)

if (remoteConfig.getBoolean("new_checkout_flow")) {
    navigateToNewCheckout()
} else {
    navigateToLegacyCheckout()
}

// Staged rollout: Play Console'da %5 → %20 → %50 → %100
```

---

## 12. Edge Case Master Checklist

### 12.1 Network Edge Cases

- [ ] Yavaş bağlantı (3G simülasyonu)
- [ ] Bağlantı kaybı ortasında işlem
- [ ] Timeout sonrası retry mekanizması
- [ ] Aynı isteği çift gönderme (double tap)
- [ ] Büyük payload (10MB+ response)
- [ ] API 500 hatası → graceful error
- [ ] Malformed JSON response → crash olmamalı
- [ ] Certificate expiry → anlamlı hata
- [ ] DNS resolution failure
- [ ] Rate limiting (429 response)

### 12.2 Device Edge Cases

- [ ] Düşük bellek (memory trim callback)
- [ ] Dolu disk alanı
- [ ] Arka plana gitme ve geri dönme
- [ ] Process death ve recreation
- [ ] Gelen telefon araması sırasında işlem
- [ ] Multi-window / Split screen
- [ ] Farklı ekran boyutları (small phone, large tablet, foldable)
- [ ] Farklı Android versiyonları (API 24-34+)
- [ ] Farklı üretici katmanları (Samsung, Xiaomi, Huawei)
- [ ] Saat dilimi değişikliği
- [ ] Dil değişikliği (runtime)
- [ ] Battery saver mode
- [ ] Data saver mode
- [ ] Airplane mode açma/kapama
- [ ] Foldable cihaz: fold/unfold

### 12.3 Data Edge Cases

- [ ] Boş liste / boş state
- [ ] Tek item'lı liste
- [ ] Çok uzun text (1000+ karakter)
- [ ] Özel karakterler: emoji, Arapça, Çince
- [ ] null değerler
- [ ] Negatif sayılar, sıfır, `Int.MAX_VALUE`
- [ ] Tarih: 29 Şubat, yıl sonu, timezone
- [ ] Concurrent data erişimi (race condition)
- [ ] Corrupted Room database
- [ ] Schema migration: eski → yeni versiyon
- [ ] Unicode normalization farkları

### 12.4 User Behavior Edge Cases

- [ ] Hızlı art arda buton basma (rapid tapping)
- [ ] Back button ile mid-flow çıkış
- [ ] Force stop ve tekrar açma
- [ ] App update sonrası migration
- [ ] İlk açılış vs tekrar açılış farkı
- [ ] Permission reddi sonrası tekrar isteme
- [ ] Gesture navigation
- [ ] Configuration change (rotation, dark mode toggle)
- [ ] Clipboard'dan paste (beklenmedik format)

### 12.5 Android-Specific Edge Cases

- [ ] Process death: ViewModel state kaybolması
- [ ] Configuration change: Activity recreation
- [ ] Doze mode: Background job'lar çalışıyor mu?
- [ ] App Standby: Push notification'lar geliyor mu?
- [ ] Background execution limits (API 26+)
- [ ] Scoped storage (API 30+)
- [ ] Notification permission (API 33+)
- [ ] Predictive back gesture (API 34+)
- [ ] Photo picker vs legacy storage access

---

## 13. Sektör Devlerinin Test Yaklaşımı

| Şirket | Yaklaşım | Önemli Detay |
|--------|----------|-------------|
| Google | Robolectric + Espresso + Firebase Test Lab | Yüzlerce gerçek cihazda paralel test |
| Meta | Screenshot Tests + custom E2E | Android'de screenshot diff sistemi |
| Uber | Espresso + Compose Test + RIBs | Modüler mimari ile izole test |
| Spotify | Compose Test + snapshot + feature flags | Canary release ile kademeli yayınlama |
| Netflix | Espresso + Maestro + device farm | A/B test ile kalite ölçümü |
| Cash App | Paparazzi + JUnit 5 + Turbine | Paparazzi'yi onlar geliştirdi |
| Square | Compose Test + LeakCanary + OkHttp MockWebServer | LeakCanary'yi onlar geliştirdi |
| Airbnb | Compose Test + Showkase + custom CI | Component catalog + screenshot test |

---

## 14. AI-Driven Geliştirme İçin Özel Test Stratejisi

AI ile kod yazıyorsan (Claude, Copilot, Cursor vs.), AI kodunun standart insan kodundan farklı hata profili var. AI-authored PR'lar ortalama %75 daha fazla logic hatası ve %57 daha fazla security açığı içerir.

### 14.1 AI Kodunun Tipik Hata Profili

| Hata Tipi | Risk Seviyesi | Açıklama |
|-----------|--------------|----------|
| Edge case eksikliği | Yüksek | Happy path çalışır, null/empty/negatif değerlerde patlar |
| Null safety ihmali | Yüksek | `!!` kullanımı, platform type hataları |
| Context gap | Kritik | AI mevcut codebase kurallarını bilmez |
| Memory leak | Orta | Context leak, CoroutineScope cancel edilmemiş |
| Lifecycle farkındalığı | Yüksek | viewModelScope dışında coroutine başlatma |
| Deprecated API | Orta | Eski Android API'ları, deprecated Compose API |
| Hardcoded değerler | Orta | Magic number, hardcoded string, URL |
| ProGuard sorunları | Orta | Keep rule eksikliği, reflection sorunları |

### 14.2 AI Kodu İçin Zorunlu Test Kuralları

```kotlin
// KURAL 1: AI her fonksiyon yazdığında, aynı PR'da test de olmalı

// KURAL 2: Her AI-generated fonksiyon için minimum test seti:
fun `function happyPath works`() { }
fun `function null input handled`() { }
fun `function empty input handled`() { }
fun `function boundary values handled`() { }
fun `function error case handled`() { }
fun `function thread safety verified`() { }

// KURAL 3: AI kodunda leak kontrolü zorunlu
@Test
fun `viewModel no memory leak after clear`() {
    var vm: SomeViewModel? = SomeViewModel(mockRepo)
    val weakRef = WeakReference(vm)
    vm?.onCleared()
    vm = null
    System.gc()
    assertNull(weakRef.get(), "ViewModel leak tespit edildi!")
}
```

### 14.3 AI Code Review Checklist (Her PR'da Kontrol Et)

- [ ] `!!` (force unwrap) kullanılmış mı? → `?.let` veya `?:` ile değiştir
- [ ] `GlobalScope` kullanılmış mı? → `viewModelScope` veya `lifecycleScope` kullan
- [ ] `@SuppressLint` var mı? → Neden gerektiğini doğrula
- [ ] Hardcoded string/URL var mı? → strings.xml veya constant'a taşı
- [ ] Deprecated API kullanılmış mı? → Alternatifini kullan
- [ ] Error handling var mı? `runCatching` sonucu sessizce yutulmuş mu?
- [ ] `Context` leak riski var mı? (Activity reference ViewModel'da)
- [ ] ProGuard/R8 keep rule gerekiyor mu? (reflection, serialization)
- [ ] Kullanılmayan import/değişken var mı?
- [ ] Business logic doğru mu? (AI context'i bilmez)
- [ ] Mevcut architecture pattern'e uygun mu? (MVVM, Clean, MVI)
- [ ] Compose'da gereksiz recomposition var mı? (`remember`, `derivedStateOf`)

---

## 15. Static Analysis — Derleme Öncesi Hata Yakalama

### 15.1 detekt — Kotlin Static Analysis

```kotlin
// build.gradle.kts
plugins {
    id("io.gitlab.arturbosch.detekt") version "1.23.7"
}

detekt {
    config.setFrom("$rootDir/config/detekt.yml")
    buildUponDefaultConfig = true
    allRules = false
}
```

```yaml
# config/detekt.yml — AI-driven geliştirme için önerilen kurallar
complexity:
  LongMethod:
    threshold: 40
  CyclomaticComplexMethod:
    threshold: 10
  LongParameterList:
    functionThreshold: 5
    constructorThreshold: 8

style:
  ForbiddenComment:
    values: ['TODO', 'FIXME', 'HACK']  # AI'ın bıraktığı TODO'ları yakala
  MagicNumber:
    active: true
    ignoreNumbers: ['-1', '0', '1', '2']
  MaxLineLength:
    maxLineLength: 120
  UnusedImports:
    active: true
  WildcardImport:
    active: true

potential-bugs:
  UnsafeCast:
    active: true
  UselessPostfixExpression:
    active: true

performance:
  SpreadOperator:
    active: true

exceptions:
  SwallowedException:
    active: true
  TooGenericExceptionCaught:
    active: true
```

### 15.2 Android Lint

```kotlin
// build.gradle.kts
android {
    lint {
        warningsAsErrors = true
        abortOnError = true
        checkDependencies = true

        // Kritik kontroller
        enable += listOf(
            "HardcodedText",          // Hardcoded string
            "MissingTranslation",      // Eksik çeviri
            "SecurityException",       // Güvenlik açığı
            "ObsoleteSdkInt",         // Gereksiz SDK check
            "UnusedResources",        // Kullanılmayan resource
            "Accessibility",          // Erişilebilirlik
        )
    }
}
```

```bash
./gradlew lintDebug
# Rapor: app/build/reports/lint-results-debug.html
```

### 15.3 ktlint — Kotlin Code Style

```kotlin
// build.gradle.kts
plugins {
    id("org.jlleitschuh.gradle.ktlint") version "12.1.0"
}

ktlint {
    android.set(true)
    verbose.set(true)
    outputToConsole.set(true)
}
```

### 15.4 Dependency Guard — Bağımlılık Değişikliği Tespiti

```kotlin
// build.gradle.kts
plugins {
    id("com.dropbox.dependency-guard") version "0.5.0"
}

dependencyGuard {
    configuration("releaseRuntimeClasspath")
}

// ./gradlew dependencyGuardBaseline  → baseline oluştur
// ./gradlew dependencyGuard           → değişiklik var mı kontrol et
```

Yeni dependency eklenince CI fail olur — bilinçli onay gerektirir.

### 15.5 Static Analysis Tablo Özeti

| Araç | Ne Yakalar | Ne Zaman | Süre |
|------|-----------|----------|------|
| detekt | Code smell, karmaşıklık, bug pattern | Her commit | 15-30sn |
| Android Lint | Android-specific sorunlar, güvenlik | Her commit | 30-60sn |
| ktlint | Stil/format | Her commit | 5-15sn |
| Dependency Guard | Beklenmeyen dependency değişikliği | Her PR | 5sn |
| LeakCanary | Memory leak (runtime) | Debug build | Otomatik |
| Strict Mode | Disk/Network on main thread | Debug build | Otomatik |

---

## 16. Mutation Testing — Testlerin Testini Yap

### 16.1 PIT (Pitest) + Kotlin Plugin

```kotlin
// build.gradle.kts
plugins {
    id("info.solidsoft.pitest") version "1.15.0"
}

pitest {
    targetClasses.set(listOf("com.myapp.*"))
    targetTests.set(listOf("com.myapp.*Test"))
    junit5PluginVersion.set("1.2.1")
    mutators.set(listOf("STRONGER"))
    outputFormats.set(listOf("HTML", "XML"))
    timestampedReports.set(false)
    threads.set(Runtime.getRuntime().availableProcessors())

    // Kotlin desteği
    // build.gradle.kts dependencies
    // pitest("org.pitest:pitest-kotlin:1.2.1")
}

// Android modülü için:
// id("pl.droidsonroids.pitest")
```

```bash
# Çalıştır
./gradlew pitest

# Rapor: build/reports/pitest/index.html
```

### 16.2 Mutation Operatörleri

| Operatör | Orijinal | Mutant | Ne Test Eder |
|----------|----------|--------|-------------|
| Conditionals | `>` | `>=` | Boundary condition |
| Negate | `==` | `!=` | Eşitlik kontrolü |
| Math | `+` | `-` | Aritmetik doğruluk |
| Return Values | `return x` | `return null` | Null handling |
| Void Method | `list.add(x)` | (silindi) | Side effect testi |
| Remove Conditionals | `if (x) { }` | `{ }` (her zaman çalış) | Branch testi |

### 16.3 Mutation Score Hedefleri

| Modül | Minimum | Hedef |
|-------|---------|-------|
| Business Logic / ViewModel | %70 | %85+ |
| Payment / Auth | %80 | %90+ |
| Utility / Helper | %75 | %90+ |
| UI Logic | %50 | %70+ |

### 16.4 AI + Mutation Testing Feedback Loop

```
1. AI kod yazar
2. AI test yazar (veya sen yazarsın)
3. ./gradlew pitest koş
4. Hayatta kalan mutant'ları incele
5. Eksik testleri yaz
6. Tekrar pitest koş
7. Score %80+ olana kadar döngü
```

---

## 17. Contract Testing — API Uyumu Garantisi

### 17.1 Pact-JVM ile Consumer-Driven Contract Testing

```kotlin
// build.gradle.kts
testImplementation("au.com.dius.pact.consumer:junit5:4.6.5")
```

```kotlin
@ExtendWith(PactConsumerTestExt::class)
@PactTestFor(providerName = "UserService", port = "8080")
class UserApiContractTest {

    @Pact(consumer = "AndroidApp")
    fun getUserByIdPact(builder: PactDslWithProvider): V4Pact {
        return builder
            .given("user 123 exists")
            .uponReceiving("a request for user by ID")
            .path("/api/users/123")
            .method("GET")
            .willRespondWith()
            .status(200)
            .headers(mapOf("Content-Type" to "application/json"))
            .body(
                PactDslJsonBody()
                    .integerType("id", 123)
                    .stringType("name", "Ali")
                    .stringMatcher("email", "^[\\w.]+@[\\w.]+\\.[a-z]{2,}$", "ali@test.com")
            )
            .toPact(V4Pact::class.java)
    }

    @Test
    @PactTestFor(pactMethod = "getUserByIdPact")
    fun `verify get user by id contract`(mockServer: MockServer) = runTest {
        val apiClient = ApiClient(baseUrl = mockServer.getUrl())

        val user = apiClient.getUser("123")

        assertEquals(123, user.id)
        assertFalse(user.name.isBlank())
        assertTrue(user.email.contains("@"))
    }

    @Pact(consumer = "AndroidApp")
    fun getUserNotFoundPact(builder: PactDslWithProvider): V4Pact {
        return builder
            .uponReceiving("a request for non-existent user")
            .path("/api/users/999")
            .method("GET")
            .willRespondWith()
            .status(404)
            .body(PactDslJsonBody().stringType("error", "User not found"))
            .toPact(V4Pact::class.java)
    }

    @Test
    @PactTestFor(pactMethod = "getUserNotFoundPact")
    fun `verify not found contract`(mockServer: MockServer) = runTest {
        val apiClient = ApiClient(baseUrl = mockServer.getUrl())

        assertThrows<NotFoundException> {
            apiClient.getUser("999")
        }
    }
}
```

### 17.2 Contract Testing Neden Gerekli?

| Sorun | Contract Testing Olmadan | Contract Testing İle |
|-------|------------------------|---------------------|
| Backend field adı değişir | Production'da crash | CI'da fail |
| Yeni zorunlu field eklenir | JSON parse fail | Contract kırılır |
| Response tipi değişir | Sessiz data kaybı | Pact doğrulaması yakalar |
| Endpoint kaldırılır | 404 hataları | Contract kırılması ile erken uyarı |

---

## 18. Property-Based Testing

### 18.1 Kotest ile Property-Based Testing

```kotlin
// build.gradle.kts
testImplementation("io.kotest:kotest-runner-junit5:5.9.1")
testImplementation("io.kotest:kotest-assertions-core:5.9.1")
testImplementation("io.kotest:kotest-property:5.9.1")
```

```kotlin
import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe
import io.kotest.property.forAll
import io.kotest.property.Arb
import io.kotest.property.arbitrary.*

class PropertyBasedTests : FunSpec({

    test("JSON encode/decode round-trip") {
        forAll(Arb.string(), Arb.int(0..150)) { name, age ->
            val user = User(name = name, age = age)
            val json = moshi.adapter(User::class.java).toJson(user)
            val decoded = moshi.adapter(User::class.java).fromJson(json)
            decoded == user
        }
    }

    test("sort always produces sorted output") {
        forAll(Arb.list(Arb.int())) { list ->
            val sorted = list.customSort()
            sorted == list.sorted()
        }
    }

    test("price calculation never negative") {
        forAll(
            Arb.double(0.0..10000.0),  // price
            Arb.int(1..100),             // quantity
            Arb.double(0.0..1.0)         // discount
        ) { price, quantity, discount ->
            val total = PriceCalculator.calculate(price, quantity, discount)
            total >= 0.0
        }
    }

    test("string sanitization is idempotent") {
        forAll(Arb.string()) { input ->
            val once = InputSanitizer.sanitize(input)
            val twice = InputSanitizer.sanitize(once)
            once == twice
        }
    }

    test("email validation accepts valid emails") {
        forAll(Arb.email()) { email ->
            EmailValidator.isValid(email)
        }
    }
})
```

### 18.2 Property-Based Testing Ne Zaman Kullan?

- JSON/Protobuf encode/decode round-trip
- Matematiksel hesaplamalar (fiyat, vergi, puan)
- String işleme (sanitize, format, parse)
- Sıralama ve filtreleme
- State machine geçişleri
- Encryption/decryption round-trip

---

## 19. Localization Testing

### 19.1 Otomatik Localization Kontrolleri

```kotlin
@Test
fun `all string resources have translations`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val languages = listOf("tr", "en", "de", "fr")
    val defaultStrings = getStringResources(context, Locale.ENGLISH)

    for (lang in languages) {
        val locale = Locale(lang)
        val localizedStrings = getStringResources(context, locale)

        for ((key, _) in defaultStrings) {
            assertTrue(
                localizedStrings.containsKey(key),
                "'$key' key'inin $lang çevirisi eksik"
            )
        }
    }
}

@Test
fun `format specifiers match across translations`() {
    val defaultStrings = parseStringsXml("values/strings.xml")
    val turkishStrings = parseStringsXml("values-tr/strings.xml")

    for ((key, defaultValue) in defaultStrings) {
        val turkishValue = turkishStrings[key] ?: continue
        val defaultSpecifiers = extractFormatSpecifiers(defaultValue)
        val turkishSpecifiers = extractFormatSpecifiers(turkishValue)

        assertEquals(
            defaultSpecifiers, turkishSpecifiers,
            "Format specifier uyuşmazlığı: $key"
        )
    }
}
```

### 19.2 Pseudo-Localization ile UI Testi

```kotlin
// Uzun çeviri simülasyonu
@Test
fun `UI handles long translations without overflow`() {
    val paparazzi = Paparazzi(
        deviceConfig = DeviceConfig.PIXEL_6,
        locale = "de"  // Almanca — genelde %30 daha uzun
    )
    paparazzi.snapshot {
        HomeScreen(state = HomeUiState.Loaded(mockData))
    }
}
```

---

## 20. Jetpack Compose-Specific Testing

### 20.1 Recomposition Kontrolü

```kotlin
@Test
fun `item card does not recompose unnecessarily`() {
    var recompositionCount = 0

    composeTestRule.setContent {
        val item = remember { ItemData(id = "1", title = "Test") }
        SideEffect { recompositionCount++ }
        ItemCard(item = item)
    }

    // İlk composition
    assertEquals(1, recompositionCount)

    // State değişmeyen tıklama — recompose OLMAMALI
    composeTestRule.onNodeWithTag("otherButton").performClick()
    assertEquals(1, recompositionCount, "Gereksiz recomposition tespit edildi!")
}
```

### 20.2 Lazy List (LazyColumn/LazyRow) Testi

```kotlin
@Test
fun `lazy list displays correct items`() {
    val items = List(100) { Item(id = "$it", title = "Item $it") }

    composeTestRule.setContent {
        ItemList(items = items)
    }

    // İlk görünen item'lar
    composeTestRule
        .onNodeWithText("Item 0")
        .assertIsDisplayed()

    // Scroll et
    composeTestRule
        .onNodeWithTag("itemList")
        .performScrollToIndex(50)

    // Scroll sonrası item
    composeTestRule
        .onNodeWithText("Item 50")
        .assertIsDisplayed()
}
```

### 20.3 Navigation Testi

```kotlin
@Test
fun `navigation from login to home works`() {
    val navController = TestNavHostController(
        ApplicationProvider.getApplicationContext()
    )

    composeTestRule.setContent {
        navController.navigatorProvider.addNavigator(ComposeNavigator())
        MyAppNavHost(navController = navController)
    }

    // Login ekranında başla
    assertEquals("login", navController.currentBackStackEntry?.destination?.route)

    // Login yap
    composeTestRule.onNodeWithTag("emailField").performTextInput("test@test.com")
    composeTestRule.onNodeWithTag("passwordField").performTextInput("pass")
    composeTestRule.onNodeWithText("Giriş Yap").performClick()

    // Home'a navigate etti mi?
    composeTestRule.waitUntil(5000) {
        navController.currentBackStackEntry?.destination?.route == "home"
    }
}
```

---

## 21. Dependency Vulnerability Scanning

### 21.1 OWASP Dependency Check

```kotlin
// build.gradle.kts
plugins {
    id("org.owasp.dependencycheck") version "9.2.0"
}

dependencyCheck {
    failBuildOnCVSS = 7.0f  // HIGH severity'de fail
    formats = listOf("HTML", "JSON")
}
```

```bash
./gradlew dependencyCheckAnalyze
# Rapor: build/reports/dependency-check-report.html
```

### 21.2 GitHub Dependabot

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "gradle"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    labels: ["dependencies"]
```

### 21.3 Hardcoded Secret Taraması

```bash
# gitleaks
brew install gitleaks
gitleaks detect --source . --report-format json --report-path leaks.json

# CI'da
gitleaks detect --source . --exit-code 1
```

---

## 22. Self-Hosted Runner ile Sıfır Maliyet CI/CD

### 22.1 Runner Kurulumu (MacBook veya Linux)

```bash
# Android testleri Linux'ta da çalışır!
# Ama MacBook'ta da kurulabilir.

# 1. GitHub repo → Settings → Actions → Runners → New self-hosted runner

# 2. Kurulum
mkdir ~/actions-runner && cd ~/actions-runner
curl -o actions-runner.tar.gz -L \
  https://github.com/actions/runner/releases/latest/download/actions-runner-osx-arm64-2.x.x.tar.gz
tar xzf ./actions-runner.tar.gz

# 3. Konfigüre et
./config.sh --url https://github.com/KULLANICI/REPO --token XXXXX

# 4. Servis olarak çalıştır
./svc.sh install
./svc.sh start

# 5. Android SDK ve emulator kur
sdkmanager "platform-tools" "platforms;android-34" "emulator" "system-images;android-34;google_apis;arm64-v8a"
avdmanager create avd -n Pixel_7_API_34 -k "system-images;android-34;google_apis;arm64-v8a" --device "pixel_7"
```

### 22.2 Maliyet Karşılaştırma

| Setup | Aylık Maliyet | Dakika Sınırı | Not |
|-------|--------------|---------------|-----|
| GitHub Actions (Linux) | $0 | 2000 dk/ay | Unit test için yeterli |
| GitHub Actions (self-hosted) | $0 | Sınırsız | Emulator da çalışır |
| Firebase Test Lab | $0-$$ | 15 test/gün ücretsiz | Gerçek cihaz |
| **Self-hosted MacBook/Linux** | **$0** | **Sınırsız** | **En hızlı** |

---

## 23. Hilt Dependency Injection Testi

### 23.1 Neden Önemli?

AI-generated kodda en sık yapılan hatalardan biri DI graph'ındaki bağımlılıkların yanlış bağlanmasıdır. Hilt testleri, runtime'da `UninitializedPropertyAccessException` veya yanlış scope hatalarını yakalar.

### 23.2 Temel Hilt Test Kurulumu

```kotlin
// build.gradle.kts
testImplementation("com.google.dagger:hilt-android-testing:2.51")
kaptTest("com.google.dagger:hilt-android-compiler:2.51")
androidTestImplementation("com.google.dagger:hilt-android-testing:2.51")
kaptAndroidTest("com.google.dagger:hilt-android-compiler:2.51")
```

### 23.3 Unit Test ile Module Doğrulama

```kotlin
@HiltAndroidTest
@RunWith(RobolectricTestRunner::class)
@Config(application = HiltTestApplication::class)
class PaymentModuleTest {

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @Inject
    lateinit var paymentRepository: PaymentRepository

    @Inject
    lateinit var paymentValidator: PaymentValidator

    @Before
    fun setup() {
        hiltRule.inject()
    }

    @Test
    fun `payment repository is injected correctly`() {
        assertNotNull(paymentRepository)
        assertTrue(paymentRepository is PaymentRepositoryImpl)
    }

    @Test
    fun `payment validator uses correct rules`() {
        assertNotNull(paymentValidator)
        val result = paymentValidator.validate(amount = 100.0)
        assertTrue(result.isValid)
    }
}
```

### 23.4 Fake Module ile Test İzolasyonu

```kotlin
@Module
@TestInstallIn(
    components = [SingletonComponent::class],
    replaces = [NetworkModule::class]
)
object FakeNetworkModule {
    @Provides
    @Singleton
    fun provideApiService(): ApiService = FakeApiService()

    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient = OkHttpClient.Builder()
        .addInterceptor(MockInterceptor())
        .build()
}

// Test'te belirli modülleri tamamen kaldırma
@HiltAndroidTest
@UninstallModules(AnalyticsModule::class)
class FeatureWithoutAnalyticsTest {

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @BindValue
    val analyticsTracker: AnalyticsTracker = FakeAnalyticsTracker()

    @Test
    fun `feature works without real analytics`() {
        hiltRule.inject()
        // Analytics çağrıları fake'e gider
    }
}
```

### 23.5 Custom Scope Testi

```kotlin
@HiltAndroidTest
class ScopingTest {

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @Inject
    lateinit var singletonA: MySingleton

    @Inject
    lateinit var singletonB: MySingleton

    @Test
    fun `singleton scope returns same instance`() {
        hiltRule.inject()
        assertSame(singletonA, singletonB)
    }
}
```

---

## 24. WorkManager Testi

### 24.1 Neden Önemli?

Background task'ler en zor debug edilen alanlardandır. Yanlış constraint, retry policy veya data passing hataları production'da saatler sonra ortaya çıkar. WorkManager testleri bu hataları anında yakalar.

### 24.2 Test Dependencies

```kotlin
// build.gradle.kts
testImplementation("androidx.work:work-testing:2.9.1")
androidTestImplementation("androidx.work:work-testing:2.9.1")
```

### 24.3 Simple Worker Testi

```kotlin
class SyncWorkerTest {

    private lateinit var context: Context

    @Before
    fun setup() {
        context = ApplicationProvider.getApplicationContext()
    }

    @Test
    fun `sync worker returns success when API responds OK`() {
        // Arrange
        val inputData = workDataOf(
            "user_id" to "12345",
            "sync_type" to "full"
        )

        val worker = TestWorkerBuilder<SyncWorker>(
            context = context,
            inputData = inputData
        ).build()

        // Act
        val result = worker.doWork()

        // Assert
        assertEquals(ListenableWorker.Result.success(), result)
    }

    @Test
    fun `sync worker returns retry on network failure`() {
        val worker = TestWorkerBuilder<SyncWorker>(
            context = context,
            inputData = workDataOf("user_id" to "12345")
        ).build()

        // Simulate network off
        val result = worker.doWork()
        assertEquals(ListenableWorker.Result.retry(), result)
    }
}
```

### 24.4 CoroutineWorker Testi

```kotlin
class DataUploadWorkerTest {

    @Test
    fun `upload worker processes data correctly`() = runTest {
        val context = ApplicationProvider.getApplicationContext<Context>()

        val worker = TestListenableWorkerBuilder<DataUploadWorker>(
            context = context,
            inputData = workDataOf(
                "file_path" to "/data/export.json",
                "compress" to true
            )
        ).build()

        val result = worker.startWork().get()

        assertEquals(ListenableWorker.Result.success(), result)
        // Output data'yı kontrol et
        val outputData = (result as ListenableWorker.Result.Success).outputData
        assertTrue(outputData.getBoolean("uploaded", false))
    }
}
```

### 24.5 WorkManager Chain Testi

```kotlin
@HiltAndroidTest
class WorkChainTest {

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @Before
    fun setup() {
        val config = Configuration.Builder()
            .setMinimumLoggingLevel(Log.DEBUG)
            .setExecutor(SynchronousExecutor())
            .build()

        WorkManagerTestInitHelper.initializeTestWorkManager(
            ApplicationProvider.getApplicationContext(), config
        )
    }

    @Test
    fun `download then process chain completes in order`() {
        val workManager = WorkManager.getInstance(
            ApplicationProvider.getApplicationContext()
        )

        val downloadWork = OneTimeWorkRequestBuilder<DownloadWorker>()
            .setInputData(workDataOf("url" to "https://api.example.com/data"))
            .build()

        val processWork = OneTimeWorkRequestBuilder<ProcessWorker>()
            .build()

        workManager.beginWith(downloadWork)
            .then(processWork)
            .enqueue()

        // TestDriver ile work'leri tetikle
        val testDriver = WorkManagerTestInitHelper.getTestDriver(
            ApplicationProvider.getApplicationContext()
        )!!
        testDriver.setAllConstraintsMet(downloadWork.id)
        testDriver.setAllConstraintsMet(processWork.id)

        val downloadInfo = workManager.getWorkInfoById(downloadWork.id).get()
        assertEquals(WorkInfo.State.SUCCEEDED, downloadInfo.state)

        val processInfo = workManager.getWorkInfoById(processWork.id).get()
        assertEquals(WorkInfo.State.SUCCEEDED, processInfo.state)
    }
}
```

### 24.6 Periodic Work Constraint Testi

```kotlin
@Test
fun `periodic sync respects network constraint`() {
    val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(
        15, TimeUnit.MINUTES
    ).setConstraints(
        Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .setRequiresBatteryNotLow(true)
            .build()
    ).build()

    val workManager = WorkManager.getInstance(context)
    workManager.enqueueUniquePeriodicWork(
        "periodic_sync",
        ExistingPeriodicWorkPolicy.KEEP,
        syncRequest
    )

    val workInfo = workManager.getWorkInfoById(syncRequest.id).get()
    assertNotNull(workInfo)
    // Constraint met olmadan çalışmamalı
    assertEquals(WorkInfo.State.ENQUEUED, workInfo.state)
}
```

---

## 25. Room Database Migration Testi

### 25.1 Neden Önemli?

Database migration hataları kullanıcı verisini siler veya bozar. Bu, app store'da 1 yıldız review'ların en büyük sebebidir. Migration testleri her schema değişikliğinde zorunlu olmalıdır.

### 25.2 MigrationTestHelper Kurulumu

```kotlin
// build.gradle.kts
androidTestImplementation("androidx.room:room-testing:2.6.1")

// Room schema export (build.gradle.kts)
ksp {
    arg("room.schemaLocation", "$projectDir/schemas")
}
```

### 25.3 Migration Test Yazımı

```kotlin
@RunWith(AndroidJUnit4::class)
class MigrationTest {

    @get:Rule
    val helper = MigrationTestHelper(
        InstrumentationRegistry.getInstrumentation(),
        AppDatabase::class.java,
        listOf(), // AutoMigration specs
        FrameworkSQLiteOpenHelperFactory()
    )

    @Test
    fun migrate1To2_addsUserAgeColumn() {
        // Versiyon 1 ile database oluştur
        helper.createDatabase(TEST_DB, 1).apply {
            execSQL("""
                INSERT INTO users (id, name, email)
                VALUES (1, 'Atakan', 'test@test.com')
            """)
            close()
        }

        // Versiyon 2'ye migrate et
        val db = helper.runMigrationsAndValidate(
            TEST_DB, 2, true,
            MIGRATION_1_2
        )

        // Eski veri korunmuş mu?
        val cursor = db.query("SELECT * FROM users WHERE id = 1")
        assertTrue(cursor.moveToFirst())
        assertEquals("Atakan", cursor.getString(cursor.getColumnIndex("name")))

        // Yeni kolon default değerle eklenmiş mi?
        val ageIndex = cursor.getColumnIndex("age")
        assertTrue(ageIndex >= 0)
        assertEquals(0, cursor.getInt(ageIndex)) // default value
        cursor.close()
    }

    @Test
    fun migrate2To3_createsOrdersTable() {
        helper.createDatabase(TEST_DB, 2).apply {
            execSQL("""
                INSERT INTO users (id, name, email, age)
                VALUES (1, 'Atakan', 'test@test.com', 30)
            """)
            close()
        }

        val db = helper.runMigrationsAndValidate(
            TEST_DB, 3, true,
            MIGRATION_2_3
        )

        // Yeni tablo oluşmuş mu?
        val cursor = db.query(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='orders'"
        )
        assertTrue(cursor.moveToFirst())
        cursor.close()
    }

    @Test
    fun migrateAll_fullChain() {
        // Versiyon 1'den en son versiyona kadar tüm migration'ları test et
        helper.createDatabase(TEST_DB, 1).apply {
            execSQL("""
                INSERT INTO users (id, name, email)
                VALUES (1, 'Atakan', 'test@test.com')
            """)
            close()
        }

        helper.runMigrationsAndValidate(
            TEST_DB,
            AppDatabase.VERSION, // Son versiyon
            true,
            MIGRATION_1_2,
            MIGRATION_2_3,
            MIGRATION_3_4
        )
    }

    companion object {
        private const val TEST_DB = "migration-test"
    }
}
```

### 25.4 Destructive Migration Koruması

```kotlin
// YANLIŞ — kullanıcı verisi silinir!
Room.databaseBuilder(context, AppDatabase::class.java, "app.db")
    .fallbackToDestructiveMigration()
    .build()

// DOĞRU — her migration açıkça tanımlanmalı
Room.databaseBuilder(context, AppDatabase::class.java, "app.db")
    .addMigrations(MIGRATION_1_2, MIGRATION_2_3, MIGRATION_3_4)
    .build()

// CI'da destructive migration kullanımını detekt ile yakala
// detekt custom rule:
class NoDestructiveMigrationRule : Rule() {
    override fun visitCallExpression(expression: KtCallExpression) {
        if (expression.text.contains("fallbackToDestructiveMigration")) {
            report(
                CodeSmell(issue, Entity.from(expression),
                    "fallbackToDestructiveMigration kullanımı yasak!")
            )
        }
    }
}
```

---

## 26. Baseline Profiles ve Startup Optimizasyonu

### 26.1 Neden Önemli?

Baseline Profiles, app başlangıç süresini %30-40 azaltır. Google Play Store, Baseline Profile olmayan uygulamaları performans sıralamasında cezalandırır. Test ile hem profil doğruluğunu hem startup performansını ölçersiniz.

### 26.2 Baseline Profile Modülü Kurulumu

```kotlin
// build.gradle.kts (app module)
plugins {
    id("androidx.baselineprofile")
}

dependencies {
    baselineProfile(project(":baselineprofile"))
}

// build.gradle.kts (baselineprofile module)
plugins {
    id("com.android.test")
    id("androidx.baselineprofile")
}

android {
    namespace = "com.example.baselineprofile"
    targetProjectPath = ":app"
}

baselineProfile {
    managedDevices += "pixel6Api34"
    useConnectedDevices = false
}

dependencies {
    implementation("androidx.test.ext:junit:1.2.1")
    implementation("androidx.test.espresso:espresso-core:3.6.1")
    implementation("androidx.benchmark:benchmark-macro-junit4:1.3.3")
}
```

### 26.3 Baseline Profile Generator

```kotlin
@RunWith(AndroidJUnit4::class)
@LargeTest
class BaselineProfileGenerator {

    @get:Rule
    val rule = BaselineProfileRule()

    @Test
    fun generateBaselineProfile() {
        rule.collect(
            packageName = "com.example.app",
            maxIterations = 5,
            stableIterations = 3
        ) {
            // Cold start
            pressHome()
            startActivityAndWait()

            // Kritik kullanıcı akışları
            // Ana sayfa scroll
            device.findObject(By.res("main_list")).scroll(Direction.DOWN, 2f)

            // Arama
            device.findObject(By.res("search_button")).click()
            device.findObject(By.res("search_input")).text = "test"
            device.waitForIdle()

            // Detay sayfası
            device.findObject(By.res("item_0")).click()
            device.waitForIdle()

            // Sepet
            device.findObject(By.res("add_to_cart")).click()
            device.findObject(By.res("cart_icon")).click()
            device.waitForIdle()
        }
    }
}
```

### 26.4 Startup Benchmark ile Profil Doğrulama

```kotlin
@RunWith(AndroidJUnit4::class)
class StartupBenchmark {

    @get:Rule
    val benchmarkRule = MacrobenchmarkRule()

    @Test
    fun startupWithBaselineProfile() {
        benchmarkRule.measureRepeated(
            packageName = "com.example.app",
            metrics = listOf(StartupTimingMetric()),
            compilationMode = CompilationMode.Partial(
                baselineProfileMode = BaselineProfileMode.Require
            ),
            iterations = 10,
            startupMode = StartupMode.COLD
        ) {
            pressHome()
            startActivityAndWait()
        }
    }

    @Test
    fun startupWithoutProfile() {
        benchmarkRule.measureRepeated(
            packageName = "com.example.app",
            metrics = listOf(StartupTimingMetric()),
            compilationMode = CompilationMode.None(),
            iterations = 10,
            startupMode = StartupMode.COLD
        ) {
            pressHome()
            startActivityAndWait()
        }
    }
}
```

### 26.5 CI'da Baseline Profile Üretimi

```yaml
# GitHub Actions
baseline-profile:
  runs-on: self-hosted
  steps:
    - uses: actions/checkout@v4

    - name: Generate Baseline Profile
      run: ./gradlew :app:generateBaselineProfile

    - name: Verify Profile Exists
      run: |
        PROFILE_PATH="app/src/main/generated/baselineProfiles/baseline-prof.txt"
        if [ ! -f "$PROFILE_PATH" ]; then
          echo "ERROR: Baseline Profile üretilemedi!"
          exit 1
        fi
        LINES=$(wc -l < "$PROFILE_PATH")
        echo "Profile satır sayısı: $LINES"
        if [ "$LINES" -lt 100 ]; then
          echo "WARNING: Profile çok kısa, kullanıcı akışlarını kontrol et"
        fi
```

---

## 27. Gradle Managed Devices

### 27.1 Neden Önemli?

CI ortamında emulator yönetimi en büyük flaky test kaynağıdır. Gradle Managed Devices, emulator lifecycle'ını Gradle'a devrederek %100 tekrarlanabilir test ortamı sağlar.

### 27.2 Kurulum

```kotlin
// build.gradle.kts (app module)
android {
    testOptions {
        managedDevices {
            localDevices {
                create("pixel6Api34") {
                    device = "Pixel 6"
                    apiLevel = 34
                    systemImageSource = "google-atd" // Automated Test Device — daha hızlı
                }
                create("pixel4Api30") {
                    device = "Pixel 4"
                    apiLevel = 30
                    systemImageSource = "aosp-atd"
                }
                create("smallPhone") {
                    device = "Nexus 5"
                    apiLevel = 30
                    systemImageSource = "aosp-atd"
                }
            }
            groups {
                create("phoneGroup") {
                    targetDevices.addAll(
                        devices["pixel6Api34"]!!,
                        devices["pixel4Api30"]!!,
                        devices["smallPhone"]!!
                    )
                }
            }
        }
    }
}
```

### 27.3 CI'da Kullanım

```yaml
# GitHub Actions
instrumented-tests:
  runs-on: self-hosted
  steps:
    - uses: actions/checkout@v4

    - name: Accept SDK Licenses
      run: yes | sdkmanager --licenses

    - name: Run tests on Gradle Managed Device
      run: ./gradlew pixel6Api34DebugAndroidTest

    - name: Run on all phone group
      run: ./gradlew phoneGroupDebugAndroidTest

    - name: Upload test results
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: gmd-test-results
        path: app/build/reports/androidTests/managedDevice/
```

### 27.4 ATD (Automated Test Device) Avantajları

```
Normal System Image vs ATD:
┌─────────────────────────┬──────────┬─────────────┐
│ Özellik                 │ Normal   │ ATD         │
├─────────────────────────┼──────────┼─────────────┤
│ Boot süresi             │ ~45s     │ ~15s        │
│ Disk kullanımı          │ ~8GB     │ ~3GB        │
│ RAM kullanımı           │ ~2GB     │ ~1GB        │
│ Google Play Services    │ Var      │ Yok         │
│ Kamera/Sensör           │ Var      │ Yok         │
│ CI için uygunluk        │ Orta     │ Mükemmel    │
└─────────────────────────┴──────────┴─────────────┘

Kural: CI'da ATD kullan, Google Play gerektiren testleri
ayrı bir pipeline'da google_apis image ile çalıştır.
```

---

## 28. Process Death ve SavedStateHandle Testi

### 28.1 Neden Önemli?

Android, bellek baskısında arka plandaki Activity/Fragment'ları öldürür. Kullanıcı geri döndüğünde state kaybolmuşsa veri kaybı yaşanır. Bu, AI kodunda çoğunlukla unutulan bir senaryodur çünkü development sırasında nadiren tetiklenir.

### 28.2 ViewModel SavedStateHandle Testi

```kotlin
class CheckoutViewModelTest {

    @Test
    fun `state survives process death`() = runTest {
        // İlk başlangıç
        val savedStateHandle = SavedStateHandle()
        val viewModel = CheckoutViewModel(savedStateHandle, FakeCartRepository())

        // Kullanıcı sepete ürün ekler
        viewModel.addToCart(Product(id = "p1", name = "Widget", price = 29.99))
        viewModel.addToCart(Product(id = "p2", name = "Gadget", price = 49.99))
        viewModel.setShippingAddress("İstanbul, Türkiye")

        // State kaydedildiğini doğrula
        val savedCart = savedStateHandle.get<List<CartItem>>("cart_items")
        assertNotNull(savedCart)
        assertEquals(2, savedCart!!.size)

        val savedAddress = savedStateHandle.get<String>("shipping_address")
        assertEquals("İstanbul, Türkiye", savedAddress)

        // PROCESS DEATH SIMÜLASYONU:
        // Aynı SavedStateHandle ile yeni ViewModel oluştur
        val restoredViewModel = CheckoutViewModel(savedStateHandle, FakeCartRepository())

        // State geri gelmiş mi?
        val restoredState = restoredViewModel.uiState.first()
        assertEquals(2, restoredState.cartItems.size)
        assertEquals("İstanbul, Türkiye", restoredState.shippingAddress)
        assertEquals(79.98, restoredState.total, 0.01)
    }

    @Test
    fun `form input survives process death`() = runTest {
        val savedStateHandle = SavedStateHandle()
        val viewModel = ProfileEditViewModel(savedStateHandle)

        // Kullanıcı form doldurur
        viewModel.updateName("Atakan")
        viewModel.updateBio("Android Developer")

        // Process death → restore
        val restoredViewModel = ProfileEditViewModel(savedStateHandle)
        val state = restoredViewModel.uiState.first()

        assertEquals("Atakan", state.name)
        assertEquals("Android Developer", state.bio)
    }
}
```

### 28.3 Activity Recreation Testi (Instrumented)

```kotlin
@RunWith(AndroidJUnit4::class)
class ProcessDeathInstrumentedTest {

    @Test
    fun activityRecreation_preservesState() {
        val scenario = launchActivity<CheckoutActivity>()

        // State'i ayarla
        scenario.onActivity { activity ->
            activity.viewModel.addToCart(
                Product(id = "1", name = "Test", price = 10.0)
            )
        }

        // Activity recreation simülasyonu (config change + process death benzeri)
        scenario.recreate()

        // State korunmuş mu?
        scenario.onActivity { activity ->
            val state = activity.viewModel.uiState.value
            assertEquals(1, state.cartItems.size)
        }
    }
}
```

### 28.4 Maestro ile Process Death Testi

```yaml
# process_death_test.yaml
appId: com.example.app
---
- launchApp
- tapOn: "Ürün Ekle"
- tapOn: "Sepete Git"
- assertVisible: "1 ürün"

# Process death simülasyonu
- runFlow:
    file: kill_app.yaml

- launchApp
- assertVisible: "1 ürün"  # State geri gelmeli!
```

```yaml
# kill_app.yaml
appId: com.example.app
---
- runScript:
    script: |
      const result = runCommand("adb shell am kill com.example.app")
      output(result)
```

---

## 29. R8/ProGuard Obfuscation Testi

### 29.1 Neden Önemli?

R8 code shrinking ve obfuscation, production APK'da class/method isimlerini değiştirir. Yanlış ProGuard rule'ları reflection kullanan kodları (Retrofit, Gson, Room, Hilt) kırar. Bu hatalar sadece release build'de ortaya çıkar, debug build'de her şey çalışır.

### 29.2 Release Build ile Test

```kotlin
// build.gradle.kts
android {
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        // Test için release benzeri debug build
        create("staging") {
            initWith(getByName("release"))
            isDebuggable = true
            signingConfig = signingConfigs.getByName("debug")
            matchingFallbacks += listOf("release")
        }
    }
}
```

### 29.3 CI'da Release Build Smoke Test

```yaml
# GitHub Actions
r8-test:
  runs-on: self-hosted
  steps:
    - uses: actions/checkout@v4

    - name: Build staging APK
      run: ./gradlew assembleStagingDebug

    - name: Install on emulator
      run: adb install app/build/outputs/apk/staging/app-staging.apk

    - name: Run Maestro smoke tests on minified build
      run: |
        maestro test \
          --app-id com.example.app \
          --env BUILD_TYPE=staging \
          .maestro/critical_flows/

    - name: Check for R8 mapping file
      run: |
        MAPPING="app/build/outputs/mapping/staging/mapping.txt"
        if [ ! -f "$MAPPING" ]; then
          echo "ERROR: mapping.txt bulunamadı!"
          exit 1
        fi
```

### 29.4 Reflection Koruması Testi

```kotlin
@Test
fun `all API models survive R8 obfuscation`() {
    // Retrofit/Gson ile deserialize edilen tüm model class'ları test et
    val testJson = """{"id": 1, "name": "Test", "price": 9.99}"""
    val gson = GsonBuilder().create()

    // Her model class'ını test et
    val models = listOf(
        Product::class.java,
        User::class.java,
        Order::class.java,
        CartItem::class.java,
        ApiResponse::class.java
    )

    models.forEach { modelClass ->
        try {
            val instance = gson.fromJson(testJson, modelClass)
            assertNotNull("${modelClass.simpleName} deserialize başarısız", instance)
        } catch (e: Exception) {
            fail("${modelClass.simpleName} R8 sonrası kırılıyor: ${e.message}\n" +
                 "ProGuard rule ekle: -keep class ${modelClass.name} { *; }")
        }
    }
}
```

### 29.5 ProGuard Rules Checklist

```proguard
# proguard-rules.pro

# === Retrofit / OkHttp ===
-keepattributes Signature
-keepattributes *Annotation*
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

# === Gson / Serialization ===
-keep class com.example.app.data.model.** { *; }

# === Room ===
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *

# === Hilt ===
-keep class dagger.hilt.** { *; }
-keep class * extends dagger.hilt.android.internal.managers.ViewComponentManager

# === Enum ===
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
```

---

## 30. Gradle Version Catalog ile Bağımlılık Yönetimi

### 30.1 Neden Önemli?

AI-generated kodda her modül farklı versiyon kullanabilir. Version Catalog, tüm bağımlılıkları tek yerden yöneterek versiyon çakışmalarını önler ve güvenlik güncellemelerini kolaylaştırır.

### 30.2 Version Catalog Kurulumu

```toml
# gradle/libs.versions.toml
[versions]
kotlin = "2.0.21"
agp = "8.7.3"
compose-bom = "2024.12.01"
hilt = "2.51"
room = "2.6.1"
junit5 = "5.10.2"
mockk = "1.13.13"
turbine = "1.1.0"
paparazzi = "1.3.4"
detekt = "1.23.7"
work = "2.9.1"
benchmark = "1.3.3"
leakcanary = "2.14"

[libraries]
# Test
junit5-api = { module = "org.junit.jupiter:junit-jupiter-api", version.ref = "junit5" }
junit5-engine = { module = "org.junit.jupiter:junit-jupiter-engine", version.ref = "junit5" }
mockk = { module = "io.mockk:mockk", version.ref = "mockk" }
mockk-android = { module = "io.mockk:mockk-android", version.ref = "mockk" }
turbine = { module = "app.cash.turbine:turbine", version.ref = "turbine" }

# Room
room-runtime = { module = "androidx.room:room-runtime", version.ref = "room" }
room-ktx = { module = "androidx.room:room-ktx", version.ref = "room" }
room-compiler = { module = "androidx.room:room-compiler", version.ref = "room" }
room-testing = { module = "androidx.room:room-testing", version.ref = "room" }

# Hilt
hilt-android = { module = "com.google.dagger:hilt-android", version.ref = "hilt" }
hilt-compiler = { module = "com.google.dagger:hilt-android-compiler", version.ref = "hilt" }
hilt-testing = { module = "com.google.dagger:hilt-android-testing", version.ref = "hilt" }

# WorkManager
work-runtime = { module = "androidx.work:work-runtime-ktx", version.ref = "work" }
work-testing = { module = "androidx.work:work-testing", version.ref = "work" }

# Compose BOM
compose-bom = { module = "androidx.compose:compose-bom", version.ref = "compose-bom" }

# Debug
leakcanary = { module = "com.squareup.leakcanary:leakcanary-android", version.ref = "leakcanary" }

[bundles]
unit-testing = ["junit5-api", "mockk", "turbine"]

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
```

### 30.3 Kullanım

```kotlin
// build.gradle.kts (app)
dependencies {
    // Bundle kullanımı
    testImplementation(libs.bundles.unitTesting)
    testRuntimeOnly(libs.junit5.engine)

    // Tekil kullanım
    implementation(libs.room.runtime)
    implementation(libs.room.ktx)
    ksp(libs.room.compiler)
    testImplementation(libs.room.testing)

    implementation(libs.hilt.android)
    ksp(libs.hilt.compiler)
    testImplementation(libs.hilt.testing)
    kspTest(libs.hilt.compiler)

    implementation(libs.work.runtime)
    testImplementation(libs.work.testing)

    implementation(platform(libs.compose.bom))

    debugImplementation(libs.leakcanary)
}
```

### 30.4 CI'da Dependency Consistency Check

```yaml
# GitHub Actions
dependency-check:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Check for version catalog consistency
      run: |
        # Tüm build.gradle.kts dosyalarında hardcoded versiyon var mı?
        if grep -rn "implementation(\".*:.*:.*\")" --include="*.kts" app/ feature/ ; then
          echo "ERROR: Hardcoded bağımlılık bulundu! Version catalog kullan."
          exit 1
        fi

    - name: Dependency Guard check
      run: ./gradlew dependencyGuard
```

---

## 31. Sıfırdan Başlama Planı (AI-Driven Geliştirme İçin)

### Hafta 1-2: Temel Altyapı
1. Version Catalog kur (libs.versions.toml) — tüm bağımlılıklar merkezden (Bölüm 30)
2. JUnit 5 + MockK + Turbine ekle, ilk unit testleri yaz
3. detekt + ktlint + Android Lint konfigüre et
4. Self-hosted runner kur + GitHub Actions pipeline
5. JaCoCo coverage raporlamasını aktifleştir
6. LeakCanary + StrictMode ekle (debug build)

### Hafta 3-4: Genişleme
1. Paparazzi ekle, her ekran için snapshot baseline oluştur
2. MockWebServer ile integration testleri yaz
3. Room database testleri (in-memory) + Migration testleri (Bölüm 25)
4. Hilt DI testleri kur — @HiltAndroidTest + FakeModule (Bölüm 23)
5. Dependency Guard ekle

### Hafta 5-6: E2E, Contract ve Background
1. Compose Test + Maestro ile kritik 5 akışı test et
2. Pact-JVM ile contract testleri yaz
3. WorkManager testleri — TestWorkerBuilder ile (Bölüm 24)
4. Process Death / SavedStateHandle testleri (Bölüm 28)
5. Kotest property-based testleri kritik fonksiyonlara ekle
6. Localization testleri

### Hafta 7-8: Performance ve Security
1. Macrobenchmark ile app launch + scroll baseline
2. Baseline Profile üret ve doğrula (Bölüm 26)
3. Gradle Managed Devices kur — ATD ile CI stabilize et (Bölüm 27)
4. Firebase Crashlytics entegrasyonu
5. Security testleri (EncryptedSharedPreferences, HTTPS, gitleaks)
6. Accessibility audit + TalkBack testleri

### Hafta 9-10: Derinleştirme
1. PIT mutation testing kur — test kalitesini ölç
2. R8/ProGuard staging build smoke test pipeline (Bölüm 29)
3. Edge case testleri (Bölüm 12 checklist'inden)
4. Nightly pipeline: benchmark + mutation
5. AI Code Review Checklist'i PR template'ine ekle (Bölüm 14.3)
6. OWASP Dependency Check

### Sürekli (Ongoing)
- Her AI-generated PR'da: lint → unit → snapshot → integration → contract → E2E
- Haftalık: dead code scan + dependency vulnerability scan + secret scan
- Nightly: benchmark + mutation testing + R8 smoke test
- Her release öncesi: accessibility audit + security audit + full regression
- Her schema değişikliğinde: Room migration testi (Bölüm 25)
- Her release build'de: Baseline Profile regenerate + startup benchmark

---

## Sonuç

Bu rehber 21 test ve altyapı katmanını kapsıyor:

1. **Unit Test** — Logic doğruluğu (JUnit 5 + MockK + Turbine)
2. **Snapshot Test** — Görsel regresyon (Paparazzi / Roborazzi)
3. **Integration Test** — Modül uyumu (MockWebServer + Room)
4. **UI / E2E Test** — Kullanıcı akışları (Compose Test + Maestro)
5. **Performance Test** — Hız ve bellek (Macrobenchmark + LeakCanary)
6. **Security Test** — Veri güvenliği (OWASP + EncryptedPrefs)
7. **Accessibility Test** — Erişilebilirlik (TalkBack + A11y Framework)
8. **Static Analysis** — Derleme öncesi hata (detekt + Android Lint)
9. **Mutation Testing** — Test kalitesi ölçümü (PIT / Pitest)
10. **Contract Testing** — API uyumu (Pact-JVM)
11. **Property-Based Testing** — Rastgele edge case (Kotest Property)
12. **Localization Testing** — Çeviri doğruluğu
13. **Production Monitoring** — Canlı hata takibi (Crashlytics + Android Vitals)
14. **Hilt DI Testing** — Dependency injection doğruluğu (@HiltAndroidTest)
15. **WorkManager Testing** — Background task güvenilirliği (TestWorkerBuilder)
16. **Room Migration Testing** — Veritabanı göçü güvenliği (MigrationTestHelper)
17. **Baseline Profiles** — Startup optimizasyonu ve doğrulaması
18. **Gradle Managed Devices** — Tekrarlanabilir CI emülatör ortamı (ATD)
19. **Process Death Testing** — State kaybı önleme (SavedStateHandle)
20. **R8/ProGuard Testing** — Obfuscation sonrası crash önleme
21. **Version Catalog** — Merkezi bağımlılık yönetimi (libs.versions.toml)

AI-driven geliştirmede bu katmanların tamamı kritik. **Coverage değil, mutation score ölç. Stil değil, güvenlik kontrol et. Happy path değil, edge case'leri test et.**

Tamamını uyguladığında hataların **%98+'sini** production öncesi yakalarsın. Kalan %2 için production monitoring + feature flags + staged rollout kullan.

**Her 1 saat test yazma = 10+ saat debug zamanı tasarrufu.**
**AI ile 10x hızlı kod yaz, bu rehber ile 10x güvenli gönder.**
