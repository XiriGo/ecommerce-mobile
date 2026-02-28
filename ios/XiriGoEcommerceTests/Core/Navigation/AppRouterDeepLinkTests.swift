import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - AppRouterDeepLinkTests

@Suite("AppRouter DeepLink Tests")
@MainActor
struct AppRouterDeepLinkTests {
    // MARK: - handleDeepLink — valid public routes

    @Test("handleDeepLink with product URL switches to home tab and appends to home path")
    func test_handleDeepLink_validProductURL_switchesToHomeAndAppends() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "molt://product/prod_deep"))
        router.handleDeepLink(url)
        #expect(!router.homePath.isEmpty)
    }

    @Test("handleDeepLink with cart URL switches to cart tab")
    func test_handleDeepLink_moltCart_switchesToCartTab() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "molt://cart"))
        router.handleDeepLink(url)
        #expect(router.selectedTab == .cart)
    }

    @Test("handleDeepLink with profile URL switches to profile tab")
    func test_handleDeepLink_moltProfile_switchesToProfileTab() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "molt://profile"))
        router.handleDeepLink(url)
        #expect(router.selectedTab == .profile)
    }

    @Test("handleDeepLink with category URL switches to categories tab")
    func test_handleDeepLink_moltCategory_switchesToCategoriesTab() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "molt://category/cat_electronics"))
        router.handleDeepLink(url)
        #expect(router.selectedTab == .categories)
        #expect(!router.categoriesPath.isEmpty)
    }

    @Test("handleDeepLink with https product URL navigates to productDetail on home tab")
    func test_handleDeepLink_httpsProductURL_navigatesToProductDetail() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "https://molt.mt/product/prod_web"))
        router.handleDeepLink(url)
        #expect(!router.homePath.isEmpty)
    }

    // MARK: - handleDeepLink — auth-required routes

    @Test("handleDeepLink with order URL presents login since order requiresAuth")
    func test_handleDeepLink_moltOrder_presentsLoginInsteadOfNavigating() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "molt://order/ord_123"))
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
    func test_handleDeepLink_invalidURL_doesNothing() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "https://example.com/unknown/path"))
        router.handleDeepLink(url)
        #expect(router.selectedTab == .home)
        #expect(router.homePath.isEmpty)
        #expect(router.presentedAuth == nil)
    }

    @Test("handleDeepLink with unrecognized molt host does nothing")
    func test_handleDeepLink_unrecognizedMoltHost_doesNothing() throws {
        let router = AppRouter()
        let url = try #require(URL(string: "molt://unknown/path"))
        router.handleDeepLink(url)
        #expect(router.selectedTab == .home)
        #expect(router.homePath.isEmpty)
        #expect(router.presentedAuth == nil)
    }
}
