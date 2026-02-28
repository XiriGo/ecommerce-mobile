import Foundation

// MARK: - HomeBanner

/// A single hero banner in the home screen carousel.
struct HomeBanner: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let imageUrl: String?
    let tag: String?
    let actionProductId: String?
    let actionCategoryId: String?
}
