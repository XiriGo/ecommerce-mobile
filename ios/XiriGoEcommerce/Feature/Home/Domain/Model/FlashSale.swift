import Foundation

// MARK: - FlashSale

/// Flash sale promotional banner data for the home screen.
struct FlashSale: Identifiable, Equatable {
    let id: String
    let title: String
    let imageUrl: String?
    let actionUrl: String?
}
