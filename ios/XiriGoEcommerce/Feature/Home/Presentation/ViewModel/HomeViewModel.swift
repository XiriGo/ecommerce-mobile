import Foundation

// MARK: - HomeViewModel

/// ViewModel for the home screen. Coordinates all use cases and manages UI state.
@MainActor
@Observable
final class HomeViewModel {
    // MARK: - Lifecycle

    init(
        getBanners: GetHomeBannersUseCase,
        getCategories: GetHomeCategoriesUseCase,
        getPopularProducts: GetPopularProductsUseCase,
        getDailyDeal: GetDailyDealUseCase,
        getNewArrivals: GetNewArrivalsUseCase,
        getFlashSale: GetFlashSaleUseCase,
    ) {
        self.getBanners = getBanners
        self.getCategories = getCategories
        self.getPopularProducts = getPopularProducts
        self.getDailyDeal = getDailyDeal
        self.getNewArrivals = getNewArrivals
        self.getFlashSale = getFlashSale
    }

    // MARK: - Internal

    private(set) var uiState: HomeUiState = .loading
    var currentBannerPage: Int = 0
    private(set) var isRefreshing: Bool = false

    func loadHomeData() async {
        uiState = .loading
        do {
            async let bannersResult = getBanners.execute()
            async let categoriesResult = getCategories.execute()
            async let popularResult = getPopularProducts.execute()
            async let dealResult = getDailyDeal.execute()
            async let arrivalsResult = getNewArrivals.execute()
            async let flashResult = getFlashSale.execute()

            let data = try await HomeScreenData(
                banners: bannersResult,
                categories: categoriesResult,
                popularProducts: popularResult,
                dailyDeal: dealResult,
                newArrivals: arrivalsResult,
                flashSale: flashResult,
                wishedProductIds: [],
            )
            uiState = .success(data: data)
        } catch {
            uiState = .error(message: error.localizedDescription)
        }
    }

    func onEvent(_ event: HomeEvent) {
        switch event {
            case .refresh:
                Task { await refresh() }

            case let .wishlistToggled(productId):
                toggleWishlist(productId)

            case .retryTapped:
                Task { await loadHomeData() }

            case .bannerTapped,
                 .categoryTapped,
                 .dailyDealTapped,
                 .productTapped,
                 .searchBarTapped,
                 .seeAllNewArrivalsTapped,
                 .seeAllPopularTapped:
                break
        }
    }

    func refresh() async {
        isRefreshing = true
        await loadHomeData()
        isRefreshing = false
    }

    // MARK: - Private

    private let getBanners: GetHomeBannersUseCase
    private let getCategories: GetHomeCategoriesUseCase
    private let getPopularProducts: GetPopularProductsUseCase
    private let getDailyDeal: GetDailyDealUseCase
    private let getNewArrivals: GetNewArrivalsUseCase
    private let getFlashSale: GetFlashSaleUseCase

    private func toggleWishlist(_ productId: String) {
        guard case var .success(data) = uiState else {
            return
        }
        if data.wishedProductIds.contains(productId) {
            data.wishedProductIds.remove(productId)
        } else {
            data.wishedProductIds.insert(productId)
        }
        uiState = .success(data: data)
    }
}
