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

    // MARK: - Auth Requirement

    /// Whether this route requires the user to be authenticated.
    var requiresAuth: Bool {
        switch self {
        case .checkout,
             .checkoutAddress,
             .checkoutShipping,
             .checkoutPayment,
             .orderConfirmation,
             .orderList,
             .orderDetail,
             .settings,
             .addressManagement,
             .wishlist,
             .paymentMethods,
             .notifications,
             .writeReview,
             .priceAlerts:
            return true
        case .home,
             .productDetail,
             .productSearch,
             .vendorStore,
             .productReviews,
             .categories,
             .categoryProducts,
             .productList,
             .cart,
             .profile,
             .login,
             .register,
             .forgotPassword,
             .onboarding,
             .recentlyViewed:
            return false
        }
    }

    // MARK: - Display Title

    /// Human-readable title for placeholder screens.
    var title: String {
        switch self {
        case .home: return String(localized: "nav_tab_home")
        case .categories: return String(localized: "nav_tab_categories")
        case .cart: return String(localized: "nav_tab_cart")
        case .profile: return String(localized: "nav_tab_profile")
        case .productDetail: return "Product Detail"
        case .productSearch: return "Search"
        case .vendorStore: return "Vendor Store"
        case .productReviews: return "Reviews"
        case .writeReview: return "Write Review"
        case .categoryProducts(_, let name): return name.isEmpty ? "Category" : name
        case .productList: return "Products"
        case .checkout: return "Checkout"
        case .checkoutAddress: return "Address"
        case .checkoutShipping: return "Shipping"
        case .checkoutPayment: return "Payment"
        case .orderConfirmation: return "Order Confirmed"
        case .orderList: return "Orders"
        case .orderDetail: return "Order Detail"
        case .settings: return "Settings"
        case .addressManagement: return "Addresses"
        case .wishlist: return "Wishlist"
        case .paymentMethods: return "Payment Methods"
        case .notifications: return "Notifications"
        case .recentlyViewed: return "Recently Viewed"
        case .priceAlerts: return "Price Alerts"
        case .login: return "Log In"
        case .register: return "Register"
        case .forgotPassword: return "Forgot Password"
        case .onboarding: return "Welcome"
        }
    }
}
