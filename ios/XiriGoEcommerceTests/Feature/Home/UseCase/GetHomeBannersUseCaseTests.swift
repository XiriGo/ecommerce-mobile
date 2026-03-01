import Testing
@testable import XiriGoEcommerce

// MARK: - GetHomeBannersUseCaseTests

@Suite("GetHomeBannersUseCase Tests")
struct GetHomeBannersUseCaseTests {
    // MARK: - Success

    @Test("execute returns banners from repository")
    func execute_returnsBannersFromRepository() async throws {
        let repository = FakeHomeRepository()
        let banner = HomeBanner(
            id: "b1",
            title: "Summer Sale",
            subtitle: "Up to 50% off",
            imageUrl: "https://example.com/image.jpg",
            tag: "SALE",
            actionProductId: nil,
            actionCategoryId: "cat_1",
        )
        repository.bannersToReturn = [banner]
        let useCase = GetHomeBannersUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result == [banner])
    }

    @Test("execute returns empty array when repository has no banners")
    func execute_returnsEmptyArray_whenNoBanners() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetHomeBannersUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result.isEmpty)
    }

    @Test("execute returns multiple banners in order")
    func execute_returnsMultipleBanners_inOrder() async throws {
        let repository = FakeHomeRepository()
        let banners = [
            HomeBanner(
                id: "b1",
                title: "First",
                subtitle: "S1",
                imageUrl: nil,
                tag: nil,
                actionProductId: nil,
                actionCategoryId: nil,
            ),
            HomeBanner(
                id: "b2",
                title: "Second",
                subtitle: "S2",
                imageUrl: nil,
                tag: nil,
                actionProductId: nil,
                actionCategoryId: nil,
            ),
            HomeBanner(
                id: "b3",
                title: "Third",
                subtitle: "S3",
                imageUrl: nil,
                tag: nil,
                actionProductId: nil,
                actionCategoryId: nil,
            ),
        ]
        repository.bannersToReturn = banners
        let useCase = GetHomeBannersUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result.count == 3)
        #expect(result[0].id == "b1")
        #expect(result[2].id == "b3")
    }

    // MARK: - Error Propagation

    @Test("execute propagates network error from repository")
    func execute_propagatesNetworkError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        let useCase = GetHomeBannersUseCase(repository: repository)

        await #expect(throws: AppError.network()) {
            _ = try await useCase.execute()
        }
    }

    @Test("execute propagates server error from repository")
    func execute_propagatesServerError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.server(code: 500, message: "Internal Server Error")
        let useCase = GetHomeBannersUseCase(repository: repository)

        await #expect(throws: AppError.server(code: 500, message: "Internal Server Error")) {
            _ = try await useCase.execute()
        }
    }

    // MARK: - Delegation

    @Test("execute delegates to repository.getBanners")
    func execute_delegatesToRepository() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetHomeBannersUseCase(repository: repository)

        _ = try await useCase.execute()

        #expect(repository.getBannersCallCount == 1)
    }
}
