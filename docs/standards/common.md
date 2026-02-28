# Common Standards — Both Platforms

This document contains all cross-platform and shared standards for the XiriGo Ecommerce mobile app.
Both Android (Kotlin + Jetpack Compose) and iOS (Swift + SwiftUI) teams must follow these rules.

---

## Naming Conventions

| Element | Android (Kotlin) | iOS (Swift) |
|---------|-------------------|-------------|
| Classes/Structs | PascalCase | PascalCase |
| Functions | camelCase | camelCase |
| Variables | camelCase | camelCase |
| Constants | SCREAMING_SNAKE | PascalCase (static let) |
| Files | PascalCase.kt | PascalCase.swift |
| Packages/Modules | lowercase.dotted | PascalCase |

---

## Architecture Naming Rules

| Type | Pattern | Android Example | iOS Example |
|------|---------|-----------------|-------------|
| DTO | `{Name}Dto` | `ProductDto` | `ProductDTO` |
| Domain model | `{Name}` | `Product` | `Product` |
| UI state | `{Screen}UiState` | `ProductListUiState` | `ProductListUiState` |
| UI event | `{Screen}Event` | `ProductListEvent` | `ProductListEvent` |
| Repository interface | `{Name}Repository` | `ProductRepository` | `ProductRepository` |
| Repository impl | `{Name}RepositoryImpl` | `ProductRepositoryImpl` | `ProductRepositoryImpl` |
| Use case | `{Verb}{Name}UseCase` | `GetProductsUseCase` | `GetProductsUseCase` |
| ViewModel | `{Screen}ViewModel` | `ProductListViewModel` | `ProductListViewModel` |
| API service | `{Name}Api` | `ProductApi` | N/A (use Endpoint enum) |
| Mapper | `{Name}Mapper` | `ProductMapper` | extension on DTO |
| Stream getter | `get{Name}Stream()` | `getProductsStream(): Flow<List<Product>>` | `getProductsStream() -> AsyncStream<[Product]>` |
| Test fake | `Fake{Name}` | `FakeProductRepository` | `FakeProductRepository` |
| Test file | `{Name}Test` | `ProductListViewModelTest` | `ProductListViewModelTests` |

---

## Import Order

Imports must follow this order, separated by blank lines:

1. Platform imports (android.*, UIKit, SwiftUI)
2. Framework imports (androidx.*, Foundation)
3. Third-party imports
4. Internal/project imports
5. Relative imports

---

## Error Handling

- Domain errors as sealed class (Kotlin) / enum (Swift)
- Map API errors to domain errors in repository layer
- UI-friendly error messages in presentation layer
- Never swallow errors silently
- Log errors for debugging
- **Never send one-off events from ViewModel to UI** (Google strongly recommended). Process the event immediately in ViewModel and update state with the result.

---

## API Integration

- All backend API calls go through the repository layer
- DTOs are separate from domain models (always map)
- API contracts defined in `shared/api-contracts/`
- Base URL from environment/build config (never hardcoded)
- Auth token injected via interceptor (Android) / middleware (iOS)
- Pagination: offset-based (Medusa standard)

---

## Localization

### Supported Languages

| Priority | Language | Code | Role |
|----------|----------|------|------|
| 1 | English | `en` | **Default** (development language, fallback) |
| 2 | Maltese | `mt` | Secondary |
| 3 | Turkish | `tr` | Tertiary |

### File Structure

**Android** (`android/app/src/main/res/`):
```
res/
  values/             # English (default)
    strings.xml
  values-mt/          # Maltese
    strings.xml
  values-tr/          # Turkish
    strings.xml
```

**iOS** (`ios/XiriGoEcommerce/Resources/`):
```
Resources/
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

**Android**:
```xml
<string name="product_detail_price">%1$s</string>
<string name="cart_item_count">%1$d items</string>
<string name="order_status_format">Order #%1$s -- %2$s</string>
```
```kotlin
stringResource(R.string.cart_item_count, count)
```

**iOS**:
```swift
// String Catalog supports interpolation automatically
String(localized: "cart_item_count \(count)")
// or with explicit table
String(localized: "order_status_format \(orderId) \(status)")
```

### Pluralization

**Android** (`res/values/strings.xml`):
```xml
<plurals name="cart_item_count">
    <item quantity="one">%d item</item>
    <item quantity="other">%d items</item>
