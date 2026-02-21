import Foundation
import SwiftUI
import Testing
@testable import MoltMarketplace

// MARK: - AppRouterTests

@Suite("AppRouter Tests")
@MainActor
struct AppRouterTests {
    // MARK: - Initial State

    @Test("initial selectedTab is home")
    func test_init_selectedTab_isHome() {
        let router = AppRouter()
        #expect(router.selectedTab == .home)
    }

    @Test("initial homePath is empty")
    func test_init_homePath_isEmpty() {
        let router = AppRouter()
        #expect(router.homePath.isEmpty)
    }

    @Test("initial categoriesPath is empty")
    func test_init_categoriesPath_isEmpty() {
        let router = AppRouter()
        #expect(router.categoriesPath.isEmpty)
    }

    @Test("initial cartPath is empty")
    func test_init_cartPath_isEmpty() {
        let router = AppRouter()
        #expect(router.cartPath.isEmpty)
    }

    @Test("initial profilePath is empty")
    func test_init_profilePath_isEmpty() {
        let router = AppRouter()
        #expect(router.profilePath.isEmpty)
    }

    @Test("initial presentedAuth is nil")
    func test_init_presentedAuth_isNil() {
        let router = AppRouter()
        #expect(router.presentedAuth == nil)
    }

    @Test("initial cartBadgeCount is zero")
    func test_init_cartBadgeCount_isZero() {
        let router = AppRouter()
        #expect(router.cartBadgeCount == 0)
    }

    // MARK: - selectTab

    @Test("selectTab changes selectedTab to new tab")
    func test_selectTab_differentTab_changesSelectedTab() {
        let router = AppRouter()
        router.selectTab(.categories)
        #expect(router.selectedTab == .categories)
    }

    @Test("selectTab to cart changes selectedTab to cart")
    func test_selectTab_cart_setsSelectedTabToCart() {
        let router = AppRouter()
        router.selectTab(.cart)
        #expect(router.selectedTab == .cart)
    }

    @Test("selectTab to profile changes selectedTab to profile")
    func test_selectTab_profile_setsSelectedTabToProfile() {
        let router = AppRouter()
        router.selectTab(.profile)
        #expect(router.selectedTab == .profile)
    }

    @Test("selectTab same tab pops to root when stack is non-empty")
    func test_selectTab_sameTab_withNonEmptyPath_popsToRoot() {
        let router = AppRouter()
        // Navigate to a public route to add to home path
        router.navigate(to: .productSearch)
        #expect(!router.homePath.isEmpty)

        // Select home again — should pop to root
        router.selectTab(.home)
        #expect(router.homePath.isEmpty)
    }

    @Test("selectTab same tab when path is empty stays on root")
    func test_selectTab_sameTab_emptyPath_staysOnRoot() {
        let router = AppRouter()
        router.selectTab(.home) // already home, empty path
        #expect(router.selectedTab == .home)
        #expect(router.homePath.isEmpty)
    }

    // MARK: - navigate(to:) — public routes

    @Test("navigate to productSearch appends to current tab path")
    func test_navigate_productSearch_appendsToHomePath() {
        let router = AppRouter()
        router.navigate(to: .productSearch)
        #expect(!router.homePath.isEmpty)
    }

    @Test("navigate to productDetail appends to current tab path")
    func test_navigate_productDetail_appendsToHomePath() {
        let router = AppRouter()
        router.navigate(to: .productDetail(productId: "prod_1"))
        #expect(!router.homePath.isEmpty)
    }

    @Test("navigate to categories tab route appends to categories path when on categories tab")
    func test_navigate_categoriesRoute_whileOnCategoriesTab_appendsToCategoriesPath() {
        let router = AppRouter()
        router.selectTab(.categories)
        router.navigate(to: .categoryProducts(categoryId: "cat_1", categoryName: "Test"))
        #expect(!router.categoriesPath.isEmpty)
        #expect(router.homePath.isEmpty)
    }

