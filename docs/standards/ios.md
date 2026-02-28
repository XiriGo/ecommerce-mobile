# iOS Standards — Swift + SwiftUI

Extracted from the project's `CLAUDE.md`. This is the authoritative reference for all iOS development
in the XiriGo Ecommerce app. Agents and developers must follow these patterns exactly.

---

## Table of Contents

- [Versions](#versions)
- [Dependencies (SPM)](#dependencies-spm)
- [Swift Rules](#swift-rules)
- [SwiftUI Rules](#swiftui-rules)
- [DI Pattern (Factory)](#di-pattern-factory)
- [Network Pattern](#network-pattern)
- [Code Templates](#code-templates)
  - [UiState Pattern](#uistate-pattern)
  - [ViewModel Pattern](#viewmodel-pattern)
  - [View Pattern](#view-pattern)
  - [Repository Pattern](#repository-pattern)
  - [UseCase Pattern](#usecase-pattern)
  - [Domain Error Pattern](#domain-error-pattern)
  - [Fake Repository for Tests](#fake-repository-for-tests)
- [Design System](#design-system)
  - [Theme: XGColors.swift](#theme-xgcolorsswift)
  - [Theme: XGSpacing.swift](#theme-xgspacingswift)
  - [Component: XGButton.swift](#component-xgbuttonswift)
  - [Component: XGLoadingView.swift](#component-xgloadingviewswift)
  - [Component: XGErrorView.swift](#component-xgerrorviewswift)
  - [Component: XGEmptyView.swift](#component-xgemptyviewswift)
  - [Component: XGImage.swift](#component-xgimageswift)
- [Localization](#localization)
- [Environment Configuration](#environment-configuration)
- [Security](#security)
- [Accessibility](#accessibility)
- [Performance](#performance)
- [Common Pitfalls](#common-pitfalls)
- [Debugging Tools](#debugging-tools)
- [CI Pipeline](#ci-pipeline)
- [Release Process](#release-process)
- [File Checklists](#file-checklists)
  - [Design System Files (One-Time Scaffold)](#design-system-files-one-time-scaffold)
  - [Per-Feature Files](#per-feature-files)
- [Naming Conventions](#naming-conventions)
- [Architecture Naming Rules](#architecture-naming-rules)
- [Test Requirements](#test-requirements)
- [Code Review Checklist (iOS)](#code-review-checklist-ios)
- [Design Transition Strategy](#design-transition-strategy)
- [Enforcement Rules](#enforcement-rules)

---

## Versions

- **Minimum iOS**: 17.0
- **Target iOS**: 18.0
- **Swift**: 6.2
- **Xcode**: 16+

## Dependencies (SPM)

| Category | Library |
|----------|---------|
| UI | SwiftUI (built-in) |
| DI | Factory (`@Injected` property wrapper) |
| Network | URLSession + async/await + Codable |
| Image | Nuke (NukeUI) |
| Navigation | NavigationStack + NavigationPath |
| Async | Swift Concurrency (async/await, Task) |
| Storage | UserDefaults, SwiftData |
| Security | KeychainAccess (token storage) |
| Logging | os.Logger (Apple unified logging) |
| Crash Reporting | Sentry |
| Analytics | Firebase Analytics |
| Remote Config | Firebase Remote Config (feature flags, force update) |
| Biometrics | LocalAuthentication (Face ID / Touch ID) |
| Maps | Google Places Autocomplete (address input) |
| Cache | URLCache (HTTP) + SwiftData (structured local data) |
| Testing | Swift Testing + XCTest, ViewInspector, swift-snapshot-testing |
| Lint | SwiftFormat + SwiftLint |

## Swift Rules

- **No force unwrap (`!`)**: Always use `guard let`, `if let`, or nil coalescing (`??`).
- **No `Any` or `AnyObject`** in domain/presentation. Use protocols and generics.
- **Explicit access control**: `public`, `internal`, `private` on all declarations.
- **`@MainActor`** on all ViewModels and UI-related classes.
- **Sendable conformance** for all types passed across concurrency boundaries.
- **`final class`** by default. Only remove `final` when subclassing is explicitly needed.
- **Prefer value types** (struct, enum) over reference types (class).
- **Use `@Observable`** for view models (iOS 17+ minimum -- no `ObservableObject` needed).

## SwiftUI Rules

- **Body should be simple**: Extract complex views into separate structs.
- **Use `@Environment`** for dependency injection in views.
- **No `AnyView`**: Use `@ViewBuilder` or `some View` generics.
- **Previews**: Every view has a `#Preview` block.
- **No hardcoded strings**: Use `String(localized:)` or `.localizable` pattern.
- **Theme tokens**: Always use theme constants, never hardcode colors/fonts.

## DI Pattern (Factory)

```swift
import Factory

// Container.swift — register dependencies
extension Container {
    var apiClient: Factory<APIClient> {
        self { APIClientImpl(baseURL: Config.apiBaseURL) }
            .singleton
    }
    var productRepository: Factory<ProductRepository> {
        self { ProductRepositoryImpl(apiClient: self.apiClient()) }
    }
}

// Usage in ViewModel
@MainActor @Observable
final class ProductListViewModel {
    @ObservationIgnored @Injected(\.productRepository) private var repository
    // ...
}
```

## Network Pattern

```swift
struct APIClient {
    let baseURL: URL
    let session: URLSession

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let (data, response) = try await session.data(for: endpoint.urlRequest(baseURL: baseURL))
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        return try JSONDecoder.api.decode(T.self, from: data)
    }
}
```

---

## Code Templates

Every feature implementation MUST follow these templates exactly. Agents should
copy these patterns for each new feature, replacing `Product` with the feature name.

### UiState Pattern

```swift
// Feature/Product/Presentation/ProductListUiState.swift
enum ProductListUiState: Equatable {
    case loading
    case success(products: [Product], isLoadingMore: Bool = false, hasMore: Bool = true)
    case error(message: String)
}

enum ProductListEvent {
    case navigateToDetail(productId: String)
    case showToast(message: String)
}
```

### ViewModel Pattern

```swift
// Feature/Product/Presentation/ProductListViewModel.swift
@MainActor @Observable
final class ProductListViewModel {
    private(set) var uiState: ProductListUiState = .loading
    private let getProductsUseCase: GetProductsUseCase

    private var offset = 0
    private let limit = 20
    var onEvent: ((ProductListEvent) -> Void)?

    init(getProductsUseCase: GetProductsUseCase) {
        self.getProductsUseCase = getProductsUseCase
    }

    func loadProducts() async {
        uiState = .loading
        do {
            let products = try await getProductsUseCase.execute(offset: 0, limit: limit)
            offset = products.count
            uiState = .success(products: products, hasMore: products.count >= limit)
        } catch {
            uiState = .error(message: error.toUserMessage())
        }
    }

    func loadMore() async {
        guard case .success(let products, false, true) = uiState else { return }
        uiState = .success(products: products, isLoadingMore: true, hasMore: true)
        do {
            let newProducts = try await getProductsUseCase.execute(offset: offset, limit: limit)
            offset += newProducts.count
            uiState = .success(
                products: products + newProducts,
                hasMore: newProducts.count >= limit
            )
        } catch {
            uiState = .success(products: products, hasMore: true) // keep existing data
        }
    }

    func onProductTap(_ productId: String) {
        onEvent?(.navigateToDetail(productId: productId))
    }
}
```

### View Pattern

```swift
// Feature/Product/Presentation/ProductListView.swift
// NOTE: Import from Core/DesignSystem — NEVER use raw SwiftUI ProgressView/etc. in screens
import SwiftUI

struct ProductListView: View {
    @State private var viewModel: ProductListViewModel

    init(viewModel: ProductListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                XGLoadingView()
            case .error(let message):
                XGErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.loadProducts() } }
                )
            case .success(let products, let isLoadingMore, let hasMore):
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: XGSpacing.productGridSpacing
                    ) {
                        ForEach(products) { product in
                            ProductCard(product: product)
                                .onTapGesture { viewModel.onProductTap(product.id) }
                        }
                    }
                    .padding(.horizontal, XGSpacing.screenPaddingHorizontal)

                    if isLoadingMore {
                        XGLoadingIndicator()
                    }

                    if hasMore {
                        Color.clear
                            .frame(height: 1)
                            .onAppear { Task { await viewModel.loadMore() } }
                    }
                }
                .refreshable { await viewModel.loadProducts() }
            }
        }
        .task { await viewModel.loadProducts() }
    }
}

#Preview {
    ProductListView(viewModel: ProductListViewModel(
        getProductsUseCase: GetProductsUseCase(repository: FakeProductRepository())
    ))
}
```

### Repository Pattern

```swift
// Feature/Product/Domain/ProductRepository.swift
protocol ProductRepository: Sendable {
    func getProducts(offset: Int, limit: Int) async throws -> [Product]
    func getProductById(_ id: String) async throws -> Product
}

// Feature/Product/Data/ProductRepositoryImpl.swift
final class ProductRepositoryImpl: ProductRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getProducts(offset: Int, limit: Int) async throws -> [Product] {
        let response: ProductListResponse = try await apiClient.request(
            .getProducts(offset: offset, limit: limit)
        )
        return response.products.map(\.toDomain)
    }

    func getProductById(_ id: String) async throws -> Product {
        let response: ProductDetailResponse = try await apiClient.request(
            .getProduct(id: id)
        )
        return response.product.toDomain
    }
}
```

### UseCase Pattern

```swift
// Feature/Product/Domain/GetProductsUseCase.swift
final class GetProductsUseCase: Sendable {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(offset: Int, limit: Int) async throws -> [Product] {
        try await repository.getProducts(offset: offset, limit: limit)
    }
}
```

### Domain Error Pattern

```swift
// Core/Network/AppError.swift
enum AppError: Error, Equatable {
    case network(message: String = "Network error")
    case server(code: Int, message: String)
    case notFound(message: String = "Not found")
    case unauthorized(message: String = "Unauthorized")
    case unknown(message: String = "Unknown error")
}

extension Error {
    /// Returns localized user-facing message from String Catalog
    var toUserMessage: String {
        guard let appError = self as? AppError else {
            return String(localized: "common_error_unknown")
        }
        switch appError {
        case .network: return String(localized: "common_error_network")
        case .server(let code, _): return String(localized: "common_error_server \(code)")
        case .unauthorized: return String(localized: "common_error_unauthorized")
        case .notFound: return String(localized: "common_error_not_found")
        case .unknown: return String(localized: "common_error_unknown")
        }
    }
}
```

### Fake Repository for Tests

```swift
// XiriGoEcommerceTests/Fakes/FakeProductRepository.swift
final class FakeProductRepository: ProductRepository, @unchecked Sendable {
    var products: [Product] = []
    var errorToThrow: AppError?

    func getProducts(offset: Int, limit: Int) async throws -> [Product] {
        if let error = errorToThrow { throw error }
        return Array(products.dropFirst(offset).prefix(limit))
    }

    func getProductById(_ id: String) async throws -> Product {
        if let error = errorToThrow { throw error }
        guard let product = products.first(where: { $0.id == id }) else {
            throw AppError.notFound()
        }
        return product
    }
}
```

---

## Design System

### Design System Layer Structure

All UI components live in a shared design system module that wraps platform components.
Feature screens **NEVER** use raw SwiftUI components directly -- they use `XG*` wrappers.

```
shared/design-tokens/ (JSON)  ->  Core/DesignSystem/ (Swift code)  ->  Feature/*/Presentation/
         ^                              ^                                       ^
   Figma export               Only layer that changes              Stays untouched
   updates these               when Figma arrives                  on design change
```

**Directory layout** (`ios/XiriGoEcommerce/Core/DesignSystem/`):
```
Core/DesignSystem/
  +-- Theme/
  |   +-- XGTheme.swift       # ViewModifier, applies color + typography
  |   +-- XGColors.swift      # Color constants from design tokens
  |   +-- XGTypography.swift  # Font styles from design tokens
  |   +-- XGSpacing.swift     # Spacing constants enum
  +-- Component/
      +-- XGButton.swift      # Primary/Secondary/Text button variants
      +-- XGCard.swift        # Product card, info card variants
      +-- XGTextField.swift   # Text field with label, error, icon
      +-- XGTopBar.swift      # NavigationBar wrapper
      +-- XGTabBar.swift      # Tab bar wrapper
      +-- XGLoadingView.swift # Full-screen + inline loading
      +-- XGErrorView.swift   # Error with retry button
      +-- XGEmptyView.swift   # Empty state with illustration
      +-- XGImage.swift       # Nuke image with placeholder/error
      +-- XGBadge.swift       # Count badge, status badge
```

**Critical Rule**: Feature screens import `Core/DesignSystem` components. When Figma designs arrive, only files under `Core/DesignSystem/` change. Zero feature screen edits needed.

### Theme: XGColors.swift

```swift
// Core/DesignSystem/Theme/XGColors.swift
import SwiftUI

enum XGColors {
    // Primary — updated when Figma arrives
    static let primary = Color(hex: "#6750A4")
    static let onPrimary = Color.white
    static let primaryContainer = Color(hex: "#EADDFF")
    static let onPrimaryContainer = Color(hex: "#21005D")

    // Semantic — e-commerce specific
    static let success = Color(hex: "#4CAF50")
    static let onSuccess = Color.white
    static let warning = Color(hex: "#FF9800")
    static let priceRegular = Color(hex: "#1C1B1F")
    static let priceSale = Color(hex: "#B3261E")
    static let priceOriginal = Color(hex: "#79747E")
    static let ratingStarFilled = Color(hex: "#FFC107")
    static let ratingStarEmpty = Color(hex: "#E0E0E0")
    static let badgeBackground = Color(hex: "#B3261E")
    static let badgeText = Color.white
    static let divider = Color(hex: "#CAC4D0")
    static let shimmer = Color(hex: "#E7E0EC")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
```

### Theme: XGSpacing.swift

```swift
// Core/DesignSystem/Theme/XGSpacing.swift
import SwiftUI

enum XGSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64

    // Layout
    static let screenPaddingHorizontal: CGFloat = 16
    static let screenPaddingVertical: CGFloat = 16
    static let cardPadding: CGFloat = 12
    static let listItemSpacing: CGFloat = 8
    static let sectionSpacing: CGFloat = 24
    static let productGridSpacing: CGFloat = 8
    static let minTouchTarget: CGFloat = 44  // Apple HIG: 44pt
}
```

### Component: XGButton.swift

```swift
// Core/DesignSystem/Component/XGButton.swift
import SwiftUI

enum XGButtonStyle { case primary, secondary, text }

struct XGButton: View {
    let title: String
    let style: XGButtonStyle
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, style: XGButtonStyle = .primary, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: XGSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(style == .primary ? .white : XGColors.primary)
                }
                Text(title)
            }
            .frame(maxWidth: style == .text ? nil : .infinity)
            .frame(minHeight: XGSpacing.minTouchTarget)
        }
        .disabled(isLoading)
        .buttonStyle(xgButtonStyle)
    }

    @ViewBuilder
    private var xgButtonStyle: some ButtonStyle {
        switch style {
        case .primary: .borderedProminent
        case .secondary: .bordered
        case .text: .plain
        }
    }
}
```

### Component: XGLoadingView.swift

```swift
// Core/DesignSystem/Component/XGLoadingView.swift
struct XGLoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct XGLoadingIndicator: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding(XGSpacing.base)
    }
}
```

### Component: XGErrorView.swift

```swift
// Core/DesignSystem/Component/XGErrorView.swift
struct XGErrorView: View {
    let message: String
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: XGSpacing.base) {
            Spacer()
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
            if let onRetry {
                XGButton(String(localized: "common_retry_button"), action: onRetry)
                    .frame(width: 200)
            }
            Spacer()
        }
        .padding(XGSpacing.base)
    }
}
```

### Component: XGEmptyView.swift

```swift
// Core/DesignSystem/Component/XGEmptyView.swift
struct XGEmptyView: View {
    let message: String
    var systemImage: String = "tray"

    var body: some View {
        VStack(spacing: XGSpacing.base) {
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(XGSpacing.base)
    }
}
```

### Component: XGImage.swift

```swift
// Core/DesignSystem/Component/XGImage.swift
import NukeUI
import SwiftUI

struct XGImage: View {
    let url: URL?
    var contentMode: SwiftUI.ContentMode = .fill

    var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if state.error != nil {
                Color(XGColors.shimmer)
            } else {
                Color(XGColors.shimmer)
            }
        }
        .transition(.opacity.animation(.easeInOut(duration: 0.25)))
    }
}
```

---

## Localization

### Supported Languages

| Priority | Language | Code | Role |
|----------|----------|------|------|
| 1 | English | `en` | **Default** (development language, fallback) |
| 2 | Maltese | `mt` | Secondary |
| 3 | Turkish | `tr` | Tertiary |

### File Structure

```
ios/XiriGoEcommerce/Resources/
  Localizable.xcstrings    # All languages in one file (Xcode 15+ String Catalog)
  -- or --
  en.lproj/Localizable.strings   # English (default)
  mt.lproj/Localizable.strings   # Maltese
  tr.lproj/Localizable.strings   # Turkish
```

Prefer `Localizable.xcstrings` (String Catalog) -- single file, Xcode handles all languages.

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

```swift
// String Catalog supports interpolation automatically
String(localized: "cart_item_count \(count)")
// or with explicit table
String(localized: "order_status_format \(orderId) \(status)")
```

### Pluralization

```swift
// Xcode String Catalog auto-detects plurals from interpolation
String(localized: "\(count) items in cart")
// Configure plural variants in Xcode String Catalog UI
```

### Localization Rules

1. **All user-facing strings in resource files** -- zero hardcoded strings in code
2. **Development in English first** -- write English strings, then translate
3. **Keys are code, values are content** -- never change a key after release (breaks translations)
4. **No string concatenation for sentences** -- use parameterized strings (word order differs per language)
5. **Test with longest language** -- Maltese/Turkish strings may be longer than English, test layout
6. **No RTL required** -- all three languages are LTR
7. **Number/currency formatting** -- use `NumberFormatter` with locale
8. **Date formatting** -- use locale-aware formatters, never manual format strings

---

## Environment Configuration

```swift
// Config.swift
enum Config {
    static let apiBaseURL: URL = {
        #if DEBUG
        return URL(string: "https://api-dev.xirigo.com")!
        #else
        return URL(string: "https://api.xirigo.com")!
        #endif
    }()
}
```

- Use `.xcconfig` files for local secrets (API keys, etc.)
- Never commit API keys, tokens, or secrets to version control
- Production secrets via CI/CD environment variables

---

## Security

### API Keys & Secrets
- **Never commit** API keys, tokens, or secrets to version control
- iOS: `.xcconfig` files for local secrets (gitignored)
- Production secrets via CI/CD environment variables

### Authentication
- Store auth tokens securely via **KeychainAccess** (wrapper for Keychain Services)
- Auto-refresh expired tokens via middleware
- Clear tokens on logout or 401 Unauthorized

### Network Security
- Enforce HTTPS for all API calls
- Certificate pinning for production builds
- App Transport Security (ATS) enabled

### Biometric Authentication
- **First login**: Email + password (mandatory)
- **Subsequent logins**: Biometric option (if device supports it)
- **Framework**: `LocalAuthentication` (Face ID / Touch ID)
- **Storage**: On successful first login, encrypt refresh token with biometric key
- **Fallback**: If biometric fails 3x, fall back to email + password
- **Opt-in**: User enables biometric from Settings screen (not forced)

---

## Accessibility

- All interactive elements have `accessibilityLabel`
- Minimum touch target size: 44pt x 44pt
- Support VoiceOver screen reader
- Test with Accessibility Inspector
- Support Dynamic Type (text scaling)

---

## Performance

- App startup time (cold): < 2 seconds
- Screen navigation: < 300ms
- List scrolling: 60fps (16ms per frame)
- Image loading: Progressive with caching
- Memory leaks: Zero detected by Instruments

---

## Common Pitfalls

- **Don't**: Use `@State` in ViewModels --> **Do**: Use `@Observable` macro (iOS 17+)
- **Don't**: Perform async work in view initializers --> **Do**: Use `.task` or `.onAppear`
- **Don't**: Force unwrap optionals --> **Do**: Use `guard let`, `if let`, or `??`
- **Don't**: Use `DispatchQueue.main.async` --> **Do**: Use `@MainActor` and async/await
- **Don't**: Create retain cycles with `self` in closures --> **Do**: Use `[weak self]` or `[unowned self]`

---

## Debugging Tools

- **Console**: Structured logging with os.Logger (privacy redaction)
- **View Hierarchy**: UI hierarchy debugging (Xcode)
- **Network Link Conditioner**: Network simulation
- **Instruments**: Performance profiling
- **Proxyman**: HTTP traffic inspector

---

## CI Pipeline

Platform: **GitHub Actions** (`/.github/workflows/ios-ci.yml`)

Steps:

1. Format (SwiftFormat) + Lint (SwiftLint)
2. Unit tests (Swift Testing)
3. Build debug app
4. UI tests (on simulator)
5. Code coverage report
6. Build release IPA (signed)

### Lint Configuration

- `.swiftlint.yml` (SwiftLint rules)
- `.swiftformat` (SwiftFormat rules)

### CI Requirements

- All checks must pass before merge
- Coverage must not decrease
- No new lint warnings
- Build succeeds for both debug and release
- Zero `swiftlint:disable` comments in code (see Zero Lint Suppression Policy in `faang-rules.md`)

### SwiftLint Exclusion Patterns

When a lint rule is structurally incompatible with certain files (e.g., design tokens contain literal numbers), configure exclusions in `.swiftlint.yml` -- **never** use inline `swiftlint:disable`:

```yaml
# .swiftlint.yml - exclude design system tokens from no_magic_numbers
no_magic_numbers:
  excluded:
    - "XiriGoEcommerce/Core/DesignSystem/Theme/*"
    - "XiriGoEcommerce/Core/DesignSystem/Component/*"

# Higher length limits for test files
file_length:
  warning: 300
  error: 400
  excluded:
    - "XiriGoEcommerceTests/**"
```

---

## Release Process

### Versioning

- Follow semantic versioning: `MAJOR.MINOR.PATCH`
- Increment MAJOR for breaking changes
- Increment MINOR for new features
- Increment PATCH for bug fixes

### iOS Release Steps

1. Update version and build number in Xcode
2. Update CHANGELOG.md
3. Create git tag: `ios/v1.2.3`
4. Archive and upload to App Store Connect
5. Submit for review (TestFlight --> App Store)

### Beta Distribution

- **iOS**: TestFlight
- No Firebase App Distribution -- native store tools only

### App Size Budget

- **Target**: < 30 MB (IPA)
- Monitor size in CI pipeline, warn if exceeds budget
- Use bitcode + app thinning for optimization

---

## File Checklists

### Design System Files (One-Time Scaffold)

Created once during app scaffold (M0-01). All features depend on these.

Location: `ios/XiriGoEcommerce/Core/DesignSystem/`

1. `Theme/XGColors.swift` -- Color constants from design tokens
2. `Theme/XGTypography.swift` -- Font styles from design tokens
3. `Theme/XGSpacing.swift` -- Spacing constants
4. `Theme/XGTheme.swift` -- ViewModifier theme wrapper
5. `Component/XGButton.swift` -- Primary/Secondary/Text button
6. `Component/XGCard.swift` -- Product card, info card
7. `Component/XGTextField.swift` -- Text field with label/error
8. `Component/XGTopBar.swift` -- Navigation bar wrapper
9. `Component/XGTabBar.swift` -- Tab bar wrapper
10. `Component/XGLoadingView.swift` -- Full-screen + inline loading
11. `Component/XGErrorView.swift` -- Error with retry
12. `Component/XGEmptyView.swift` -- Empty state
13. `Component/XGImage.swift` -- Nuke image with placeholder
14. `Component/XGBadge.swift` -- Count/status badge

### Per-Feature Files

When implementing a feature, create these files in order.

Location: `ios/XiriGoEcommerce/Feature/{Name}/`

1. `Data/{Name}DTO.swift` -- Codable struct
2. `Domain/{Name}.swift` -- domain struct
3. `Data/{Name}DTO+Extensions.swift` -- DTO -> Domain mapping
4. `Domain/{Name}Repository.swift` -- protocol
5. `Data/{Name}Endpoint.swift` -- API endpoint enum
6. `Data/{Name}RepositoryImpl.swift` -- implementation
7. `Domain/{Verb}{Name}UseCase.swift` -- business logic
8. `Presentation/{Screen}UiState.swift` -- enum
9. `Presentation/{Screen}ViewModel.swift` -- @Observable @MainActor
10. `Presentation/{Screen}View.swift` -- SwiftUI View + #Preview (uses XG* components)
11. Register in `Container+Extensions.swift` (Factory)

---

## Naming Conventions

| Element | Convention |
|---------|------------|
| Classes/Structs | PascalCase |
| Functions | camelCase |
| Variables | camelCase |
| Constants | PascalCase (static let) |
| Files | PascalCase.swift |
| Modules | PascalCase |

## Architecture Naming Rules

| Type | Pattern | iOS Example |
|------|---------|-------------|
| DTO | `{Name}DTO` | `ProductDTO` |
| Domain model | `{Name}` | `Product` |
| UI state | `{Screen}UiState` | `ProductListUiState` |
| UI event | `{Screen}Event` | `ProductListEvent` |
| Repository interface | `{Name}Repository` | `ProductRepository` |
| Repository impl | `{Name}RepositoryImpl` | `ProductRepositoryImpl` |
| Use case | `{Verb}{Name}UseCase` | `GetProductsUseCase` |
| ViewModel | `{Screen}ViewModel` | `ProductListViewModel` |
| API service | N/A (use Endpoint enum) | -- |
| Mapper | extension on DTO | -- |
| Stream getter | `get{Name}Stream()` | `getProductsStream() -> AsyncStream<[Product]>` |
| Test fake | `Fake{Name}` | `FakeProductRepository` |
| Test file | `{Name}Tests` | `ProductListViewModelTests` |

### Import Order

Imports must follow this order, separated by blank lines:

1. Platform imports (UIKit, SwiftUI)
2. Framework imports (Foundation)
3. Third-party imports
4. Internal/project imports
5. Relative imports

---

## Test Requirements

### Coverage Thresholds

- **Lines**: >= 80%
- **Functions**: >= 80%
- **Branches**: >= 70%

### Test Types

| Type | Location |
|------|----------|
| Unit (ViewModel) | `XiriGoEcommerceTests/**/ViewModel/*Tests.swift` |
| Unit (UseCase) | `XiriGoEcommerceTests/**/UseCase/*Tests.swift` |
| Unit (Repository) | `XiriGoEcommerceTests/**/Repository/*Tests.swift` |
| UI | `XiriGoEcommerceUITests/**/*UITests.swift` |

### Test Rules

- **Prefer fakes over mocks** (Google strongly recommended). Create `Fake{Name}Repository` classes that implement the interface with in-memory data. Use mocks (protocol mocks) only when fakes are impractical.
- **Never mock**: DI container, navigation, platform frameworks
- **Only mock/fake**: Network layer, time, local storage
- Each test is independent (no shared mutable state)
- **Test naming**: `test_<method>_<condition>_<expected>` or `func methodName should expectedResult when condition`
- Use **Swift Testing** framework with `@Test` macro, **ViewInspector** for SwiftUI testing

---

## Code Review Checklist (iOS)

### Architecture
- [ ] Clean Architecture layers respected (Data -> Domain -> Presentation)
- [ ] No business logic in ViewModels or UI
- [ ] Repository pattern used for data access
- [ ] Use cases encapsulate business logic

### Code Quality
- [ ] No force unwrap (`!`) in code
- [ ] No `Any` or `AnyObject` in domain/presentation
- [ ] All functions have explicit return types
- [ ] Immutable data models (structs)
- [ ] Proper error handling (no silent failures)
- [ ] No hardcoded strings or colors

### Testing
- [ ] Unit tests for ViewModels and UseCases
- [ ] UI tests for critical user flows
- [ ] Coverage >= 80% for new code
- [ ] All tests pass before merge

### UI/UX
- [ ] Uses `XG*` design system components (no raw SwiftUI components in feature screens)
- [ ] All colors from `XGColors`, all spacing from `XGSpacing` (no magic numbers)
- [ ] Responsive to different screen sizes
- [ ] Loading and error states implemented (XGLoadingView, XGErrorView)
- [ ] Accessibility labels present
- [ ] No hardcoded strings (all localized)

### Documentation
- [ ] Public APIs documented
- [ ] Complex logic explained with comments
- [ ] Feature README updated
- [ ] CHANGELOG updated

---

## Design Transition Strategy

### Phase 1: Dummy Screens (Current)

- Use system styles via `XGTheme`
- All colors/spacing from `XGColors` / `XGSpacing` (which map to design tokens)
- Feature screens use `XG*` design system components (XGButton, XGCard, etc.)
- Focus on correct architecture, data flow, and business logic -- not pixel-perfect design

### Phase 2: Figma Design Arrives

When Figma designs are ready, **only these change**:

| What Changes | Files | Impact |
|-------------|-------|--------|
| Design tokens | `shared/design-tokens/*.json` | Colors, typography, spacing values |
| Theme | `Core/DesignSystem/Theme/XG*.swift` | New color scheme, fonts, spacing |
| Components | `Core/DesignSystem/Component/XG*.swift` | Visual appearance (padding, shapes, shadows) |
| Assets | `Assets.xcassets` | Icons, illustrations, placeholders |

**What NEVER changes**: ViewModels, UseCases, Repositories, DTOs, domain models, navigation, API integration, tests.

### Rules for Figma-Safe Code

1. **No magic numbers in feature screens**: All dimensions from `XGSpacing`, all colors from `XGColors`
2. **No raw platform components in feature screens**: Use `XGButton` not `Button`, `XGLoadingView` not `ProgressView`
3. **Component props, not visual props**: Feature screens pass data + events to components. Components decide how to render.
4. **Preview with theme**: All `#Preview` wrapped in `XGTheme` to reflect current design tokens

---

## Enforcement Rules

These rules are enforced by lint configs (`.swiftlint.yml`), architecture tests
(`ArchitectureTests.swift`), and CI/CD pipelines. Violations block merge.

### Complexity Budget

| Metric | Limit | Enforced By |
|--------|-------|-------------|
| Cyclomatic complexity | <= 10 per function | SwiftLint |
| Function body length | <= 60 lines | SwiftLint |
| File length | <= 400 lines | SwiftLint |
| Method parameters | <= 6 | SwiftLint |
| Line length | <= 120 characters | SwiftLint |

### Zero Dead Code Policy

- Zero unused imports, variables, functions, or parameters
- No commented-out code blocks
- No `TODO` comments without linked GitHub issue
- No unreachable code paths

### Dependency Direction Enforcement

Enforced by `ArchitectureTests.swift`:

```
presentation/ -> domain/ -> (nothing)
data/ -> domain/ -> (nothing)
presentation/ X data/  (forbidden)
domain/ X data/         (forbidden)
domain/ X presentation/ (forbidden)
```

- Domain layer: ZERO imports from `data/` or `presentation/`
- Presentation layer: ZERO imports from `data/`
- ViewModels: Must have `@MainActor` and `@Observable`
- Feature screens: Must use `XG*` components, no raw SwiftUI

### API Safety

- All network calls wrapped in `try/catch` with domain error mapping
- Never swallow exceptions -- every `catch` has a meaningful action (log + user message)
- Domain errors as enum (Swift)
- No hardcoded API URLs, keys, or secrets
- Auth tokens via middleware only

### Immutability Rules

- All domain models are immutable (`struct`)
- No `var` for state in ViewModels -- use `@Observable`
- All DTOs are immutable
- Collections exposed as `[T]`, never mutable

### Naming Discipline

- Intention-revealing names -- no abbreviations (`productListViewModel`, not `plvm`)
- No single-letter variables except lambdas (`$0`)
- No Hungarian notation
- Follow platform naming conventions strictly (see Naming Conventions table)

### Design System Compliance

- Feature screens: `XG*` components ONLY (no raw `Button`, `TextField`, `ProgressView`)
- All colors from `XGColors` -- no hardcoded hex values in feature code
- All spacing from `XGSpacing` -- no magic numbers for dimensions
- Every view has `#Preview` wrapped in `XGTheme`

---

## Key File Locations

- `ios/XiriGoEcommerce/` -- iOS source root
- `ios/XiriGoEcommerce/Core/DesignSystem/` -- Design system (theme + components)
- `ios/XiriGoEcommerce/Core/` -- Core utilities, DI, network
- `ios/XiriGoEcommerce/Feature/` -- Feature modules
- `ios/XiriGoEcommerce/Resources/` -- iOS resources (assets, localization)
- `ios/XiriGoEcommerce.xcodeproj/` -- Xcode project file
- `ios/Package.swift` -- Swift Package Manager dependencies

---

## Pagination Helper

All list screens use offset-based pagination with these rules:
- `offset`: starts at 0, incremented by `limit` each page
- `limit`: 20 items per page (Medusa default)
- `hasMore`: `true` if returned items count >= limit
- Trigger load more when last item becomes visible
- Show loading indicator at bottom during load more
- Keep existing data on load more failure

---

## Caching Strategy

### HTTP Cache Layer
- `URLCache` with 10 MB memory / 50 MB disk
- Cache headers from backend control TTL (5 min products, 1 hour categories)

### Local Structured Data
- SwiftData for cart, wishlist, recent searches, user profile
- Cart persists offline, syncs on next network call
- Wishlist works offline (toggle locally, sync when online)
- Recent searches: max 10 items, stored locally only

### Offline Behavior
- Show cached data when offline (product lists, categories)
- Show "No Internet" banner (non-blocking)
- Disable actions requiring network (checkout, add to cart for new items)
- Auto-retry when connection restored

---

## Device Support

- **Phone-first**: No special tablet layouts. Grid columns adapt by width class (Compact=2, Medium=3, Expanded=4).
- **Portrait-only**: All screens locked to portrait orientation via `UISupportedInterfaceOrientations` = portrait only in Info.plist
- **Minimum screen**: 375pt width (iPhone SE 3rd gen)
- **Dark mode**: Handled by `XGTheme` -- no extra configuration needed

---

## Payment Integration (iOS)

- **SDK**: Stripe iOS SDK (PaymentSheet)
- **Apple Pay**: Supported via Stripe PaymentSheet
- **3D Secure**: Handled automatically by Stripe SDK
- **Currency**: EUR (single currency)
- Use locale-aware `NumberFormatter` for price display
- Format: `€12.99` (symbol before amount, dot separator)

---

*Extracted from `CLAUDE.md`. Last Updated: 2026-02-20.*
