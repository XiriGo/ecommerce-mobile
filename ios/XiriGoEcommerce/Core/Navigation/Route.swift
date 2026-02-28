import Foundation

// MARK: - Route

/// Type-safe route definitions for all screens across milestones M0 through M4.
/// Routes that are not yet implemented render a placeholder view.
enum Route: Hashable {
    // MARK: - Home Tab

    case home
    case productDetail(productId: String)
    case productSearch
    case vendorStore(vendorId: String)
    case productReviews(productId: String)
    case writeReview(productId: String)

    // MARK: - Categories Tab

    case categories
    case categoryProducts(categoryId: String, categoryName: String)
    case productList(categoryId: String?, query: String?)

    // MARK: - Cart Tab

    case cart
    case checkout
    case checkoutAddress
    case checkoutShipping
    case checkoutPayment
    case orderConfirmation(orderId: String)

    // MARK: - Profile Tab

    case profile
    case orderList
    case orderDetail(orderId: String)
    case settings
    case addressManagement
    case wishlist
    case paymentMethods
    case notifications
    case recentlyViewed
    case priceAlerts

    // MARK: - Auth (Modal / Fullscreen)

    case login(returnTo: String?)
    case register
    case forgotPassword

    // MARK: - Onboarding (Fullscreen)

    case onboarding

    // MARK: - Internal

    // MARK: - Auth Requirement

    /// Whether this route requires the user to be authenticated.
    var requiresAuth: Bool {
        switch self {
            case .addressManagement,
                 .checkout,
                 .checkoutAddress,
                 .checkoutPayment,
                 .checkoutShipping,
                 .notifications,
                 .orderConfirmation,
                 .orderDetail,
                 .orderList,
                 .paymentMethods,
                 .priceAlerts,
                 .settings,
                 .wishlist,
                 .writeReview:
                true

            case .cart,
                 .categories,
                 .categoryProducts,
                 .forgotPassword,
                 .home,
                 .login,
                 .onboarding,
                 .productDetail,
                 .productList,
                 .productReviews,
                 .productSearch,
                 .profile,
                 .recentlyViewed,
                 .register,
                 .vendorStore:
                false
        }
    }

    // MARK: - Display Title

    /// Human-readable title for placeholder screens.
    var title: String {
        switch self {
            case .home: String(localized: "nav_tab_home")
            case .categories: String(localized: "nav_tab_categories")
            case .cart: String(localized: "nav_tab_cart")
            case .profile: String(localized: "nav_tab_profile")
            case .productDetail: "Product Detail"
            case .productSearch: "Search"
            case .vendorStore: "Vendor Store"
            case .productReviews: "Reviews"
            case .writeReview: "Write Review"
            case let .categoryProducts(_, name): name.isEmpty ? "Category" : name
            case .productList: "Products"
            case .checkout: "Checkout"
            case .checkoutAddress: "Address"
            case .checkoutShipping: "Shipping"
            case .checkoutPayment: "Payment"
            case .orderConfirmation: "Order Confirmed"
            case .orderList: "Orders"
            case .orderDetail: "Order Detail"
            case .settings: "Settings"
            case .addressManagement: "Addresses"
            case .wishlist: "Wishlist"
            case .paymentMethods: "Payment Methods"
            case .notifications: "Notifications"
            case .recentlyViewed: "Recently Viewed"
            case .priceAlerts: "Price Alerts"
            case .login: "Log In"
            case .register: "Register"
            case .forgotPassword: "Forgot Password"
            case .onboarding: "Welcome"
        }
    }
}