</plurals>
```
```kotlin
pluralStringResource(R.plurals.cart_item_count, count, count)
```

**iOS** (String Catalog handles automatically):
```swift
// Xcode String Catalog auto-detects plurals from interpolation
String(localized: "\(count) items in cart")
// Configure plural variants in Xcode String Catalog UI
```

### Rules

1. **All user-facing strings in resource files** -- zero hardcoded strings in code
2. **Development in English first** -- write English strings, then translate
3. **Keys are code, values are content** -- never change a key after release (breaks translations)
4. **No string concatenation for sentences** -- use parameterized strings (word order differs per language)
5. **Test with longest language** -- Maltese/Turkish strings may be longer than English, test layout
6. **No RTL required** -- all three languages are LTR
7. **Number/currency formatting** -- use `NumberFormatter` (iOS) / `NumberFormat` (Android) with locale
8. **Date formatting** -- use locale-aware formatters, never manual format strings

---

## State Management

- **Unidirectional Data Flow (UDF)**: UI -> Event -> ViewModel -> State -> UI
- Screen state as a single sealed interface/enum with Loading, Success, Error variants
- Side effects (navigation, snackbar) via Channel/SharedFlow (Android) or AsyncSequence (iOS)

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

## Security Standards

### API Keys & Secrets
- **Never commit** API keys, tokens, or secrets to version control
- Use environment-specific configuration files (gitignored)
- Android: `local.properties` for local secrets
- iOS: `.xcconfig` files for local secrets
- Production secrets via CI/CD environment variables

### Authentication
- Store auth tokens securely:
  - Android: Proto DataStore + Google Tink (EncryptedSharedPreferences is deprecated)
  - iOS: KeychainAccess (wrapper for Keychain Services)
- Auto-refresh expired tokens via interceptor/middleware
- Clear tokens on logout or 401 Unauthorized

### Network Security
- Enforce HTTPS for all API calls
- Certificate pinning for production builds
- Android: Network Security Configuration
- iOS: App Transport Security (ATS)

---

## Accessibility Standards

### Android
- All interactive elements have `contentDescription`
- Minimum touch target size: 48dp x 48dp
- Support TalkBack screen reader
- Test with Accessibility Scanner
- Color contrast ratio >= 4.5:1 (WCAG AA)

### iOS
- All interactive elements have `accessibilityLabel`
- Minimum touch target size: 44pt x 44pt
- Support VoiceOver screen reader
- Test with Accessibility Inspector
- Support Dynamic Type (text scaling)

---

## Performance Standards

### Android
- App startup time (cold): < 2 seconds
- Screen navigation: < 300ms
- List scrolling: 60fps (16ms per frame)
- Image loading: Progressive (placeholder -> thumbnail -> full)
- Memory leaks: Zero detected by LeakCanary

### iOS
- App startup time (cold): < 2 seconds
- Screen navigation: < 300ms
- List scrolling: 60fps (16ms per frame)
- Image loading: Progressive with caching
- Memory leaks: Zero detected by Instruments

---

## Code Review Checklist

### Architecture
- [ ] Clean Architecture layers respected (Data -> Domain -> Presentation)
- [ ] No business logic in ViewModels or UI
- [ ] Repository pattern used for data access
- [ ] Use cases encapsulate business logic

### Code Quality
- [ ] No `Any` type (Kotlin) or force unwrap (Swift)
- [ ] All functions have explicit return types
- [ ] Immutable data models
- [ ] Proper error handling (no silent failures)
- [ ] No hardcoded strings or colors

### Testing
- [ ] Unit tests for ViewModels and UseCases
- [ ] UI tests for critical user flows
- [ ] Coverage >= 80% for new code
- [ ] All tests pass before merge

### UI/UX
- [ ] Uses `XG*` design system components (no raw Material 3 / SwiftUI components in feature screens)
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

## Design System & Component Architecture

### Design Source

Designs come from Adobe Illustrator SVG files in `XiriGo-Design/Svg/`. Design tokens are extracted into `shared/design-tokens/*.json`. The `XGTheme` on each platform reads these tokens.

### SVG & Design Asset Rules (CRITICAL)

1. **SVG files are VISUAL REFERENCE ONLY**: Do NOT extract hex colors, pixel dimensions, or gradient stops from SVG files and hardcode them into code. SVGs show design intent and layout — not implementation specs.
2. **Use design tokens**: All colors via `XGColors.*`, spacing via `XGSpacing.*`, typography via `XGTypography.*`, gradients via `gradients.json`. Never hardcode `#6000FE` or `350×192` from SVG analysis.
3. **Use ready-made PNG/image assets when available**: If `XiriGo-Design/Png_Pattern/` or asset catalogs contain ready-made images (backgrounds, patterns, icons), use them directly via `Image()`. Do NOT recreate them in code with gradients, shaders, or canvas drawing.
4. **Responsive layouts**: All dimensions must be responsive. No hardcoded pixel widths/heights from SVG coordinates. Use relative sizing, flexible frames, and design token spacing.
5. **Native platform components**: Build UI with native Jetpack Compose / SwiftUI components wrapped in `XG*` design system wrappers. Do NOT try to replicate SVG layers as coded canvas drawings.

### Existing Code Rules (CRITICAL)

1. **Check before creating**: Before creating any file, component, or screen — check if it already exists. Use `Glob` and `Grep` to search the codebase.
2. **Extend, don't recreate**: If a screen or component already exists, refactor/extend it. Do NOT create a new file that duplicates or replaces existing code without explicit instruction.
3. **Component inventory in issues**: Issue descriptions mark components as `NEW`, `EXISTS`, `UPDATE`, or `VERIFY`. Follow these statuses strictly. If a component is marked `EXISTS`, do NOT recreate it.
4. **Preserve working code**: When adding Clean Architecture layers (ViewModel, UseCase, Repository) to an existing screen, keep the existing UI and refactor it to consume the new ViewModel — don't rewrite the screen from scratch.

### XG* Component Rules

1. **One component per file**: Each `XG*` component lives in its own file in `core/designsystem/component/`. No monolithic "ScreenComponents.kt" files.
2. **Single responsibility**: Each component does one thing. `XGProductCard` renders a product card. `XGPriceText` renders a price. Never combine unrelated UI into one component.
3. **Data + callbacks only**: Components accept domain data and event callbacks as parameters. Zero business logic inside components. Zero ViewModel references.
4. **Reusable across features**: If a component appears in more than one screen, it MUST be in `core/designsystem/`. Never duplicate UI code in feature screens.
5. **Token-driven**: All colors from `XGColors`, all spacing from `XGSpacing`, all typography from `XGTypography`. Zero magic numbers.
6. **Preview mandatory**: Every component must have `@Preview` (Android) / `#Preview` (iOS) showing all variants (default, loading, error, empty, active, inactive).

### Design Token Files

| File | Content |
|------|---------|
| `shared/design-tokens/colors.json` | Brand, light/dark theme, semantic, category colors |
| `shared/design-tokens/typography.json` | Poppins + Source Sans 3, type scale, price typography |
| `shared/design-tokens/spacing.json` | Spacing scale, corner radius, elevation, layout specs |
| `shared/design-tokens/gradients.json` | Brand gradient, hero overlay, daily deal, card fade |
| `shared/design-tokens/components.json` | All XG* component specs with exact pixel values |

### What Changes vs What Doesn't

| Changes (design layer) | Never Changes (architecture layer) |
|------------------------|-----------------------------------|
| `shared/design-tokens/*.json` | ViewModels, UseCases |
| `core/designsystem/theme/XG*.kt/.swift` | Repositories, DTOs, domain models |
| `core/designsystem/component/XG*.kt/.swift` | Navigation, API integration |
| `res/drawable/` / `Assets.xcassets` | Tests, DI modules |

### Rules for Feature Screens

1. **No magic numbers**: All dimensions from `XGSpacing`, all colors from `XGColors`
2. **No raw platform components**: Use `XGButton` not `Button`, `XGLoadingView` not `CircularProgressIndicator`
3. **Component props, not visual props**: Feature screens pass data + events to components. Components decide how to render.
4. **Preview with theme**: All `@Preview` / `#Preview` wrapped in `XGTheme`

---

## Image Loading Pattern

All async images MUST use `XGImage` with a 3-state approach:

### Image States

1. **Loading**: Animated shimmer placeholder (gradient sweep, not spinner)
2. **Success**: Fade-in transition (300ms crossfade)
3. **Error**: Branded fallback image (product silhouette on light gray background)

### Android Example (Coil)

```kotlin
XGImage(
    url = product.thumbnailUrl,
    contentDescription = product.name,
    modifier = Modifier.size(160.dp),
    // shimmer while loading, branded placeholder on error
)
```

### iOS Example (AsyncImage / Nuke)

```swift
XGImage(
    url: product.thumbnailUrl,
    contentDescription: product.name
)
.frame(width: 160, height: 160)
```

### Image Loading Rules

- **Never show broken image icon** -- always show branded fallback
- **Never block UI on image load** -- images load asynchronously
- **Cache aggressively** -- both memory and disk cache enabled
- **Placeholder matches content size** -- shimmer fills exact same frame as final image
- **Content mode**: `.fill` / `ContentScale.Crop` for product images, `.fit` / `ContentScale.Fit` for icons

---

## Mock Data → API Transition Pattern

Features use **Clean Architecture with Repository pattern** for trivial mock→API swap.

### Data Flow Architecture

```text
Screen → ViewModel → UseCase → Repository (interface) → [FakeImpl | RealImpl]
```

### Development Phase (Mock Data)

1. Define `{Feature}Repository` **interface** in `domain/repository/`
2. Create `Fake{Feature}Repository` in `data/repository/` — returns hardcoded sample data
3. Bind fake in DI module: `bind(FeatureRepository).to(FakeFeatureRepository)`
4. Feature screen works end-to-end with realistic mock data

### Production Phase (Real API)

1. Create `{Feature}RepositoryImpl` — calls Medusa API via Retrofit/URLSession
2. Change ONE line in DI: `bind(FeatureRepository).to(FeatureRepositoryImpl)`
3. Zero changes to ViewModel, UseCase, or Screen

### Mock Data Quality Rules

- **Realistic content**: Use real-looking product names, prices in EUR, rating values 1-5
- **Realistic image URLs**: Use `https://picsum.photos/{width}/{height}` for development
- **Match SVG design**: Mock data should produce screens that look like the design SVG
- **Edge cases**: Include items with long names (2-line truncation), zero reviews, no discount
- **Minimum items**: Lists should have enough items to test scrolling (6+ for horizontal, 10+ for vertical)

---

## Payment Integration

### Provider: Stripe

- **Medusa plugin**: `medusa-payment-stripe` (backend)
- **Android SDK**: Stripe Android SDK (PaymentSheet)
- **iOS SDK**: Stripe iOS SDK (PaymentSheet)
- **Apple Pay**: Supported via Stripe PaymentSheet (iOS)
- **Google Pay**: Supported via Stripe PaymentSheet (Android)
- **3D Secure**: Handled automatically by Stripe SDK
- **Currency**: EUR (single currency)

### Payment Flow
1. Client creates cart -> backend creates Stripe PaymentIntent
2. Client presents Stripe PaymentSheet with clientSecret
3. User enters card / selects Apple Pay / Google Pay
4. Stripe SDK handles 3D Secure if required
5. On success -> client confirms payment via Medusa API
6. Backend captures payment, creates order

### Currency
- **Single currency**: EUR (Euro)
- All prices stored and displayed in EUR
- Use locale-aware `NumberFormatter` (iOS) / `NumberFormat` (Android) for display
- Format: `€12.99` (symbol before amount, dot separator)

---

## Analytics & Remote Config

### Firebase Analytics
- **Both platforms** use Firebase Analytics for event tracking
- Event naming: `snake_case` (e.g., `product_view`, `add_to_cart`, `begin_checkout`)
- Screen tracking: automatic via `FirebaseAnalytics.logEvent("screen_view")`
- User properties: `user_id`, `user_type` (guest/registered), `locale`

### Firebase Remote Config
- **Feature flags**: Enable/disable features per version or user segment
- **Force update**: `min_supported_version` parameter checked on app launch
- **A/B testing**: Test UI variants via Remote Config + Analytics

### Force Update Strategy
1. App launch -> fetch `min_supported_version` from Firebase Remote Config
2. Compare with current app version
3. If current < min -> show blocking dialog: "Please update" -> link to store
4. If current < recommended (soft update) -> show dismissible banner

---

## Real-Time Updates

### Strategy: Push Notification Only

- Order status changes -> backend sends push notification (FCM / APNs)
- User taps notification -> navigates to order detail screen
- Order detail screen: pull-to-refresh for latest status
- **No WebSocket or polling** -- push + pull-to-refresh is sufficient for e-commerce

---

## Session Management

### Multi-Device Policy
- **Multiple devices allowed** -- user can be logged in on several devices simultaneously
- No session limit, no forced logout on other devices
- Each device has its own access/refresh token pair
- **No inactivity timeout** -- session persists until explicit logout or token expiry

### Biometric Authentication
- **First login**: Email + password (mandatory)
- **Subsequent logins**: Biometric option (if device supports it)
- **Android**: `BiometricPrompt` (AndroidX Biometric library)
- **iOS**: `LocalAuthentication` framework (Face ID / Touch ID)
- **Storage**: On successful first login, encrypt refresh token with biometric key
- **Fallback**: If biometric fails 3x -> fall back to email + password
- **Opt-in**: User enables biometric from Settings screen (not forced)

---

## Caching Strategy

### HTTP Cache Layer
- **Android**: OkHttp `Cache` with 10 MB disk cache
- **iOS**: `URLCache` with 10 MB memory / 50 MB disk
- Cache headers from backend control TTL (5 min products, 1 hour categories)

### Local Structured Data
- **Android**: Room database for cart, wishlist, recent searches, user profile
- **iOS**: SwiftData for cart, wishlist, recent searches, user profile
- Cart persists offline, syncs on next network call
- Wishlist works offline (toggle locally, sync when online)
- Recent searches: max 10 items, stored locally only

### Offline Behavior
- Show cached data when offline (product lists, categories)
- Show "No Internet" banner (non-blocking)
- Disable actions requiring network (checkout, add to cart for new items)
- Auto-retry when connection restored

---

## Address & Maps

### Google Places Autocomplete
- Used for shipping address input (M2-04)
- User types address -> autocomplete suggestions from Google Places API
- On selection -> fill street, city, postal code, country fields
- **Android**: Google Places SDK
- **iOS**: Google Places SDK (SPM)
- **API Key**: Stored in `local.properties` (Android) / `.xcconfig` (iOS), never committed
- **No map view** -- autocomplete only, no visual map display needed

---

## Device Support

- **Phone-first**: No special tablet layouts. Grid columns adapt by width class (Compact=2, Medium=3, Expanded=4).
- **Portrait-only**: All screens locked to portrait orientation.
  - Android: `android:screenOrientation="portrait"` in AndroidManifest.xml
  - iOS: `UISupportedInterfaceOrientations` = portrait only in Info.plist
- **Minimum screen**: Android 320dp width (minSdk 26), iOS 375pt width (iPhone SE 3rd gen)
- **Dark mode**: Handled by `XGTheme` -- no extra configuration needed
- **Full guide**: `docs/guides/device-support.md`
