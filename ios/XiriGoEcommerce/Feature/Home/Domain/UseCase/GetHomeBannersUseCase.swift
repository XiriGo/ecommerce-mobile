import Foundation

// MARK: - GetHomeBannersUseCase

/// Fetches hero banner data for the home screen carousel.
final class GetHomeBannersUseCase: Sendable {
    // MARK: - Lifecycle

    init(repository: HomeRepository) {
        self.repository = repository
    }

    // MARK: - Internal

    func execute() async throws -> [HomeBanner] {
        try await repository.getBanners()
    }

    // MARK: - Private

    private let repository: HomeRepository
}
