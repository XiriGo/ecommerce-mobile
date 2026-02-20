# Android Standards — Kotlin + Jetpack Compose + Material 3

> Extracted from `CLAUDE.md`. This is the authoritative reference for all Android development
> in the Molt Marketplace project. Agents MUST follow these patterns exactly.

---

## Table of Contents

1. [SDK Versions](#sdk-versions)
2. [Dependencies](#dependencies)
3. [Kotlin Rules](#kotlin-rules)
4. [Compose Rules](#compose-rules)
5. [Hilt DI Pattern](#hilt-di-pattern)
6. [Network Pattern](#network-pattern)
7. [Code Templates](#code-templates)
   - [UiState Pattern](#uistate-pattern)
   - [ViewModel Pattern](#viewmodel-pattern)
   - [Screen Pattern](#screen-pattern)
   - [Repository Pattern](#repository-pattern)
   - [UseCase Pattern](#usecase-pattern)
   - [Domain Error Pattern](#domain-error-pattern)
   - [Fake Repository for Tests](#fake-repository-for-tests)
8. [Design System](#design-system)
   - [Theme: MoltColors](#theme-moltcolors)
   - [Theme: MoltSpacing](#theme-moltspacing)
   - [Theme: MoltTheme](#theme-molttheme)
   - [Component: MoltButton](#component-moltbutton)
   - [Component: MoltLoadingView](#component-moltloadingview)
   - [Component: MoltErrorView](#component-molterrorview)
   - [Component: MoltEmptyView](#component-moltemptyview)
   - [Component: MoltImage](#component-moltimage)
9. [Environment Configuration](#environment-configuration)
10. [Localization](#localization)
11. [Common Pitfalls](#common-pitfalls)
12. [Debugging Tools](#debugging-tools)
13. [Accessibility Standards](#accessibility-standards)
14. [Performance Standards](#performance-standards)
15. [Security Standards](#security-standards)
16. [CI Pipeline](#ci-pipeline)
17. [Release Process](#release-process)
18. [File Checklists](#file-checklists)
    - [Design System Files](#design-system-files)
    - [Per-Feature Files](#per-feature-files)

---

## SDK Versions

- **minSdk**: 26 (Android 8.0)
- **targetSdk**: 35
- **compileSdk**: 35
- **Kotlin**: 2.1.0
- **Gradle**: 9.2.1
- **AGP**: 8.8.0
- **Compose BOM**: 2026.01.01

## Dependencies

| Category | Library |
|----------|---------|
| UI | Jetpack Compose + Material 3 |
| DI | Hilt (Dagger) |
| Network | Retrofit 3.0 + OkHttp + Kotlin Serialization |
| Image | Coil (Compose) |
| Navigation | Compose Navigation (type-safe) |
| Async | Kotlin Coroutines + Flow |
| State | StateFlow + collectAsStateWithLifecycle() |
| Pagination | Paging 3 (3.4.0) + Compose integration |
| Storage | Proto DataStore + Tink (encrypted), Room (structured) |
| Logging | Timber |
| Crash Reporting | Firebase Crashlytics |
| Analytics | Firebase Analytics |
| Remote Config | Firebase Remote Config (feature flags, force update) |
| Biometrics | BiometricPrompt (AndroidX) |
| Maps | Google Places Autocomplete (address input) |
| Cache | OkHttp Cache (HTTP) + Room (structured local data) |
| Testing | JUnit 4, Truth, MockK, Turbine, Compose UI Test |
| Lint | ktlint + detekt |

## Kotlin Rules

- **No `Any` type** in ViewModel, UseCase, or Domain layer. Use sealed class/interface.
- **Explicit return types** on all public functions.
- **No `!!` (force non-null)**. Use `requireNotNull()` with a message if truly needed.
- **No `var`** for state in ViewModels. Use `MutableStateFlow` with private setter.
- **Immutable data classes** for all models. No mutable properties.
- Use **`when` exhaustively** (no `else` branch on sealed classes).
- Prefer **extension functions** over utility classes.
- Use **`@Stable`** annotation on Compose state classes.
- **No `AndroidViewModel`**: Use `ViewModel()`. Pass dependencies via Hilt, not Context.
- **ViewModels at screen level only**: Never pass ViewModel to child composables. Hoist state.
- **Single `uiState` property**: Expose one `StateFlow<XxxUiState>` per ViewModel, use `stateIn(WhileSubscribed(5_000))`.

## Compose Rules

- **Stateless composables**: Pass state down, events up.
- **Previews**: Every screen composable has a `@Preview` function.
- **No side effects in composables**: Use `LaunchedEffect`, `SideEffect`, `DisposableEffect`.
- **Modifier parameter**: First optional parameter on every composable, default `Modifier`.
- **Material 3 theming**: Always use `MaterialTheme.colorScheme`, never hardcode colors.
- **No hardcoded strings**: Use `stringResource(R.string.xxx)`.

## Hilt DI Pattern

```kotlin
@HiltViewModel
class ProductListViewModel @Inject constructor(
    private val getProductsUseCase: GetProductsUseCase
) : ViewModel() { ... }

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    @Binds
    abstract fun bindProductRepository(impl: ProductRepositoryImpl): ProductRepository
}
```

## Network Pattern

```kotlin
interface ProductApi {
    @GET("store/products")
    suspend fun getProducts(@QueryMap filters: Map<String, String>): ProductListResponse
}
```

---

## Code Templates

Every feature implementation MUST follow these templates exactly. Agents should
copy these patterns for each new feature, replacing `Product` with the feature name.

### UiState Pattern

```kotlin
// feature/product/presentation/state/ProductListUiState.kt
@Stable
sealed interface ProductListUiState {
    data object Loading : ProductListUiState
    data class Success(
        val products: List<Product>,
        val isLoadingMore: Boolean = false,
        val hasMore: Boolean = true,
    ) : ProductListUiState
    data class Error(val message: String) : ProductListUiState
}

sealed interface ProductListEvent {
    data class NavigateToDetail(val productId: String) : ProductListEvent
    data class ShowSnackbar(val message: String) : ProductListEvent
}
```

### ViewModel Pattern

```kotlin
// feature/product/presentation/viewmodel/ProductListViewModel.kt
@HiltViewModel
class ProductListViewModel @Inject constructor(
    private val getProductsUseCase: GetProductsUseCase,
) : ViewModel() {

    private val _event = Channel<ProductListEvent>(Channel.BUFFERED)
    val event: Flow<ProductListEvent> = _event.receiveAsFlow()

    private var offset = 0
    private val limit = 20

    val uiState: StateFlow<ProductListUiState> = getProductsUseCase(
        offset = 0, limit = limit
    ).map<List<Product>, ProductListUiState> { products ->
        ProductListUiState.Success(
            products = products,
            hasMore = products.size >= limit,
        )
    }.catch { e ->
        emit(ProductListUiState.Error(e.toUserMessage()))
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = ProductListUiState.Loading,
    )

    fun onLoadMore() {
        val current = uiState.value
        if (current !is ProductListUiState.Success || current.isLoadingMore || !current.hasMore) return
        viewModelScope.launch {
            // update state, fetch next page, merge results
        }
    }

    fun onProductClick(productId: String) {
        viewModelScope.launch {
            _event.send(ProductListEvent.NavigateToDetail(productId))
        }
    }
}
```

### Screen Pattern

```kotlin
// feature/product/presentation/screen/ProductListScreen.kt
// NOTE: Import from core.designsystem — NEVER use Material 3 components directly
import com.molt.marketplace.core.designsystem.component.MoltLoadingView
import com.molt.marketplace.core.designsystem.component.MoltErrorView
import com.molt.marketplace.core.designsystem.component.MoltLoadingIndicator
import com.molt.marketplace.core.designsystem.theme.MoltSpacing
import com.molt.marketplace.core.designsystem.theme.MoltTheme

@Composable
fun ProductListScreen(
    viewModel: ProductListViewModel = hiltViewModel(),
    onNavigateToDetail: (String) -> Unit,
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(Unit) {
        viewModel.event.collect { event ->
            when (event) {
                is ProductListEvent.NavigateToDetail -> onNavigateToDetail(event.productId)
                is ProductListEvent.ShowSnackbar -> { /* show snackbar */ }
            }
        }
    }

    ProductListContent(
        uiState = uiState,
        onLoadMore = viewModel::onLoadMore,
        onProductClick = viewModel::onProductClick,
    )
}

@Composable
private fun ProductListContent(
    uiState: ProductListUiState,
    onLoadMore: () -> Unit,
    onProductClick: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    when (uiState) {
        is ProductListUiState.Loading -> MoltLoadingView(modifier)
        is ProductListUiState.Error -> MoltErrorView(
            message = uiState.message,
            onRetry = null, // or viewModel::onRetry
            modifier = modifier,
        )
        is ProductListUiState.Success -> {
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                modifier = modifier,
                horizontalArrangement = Arrangement.spacedBy(MoltSpacing.ProductGridSpacing),
                verticalArrangement = Arrangement.spacedBy(MoltSpacing.ProductGridSpacing),
                contentPadding = PaddingValues(MoltSpacing.ScreenPaddingHorizontal),
            ) {
                items(uiState.products, key = { it.id }) { product ->
                    ProductCard(product = product, onClick = { onProductClick(product.id) })
                }
                if (uiState.isLoadingMore) {
                    item(span = { GridItemSpan(2) }) { MoltLoadingIndicator() }
                }
            }
            LaunchedEffect(uiState.products.size) {
                if (uiState.hasMore) onLoadMore()
            }
        }
    }
}

@Preview
@Composable
private fun ProductListContentPreview() {
    MoltTheme {
        ProductListContent(
            uiState = ProductListUiState.Success(products = previewProducts()),
            onLoadMore = {},
            onProductClick = {},
        )
    }
}
```

### Repository Pattern

```kotlin
// feature/product/domain/repository/ProductRepository.kt
interface ProductRepository {
    fun getProductsStream(offset: Int, limit: Int): Flow<List<Product>>
    suspend fun getProductById(id: String): Product
}

// feature/product/data/repository/ProductRepositoryImpl.kt
class ProductRepositoryImpl @Inject constructor(
    private val api: ProductApi,
    private val mapper: ProductMapper,
) : ProductRepository {

    override fun getProductsStream(offset: Int, limit: Int): Flow<List<Product>> = flow {
        val response = api.getProducts(mapOf("offset" to "$offset", "limit" to "$limit"))
        emit(response.products.map(mapper::toDomain))
    }

    override suspend fun getProductById(id: String): Product {
        val response = api.getProductById(id)
        return mapper.toDomain(response.product)
    }
}
```

### UseCase Pattern

```kotlin
// feature/product/domain/usecase/GetProductsUseCase.kt
class GetProductsUseCase @Inject constructor(
    private val repository: ProductRepository,
) {
    operator fun invoke(offset: Int, limit: Int): Flow<List<Product>> =
        repository.getProductsStream(offset, limit)
}
```

### Domain Error Pattern

```kotlin
// core/domain/error/AppError.kt
sealed class AppError : Exception() {
    data class Network(override val message: String = "Network error") : AppError()
    data class Server(val code: Int, override val message: String) : AppError()
    data class NotFound(override val message: String = "Not found") : AppError()
    data class Unauthorized(override val message: String = "Unauthorized") : AppError()
    data class Unknown(override val message: String = "Unknown error") : AppError()
}

// Extension for user-friendly messages — uses string resource IDs
// Actual strings live in res/values/strings.xml (localized per language)
fun Throwable.toUserMessageResId(): Int = when (this) {
    is AppError.Network -> R.string.common_error_network
    is AppError.Server -> R.string.common_error_server
    is AppError.Unauthorized -> R.string.common_error_unauthorized
    is AppError.NotFound -> R.string.common_error_not_found
    else -> R.string.common_error_unknown
}
```

### Fake Repository for Tests

```kotlin
// feature/product/data/repository/FakeProductRepository.kt (in test source set)
class FakeProductRepository : ProductRepository {
    private val products = mutableListOf<Product>()
    var shouldThrow: AppError? = null

    fun addProducts(vararg product: Product) { products.addAll(product) }

    override fun getProductsStream(offset: Int, limit: Int): Flow<List<Product>> = flow {
        shouldThrow?.let { throw it }
        emit(products.drop(offset).take(limit))
    }

    override suspend fun getProductById(id: String): Product {
        shouldThrow?.let { throw it }
        return products.first { it.id == id }
    }
}
```

---

## Design System

All UI components live in `android/app/src/main/java/com/molt/marketplace/core/designsystem/`.

Feature screens **NEVER** use Material 3 or SwiftUI components directly -- they use `Molt*` wrappers.

```
shared/design-tokens/ (JSON)  -->  core/designsystem/ (platform code)  -->  feature/*/presentation/
         ^                              ^                                       ^
   Figma export               Only layer that changes              Stays untouched
   updates these               when Figma arrives                  on design change
```

**Critical Rule**: Feature screens import `core.designsystem` components. When Figma designs arrive, only files under `core/designsystem/` change. Zero feature screen edits needed.

### Design System Directory Structure

```
core/designsystem/
  ├── theme/
  │   ├── MoltTheme.kt          # @Composable wrapper, applies colorScheme + typography
  │   ├── MoltColors.kt         # Custom ColorScheme from design tokens
  │   ├── MoltTypography.kt     # Custom Typography from design tokens
  │   └── MoltSpacing.kt        # Spacing constants object
  └── component/
      ├── MoltButton.kt         # Primary/Secondary/Text button variants
      ├── MoltCard.kt           # Product card, info card variants
      ├── MoltTextField.kt      # Text field with label, error, icon
      ├── MoltTopBar.kt         # Top app bar with back/action
      ├── MoltBottomBar.kt      # Bottom navigation bar
      ├── MoltLoadingView.kt    # Full-screen + inline loading
      ├── MoltErrorView.kt      # Error with retry button
      ├── MoltEmptyView.kt      # Empty state with illustration
      ├── MoltImage.kt          # Coil image with placeholder/error
      └── MoltBadge.kt          # Count badge, status badge
```

### Theme: MoltColors

```kotlin
// core/designsystem/theme/MoltColors.kt
import androidx.compose.ui.graphics.Color

object MoltColors {
    // Primary — updated when Figma arrives
    val Primary = Color(0xFF6750A4)
    val OnPrimary = Color(0xFFFFFFFF)
    val PrimaryContainer = Color(0xFFEADDFF)
    val OnPrimaryContainer = Color(0xFF21005D)

    // Semantic — e-commerce specific
    val Success = Color(0xFF4CAF50)
    val OnSuccess = Color(0xFFFFFFFF)
    val Warning = Color(0xFFFF9800)
    val PriceRegular = Color(0xFF1C1B1F)
    val PriceSale = Color(0xFFB3261E)
    val PriceOriginal = Color(0xFF79747E)
    val RatingStarFilled = Color(0xFFFFC107)
    val RatingStarEmpty = Color(0xFFE0E0E0)
    val BadgeBackground = Color(0xFFB3261E)
    val BadgeText = Color(0xFFFFFFFF)
    val Divider = Color(0xFFCAC4D0)
    val Shimmer = Color(0xFFE7E0EC)
}
```

### Theme: MoltSpacing

```kotlin
// core/designsystem/theme/MoltSpacing.kt
import androidx.compose.ui.unit.dp

object MoltSpacing {
    val XXS = 2.dp
    val XS = 4.dp
    val SM = 8.dp
    val MD = 12.dp
    val Base = 16.dp
    val LG = 24.dp
    val XL = 32.dp
    val XXL = 48.dp
    val XXXL = 64.dp

    // Layout
    val ScreenPaddingHorizontal = 16.dp
    val ScreenPaddingVertical = 16.dp
    val CardPadding = 12.dp
    val ListItemSpacing = 8.dp
    val SectionSpacing = 24.dp
    val ProductGridSpacing = 8.dp
    val MinTouchTarget = 48.dp
}
```

### Theme: MoltTheme

```kotlin
// core/designsystem/theme/MoltTheme.kt
@Composable
fun MoltTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val colorScheme = if (darkTheme) MoltDarkColorScheme else MoltLightColorScheme
    MaterialTheme(
        colorScheme = colorScheme,
        typography = MoltTypography,
        content = content,
    )
}

// Color schemes built from MoltColors — single source of truth
private val MoltLightColorScheme = lightColorScheme(
    primary = MoltColors.Primary,
    onPrimary = MoltColors.OnPrimary,
    primaryContainer = MoltColors.PrimaryContainer,
    onPrimaryContainer = MoltColors.OnPrimaryContainer,
    // ... map all design token colors
)
```

### Component: MoltButton

```kotlin
// core/designsystem/component/MoltButton.kt
enum class MoltButtonStyle { Primary, Secondary, Text }

@Composable
fun MoltButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    style: MoltButtonStyle = MoltButtonStyle.Primary,
    enabled: Boolean = true,
    loading: Boolean = false,
) {
    when (style) {
        MoltButtonStyle.Primary -> Button(
            onClick = onClick,
            modifier = modifier.heightIn(min = MoltSpacing.MinTouchTarget),
            enabled = enabled && !loading,
        ) {
            if (loading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(18.dp),
                    strokeWidth = 2.dp,
                    color = MaterialTheme.colorScheme.onPrimary,
                )
                Spacer(Modifier.width(MoltSpacing.SM))
            }
            Text(text)
        }
        MoltButtonStyle.Secondary -> OutlinedButton(/* same pattern */) { Text(text) }
        MoltButtonStyle.Text -> TextButton(/* same pattern */) { Text(text) }
    }
}
```

### Component: MoltLoadingView

```kotlin
// core/designsystem/component/MoltLoadingView.kt
@Composable
fun MoltLoadingView(modifier: Modifier = Modifier) {
    Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        CircularProgressIndicator()
    }
}

@Composable
fun MoltLoadingIndicator(modifier: Modifier = Modifier) {
    Box(modifier = modifier.fillMaxWidth().padding(MoltSpacing.Base), contentAlignment = Alignment.Center) {
        CircularProgressIndicator(modifier = Modifier.size(24.dp), strokeWidth = 2.dp)
    }
}
```

### Component: MoltErrorView

```kotlin
// core/designsystem/component/MoltErrorView.kt
@Composable
fun MoltErrorView(
    message: String,
    onRetry: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier.fillMaxSize().padding(MoltSpacing.Base),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(Icons.Outlined.ErrorOutline, contentDescription = null, modifier = Modifier.size(48.dp))
        Spacer(Modifier.height(MoltSpacing.Base))
        Text(message, style = MaterialTheme.typography.bodyLarge, textAlign = TextAlign.Center)
        if (onRetry != null) {
            Spacer(Modifier.height(MoltSpacing.Base))
            MoltButton(text = stringResource(R.string.common_retry_button), onClick = onRetry)
        }
    }
}
```

### Component: MoltEmptyView

```kotlin
// core/designsystem/component/MoltEmptyView.kt
@Composable
fun MoltEmptyView(
    message: String,
    modifier: Modifier = Modifier,
    icon: ImageVector = Icons.Outlined.Inbox,
) {
    Column(
        modifier = modifier.fillMaxSize().padding(MoltSpacing.Base),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(icon, contentDescription = null, modifier = Modifier.size(64.dp), tint = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.height(MoltSpacing.Base))
        Text(message, style = MaterialTheme.typography.bodyLarge, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
```

### Component: MoltImage

```kotlin
// core/designsystem/component/MoltImage.kt
@Composable
fun MoltImage(
    url: String?,
    contentDescription: String?,
    modifier: Modifier = Modifier,
    contentScale: ContentScale = ContentScale.Crop,
) {
    AsyncImage(
        model = ImageRequest.Builder(LocalContext.current)
            .data(url)
            .crossfade(true)
            .build(),
        contentDescription = contentDescription,
        modifier = modifier,
        contentScale = contentScale,
        placeholder = painterResource(R.drawable.placeholder),
        error = painterResource(R.drawable.placeholder),
    )
}
```

---

## Environment Configuration

### BuildConfig

```kotlin
// build.gradle.kts
android {
    buildTypes {
        debug {
            buildConfigField("String", "API_BASE_URL", "\"https://api-dev.molt.com\"")
        }
        release {
            buildConfigField("String", "API_BASE_URL", "\"https://api.molt.com\"")
        }
    }
}
```

### Secrets

- `local.properties` for local secrets (API keys, etc.)
- Never commit API keys, tokens, or secrets to version control
- Production secrets via CI/CD environment variables

### Authentication Storage

- Store auth tokens securely: Proto DataStore + Google Tink (EncryptedSharedPreferences is deprecated)
- Auto-refresh expired tokens via interceptor
- Clear tokens on logout or 401 Unauthorized

### Network Security

- Enforce HTTPS for all API calls
- Certificate pinning for production builds
- Network Security Configuration

---

## Localization

### File Structure

```
android/app/src/main/res/
  values/             # English (default)
    strings.xml
  values-mt/          # Maltese
    strings.xml
  values-tr/          # Turkish
    strings.xml
```

### String Key Naming Convention

Format: `<feature>_<screen>_<element>_<description>`

```
// Examples
product_list_title                    -> "Products"
product_list_empty_message            -> "No products found"
product_detail_add_to_cart_button     -> "Add to Cart"
cart_checkout_button                  -> "Proceed to Checkout"
auth_login_email_placeholder          -> "Enter your email"
common_error_network                  -> "Connection error. Please check your internet."
common_retry_button                   -> "Retry"
common_loading_message                -> "Loading..."
```

Prefixes:
- `common_` -- shared across features (errors, buttons, labels)
- `<feature>_` -- feature-specific strings

### Parameterized Strings

```xml
<string name="product_detail_price">%1$s</string>
<string name="cart_item_count">%1$d items</string>
<string name="order_status_format">Order #%1$s — %2$s</string>
```
```kotlin
stringResource(R.string.cart_item_count, count)
```

### Pluralization

```xml
<plurals name="cart_item_count">
    <item quantity="one">%d item</item>
    <item quantity="other">%d items</item>
</plurals>
```
```kotlin
pluralStringResource(R.plurals.cart_item_count, count, count)
```

### Localization Rules

1. **All user-facing strings in resource files** -- zero hardcoded strings in code
2. **Development in English first** -- write English strings, then translate
3. **Keys are code, values are content** -- never change a key after release (breaks translations)
4. **No string concatenation for sentences** -- use parameterized strings (word order differs per language)
5. **Test with longest language** -- Maltese/Turkish strings may be longer than English, test layout
6. **No RTL required** -- all three languages are LTR
7. **Number/currency formatting** -- use `NumberFormat` with locale
8. **Date formatting** -- use locale-aware formatters, never manual format strings

---

## Common Pitfalls

- **Don't**: Put `viewModelScope.launch` in composables --> **Do**: Use `LaunchedEffect`
- **Don't**: Use `GlobalScope` --> **Do**: Use structured concurrency (viewModelScope)
- **Don't**: Pass ViewModels down the tree --> **Do**: Hoist state, pass data and events
- **Don't**: Use `remember` for state that survives configuration changes --> **Do**: Use ViewModel + StateFlow
- **Don't**: Access `Context` in ViewModels --> **Do**: Inject dependencies via Hilt. Never use `AndroidViewModel`.

---

## Debugging Tools

- **Logcat**: Standard logging with Timber
- **Layout Inspector**: UI hierarchy debugging
- **Network Profiler**: API request/response inspection
- **LeakCanary**: Memory leak detection
- **Chucker**: HTTP traffic inspector (debug builds only)

---

## Accessibility Standards

- All interactive elements have `contentDescription`
- Minimum touch target size: 48dp x 48dp
- Support TalkBack screen reader
- Test with Accessibility Scanner
- Color contrast ratio >= 4.5:1 (WCAG AA)

---

## Performance Standards

- App startup time (cold): < 2 seconds
- Screen navigation: < 300ms
- List scrolling: 60fps (16ms per frame)
- Image loading: Progressive (placeholder -> thumbnail -> full)
- Memory leaks: Zero detected by LeakCanary

---

## Security Standards

### API Keys & Secrets

- **Never commit** API keys, tokens, or secrets to version control
- Use `local.properties` for local secrets
- Production secrets via CI/CD environment variables

### Authentication

- Store auth tokens securely: Proto DataStore + Google Tink (EncryptedSharedPreferences is deprecated)
- Auto-refresh expired tokens via interceptor
- Clear tokens on logout or 401 Unauthorized

### Network Security

- Enforce HTTPS for all API calls
- Certificate pinning for production builds
- Network Security Configuration

### Biometric Authentication

- `BiometricPrompt` (AndroidX Biometric library)
- On successful first login, encrypt refresh token with biometric key
- Fallback: If biometric fails 3x, fall back to email + password
- Opt-in: User enables biometric from Settings screen (not forced)

---

## CI Pipeline

Platform: **GitHub Actions**

Workflow file: `.github/workflows/android-ci.yml`

### Pipeline Steps

1. Lint (ktlint + detekt)
2. Unit tests (JUnit)
3. Build debug APK
4. UI tests (on emulator)
5. Code coverage report
6. Build release APK (signed)

### Lint Configuration

- `android/detekt.yml` (Detekt rules)
- ktlint via Gradle plugin

### CI Requirements

- All checks must pass before merge
- Coverage must not decrease
- No new lint warnings
- Build succeeds for both debug and release

---

## Release Process

### Versioning

- Follow semantic versioning: `MAJOR.MINOR.PATCH`
- Increment MAJOR for breaking changes
- Increment MINOR for new features
- Increment PATCH for bug fixes

### Release Steps

1. Update `versionCode` and `versionName` in `build.gradle.kts`
2. Update CHANGELOG.md
3. Create git tag: `android/v1.2.3`
4. Build signed release APK/AAB
5. Upload to Google Play Console (internal test -> beta -> production)

### Beta Distribution

- Google Play Internal Testing track
- No Firebase App Distribution -- native store tools only

### App Size Budget

- **Target**: < 30 MB (APK)
- Monitor size in CI pipeline, warn if exceeds budget
- Use R8/ProGuard for optimization

---

## File Checklists

### Design System Files

Created once during app scaffold (M0-01). All features depend on these.

Location: `android/app/src/main/java/com/molt/marketplace/core/designsystem/`

1. `theme/MoltColors.kt` -- Color constants from design tokens
2. `theme/MoltTypography.kt` -- Typography from design tokens
3. `theme/MoltSpacing.kt` -- Spacing constants
4. `theme/MoltTheme.kt` -- @Composable theme wrapper
5. `component/MoltButton.kt` -- Primary/Secondary/Text button
6. `component/MoltCard.kt` -- Product card, info card
7. `component/MoltTextField.kt` -- Text field with label/error
8. `component/MoltTopBar.kt` -- Top app bar
9. `component/MoltBottomBar.kt` -- Bottom navigation
10. `component/MoltLoadingView.kt` -- Full-screen + inline loading
11. `component/MoltErrorView.kt` -- Error with retry
12. `component/MoltEmptyView.kt` -- Empty state
13. `component/MoltImage.kt` -- Coil image with placeholder
14. `component/MoltBadge.kt` -- Count/status badge

### Per-Feature Files

When implementing a feature, create these files in order.

Location: `android/app/src/main/java/com/molt/marketplace/feature/{name}/`

1. `data/dto/{Name}Dto.kt` -- `@Serializable` data class
2. `domain/model/{Name}.kt` -- domain data class
3. `data/mapper/{Name}Mapper.kt` -- DTO <-> Domain
4. `domain/repository/{Name}Repository.kt` -- interface
5. `data/remote/{Name}Api.kt` -- Retrofit interface
6. `data/repository/{Name}RepositoryImpl.kt` -- implementation
7. `domain/usecase/{Verb}{Name}UseCase.kt` -- business logic
8. `presentation/state/{Screen}UiState.kt` -- sealed interface
9. `presentation/viewmodel/{Screen}ViewModel.kt` -- @HiltViewModel
10. `presentation/screen/{Screen}Screen.kt` -- @Composable + @Preview (uses Molt* components)
11. `di/{Name}Module.kt` -- Hilt @Module

### Naming Conventions

| Element | Convention |
|---------|-----------|
| Classes/Structs | PascalCase |
| Functions | camelCase |
| Variables | camelCase |
| Constants | SCREAMING_SNAKE |
| Files | PascalCase.kt |
| Packages | lowercase.dotted |

### Architecture Naming Rules

| Type | Pattern | Example |
|------|---------|---------|
| DTO | `{Name}Dto` | `ProductDto` |
| Domain model | `{Name}` | `Product` |
| UI state | `{Screen}UiState` | `ProductListUiState` |
| UI event | `{Screen}Event` | `ProductListEvent` |
| Repository interface | `{Name}Repository` | `ProductRepository` |
| Repository impl | `{Name}RepositoryImpl` | `ProductRepositoryImpl` |
| Use case | `{Verb}{Name}UseCase` | `GetProductsUseCase` |
| ViewModel | `{Screen}ViewModel` | `ProductListViewModel` |
| API service | `{Name}Api` | `ProductApi` |
| Mapper | `{Name}Mapper` | `ProductMapper` |
| Stream getter | `get{Name}Stream()` | `getProductsStream(): Flow<List<Product>>` |
| Test fake | `Fake{Name}` | `FakeProductRepository` |
| Test file | `{Name}Test` | `ProductListViewModelTest` |

### Import Order

Imports must follow this order, separated by blank lines:

1. Platform imports (`android.*`)
2. Framework imports (`androidx.*`)
3. Third-party imports
4. Internal/project imports
5. Relative imports

### Test Locations

| Type | Location |
|------|----------|
| Unit (ViewModel) | `app/src/test/**/viewmodel/*Test.kt` |
| Unit (UseCase) | `app/src/test/**/usecase/*Test.kt` |
| Unit (Repository) | `app/src/test/**/repository/*Test.kt` |
| UI | `app/src/androidTest/**/*Test.kt` |

### Test Rules

- **Prefer fakes over mocks** (Google strongly recommended). Create `Fake{Name}Repository` classes that implement the interface with in-memory data. Use mocks (MockK) only when fakes are impractical.
- **Never mock**: DI container, navigation, platform frameworks
- **Only mock/fake**: Network layer, time, local storage
- Each test is independent (no shared mutable state)
- **Test naming**: `test_<method>_<condition>_<expected>` or `fun methodName should expectedResult when condition`
- Use `Turbine` for Flow testing, `composeTestRule` for UI testing, assert on `uiState.value` directly when possible

### Pagination Helper

All list screens use offset-based pagination with these rules:
- `offset`: starts at 0, incremented by `limit` each page
- `limit`: 20 items per page (Medusa default)
- `hasMore`: `true` if returned items count >= limit
- Trigger load more when last item becomes visible
- Show loading indicator at bottom during load more
- Keep existing data on load more failure

### Key File Locations

- `android/app/src/main/java/com/molt/marketplace/` -- Android source root
- `android/app/src/main/java/com/molt/marketplace/core/designsystem/` -- Design system (theme + components)
- `android/app/src/main/java/com/molt/marketplace/core/` -- Core utilities, DI, network
- `android/app/src/main/java/com/molt/marketplace/feature/` -- Feature modules
- `android/app/src/main/res/` -- Android resources (strings, drawables, themes)
- `android/app/build.gradle.kts` -- App-level Gradle configuration
- `android/build.gradle.kts` -- Project-level Gradle configuration
