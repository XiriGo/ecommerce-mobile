import Foundation

// MARK: - HomeCategory

/// A category tile displayed in the horizontal scroll row on the home screen.
struct HomeCategory: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let handle: String
    let iconName: String
    let colorHex: String
}
