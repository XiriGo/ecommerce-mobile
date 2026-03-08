import Foundation

// MARK: - HomeEvent

/// Events dispatched from the home screen UI to the ViewModel.
enum HomeEvent: Equatable {
    case refresh
    case bannerTapped(HomeBanner)
    case categoryTapped(HomeCategory)
    case productTapped(productId: String)
    case wishlistToggled(productId: String)
    case dailyDealTapped(productId: String)
    case seeAllPopularTapped
    case seeAllNewArrivalsTapped
    case searchBarTapped
    case retryTapped
}
