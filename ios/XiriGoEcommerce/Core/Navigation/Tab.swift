import Foundation

// MARK: - Tab

/// Defines the four top-level tabs displayed in the bottom navigation bar.
enum Tab: String, CaseIterable, Identifiable {
    case home
    case categories
    case cart
    case profile

    // MARK: - Internal

    // MARK: - Identifiable

    var id: String {
        rawValue
    }

    // MARK: - Display Properties

    var title: String {
        switch self {
            case .home: String(localized: "nav_tab_home")
            case .categories: String(localized: "nav_tab_categories")
            case .cart: String(localized: "nav_tab_cart")
            case .profile: String(localized: "nav_tab_profile")
        }
    }

    var systemImage: String {
        switch self {
            case .home: "house"
            case .categories: "square.grid.2x2"
            case .cart: "cart"
            case .profile: "person"
        }
    }

    var selectedSystemImage: String {
        switch self {
            case .home: "house.fill"
            case .categories: "square.grid.2x2.fill"
            case .cart: "cart.fill"
            case .profile: "person.fill"
        }
    }
}