    @Test("navigate to cart route while on cart tab appends to cart path")
    func test_navigate_cartRoute_whileOnCartTab_appendsToCartPath() {
        let router = AppRouter()
        router.selectTab(.cart)
        router.navigate(to: .cart)
        #expect(!router.cartPath.isEmpty)
    }

    // MARK: - navigate(to:) — auth-required routes

    @Test("navigate to auth-required route presents login instead of navigating")
    func test_navigate_authRequiredRoute_presentsLogin() {
        let router = AppRouter()
        router.navigate(to: .checkout)
        #expect(router.presentedAuth != nil)
        #expect(router.homePath.isEmpty)
    }

    @Test("navigate to checkout presents login with returnTo checkout")
    func test_navigate_checkout_presentsLoginWithReturnToCheckout() {
        let router = AppRouter()
        router.navigate(to: .checkout)
        if case .login(let returnTo) = router.presentedAuth {
            #expect(returnTo != nil)
        } else {
            Issue.record("Expected presentedAuth to be .login")
        }
    }

    @Test("navigate to wishlist presents login")
    func test_navigate_wishlist_presentsLogin() {
        let router = AppRouter()
        router.navigate(to: .wishlist)
        #expect(router.presentedAuth != nil)
    }

    @Test("navigate to settings presents login")
    func test_navigate_settings_presentsLogin() {
        let router = AppRouter()
        router.navigate(to: .settings)
        #expect(router.presentedAuth != nil)
    }

    @Test("navigate to orderList presents login")
    func test_navigate_orderList_presentsLogin() {
        let router = AppRouter()
        router.navigate(to: .orderList)
        #expect(router.presentedAuth != nil)
    }

    // MARK: - pop()

    @Test("pop removes last item from current tab path")
    func test_pop_nonEmptyPath_removesLastItem() {
        let router = AppRouter()
        router.navigate(to: .productSearch)
        #expect(!router.homePath.isEmpty)
        router.pop()
        #expect(router.homePath.isEmpty)
    }

    @Test("pop on empty path does nothing")
    func test_pop_emptyPath_doesNothing() {
        let router = AppRouter()
        #expect(router.homePath.isEmpty)
        router.pop() // should not crash
        #expect(router.homePath.isEmpty)
    }

    // MARK: - popToRoot()

    @Test("popToRoot clears current tab navigation path")
    func test_popToRoot_nonEmptyPath_clearsPath() {
        let router = AppRouter()
        router.navigate(to: .productSearch)
        router.navigate(to: .productDetail(productId: "p1"))
        router.popToRoot()
        #expect(router.homePath.isEmpty)
    }

    @Test("popToRoot on already-root path keeps path empty")
    func test_popToRoot_emptyPath_remainsEmpty() {
        let router = AppRouter()
        router.popToRoot()
        #expect(router.homePath.isEmpty)
    }

    @Test("popToRoot only clears selected tab path, not other tabs")
    func test_popToRoot_selectedTab_doesNotClearOtherTabPaths() {
        let router = AppRouter()
        router.selectTab(.categories)
        router.navigate(to: .categoryProducts(categoryId: "c1", categoryName: "Fashion"))

        router.selectTab(.home)
        router.navigate(to: .productSearch)
        router.popToRoot()

        #expect(router.homePath.isEmpty)
        #expect(!router.categoriesPath.isEmpty)
    }

    // MARK: - popToRoot(tab:)

    @Test("popToRoot(tab:) clears specified tab path")
    func test_popToRoot_tab_clearsSpecifiedTabPath() {
        let router = AppRouter()
        router.selectTab(.categories)
        router.navigate(to: .categoryProducts(categoryId: "c1", categoryName: "Electronics"))

        router.popToRoot(tab: .categories)
        #expect(router.categoriesPath.isEmpty)
    }

