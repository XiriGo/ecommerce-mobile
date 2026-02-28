import Testing
@testable import XiriGoEcommerce

// MARK: - GetHomeCategoriesUseCaseTests

@Suite("GetHomeCategoriesUseCase Tests")
struct GetHomeCategoriesUseCaseTests {
    // MARK: - Success

    @Test("execute returns categories from repository")
    func execute_returnsCategoriesFromRepository() async throws {
        let repository = FakeHomeRepository()
        let category = HomeCategory(
            id: "cat_1",
            name: "Electronics",
            handle: "electronics",
            iconName: "desktopcomputer",
            colorHex: "#37B4F2",
        )
        repository.categoriesToReturn = [category]
        let useCase = GetHomeCategoriesUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result == [category])
    }

    @Test("execute returns empty array when repository has no categories")
    func execute_returnsEmptyArray_whenNoCategories() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetHomeCategoriesUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result.isEmpty)
    }

    @Test("execute returns multiple categories in order")
    func execute_returnsMultipleCategories_inOrder() async throws {
        let repository = FakeHomeRepository()
        let categories = [
            HomeCategory(
                id: "cat_1",
                name: "Electronics",
                handle: "electronics",
                iconName: "desktopcomputer",
                colorHex: "#37B4F2",
            ),
            HomeCategory(id: "cat_2", name: "Fashion", handle: "fashion", iconName: "tshirt", colorHex: "#FE75D4"),
        ]
        repository.categoriesToReturn = categories
        let useCase = GetHomeCategoriesUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result.count == 2)
        #expect(result[0].id == "cat_1")
        #expect(result[1].id == "cat_2")
    }

    // MARK: - Error Propagation

    @Test("execute propagates network error from repository")
    func execute_propagatesNetworkError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        let useCase = GetHomeCategoriesUseCase(repository: repository)

        await #expect(throws: AppError.network()) {
            _ = try await useCase.execute()
        }
    }

    @Test("execute propagates server error from repository")
    func execute_propagatesServerError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.server(code: 503, message: "Service Unavailable")
        let useCase = GetHomeCategoriesUseCase(repository: repository)

        await #expect(throws: AppError.server(code: 503, message: "Service Unavailable")) {
            _ = try await useCase.execute()
        }
    }

    // MARK: - Delegation

    @Test("execute delegates to repository.getCategories")
    func execute_delegatesToRepository() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetHomeCategoriesUseCase(repository: repository)

        _ = try await useCase.execute()

        #expect(repository.getCategoriesCallCount == 1)
    }
}
