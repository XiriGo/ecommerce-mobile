# Testing Standards

Extracted from the project's `CLAUDE.md` — the single source of truth for Molt Marketplace testing conventions.

---

## Coverage Thresholds

- **Lines**: >= 80%
- **Functions**: >= 80%
- **Branches**: >= 70%

## Test Types

| Type | Android Location | iOS Location |
|------|-----------------|--------------|
| Unit (ViewModel) | `app/src/test/**/viewmodel/*Test.kt` | `MoltMarketplaceTests/**/ViewModel/*Tests.swift` |
| Unit (UseCase) | `app/src/test/**/usecase/*Test.kt` | `MoltMarketplaceTests/**/UseCase/*Tests.swift` |
| Unit (Repository) | `app/src/test/**/repository/*Test.kt` | `MoltMarketplaceTests/**/Repository/*Tests.swift` |
| UI | `app/src/androidTest/**/*Test.kt` | `MoltMarketplaceUITests/**/*UITests.swift` |

## Test Rules

- **Prefer fakes over mocks** (Google strongly recommended). Create `Fake{Name}Repository` classes that implement the interface with in-memory data. Use mocks (MockK/protocol mocks) only when fakes are impractical.
- **Never mock**: DI container, navigation, platform frameworks
- **Only mock/fake**: Network layer, time, local storage
- Each test is independent (no shared mutable state)
- **Test naming**: `test_<method>_<condition>_<expected>` or `fun methodName should expectedResult when condition`
- **Android**: Use `Turbine` for Flow testing, `composeTestRule` for UI testing, assert on `uiState.value` directly when possible
- **iOS**: Use `Swift Testing` framework with `@Test` macro, `ViewInspector` for SwiftUI testing

## Android: Fake Repository Pattern

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

## iOS: Fake Repository Pattern

```swift
// MoltMarketplaceTests/Fakes/FakeProductRepository.swift
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
