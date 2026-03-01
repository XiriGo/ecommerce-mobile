import Factory
import SwiftUI

// MARK: - HomeScreen

/// Main home screen displaying featured content, categories, and product sections.
/// Consumes `HomeUiState` from `HomeViewModel` and delegates events to it.
struct HomeScreen: View {
    // MARK: - Lifecycle

    init() {
        _viewModel = State(initialValue: Container.shared.homeViewModel())
    }

    // MARK: - Internal

    @Environment(AppRouter.self)
    var router

    @State var viewModel: HomeViewModel

    var body: some View {
        Group {
            switch viewModel.uiState {
                case .loading:
                    XGLoadingView()

                case let .error(message):
                    XGErrorView(
                        message: message,
                        onRetry: { viewModel.onEvent(.retryTapped) },
                    )

                case let .success(data):
                    successContent(data)
            }
        }
        .background(XGColors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "nav_tab_home"))
        .task { await viewModel.loadHomeData() }
    }

    // MARK: - Private

    private func successContent(_ data: HomeScreenData) -> some View {
        ScrollView {
            VStack(spacing: XGSpacing.sectionSpacing) {
                searchBar
                heroBannerCarousel(data.banners)
                categoriesSection(data.categories)
                popularProductsSection(data)
                dailyDealSection(data.dailyDeal)
                newArrivalsSection(data)
                flashSaleSection(data.flashSale)
            }
            .padding(.bottom, XGSpacing.xl)
        }
        .refreshable { await viewModel.refresh() }
    }
}

// MARK: - Previews

#Preview("HomeScreen") {
    NavigationStack {
        HomeScreen()
    }
    .environment(AppRouter())
}
