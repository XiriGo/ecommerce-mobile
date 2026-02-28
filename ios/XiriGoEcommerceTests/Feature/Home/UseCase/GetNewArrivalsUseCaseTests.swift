import Testing
@testable import XiriGoEcommerce

// MARK: - GetNewArrivalsUseCaseTests

@Suite("GetNewArrivalsUseCase Tests")
struct GetNewArrivalsUseCaseTests {
    // MARK: - Success

    @Test("execute returns new arrivals from repository")
    func execute_returnsNewArrivalsFromRepository() async throws {
        let repository = FakeHomeRepository()
        let product = HomeProduct(
            id: "new_1",
            title: "Keyboard",
            imageUrl: nil,
            price: "149.99",
            currencyCode: "eur",
            originalPrice: nil,
            vendor: "TechZone",
            rating: nil,
            reviewCount: nil,
            isNew: true,
        )
        repository.newArrivalsToReturn = [product]
        let useCase = GetNewArrivalsUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result == [product])
    }

    @Test("execute returns empty array when repository has no new arrivals")
    func execute_returnsEmptyArray_whenNoArrivals() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetNewArrivalsUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result.isEmpty)
    }

    @Test("execute preserves isNew flag as true for all arrivals")
    func execute_preservesIsNewFlag() async throws {
        let repository = FakeHomeRepository()
        let products = [
            HomeProduct(
                id: "new_1",
                title: "Product A",
                imageUrl: nil,
                price: "10.00",
                currencyCode: "eur",
                originalPrice: nil,
                vendor: "V",
                rating: nil,
                reviewCount: nil,
                isNew: true,
            ),
            HomeProduct(
                id: "new_2",
                title: "Product B",
                imageUrl: nil,
                price: "20.00",
                currencyCode: "eur",
                originalPrice: nil,
                vendor: "V",
                rating: nil,
                reviewCount: nil,
                isNew: true,
            ),
        ]
        repository.newArrivalsToReturn = products
        let useCase = GetNewArrivalsUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result.allSatisfy(\.isNew))
    }

    // MARK: - Error Propagation

    @Test("execute propagates network error from repository")
    func execute_propagatesNetworkError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        let useCase = GetNewArrivalsUseCase(repository: repository)

        await #expect(throws: AppError.network()) {
            _ = try await useCase.execute()
        }
    }

    // MARK: - Delegation

    @Test("execute delegates to repository.getNewArrivals")
    func execute_delegatesToRepository() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetNewArrivalsUseCase(repository: repository)

        _ = try await useCase.execute()

        #expect(repository.getNewArrivalsCallCount == 1)
    }
}
