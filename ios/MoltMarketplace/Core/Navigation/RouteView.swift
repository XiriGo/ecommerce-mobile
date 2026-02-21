import SwiftUI

// MARK: - RouteView

/// Maps a Route to its corresponding View.
/// Unimplemented screens display a PlaceholderView until their milestone is reached.
struct RouteView: View {
    // MARK: - Properties

    private let route: Route

    // MARK: - Init

    init(route: Route) {
        self.route = route
    }

    // MARK: - Body

    var body: some View {
        PlaceholderView(title: route.title, systemImage: systemImage(for: route))
    }

    // MARK: - Private

    /// Returns the SF Symbol name for the given route.
    private func systemImage(for route: Route) -> String {
        switch route {
        case .home: return "house"
        case .categories, .categoryProducts: return "square.grid.2x2"
        case .productList: return "list.bullet"
        case .productDetail: return "bag"
        case .productSearch: return "magnifyingglass"
        case .vendorStore: return "storefront"
        case .productReviews: return "star.bubble"
        case .writeReview: return "square.and.pencil"
        case .cart: return "cart"
        case .checkout, .checkoutPayment: return "creditcard"
        case .checkoutAddress, .addressManagement: return "mappin.and.ellipse"
        case .checkoutShipping: return "shippingbox"
        case .orderConfirmation: return "checkmark.circle"
        case .profile: return "person"
        case .orderList: return "list.clipboard"
        case .orderDetail: return "doc.text"
        case .settings: return "gearshape"
        case .wishlist: return "heart"
        case .paymentMethods: return "creditcard"
        case .notifications: return "bell"
        case .recentlyViewed: return "clock"
        case .priceAlerts: return "bell.badge"
        case .login: return "person.circle"
        case .register: return "person.badge.plus"
        case .forgotPassword: return "key"
        case .onboarding: return "hand.wave"
        }
    }
}

// MARK: - Previews

#Preview("RouteView - Home") {
    NavigationStack {
        RouteView(route: .home)
    }
}

#Preview("RouteView - Product Detail") {
    NavigationStack {
        RouteView(route: .productDetail(productId: "prod_123"))
    }
}