    @Test("popToRoot(tab:) does not affect other tabs")
    func test_popToRoot_tab_doesNotAffectOtherTabs() {
        let router = AppRouter()

        // Populate home tab
        router.selectTab(.home)
        router.navigate(to: .productSearch)

        // Populate categories tab
        router.selectTab(.categories)
        router.navigate(to: .categoryProducts(categoryId: "c1", categoryName: "Test"))

        // Pop only categories tab
        router.popToRoot(tab: .categories)

        #expect(router.categoriesPath.isEmpty)
        #expect(!router.homePath.isEmpty)
    }

    // MARK: - popAllToRoot()

    @Test("popAllToRoot clears all tab paths")
    func test_popAllToRoot_clearsAllPaths() {
        let router = AppRouter()

        router.selectTab(.home)
        router.navigate(to: .productSearch)

        router.selectTab(.categories)
        router.navigate(to: .categoryProducts(categoryId: "c1", categoryName: "Test"))

        router.popAllToRoot()

        #expect(router.homePath.isEmpty)
        #expect(router.categoriesPath.isEmpty)
        #expect(router.cartPath.isEmpty)
        #expect(router.profilePath.isEmpty)
    }

    // MARK: - presentLogin / dismissAuth

    @Test("presentLogin sets presentedAuth to login route")
    func test_presentLogin_noReturnTo_setsLoginRouteWithNilReturnTo() {
        let router = AppRouter()
        router.presentLogin()
        if case .login(let returnTo) = router.presentedAuth {
            #expect(returnTo == nil)
        } else {
            Issue.record("Expected presentedAuth to be .login")
        }
    }

    @Test("presentLogin with returnTo sets presentedAuth with serialized returnTo")
    func test_presentLogin_withReturnTo_setsLoginRouteWithReturnToString() {
        let router = AppRouter()
        router.presentLogin(returnTo: .checkout)
        if case .login(let returnTo) = router.presentedAuth {
            #expect(returnTo != nil)
            #expect(returnTo == "checkout")
        } else {
            Issue.record("Expected presentedAuth to be .login")
        }
    }

    @Test("dismissAuth sets presentedAuth to nil")
    func test_dismissAuth_presentedAuth_becomesNil() {
        let router = AppRouter()
        router.presentLogin()
        #expect(router.presentedAuth != nil)
        router.dismissAuth()
        #expect(router.presentedAuth == nil)
    }

    @Test("dismissAuth when no auth presented does nothing")
    func test_dismissAuth_noAuthPresented_remainsNil() {
        let router = AppRouter()
        router.dismissAuth() // should not crash
        #expect(router.presentedAuth == nil)
    }

    // MARK: - cartBadgeCount

    @Test("cartBadgeCount can be set to non-zero value")
    func test_cartBadgeCount_setToFive_isUpdated() {
        let router = AppRouter()
        router.cartBadgeCount = 5
        #expect(router.cartBadgeCount == 5)
    }

    @Test("cartBadgeCount can be reset to zero")
    func test_cartBadgeCount_resetToZero_isZero() {
        let router = AppRouter()
        router.cartBadgeCount = 10
        router.cartBadgeCount = 0
        #expect(router.cartBadgeCount == 0)
    }

    // MARK: - handleDeepLink — valid public routes

    @Test("handleDeepLink with product URL switches to home tab and appends to home path")
    func test_handleDeepLink_validProductURL_switchesToHomeAndAppends() {
        let router = AppRouter()
        let url = URL(string: "molt://product/prod_deep")!
        router.handleDeepLink(url)
        #expect(!router.homePath.isEmpty)
    }

    @Test("handleDeepLink with cart URL switches to cart tab")
    func test_handleDeepLink_moltCart_switchesToCartTab() {
        let router = AppRouter()
        let url = URL(string: "molt://cart")!
        router.handleDeepLink(url)
        #expect(router.selectedTab == .cart)
    }

    @Test("handleDeepLink with profile URL switches to profile tab")
    func test_handleDeepLink_moltProfile_switchesToProfileTab() {
        let router = AppRouter()
        let url = URL(string: "molt://profile")!
        router.handleDeepLink(url)
        #expect(router.selectedTab == .profile)
    }

