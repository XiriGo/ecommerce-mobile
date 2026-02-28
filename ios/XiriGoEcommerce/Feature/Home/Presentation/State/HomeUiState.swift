import Foundation

// MARK: - HomeUiState

/// Represents the UI state of the home screen.
enum HomeUiState: Equatable, Sendable {
    case loading
    case success(data: HomeScreenData)
    case error(message: String)
}

// MARK: - HomeScreenData

/// All data needed to render the home screen in success state.
struct HomeScreenData: Equatable, Sendable {
    let banners: [HomeBanner]
    let categories: [HomeCategory]
    let popularProducts: [HomeProduct]
    let dailyDeal: DailyDeal?
    let newArrivals: [HomeProduct]
    let flashSale: FlashSale?
    var wishedProductIds: Set<String>
}
