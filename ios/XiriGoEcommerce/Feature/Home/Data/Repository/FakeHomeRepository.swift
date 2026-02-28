import Foundation

// MARK: - FakeHomeRepository

/// Fake implementation of `HomeRepository` providing hardcoded sample data.
/// Replaces inline sample data from the original `HomeScreenSampleData.swift`.
/// Will be swapped with `HomeRepositoryImpl` when Medusa API integration is ready.
final class FakeHomeRepository: HomeRepository, @unchecked Sendable {
    func getBanners() async throws -> [HomeBanner] {
        HomeSampleData.banners
    }

    func getCategories() async throws -> [HomeCategory] {
        HomeSampleData.categories
    }

    func getPopularProducts() async throws -> [HomeProduct] {
        HomeSampleData.popularProducts
    }

    func getDailyDeal() async throws -> DailyDeal? {
        HomeSampleData.dailyDeal
    }

    func getNewArrivals() async throws -> [HomeProduct] {
        HomeSampleData.newArrivals
    }

    func getFlashSale() async throws -> FlashSale? {
        HomeSampleData.flashSale
    }
}
