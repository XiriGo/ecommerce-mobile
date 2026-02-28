import Foundation
import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - AppRouterNavigationTests

@Suite("AppRouter Navigation Tests")
@MainActor
struct AppRouterNavigationTests {
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
