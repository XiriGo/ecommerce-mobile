import Testing
@testable import XiriGoEcommerce

// MARK: - GetFlashSaleUseCaseTests

@Suite("GetFlashSaleUseCase Tests")
struct GetFlashSaleUseCaseTests {
    // MARK: - Success: flash sale present

    @Test("execute returns flash sale when repository has one")
    func execute_returnsFlashSale_whenRepositoryHasOne() async throws {
        let repository = FakeHomeRepository()
        let sale = FlashSale(
            id: "flash_1",
            title: "Flash Sale",
            imageUrl: nil,
            actionUrl: nil,
        )
        repository.flashSaleToReturn = sale
        let useCase = GetFlashSaleUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result == sale)
    }

    @Test("execute returns nil when repository has no flash sale")
    func execute_returnsNil_whenNoFlashSale() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetFlashSaleUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result == nil)
    }

    @Test("execute preserves flash sale properties")
    func execute_preservesFlashSaleProperties() async throws {
        let repository = FakeHomeRepository()
        let sale = FlashSale(
            id: "flash_99",
            title: "Mega Flash",
            imageUrl: "https://example.com/flash.jpg",
            actionUrl: "https://example.com/shop",
        )
        repository.flashSaleToReturn = sale
        let useCase = GetFlashSaleUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result?.id == "flash_99")
        #expect(result?.title == "Mega Flash")
        #expect(result?.imageUrl == "https://example.com/flash.jpg")
    }

    // MARK: - Error Propagation

    @Test("execute propagates network error from repository")
    func execute_propagatesNetworkError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        let useCase = GetFlashSaleUseCase(repository: repository)

        await #expect(throws: AppError.network()) {
            _ = try await useCase.execute()
        }
    }

    @Test("execute propagates unauthorized error from repository")
    func execute_propagatesUnauthorizedError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.unauthorized()
        let useCase = GetFlashSaleUseCase(repository: repository)

        await #expect(throws: AppError.unauthorized()) {
            _ = try await useCase.execute()
        }
    }

    // MARK: - Delegation

    @Test("execute delegates to repository.getFlashSale")
    func execute_delegatesToRepository() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetFlashSaleUseCase(repository: repository)

        _ = try await useCase.execute()

        #expect(repository.getFlashSaleCallCount == 1)
    }
}
