import Foundation

// MARK: - GetNewArrivalsUseCase

/// Fetches new arrival products for the home screen grid section.
final class GetNewArrivalsUseCase: Sendable {
    // MARK: - Lifecycle

    init(repository: HomeRepository) {
        self.repository = repository
    }

    // MARK: - Internal

    func execute() async throws -> [HomeProduct] {
        try await repository.getNewArrivals()
    }

    // MARK: - Private

    private let repository: HomeRepository
}
