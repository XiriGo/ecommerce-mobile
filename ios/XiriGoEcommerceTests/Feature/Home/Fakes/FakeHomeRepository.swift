import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - FakeHomeRepository

/// In-memory fake implementation of `HomeRepository` for use in unit tests.
/// Each test instance starts with a clean, configurable state.
final class FakeHomeRepository: HomeRepository, @unchecked Sendable {
    // MARK: - Configurable State

    var bannersToReturn: [HomeBanner] = []
    var categoriesToReturn: [HomeCategory] = []
    var popularProductsToReturn: [HomeProduct] = []
    var dailyDealToReturn: DailyDeal?
    var newArrivalsToReturn: [HomeProduct] = []
    var flashSaleToReturn: FlashSale?
    var errorToThrow: AppError?

    // MARK: - Call Counts

    var getBannersCallCount: Int = 0
    var getCategoriesCallCount: Int = 0
    var getPopularProductsCallCount: Int = 0
    var getDailyDealCallCount: Int = 0
    var getNewArrivalsCallCount: Int = 0
    var getFlashSaleCallCount: Int = 0

    // MARK: - HomeRepository

    func getBanners() async throws -> [HomeBanner] {
        getBannersCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        return bannersToReturn
    }

    func getCategories() async throws -> [HomeCategory] {
        getCategoriesCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        return categoriesToReturn
    }

    func getPopularProducts() async throws -> [HomeProduct] {
        getPopularProductsCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        return popularProductsToReturn
    }

    func getDailyDeal() async throws -> DailyDeal? {
        getDailyDealCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        return dailyDealToReturn
    }

    func getNewArrivals() async throws -> [HomeProduct] {
        getNewArrivalsCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        return newArrivalsToReturn
    }

    func getFlashSale() async throws -> FlashSale? {
        getFlashSaleCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        return flashSaleToReturn
    }
}
