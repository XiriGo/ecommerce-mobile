import Testing
@testable import XiriGoEcommerce

// MARK: - HomeViewModelWishlistTests

/// Tests for HomeViewModel wishlist toggle and navigation events.
@Suite("HomeViewModel Wishlist and Navigation Tests")
@MainActor
struct HomeViewModelWishlistTests {
    // MARK: - onEvent: wishlistToggled

    @Test("onEvent wishlistToggled adds productId when not in set")
    func onEvent_wishlistToggled_addsProductId_whenNotWishlisted() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.popularProductsToReturn = [HomeViewModelTestHelpers.makeProduct(id: "p1")]

        await viewModel.loadHomeData()
        viewModel.onEvent(.wishlistToggled(productId: "p1"))

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(data.wishedProductIds.contains("p1"))
    }

    @Test("onEvent wishlistToggled removes productId when already in set")
    func onEvent_wishlistToggled_removesProductId_whenAlreadyWishlisted() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.popularProductsToReturn = [HomeViewModelTestHelpers.makeProduct(id: "p1")]

        await viewModel.loadHomeData()
        viewModel.onEvent(.wishlistToggled(productId: "p1"))
        viewModel.onEvent(.wishlistToggled(productId: "p1"))

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(!data.wishedProductIds.contains("p1"))
    }

    @Test("onEvent wishlistToggled toggles multiple products independently")
    func onEvent_wishlistToggled_managesMultipleProducts() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.popularProductsToReturn = [
            HomeViewModelTestHelpers.makeProduct(id: "p1"),
            HomeViewModelTestHelpers.makeProduct(id: "p2"),
        ]

        await viewModel.loadHomeData()
        viewModel.onEvent(.wishlistToggled(productId: "p1"))
        viewModel.onEvent(.wishlistToggled(productId: "p2"))
        viewModel.onEvent(.wishlistToggled(productId: "p2"))

        guard case let .success(data) = viewModel.uiState else {
            Issue.record("Expected .success")
            return
        }
        #expect(data.wishedProductIds.contains("p1"))
        #expect(!data.wishedProductIds.contains("p2"))
    }

    @Test("onEvent wishlistToggled does nothing when state is loading")
    func onEvent_wishlistToggled_doesNothing_whenStateIsLoading() {
        let (viewModel, _) = HomeViewModelTestHelpers.makeViewModel()
        // State is .loading at this point
        viewModel.onEvent(.wishlistToggled(productId: "p1"))
        #expect(viewModel.uiState == .loading)
    }

    @Test("onEvent wishlistToggled does nothing when state is error")
    func onEvent_wishlistToggled_doesNothing_whenStateIsError() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        repository.errorToThrow = AppError.network()

        await viewModel.loadHomeData()
        viewModel.onEvent(.wishlistToggled(productId: "p1"))

        guard case .error = viewModel.uiState else {
            Issue.record("Expected .error")
            return
        }
    }

    // MARK: - onEvent: navigation events (no state change)

    @Test("onEvent bannerTapped does not change uiState")
    func onEvent_bannerTapped_doesNotChangeState() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)
        await viewModel.loadHomeData()
        let stateBefore = viewModel.uiState

        let banner = HomeViewModelTestHelpers.makeBanner(id: "b1")
        viewModel.onEvent(.bannerTapped(banner))

        #expect(viewModel.uiState == stateBefore)
    }

    @Test("onEvent categoryTapped does not change uiState")
    func onEvent_categoryTapped_doesNotChangeState() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)
        await viewModel.loadHomeData()
        let stateBefore = viewModel.uiState

        let category = HomeViewModelTestHelpers.makeCategory(id: "c1")
        viewModel.onEvent(.categoryTapped(category))

        #expect(viewModel.uiState == stateBefore)
    }

    @Test("onEvent productTapped does not change uiState")
    func onEvent_productTapped_doesNotChangeState() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)
        await viewModel.loadHomeData()
        let stateBefore = viewModel.uiState

        viewModel.onEvent(.productTapped(productId: "p1"))

        #expect(viewModel.uiState == stateBefore)
    }

    @Test("onEvent searchBarTapped does not change uiState")
    func onEvent_searchBarTapped_doesNotChangeState() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)
        await viewModel.loadHomeData()
        let stateBefore = viewModel.uiState

        viewModel.onEvent(.searchBarTapped)

        #expect(viewModel.uiState == stateBefore)
    }

    @Test("onEvent seeAllPopularTapped does not change uiState")
    func onEvent_seeAllPopularTapped_doesNotChangeState() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)
        await viewModel.loadHomeData()
        let stateBefore = viewModel.uiState

        viewModel.onEvent(.seeAllPopularTapped)

        #expect(viewModel.uiState == stateBefore)
    }

    @Test("onEvent seeAllNewArrivalsTapped does not change uiState")
    func onEvent_seeAllNewArrivalsTapped_doesNotChangeState() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)
        await viewModel.loadHomeData()
        let stateBefore = viewModel.uiState

        viewModel.onEvent(.seeAllNewArrivalsTapped)

        #expect(viewModel.uiState == stateBefore)
    }

    @Test("onEvent dailyDealTapped does not change uiState")
    func onEvent_dailyDealTapped_doesNotChangeState() async {
        let (viewModel, repository) = HomeViewModelTestHelpers.makeViewModel()
        HomeViewModelTestHelpers.populateRepository(repository)
        await viewModel.loadHomeData()
        let stateBefore = viewModel.uiState

        viewModel.onEvent(.dailyDealTapped(productId: "deal_1"))

        #expect(viewModel.uiState == stateBefore)
    }
}
