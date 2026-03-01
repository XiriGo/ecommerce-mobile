import SwiftUI

// MARK: - AppRouter

/// Central router managing all navigation state: selected tab, per-tab navigation paths,
/// auth flow presentation, and deep link handling.
@MainActor
@Observable
final class AppRouter {
    // MARK: - Internal

    // MARK: - Tab State

    private(set) var selectedTab: Tab = .home
    private(set) var homePath = NavigationPath()
    private(set) var categoriesPath = NavigationPath()
    private(set) var cartPath = NavigationPath()
    private(set) var profilePath = NavigationPath()

    // MARK: - Auth Presentation

    private(set) var presentedAuth: Route?

    // MARK: - Cart Badge

    var cartBadgeCount: Int = 0

    // MARK: - Computed

    /// Returns a binding to the navigation path for the currently selected tab.
    var currentPath: NavigationPath {
        get { path(for: selectedTab) }
        set { setPath(newValue, for: selectedTab) }
    }

    // MARK: - Tab Selection

    /// Selects a tab. If the tab is already selected, pops to root.
    func selectTab(_ tab: Tab) {
        if selectedTab == tab {
            popToRoot(tab: tab)
        } else {
            selectedTab = tab
        }
    }

    // MARK: - Navigation

    /// Navigates to a route on the current tab's navigation stack.
    /// If the route requires auth and the user is not authenticated, presents login instead.
    func navigate(to route: Route) {
        if route.requiresAuth {
            // Stub: treat all users as unauthenticated until M0-06
            presentLogin(returnTo: route)
            return
        }
        appendRoute(route)
    }

    /// Pops the top view from the current tab's navigation stack.
    func pop() {
        guard !currentPath.isEmpty else {
            return
        }
        currentPath.removeLast()
    }

    /// Pops all views from the current tab's navigation stack, returning to root.
    func popToRoot() {
        popToRoot(tab: selectedTab)
    }

    /// Pops all views from a specific tab's navigation stack.
    func popToRoot(tab: Tab) {
        setPath(NavigationPath(), for: tab)
    }

    /// Pops all tabs to their root screens.
    func popAllToRoot() {
        homePath = NavigationPath()
        categoriesPath = NavigationPath()
        cartPath = NavigationPath()
        profilePath = NavigationPath()
    }

    // MARK: - Auth Flow

    /// Presents the login screen as a fullscreen cover.
    func presentLogin(returnTo: Route? = nil) {
        let returnString: String? = if let returnTo {
            routeToString(returnTo)
        } else {
            nil
        }
        presentedAuth = .login(returnTo: returnString)
    }

    /// Dismisses the auth presentation (login, register, forgot password).
    func dismissAuth() {
        presentedAuth = nil
    }

    // MARK: - Deep Linking

    /// Handles an incoming deep link URL by parsing it and navigating accordingly.
    func handleDeepLink(_ url: URL) {
        guard let route = DeepLinkParser.parse(url) else {
            return
        }

        if route.requiresAuth {
            presentLogin(returnTo: route)
            return
        }

        let tab = preferredTab(for: route)
        selectedTab = tab

        // Push onto the target tab's stack after a brief delay to allow tab switch
        appendRoute(route, to: tab)
    }

    // MARK: - Path Accessors

    func path(for tab: Tab) -> NavigationPath {
        switch tab {
            case .home: homePath
            case .categories: categoriesPath
            case .cart: cartPath
            case .profile: profilePath
        }
    }

    func bindingForPath(_ tab: Tab) -> Binding<NavigationPath> {
        Binding(
            get: { self.path(for: tab) },
            set: { self.setPath($0, for: tab) },
        )
    }

    // MARK: - Private

    private func setPath(_ path: NavigationPath, for tab: Tab) {
        switch tab {
            case .home: homePath = path
            case .categories: categoriesPath = path
            case .cart: cartPath = path
            case .profile: profilePath = path
        }
    }

    private func appendRoute(_ route: Route, to tab: Tab? = nil) {
        let targetTab = tab ?? selectedTab
        var path = path(for: targetTab)
        path.append(route)
        setPath(path, for: targetTab)
    }

    private func preferredTab(for route: Route) -> Tab {
        switch route {
            case .home,
                 .productReviews,
                 .productSearch,
                 .vendorStore,
                 .writeReview:
                .home

            case .categories,
                 .categoryProducts,
                 .productList:
                .categories

            case .cart,
                 .checkout,
                 .checkoutAddress,
                 .checkoutPayment,
                 .checkoutShipping,
                 .orderConfirmation:
                .cart

            case .addressManagement,
                 .notifications,
                 .orderDetail,
                 .orderList,
                 .paymentMethods,
                 .priceAlerts,
                 .profile,
                 .recentlyViewed,
                 .settings,
                 .wishlist:
                .profile

            case .productDetail:
                selectedTab

            case .forgotPassword,
                 .login,
                 .onboarding,
                 .register:
                selectedTab
        }
    }

    private func routeToString(_ route: Route) -> String {
        switch route {
            case .home: return "home"

            case .categories: return "categories"

            case let .categoryProducts(id, _): return "category/\(id)"

            case let .productList(catId, query):
                var result = "products"
                if let catId {
                    result += "?categoryId=\(catId)"
                }
                if let query {
                    result += (catId != nil ? "&" : "?") + "query=\(query)"
                }
                return result

            case let .productDetail(id): return "product/\(id)"

            case .productSearch: return "search"

            case let .vendorStore(id): return "vendor/\(id)"

            case let .productReviews(id): return "reviews/\(id)"

            case let .writeReview(id): return "write-review/\(id)"

            case .cart: return "cart"

            case .checkout: return "checkout"

            case .checkoutAddress: return "checkout/address"

            case .checkoutShipping: return "checkout/shipping"

            case .checkoutPayment: return "checkout/payment"

            case let .orderConfirmation(id): return "order-confirmation/\(id)"

            case .profile: return "profile"

            case .orderList: return "orders"

            case let .orderDetail(id): return "order/\(id)"

            case .settings: return "settings"

            case .addressManagement: return "addresses"

            case .wishlist: return "wishlist"

            case .paymentMethods: return "payment-methods"

            case .notifications: return "notifications"

            case .recentlyViewed: return "recently-viewed"

            case .priceAlerts: return "price-alerts"

            case .login: return "login"

            case .register: return "register"

            case .forgotPassword: return "forgot-password"

            case .onboarding: return "onboarding"
        }
    }
}
