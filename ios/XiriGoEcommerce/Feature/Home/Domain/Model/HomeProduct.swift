import Foundation

// MARK: - HomeProduct

/// A product displayed in Popular Products or New Arrivals sections on the home screen.
struct HomeProduct: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let imageUrl: String?
    let price: String
    let currencyCode: String
    let originalPrice: String?
    let vendor: String
    let rating: Double?
    let reviewCount: Int?
    let isNew: Bool
}
