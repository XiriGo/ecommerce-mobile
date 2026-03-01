import Foundation

// MARK: - HomeRepository

/// Repository protocol for fetching home screen data.
/// Implementations include `FakeHomeRepository` (sample data) and future `HomeRepositoryImpl` (Medusa API).
protocol HomeRepository: Sendable {
    func getBanners() async throws -> [HomeBanner]
    func getCategories() async throws -> [HomeCategory]
    func getPopularProducts() async throws -> [HomeProduct]
    func getDailyDeal() async throws -> DailyDeal?
    func getNewArrivals() async throws -> [HomeProduct]
    func getFlashSale() async throws -> FlashSale?
}
