import Foundation

// MARK: - GetPopularProductsUseCase

/// Fetches popular products for the home screen grid section.
final class GetPopularProductsUseCase: Sendable {
    // MARK: - Lifecycle

    init(repository: HomeRepository) {
        self.repository = repository
    }

    // MARK: - Internal

    func execute() async throws -> [HomeProduct] {
        try await repository.getPopularProducts()
    }

    // MARK: - Private

    private let repository: HomeRepository
}
