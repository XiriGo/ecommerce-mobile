import Foundation

// MARK: - GetHomeCategoriesUseCase

/// Fetches category data for the home screen horizontal scroll row.
final class GetHomeCategoriesUseCase: Sendable {
    // MARK: - Lifecycle

    init(repository: HomeRepository) {
        self.repository = repository
    }

    // MARK: - Internal

    func execute() async throws -> [HomeCategory] {
        try await repository.getCategories()
    }

    // MARK: - Private

    private let repository: HomeRepository
}
