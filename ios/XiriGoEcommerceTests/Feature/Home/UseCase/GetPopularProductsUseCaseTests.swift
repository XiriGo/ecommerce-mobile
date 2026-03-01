import Testing
@testable import XiriGoEcommerce

// MARK: - GetPopularProductsUseCaseTests

@Suite("GetPopularProductsUseCase Tests")
struct GetPopularProductsUseCaseTests {
    // MARK: - Success

    @Test("execute returns products from repository")
    func execute_returnsProductsFromRepository() async throws {
        let repository = FakeHomeRepository()
        let product = HomeProduct(
            id: "prod_1",
            title: "Headphones",
            imageUrl: nil,
            price: "79.99",
            currencyCode: "eur",
            originalPrice: "129.99",
            vendor: "TechZone",
            rating: 4.5,
            reviewCount: 234,
            isNew: false,
        )
        repository.popularProductsToReturn = [product]
        let useCase = GetPopularProductsUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result == [product])
    }

    @Test("execute returns empty array when repository has no products")
    func execute_returnsEmptyArray_whenNoProducts() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetPopularProductsUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result.isEmpty)
    }

    @Test("execute preserves product properties")
    func execute_preservesProductProperties() async throws {
        let repository = FakeHomeRepository()
        let product = HomeProduct(
            id: "prod_abc",
            title: "Smart Watch",
            imageUrl: "https://example.com/watch.jpg",
            price: "199.99",
            currencyCode: "eur",
            originalPrice: "249.99",
            vendor: "LuxTime",
            rating: 4.8,
            reviewCount: 456,
            isNew: false,
        )
        repository.popularProductsToReturn = [product]
        let useCase = GetPopularProductsUseCase(repository: repository)

        let result = try await useCase.execute()

        let returned = try #require(result.first)
        #expect(returned.id == "prod_abc")
        #expect(returned.price == "199.99")
        #expect(returned.rating == 4.8)
        #expect(returned.isNew == false)
    }

    // MARK: - Error Propagation

    @Test("execute propagates network error from repository")
    func execute_propagatesNetworkError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        let useCase = GetPopularProductsUseCase(repository: repository)

        await #expect(throws: AppError.network()) {
            _ = try await useCase.execute()
        }
    }

    // MARK: - Delegation

    @Test("execute delegates to repository.getPopularProducts")
    func execute_delegatesToRepository() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetPopularProductsUseCase(repository: repository)

        _ = try await useCase.execute()

        #expect(repository.getPopularProductsCallCount == 1)
    }
}
