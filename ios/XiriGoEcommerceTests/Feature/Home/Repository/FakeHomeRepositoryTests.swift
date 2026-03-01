import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - FakeHomeRepositoryTests

/// Tests that validate the fake repository's own behaviour,
/// ensuring tests built on it are reliable.
@Suite("FakeHomeRepository Tests")
struct FakeHomeRepositoryTests {
    // MARK: - Default State

    @Test("getBanners returns empty array by default")
    func getBanners_returnsEmptyByDefault() async throws {
        let repository = FakeHomeRepository()
        let result = try await repository.getBanners()
        #expect(result.isEmpty)
    }

    @Test("getCategories returns empty array by default")
    func getCategories_returnsEmptyByDefault() async throws {
        let repository = FakeHomeRepository()
        let result = try await repository.getCategories()
        #expect(result.isEmpty)
    }

    @Test("getPopularProducts returns empty array by default")
    func getPopularProducts_returnsEmptyByDefault() async throws {
        let repository = FakeHomeRepository()
        let result = try await repository.getPopularProducts()
        #expect(result.isEmpty)
    }

    @Test("getDailyDeal returns nil by default")
    func getDailyDeal_returnsNilByDefault() async throws {
        let repository = FakeHomeRepository()
        let result = try await repository.getDailyDeal()
        #expect(result == nil)
    }

    @Test("getNewArrivals returns empty array by default")
    func getNewArrivals_returnsEmptyByDefault() async throws {
        let repository = FakeHomeRepository()
        let result = try await repository.getNewArrivals()
        #expect(result.isEmpty)
    }

    @Test("getFlashSale returns nil by default")
    func getFlashSale_returnsNilByDefault() async throws {
        let repository = FakeHomeRepository()
        let result = try await repository.getFlashSale()
        #expect(result == nil)
    }

    // MARK: - Configurable Return Values

    @Test("getBanners returns configured banners")
    func getBanners_returnsConfiguredBanners() async throws {
        let repository = FakeHomeRepository()
        let banner = HomeBanner(
            id: "b1",
            title: "Test",
            subtitle: "Sub",
            imageUrl: nil,
            tag: nil,
            actionProductId: nil,
            actionCategoryId: nil,
        )
        repository.bannersToReturn = [banner]
        let result = try await repository.getBanners()
        #expect(result == [banner])
    }

    @Test("getCategories returns configured categories")
    func getCategories_returnsConfiguredCategories() async throws {
        let repository = FakeHomeRepository()
        let category = HomeCategory(
            id: "c1",
            name: "Electronics",
            handle: "electronics",
            iconName: "desktopcomputer",
            colorHex: "#37B4F2",
        )
        repository.categoriesToReturn = [category]
        let result = try await repository.getCategories()
        #expect(result == [category])
    }

    @Test("getDailyDeal returns configured deal")
    func getDailyDeal_returnsConfiguredDeal() async throws {
        let repository = FakeHomeRepository()
        let deal = DailyDeal(
            productId: "deal_1",
            title: "Nike Air",
            imageUrl: nil,
            price: "89.99",
            originalPrice: "149.99",
            currencyCode: "eur",
            endTime: Date().addingTimeInterval(3600),
        )
        repository.dailyDealToReturn = deal
        let result = try await repository.getDailyDeal()
        #expect(result == deal)
    }

    @Test("getFlashSale returns configured flash sale")
    func getFlashSale_returnsConfiguredFlashSale() async throws {
        let repository = FakeHomeRepository()
        let sale = FlashSale(id: "flash_1", title: "Flash Sale", imageUrl: nil, actionUrl: nil)
        repository.flashSaleToReturn = sale
        let result = try await repository.getFlashSale()
        #expect(result == sale)
    }

    // MARK: - Error Propagation

    @Test("getBanners throws configured error")
    func getBanners_throwsConfiguredError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        await #expect(throws: AppError.network()) {
            _ = try await repository.getBanners()
        }
    }

    @Test("getCategories throws configured error")
    func getCategories_throwsConfiguredError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        await #expect(throws: AppError.network()) {
            _ = try await repository.getCategories()
        }
    }

    @Test("getPopularProducts throws configured error")
    func getPopularProducts_throwsConfiguredError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        await #expect(throws: AppError.network()) {
            _ = try await repository.getPopularProducts()
        }
    }

    @Test("getDailyDeal throws configured error")
    func getDailyDeal_throwsConfiguredError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        await #expect(throws: AppError.network()) {
            _ = try await repository.getDailyDeal()
        }
    }

    @Test("getNewArrivals throws configured error")
    func getNewArrivals_throwsConfiguredError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        await #expect(throws: AppError.network()) {
            _ = try await repository.getNewArrivals()
        }
    }

    @Test("getFlashSale throws configured error")
    func getFlashSale_throwsConfiguredError() async {
        let repository = FakeHomeRepository()
        repository.errorToThrow = AppError.network()
        await #expect(throws: AppError.network()) {
            _ = try await repository.getFlashSale()
        }
    }

    // MARK: - Call Counts

    @Test("call counts start at zero")
    func callCounts_startAtZero() {
        let repository = FakeHomeRepository()
        #expect(repository.getBannersCallCount == 0)
        #expect(repository.getCategoriesCallCount == 0)
        #expect(repository.getPopularProductsCallCount == 0)
        #expect(repository.getDailyDealCallCount == 0)
        #expect(repository.getNewArrivalsCallCount == 0)
        #expect(repository.getFlashSaleCallCount == 0)
    }

    @Test("each method increments its own call count")
    func callCounts_incrementPerMethod() async throws {
        let repository = FakeHomeRepository()
        _ = try await repository.getBanners()
        _ = try await repository.getBanners()
        _ = try await repository.getCategories()
        #expect(repository.getBannersCallCount == 2)
        #expect(repository.getCategoriesCallCount == 1)
        #expect(repository.getPopularProductsCallCount == 0)
    }

    // MARK: - Test Isolation

    @Test("separate instances are independent")
    func independence_separateInstances() async throws {
        let repositoryA = FakeHomeRepository()
        let repositoryB = FakeHomeRepository()
        let banner = HomeBanner(
            id: "b1",
            title: "Test",
            subtitle: "Sub",
            imageUrl: nil,
            tag: nil,
            actionProductId: nil,
            actionCategoryId: nil,
        )
        repositoryA.bannersToReturn = [banner]
        let resultA = try await repositoryA.getBanners()
        let resultB = try await repositoryB.getBanners()
        #expect(resultA.count == 1)
        #expect(resultB.isEmpty)
    }
}
