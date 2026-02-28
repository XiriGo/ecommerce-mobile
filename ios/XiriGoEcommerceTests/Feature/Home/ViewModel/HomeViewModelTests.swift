import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - HomeViewModelTests

/// Tests for HomeViewModel initial state, data loading, refresh, wishlist, and retry.
@Suite("HomeViewModel Tests")
@MainActor
struct HomeViewModelTests {
    // MARK: - Initial State

    @Test("initial uiState is loading")
    func initialUiState_isLoading() {
        let (viewModel, _) = HomeViewModelTestHelpers.makeViewModel()
        #expect(viewModel.uiState == .loading)
    }

    @Test("initial currentBannerPage is 0")
    func initialCurrentBannerPage_isZero() {
        let (viewModel, _) = HomeViewModelTestHelpers.makeViewModel()
        #expect(viewModel.currentBannerPage == 0)
    }

    @Test("initial isRefreshing is false")
    func initialIsRefreshing_isFalse() {
        let (viewModel, _) = HomeViewModelTestHelpers.makeViewModel()
        #expect(viewModel.isRefreshing == false)
    }

    // MARK: - loadHomeData: success

    @Test("loadHomeData transitions uiState to success when all data loads")
    func loadHomeData_transitionsToSuccess_whenAllDataLoads() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)

        await viewModel.loadHomeData()

        guard case .success = viewModel.uiState else {
            Issue.record("Expected .success, got \(viewModel.uiState)")
            return
        }
    }

    @Test("loadHomeData success state contains correct banner count")
    func loadHomeData_successContainsBanners() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.bannersToReturn = [
            HomeViewModelTestHelpers.makeBanner(id: "b1"),
            HomeViewModelTestHelpers.makeBanner(id: "b2"),
        ]

        await viewModel.loadHomeData()

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(data.banners.count == 2)
    }

    @Test("loadHomeData success state contains correct category count")
    func loadHomeData_successContainsCategories() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.categoriesToReturn = [
            HomeViewModelTestHelpers.makeCategory(id: "c1"),
            HomeViewModelTestHelpers.makeCategory(id: "c2"),
        ]

        await viewModel.loadHomeData()

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(data.categories.count == 2)
    }

    @Test("loadHomeData success state contains popular products")
    func loadHomeData_successContainsPopularProducts() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.popularProductsToReturn = [
            HomeViewModelTestHelpers.makeProduct(id: "p1"),
            HomeViewModelTestHelpers.makeProduct(id: "p2"),
        ]

        await viewModel.loadHomeData()

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(data.popularProducts.count == 2)
    }

    @Test("loadHomeData success state contains daily deal when repository returns one")
    func loadHomeData_successContainsDailyDeal() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        let deal = HomeViewModelTestHelpers.makeDailyDeal()
        repository.dailyDealToReturn = deal

        await viewModel.loadHomeData()

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(data.dailyDeal == deal)
    }

    @Test("loadHomeData success state has nil dailyDeal when repository returns nil")
    func loadHomeData_successHasNilDailyDeal_whenNoDeal() async {
        let (viewModel, _) = HomeViewModelTestHelpers.makeViewModel()

        await viewModel.loadHomeData()

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(data.dailyDeal == nil)
    }

    @Test("loadHomeData success state contains new arrivals")
    func loadHomeData_successContainsNewArrivals() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.newArrivalsToReturn = [
            HomeViewModelTestHelpers.makeProduct(id: "new_1"),
            HomeViewModelTestHelpers.makeProduct(id: "new_2"),
        ]

        await viewModel.loadHomeData()

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(data.newArrivals.count == 2)
    }

    @Test("loadHomeData success state has nil flashSale when repository returns nil")
    func loadHomeData_successHasNilFlashSale_whenNoSale() async {
        let (viewModel, _) = HomeViewModelTestHelpers.makeViewModel()

        await viewModel.loadHomeData()

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(data.flashSale == nil)
    }

    @Test("loadHomeData success state has empty wishedProductIds on initial load")
    func loadHomeData_successHasEmptyWishedProductIds() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)

        await viewModel.loadHomeData()

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(data.wishedProductIds.isEmpty)
    }

    @Test("loadHomeData sets uiState to loading before result arrives")
    func loadHomeData_setsLoadingBeforeResult() {
        let (viewModel, _) = HomeViewModelTestHelpers.makeViewModel()
        // Before awaiting, initial state is .loading
        #expect(viewModel.uiState == .loading)
    }

    // MARK: - loadHomeData: error

    @Test("loadHomeData transitions to error when repository throws network error")
    func loadHomeData_transitionsToError_onNetworkError() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.errorToThrow = AppError.network()

        await viewModel.loadHomeData()

        guard case .error = viewModel.uiState else {
            Issue.record("Expected .error, got \(viewModel.uiState)")
            return
        }
    }

    @Test("loadHomeData error state contains non-empty message on failure")
    func loadHomeData_errorStateHasMessage() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.errorToThrow = AppError.network()

        await viewModel.loadHomeData()

        guard case let .error(message) = viewModel.uiState else {
            Issue.record("Expected .error")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test("loadHomeData transitions to error on server error")
    func loadHomeData_transitionsToError_onServerError() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.errorToThrow = AppError.server(code: 500, message: "Internal Server Error")

        await viewModel.loadHomeData()

        guard case .error = viewModel.uiState else {
            Issue.record("Expected .error")
            return
        }
    }

    // MARK: - refresh

    @Test("refresh reloads all data and returns to success state")
    func refresh_reloadsAllData() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)

        await viewModel.refresh()

        guard case .success = viewModel.uiState else {
            Issue.record("Expected .success after refresh")
            return
        }
    }

    @Test("refresh preserves existing wishedProductIds")
    func refresh_preservesWishedProductIds() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.popularProductsToReturn = [HomeViewModelTestHelpers.makeProduct(id: "p1")]

        await viewModel.loadHomeData()
        viewModel.onEvent(.wishlistToggled(productId: "p1"))

        await viewModel.refresh()

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success after refresh")
            return
        }
        #expect(data.wishedProductIds.contains("p1"))
    }

    @Test("refresh sets isRefreshing to false after completion")
    func refresh_setsIsRefreshingFalseAfterCompletion() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)

        await viewModel.refresh()

        #expect(viewModel.isRefreshing == false)
    }

    // MARK: - onEvent: refresh

    @Test("onEvent refresh triggers loadHomeData")
    func onEvent_refresh_triggersLoadHomeData() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)

        viewModel.onEvent(.refresh)
        // Allow the spawned Task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        guard case .success = viewModel.uiState else {
            Issue.record("Expected .success after refresh event")
            return
        }
    }

    // MARK: - onEvent: retryTapped

    @Test("onEvent retryTapped triggers loadHomeData and returns success")
    func onEvent_retryTapped_triggersLoadHomeData() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.errorToThrow = AppError.network()
        await viewModel.loadHomeData()

        repository.errorToThrow = nil
        HomeViewModelTestHelpers.populateRepository(repository)
        viewModel.onEvent(.retryTapped)
        try? await Task.sleep(nanoseconds: 100_000_000)

        guard case .success = viewModel.uiState else {
            Issue.record("Expected .success after retry")
            return
        }
    }

    // MARK: - currentBannerPage

    @Test("currentBannerPage can be updated directly")
    func currentBannerPage_canBeUpdated() {
        let (viewModel, _) = HomeViewModelTestHelpers.makeViewModel()
        viewModel.currentBannerPage = 2
        #expect(viewModel.currentBannerPage == 2)
    }
}
