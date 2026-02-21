import Foundation

// MARK: - Tab

/// Defines the four top-level tabs displayed in the bottom navigation bar.
enum Tab: String, CaseIterable, Identifiable, Sendable {
    case home
    case categories
    case cart
    case profile

    // MARK: - Identifiable

    var id: String { rawValue }

    // MARK: - Display Properties

    var title: String {
        switch self {
        case .home: return String(localized: "nav_tab_home")
        case .categories: return String(localized: "nav_tab_categories")
        case .cart: return String(localized: "nav_tab_cart")
        case .profile: return String(localized: "nav_tab_profile")
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .categories: return "square.grid.2x2"
        case .cart: return "cart"
        case .profile: return "person"
        }
    }

    var selectedSystemImage: String {
        switch self {
        case .home: return "house.fill"
        case .categories: return "square.grid.2x2.fill"
        case .cart: return "cart.fill"
        case .profile: return "person.fill"
        }
    }
}
