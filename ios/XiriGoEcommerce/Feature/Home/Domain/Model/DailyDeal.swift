import Foundation

// MARK: - DailyDeal

/// The daily deal section with countdown timer on the home screen.
struct DailyDeal: Equatable {
    let productId: String
    let title: String
    let imageUrl: String?
    let price: String
    let originalPrice: String
    let currencyCode: String
    let endTime: Date
}
