import Foundation

// MARK: - GetFlashSaleUseCase

/// Fetches flash sale banner data for the home screen.
final class GetFlashSaleUseCase: Sendable {
    // MARK: - Lifecycle

    init(repository: HomeRepository) {
        self.repository = repository
    }

    // MARK: - Internal

    func execute() async throws -> FlashSale? {
        try await repository.getFlashSale()
    }

    // MARK: - Private

    private let repository: HomeRepository
}
