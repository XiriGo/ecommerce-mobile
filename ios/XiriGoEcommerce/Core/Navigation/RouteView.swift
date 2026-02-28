import SwiftUI

// MARK: - RouteView

/// Maps a Route to its corresponding View.
/// Implemented screens render their feature view; unimplemented screens show a PlaceholderView.
struct RouteView: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(route: Route) {
        self.route = route
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        switch route {
            case .home:
                HomeScreen()

            case .categories:
                CategoriesScreen()

            case .cart:
                CartScreen()

            case .profile:
                ProfileScreen()

            default:
                PlaceholderView(title: route.title, systemImage: systemImage(for: route))
        }
    }

    // MARK: - Private

    private let route: Route

    /// Returns the SF Symbol name for routes that still use PlaceholderView.
    private func systemImage(for route: Route) -> String {
        switch route {
            case .home: "house"
            case .categories,
                 .categoryProducts: "square.grid.2x2"
            case .productList: "list.bullet"
            case .productDetail: "bag"
            case .productSearch: "magnifyingglass"
            case .vendorStore: "storefront"
            case .productReviews: "star.bubble"
            case .writeReview: "square.and.pencil"
            case .cart: "cart"
            case .checkout,
                 .checkoutPayment: "creditcard"
            case .addressManagement,
                 .checkoutAddress: "mappin.and.ellipse"
            case .checkoutShipping: "shippingbox"
            case .orderConfirmation: "checkmark.circle"
            case .profile: "person"
            case .orderList: "list.clipboard"
            case .orderDetail: "doc.text"
            case .settings: "gearshape"
            case .wishlist: "heart"
            case .paymentMethods: "creditcard"
            case .notifications: "bell"
            case .recentlyViewed: "clock"
            case .priceAlerts: "bell.badge"
            case .login: "person.circle"
            case .register: "person.badge.plus"
            case .forgotPassword: "key"
            case .onboarding: "hand.wave"
        }
    }
}

// MARK: - Previews

#Preview("RouteView - Home") {
    NavigationStack {
        RouteView(route: .home)
    }
    .environment(AppRouter())
}

#Preview("RouteView - Product Detail") {
    NavigationStack {
        RouteView(route: .productDetail(productId: "prod_123"))
    }
}
