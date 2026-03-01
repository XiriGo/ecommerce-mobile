import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - GetDailyDealUseCaseTests

@Suite("GetDailyDealUseCase Tests")
struct GetDailyDealUseCaseTests {
    // MARK: - Success: deal present

    @Test("execute returns deal when repository has one")
    func execute_returnsDeal_whenRepositoryHasDeal() async throws {
        let repository = FakeHomeRepository()
        let deal = DailyDeal(
            productId: "deal_1",
            title: "Nike Air Zoom",
            imageUrl: "https://example.com/deal.jpg",
            price: "89.99",
            originalPrice: "149.99",
            currencyCode: "eur",
            endTime: Date().addingTimeInterval(3600),
        )
        repository.dailyDealToReturn = deal
        let useCase = GetDailyDealUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result == deal)
    }

    @Test("execute returns nil when repository has no deal")
    func execute_returnsNil_whenNoDeal() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetDailyDealUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result == nil)
    }

    @Test("execute preserves deal end time")
    func execute_preservesDealEndTime() async throws {
        let repository = FakeHomeRepository()
        let futureDate = Date().addingTimeInterval(28800)
        let deal = DailyDeal(
            productId: "deal_1",
            title: "Deal",
            imageUrl: nil,
            price: "50.00",
            originalPrice: "100.00",
            currencyCode: "eur",
            endTime: futureDate,
        )
        repository.dailyDealToReturn = deal
        let useCase = GetDailyDealUseCase(repository: repository)

        let result = try await useCase.execute()

        #expect(result?.endTime == futureDate)
    }

    // MARK: - Error Propagation

    @Test("execute propagates network error from repository")
    func execute_propagatesNetworkError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        let useCase = GetDailyDealUseCase(repository: repository)

        await #expect(throws: AppError.network()) {
            _ = try await useCase.execute()
        }
    }

    // MARK: - Delegation

    @Test("execute delegates to repository.getDailyDeal")
    func execute_delegatesToRepository() async throws {
        let repository = FakeHomeRepository()
        let useCase = GetDailyDealUseCase(repository: repository)

        _ = try await useCase.execute()

        #expect(repository.getDailyDealCallCount == 1)
    }
}
