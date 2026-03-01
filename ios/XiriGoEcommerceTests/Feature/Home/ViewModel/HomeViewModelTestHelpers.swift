import Foundation
@testable import XiriGoEcommerce

// MARK: - HomeViewModelTestHelpers

/// Shared factory helpers for HomeViewModel test suites.
@MainActor
enum HomeViewModelTestHelpers {
    // MARK: - Internal

    static func makeViewModel() -> (HomeViewModel, FakeHomeRepository) {
        let repository = FakeHomeRepository()
        let viewModel = HomeViewModel(
            getBanners: GetHomeBannersUseCase(repository: repository),
            getCategories: GetHomeCategoriesUseCase(repository: repository),
            getPopularProducts: GetPopularProductsUseCase(repository: repository),
            getDailyDeal: GetDailyDealUseCase(repository: repository),
            getNewArrivals: GetNewArrivalsUseCase(repository: repository),
            getFlashSale: GetFlashSaleUseCase(repository: repository),
        )
        return (viewModel, repository)
    }

    static func populateRepository(_ repository: FakeHomeRepository) {
        repository.bannersToReturn = [makeBanner(id: "b1")]
        repository.categoriesToReturn = [makeCategory(id: "c1")]
        repository.popularProductsToReturn = [makeProduct(id: "p1")]
        repository.newArrivalsToReturn = [makeProduct(id: "new_1")]
    }

    static func makeBanner(id: String) -> HomeBanner {
        HomeBanner(
            id: id,
            title: "Banner \(id)",
            subtitle: "Subtitle",
            imageUrl: nil,
            tag: nil,
            actionProductId: nil,
            actionCategoryId: nil,
        )
    }

    static func makeCategory(id: String) -> HomeCategory {
        HomeCategory(
            id: id,
            name: "Category \(id)",
            handle: "category-\(id)",
            iconName: "house",
            colorHex: "#37B4F2",
        )
    }

    static func makeProduct(id: String) -> HomeProduct {
        HomeProduct(
            id: id,
            title: "Product \(id)",
            imageUrl: nil,
            price: "9.99",
            currencyCode: "eur",
            originalPrice: nil,
            vendor: "Vendor",
            rating: nil,
            reviewCount: nil,
            isNew: false,
        )
    }

    static func makeDailyDeal() -> DailyDeal {
        DailyDeal(
            productId: "deal_1",
            title: "Daily Deal",
            imageUrl: nil,
            price: "49.99",
            originalPrice: "99.99",
            currencyCode: "eur",
            endTime: Date().addingTimeInterval(oneHourInSeconds),
        )
    }

    // MARK: - Private

    // MARK: - Private Constants

    private static let oneHourInSeconds: TimeInterval = 3600
}
