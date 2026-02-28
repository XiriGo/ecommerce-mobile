import Foundation

// MARK: - GetDailyDealUseCase

/// Fetches the daily deal for the home screen countdown section.
final class GetDailyDealUseCase: Sendable {
    // MARK: - Lifecycle

    init(repository: HomeRepository) {
        self.repository = repository
    }

    // MARK: - Internal

    func execute() async throws -> DailyDeal? {
        try await repository.getDailyDeal()
    }

    // MARK: - Private

    private let repository: HomeRepository
}
