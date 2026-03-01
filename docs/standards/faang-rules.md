# FAANG-Level Enforcement Rules

> **Note:** These rules are enforced by lint configs, architecture tests, and CI/CD pipelines. Violations block merge.

These rules are enforced by lint configs (`detekt.yml`, `.swiftlint.yml`), architecture tests
(`ArchitectureTest.kt`, `ArchitectureTests.swift`), and CI/CD pipelines. Violations block merge.

---

## Complexity Budget

| Metric | Limit | Enforced By |
|--------|-------|-------------|
| Cyclomatic complexity | <= 10 per function | detekt / SwiftLint |
| Function body length | <= 60 lines | detekt / SwiftLint |
| File length | <= 400 lines | detekt / SwiftLint |
| Method parameters | <= 6 | detekt / SwiftLint |
| Line length | <= 120 characters | ktlint / SwiftLint |

## Zero Dead Code Policy

- Zero unused imports, variables, functions, or parameters
- No commented-out code blocks
- No `TODO` comments without linked GitHub issue
- No unreachable code paths

## Dependency Direction Enforcement

Enforced by `ArchitectureTest.kt` (Android) and `ArchitectureTests.swift` (iOS):

```
presentation/ → domain/ → (nothing)
data/ → domain/ → (nothing)
presentation/ ✗ data/  (forbidden)
domain/ ✗ data/         (forbidden)
domain/ ✗ presentation/ (forbidden)
```

- Domain layer: ZERO imports from `data/` or `presentation/`
- Presentation layer: ZERO imports from `data/`
- ViewModels: No `android.content.Context` or `android.app.*` imports (Android)
- ViewModels: Must have `@MainActor` and `@Observable` (iOS)
- Feature screens: Must use `XG*` components, no raw Material 3 / SwiftUI

## API Safety

- All network calls wrapped in `try/catch` with domain error mapping
- Never swallow exceptions — every `catch` has a meaningful action (log + user message)
- Domain errors as sealed class (Kotlin) / enum (Swift)
- No hardcoded API URLs, keys, or secrets
- Auth tokens via interceptor/middleware only

## Immutability Rules

- All domain models are immutable (`data class` / `struct`)
- No `var` for state in ViewModels — use `MutableStateFlow` (Android) / `@Observable` (iOS)
- All DTOs are immutable
- Collections exposed as `List` (Kotlin) / `[T]` (Swift), never mutable

## Naming Discipline

- Intention-revealing names — no abbreviations (`productListViewModel`, not `plvm`)
- No single-letter variables except lambdas (`it`, `$0`)
- No Hungarian notation
- Follow platform naming conventions strictly (see Naming Conventions table)

## Design System Compliance

### Component Rules
- Feature screens: `XG*` components ONLY (no raw `Button`, `TextField`, `ProgressView`, `SearchBar`)
- If a reusable UI element exists in feature code, extract it to `core/designsystem/component/`

### Color Token Rules
- All colors from `XGColors` — no exceptions
- **`Color.White` / `Color.white` / `.white` counts as hardcoded** — use `XGColors.TextOnDark` / `XGColors.textOnDark`
- **`Color.Black` / `Color.black` counts as hardcoded** — use `XGColors.TextDark` / `XGColors.textDark`
- **`Color(0xFF...)` counts as hardcoded** — define in `XGColors` first, then reference the token
- Platform defaults (`.primary`, `.secondary`) are allowed only inside `core/designsystem/`

### Typography Token Rules
- All fonts from `XGTypography` — never use `Font.system(...)`, `Font.custom("Poppins-...")`, or inline `TextStyle(fontFamily = ...)` in components or feature screens
- **Primary font**: Poppins (all weights via `XGTypography.*`)
- **Price font**: Source Sans 3 Black (via `XGTypography.priceFont` / `XGTypography.PriceStyle`)
- If a new font style is needed, add it to `XGTypography` first, then use the token

### Spacing & Corner Radius Token Rules
- All spacing from `XGSpacing` — no magic numbers for padding, margins, gaps
- All corner radii from `XGCornerRadius` — never hardcode `10.dp` / `10` for corners
- All elevation from `XGElevation` — never hardcode shadow values

### Font Size & Line Height Constants
- Inline `fontSize = XX.sp` and `lineHeight = XX.sp` in composables MUST be extracted to named `private val` or `private enum Constants`
- Never duplicate the same dimension value across multiple composables — extract to a shared constant

### Preview Rules
- Every `@Preview` (Android) / `#Preview` (iOS) MUST be wrapped in `XGTheme { }` / `.xgTheme()`
- Previews must show realistic data (not "Lorem ipsum")
- Extract repeated preview data to a `private object PreviewData` / `private enum PreviewData`

## Sample Data & Mock Data Localization

- **All user-facing strings in sample/mock/fake data MUST be localized** — use `stringResource()` (Android) / `String(localized:)` (iOS)
- This includes: product names, banner titles, badge labels, category names, error messages
- Sample data string keys follow the same `<feature>_<element>_<description>` convention
- Only non-user-facing IDs and technical values (URLs, hex codes, currency codes) can be raw strings