    @Test("handleDeepLink with category URL switches to categories tab")
    func test_handleDeepLink_moltCategory_switchesToCategoriesTab() {
        let router = AppRouter()
        let url = URL(string: "molt://category/cat_electronics")!
        router.handleDeepLink(url)
        #expect(router.selectedTab == .categories)
        #expect(!router.categoriesPath.isEmpty)
    }

    @Test("handleDeepLink with https product URL navigates to productDetail on home tab")
    func test_handleDeepLink_httpsProductURL_navigatesToProductDetail() {
        let router = AppRouter()
        let url = URL(string: "https://molt.mt/product/prod_web")!
        router.handleDeepLink(url)
        #expect(!router.homePath.isEmpty)
    }

    // MARK: - handleDeepLink — auth-required routes

    @Test("handleDeepLink with order URL presents login since order requiresAuth")
    func test_handleDeepLink_moltOrder_presentsLoginInsteadOfNavigating() {
        let router = AppRouter()
        let url = URL(string: "molt://order/ord_123")!
        router.handleDeepLink(url)
        #expect(router.presentedAuth != nil)
        if case .login(let returnTo) = router.presentedAuth {
            #expect(returnTo != nil)
        } else {
            Issue.record("Expected login to be presented for auth-required deep link")
        }
    }

    // MARK: - handleDeepLink — invalid URLs

    @Test("handleDeepLink with invalid URL does nothing")
    func test_handleDeepLink_invalidURL_doesNothing() {
        let router = AppRouter()
        let url = URL(string: "https://example.com/unknown/path")!
        router.handleDeepLink(url)
        #expect(router.selectedTab == .home)
        #expect(router.homePath.isEmpty)
        #expect(router.presentedAuth == nil)
    }

    @Test("handleDeepLink with unrecognized molt host does nothing")
    func test_handleDeepLink_unrecognizedMoltHost_doesNothing() {
        let router = AppRouter()
        let url = URL(string: "molt://unknown/path")!
        router.handleDeepLink(url)
        #expect(router.selectedTab == .home)
        #expect(router.homePath.isEmpty)
        #expect(router.presentedAuth == nil)
    }

    // MARK: - path(for:)

    @Test("path(for: .home) returns homePath")
    func test_pathForTab_home_returnsHomePath() {
        let router = AppRouter()
        router.navigate(to: .productSearch)
        let path = router.path(for: .home)
        #expect(!path.isEmpty)
    }

    @Test("path(for: .categories) returns categoriesPath")
    func test_pathForTab_categories_returnsCategoriesPath() {
        let router = AppRouter()
        router.selectTab(.categories)
        router.navigate(to: .categoryProducts(categoryId: "c1", categoryName: "Test"))
        let path = router.path(for: .categories)
        #expect(!path.isEmpty)
    }

    @Test("path(for: .cart) returns cartPath")
    func test_pathForTab_cart_returnsCartPath() {
        let router = AppRouter()
        router.selectTab(.cart)
        router.navigate(to: .cart)
        let path = router.path(for: .cart)
        #expect(!path.isEmpty)
    }

    @Test("path(for: .profile) returns profilePath")
    func test_pathForTab_profile_returnsProfilePath() {
        let router = AppRouter()
        router.selectTab(.profile)
        router.navigate(to: .profile)
        let path = router.path(for: .profile)
        #expect(!path.isEmpty)
    }

    // MARK: - currentPath computed property

    @Test("currentPath getter returns path for selectedTab")
    func test_currentPath_getter_returnsSelectedTabPath() {
        let router = AppRouter()
        router.selectTab(.categories)
        router.navigate(to: .categoryProducts(categoryId: "c1", categoryName: "Test"))
        #expect(!router.currentPath.isEmpty)
        #expect(router.categoriesPath == router.currentPath)
    }

    @Test("currentPath setter updates path for selectedTab")
    func test_currentPath_setter_updatesSelectedTabPath() {
        let router = AppRouter()
        var newPath = NavigationPath()
        newPath.append(Route.productSearch)
        router.currentPath = newPath
        #expect(!router.homePath.isEmpty)
    }
}
