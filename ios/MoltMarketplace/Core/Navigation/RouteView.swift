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
        placeholder(for: route)
    }

    // MARK: - Private

    /// Returns a placeholder view for the given route.
    /// As features are implemented in M1+, replace the placeholder with the actual view.
    @ViewBuilder
    private func placeholder(for route: Route) -> some View {
        switch route {
        case .home:
            PlaceholderView(title: route.title, systemImage: "house")
        case .categories:
            PlaceholderView(title: route.title, systemImage: "square.grid.2x2")
        case .categoryProducts:
            PlaceholderView(title: route.title, systemImage: "square.grid.2x2")
        case .productList:
            PlaceholderView(title: route.title, systemImage: "list.bullet")
        case .productDetail:
            PlaceholderView(title: route.title, systemImage: "bag")
        case .productSearch:
            PlaceholderView(title: route.title, systemImage: "magnifyingglass")
        case .vendorStore:
            PlaceholderView(title: route.title, systemImage: "storefront")
        case .productReviews:
            PlaceholderView(title: route.title, systemImage: "star.bubble")
        case .writeReview:
            PlaceholderView(title: route.title, systemImage: "square.and.pencil")
        case .cart:
            PlaceholderView(title: route.title, systemImage: "cart")
        case .checkout:
            PlaceholderView(title: route.title, systemImage: "creditcard")
        case .checkoutAddress:
            PlaceholderView(title: route.title, systemImage: "mappin.and.ellipse")
        case .checkoutShipping:
            PlaceholderView(title: route.title, systemImage: "shippingbox")
        case .checkoutPayment:
            PlaceholderView(title: route.title, systemImage: "creditcard")
        case .orderConfirmation:
            PlaceholderView(title: route.title, systemImage: "checkmark.circle")
        case .profile:
            PlaceholderView(title: route.title, systemImage: "person")
        case .orderList:
            PlaceholderView(title: route.title, systemImage: "list.clipboard")
        case .orderDetail:
            PlaceholderView(title: route.title, systemImage: "doc.text")
        case .settings:
            PlaceholderView(title: route.title, systemImage: "gearshape")
        case .addressManagement:
            PlaceholderView(title: route.title, systemImage: "mappin.and.ellipse")
        case .wishlist:
            PlaceholderView(title: route.title, systemImage: "heart")
        case .paymentMethods:
            PlaceholderView(title: route.title, systemImage: "creditcard")
        case .notifications:
            PlaceholderView(title: route.title, systemImage: "bell")
        case .recentlyViewed:
            PlaceholderView(title: route.title, systemImage: "clock")
        case .priceAlerts:
            PlaceholderView(title: route.title, systemImage: "bell.badge")
        case .login:
            PlaceholderView(title: route.title, systemImage: "person.circle")
        case .register:
            PlaceholderView(title: route.title, systemImage: "person.badge.plus")
        case .forgotPassword:
            PlaceholderView(title: route.title, systemImage: "key")
        case .onboarding:
            PlaceholderView(title: route.title, systemImage: "hand.wave")
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