## Error Handling Patterns

### Error Message Resolution
- **Android**: Use `@StringRes` resource IDs in `UiState.Error`, never raw `String` messages
  - `HomeUiState.Error(messageResId = R.string.common_error_network)` — correct
  - `HomeUiState.Error(message = e.message ?: "Error")` — **wrong**
- **iOS**: Use `error.toUserMessage` (which reads from String Catalog), never `error.localizedDescription`
  - `uiState = .error(message: error.toUserMessage)` — correct
  - `uiState = .error(message: error.localizedDescription)` — **wrong**
- Every exception type maps to a specific localized string resource
- Catch chains must be specific: `IOException` → network, `HttpException` → server, `SerializationException` → parse

### Exception Catch Chains (Android)
```kotlin
// WRONG — generic catch
catch (e: Exception) { ... }

// RIGHT — specific catch chain
catch (e: IOException) { HomeUiState.Error(R.string.common_error_network) }
catch (e: retrofit2.HttpException) { HomeUiState.Error(R.string.common_error_server) }
catch (e: SerializationException) { HomeUiState.Error(R.string.common_error_server) }
```

## ViewModel State Consolidation

### Single StateFlow Rule (Android)
- Each ViewModel exposes exactly ONE `StateFlow<UiState>` — no secondary flows
- Transient states (like `isRefreshing`) MUST be properties of the `UiState` variant, not separate StateFlows
  - `data class Success(val data: Data, val isRefreshing: Boolean = false)` — correct
  - `private val _isRefreshing = MutableStateFlow(false)` — **wrong** (separate flow)
- On refresh error, stay in `Success` with `isRefreshing = false` — don't transition to `Error` (preserves user's data)

### Immutable UI State (iOS)
- All properties in UI state models MUST be `let`, never `var`
- Use `copy()` / new enum case to update state — never mutate in place

## Zero Lint Suppression Policy

Lint rules exist to enforce production-quality code. Suppressing them hides problems instead of fixing them.

### Banned Patterns

| Platform | Banned Pattern | What To Do Instead |
|----------|----------------|-------------------|
| Android | `@Suppress("...")` on any detekt/ktlint rule | Fix the code to comply, or configure the rule properly in `detekt.yml` / `.editorconfig` |
| iOS | `// swiftlint:disable` (file-level or inline) | Fix the code to comply, or configure exclusions in `.swiftlint.yml` |

### Allowed Exceptions (Configure, Don't Suppress)

When a lint rule is structurally incompatible with a pattern (not just inconvenient), **configure the tool** -- never suppress inline:

| Situation | Wrong (Suppress) | Right (Configure) |
|-----------|-------------------|-------------------|
| Compose PascalCase functions | `@Suppress("ktlint:standard:function-naming")` | `.editorconfig`: `ktlint_function_naming_ignore_when_annotated_with = Composable,Preview` |
| Design token literal numbers | `// swiftlint:disable no_magic_numbers` | `.swiftlint.yml`: exclude `Theme/` and token files from `no_magic_numbers` |
| Test files exceeding length | `// swiftlint:disable file_length` | `.swiftlint.yml`: higher limits for test paths via per-rule `excluded` |
| Catching broad exceptions | `@Suppress("TooGenericExceptionCaught")` | Catch specific types: `IOException`, `HttpException`, `SerializationException` |
| Complex Compose functions | `@Suppress("CyclomaticComplexMethod")` | Extract sub-composables and helper functions to reduce complexity |

### CI Enforcement

The quality gate (`/verify`) checks for suppression markers. Any `@Suppress` or `swiftlint:disable` in committed code **fails the gate** (except in auto-generated files).

### Pre-commit Check

```bash
# Runs automatically via pre-commit hook
grep -rn '@Suppress' --include='*.kt' android/app/src/main/
grep -rn 'swiftlint:disable' --include='*.swift' ios/XiriGoEcommerce/ ios/XiriGoEcommerceTests/
# Both must return zero results
```

## Component Performance Rules

See `docs/standards/component-quality.md` for full details. Summary of enforced rules:

| Rule | Android | iOS | Enforced By |
|------|---------|-----|-------------|
| Lazy rendering for lists >4 | LazyColumn/LazyVerticalGrid | LazyVStack/LazyVGrid | Code review |
| Animated shimmer (not static) | Modifier.shimmerEffect() | .shimmerEffect() | Code review |
| Skeleton loading screens | Shape-matching composables | Shape-matching views | Code review |
| Image downsampling | Coil size() | Nuke resize() | Code review |
| key() on lazy items | LazyColumn items(key=) | ForEach(id:) | detekt custom rule |
| Animation tokens only | motion.json durations | motion.json durations | Code review |
| Zero hardcoded animation ms | No `300L`, `500` inline | No `0.3`, `0.5` inline | Code review |
