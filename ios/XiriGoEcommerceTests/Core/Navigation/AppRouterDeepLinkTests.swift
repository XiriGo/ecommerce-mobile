import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - AppRouterDeepLinkTests

@Suite("AppRouter DeepLink Tests")
@MainActor
struct AppRouterDeepLinkTests {
    // MARK: - handleDeepLink — valid public routes

    @Test("handleDeepLink with product URL switches to home tab and appends to home path")
    func handleDeepLink_validProductURL_switchesToHomeAndAppends() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "xirigo://product/prod_deep"))
        router.handleDeepLink(url)
        #expect(!router.homePath.isEmpty)
    }

    @Test("handleDeepLink with cart URL switches to cart tab")
    func handleDeepLink_xgCart_switchesToCartTab() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "xirigo://cart"))
        router.handleDeepLink(url)
        #expect(router.selectedTab == .cart)
    }

    @Test("handleDeepLink with profile URL switches to profile tab")
    func handleDeepLink_xgProfile_switchesToProfileTab() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "xirigo://profile"))
        router.handleDeepLink(url)
        #expect(router.selectedTab == .profile)
    }

    @Test("handleDeepLink with category URL switches to categories tab")
    func handleDeepLink_xgCategory_switchesToCategoriesTab() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "xirigo://category/cat_electronics"))
        router.handleDeepLink(url)
        #expect(router.selectedTab == .categories)
        #expect(!router.categoriesPath.isEmpty)
    }

    @Test("handleDeepLink with https product URL navigates to productDetail on home tab")
    func handleDeepLink_httpsProductURL_navigatesToProductDetail() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "https://xirigo.com/product/prod_web"))
        router.handleDeepLink(url)
        #expect(!router.homePath.isEmpty)
    }

    // MARK: - handleDeepLink — auth-required routes

    @Test("handleDeepLink with order URL presents login since order requiresAuth")
    func handleDeepLink_xgOrder_presentsLoginInsteadOfNavigating() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "xirigo://order/ord_123"))
        router.handleDeepLink(url)
        #expect(router.presentedAuth != nil)
        if case let .login(returnTo) = router.presentedAuth {
            #expect(returnTo != nil)
        } else {
            Issue.record("Expected login to be presented for auth-required deep link")
        }
    }

    // MARK: - handleDeepLink — invalid URLs

    @Test("handleDeepLink with invalid URL does nothing")
    func handleDeepLink_invalidURL_doesNothing() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "https://example.com/unknown/path"))
        router.handleDeepLink(url)
        #expect(router.selectedTab == .home)
        #expect(router.homePath.isEmpty)
        #expect(router.presentedAuth == nil)
    }

    @Test("handleDeepLink with unrecognized xirigo host does nothing")
    func handleDeepLink_unrecognizedXGHost_doesNothing() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "xirigo://unknown/path"))
        router.handleDeepLink(url)
        #expect(router.selectedTab == .home)
        #expect(router.homePath.isEmpty)
        #expect(router.presentedAuth == nil)
    }
}
