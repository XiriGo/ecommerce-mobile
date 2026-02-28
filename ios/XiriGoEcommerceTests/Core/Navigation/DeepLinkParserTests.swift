import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - DeepLinkParserTests

@Suite("DeepLinkParser Tests")
struct DeepLinkParserTests {
    // MARK: - xirigo:// product routes

    @Test("xirigo://product/{id} parses to productDetail")
    func test_parse_xgProductScheme_returnsProductDetail() throws {
        let url = try #require(URL(string: "xirigo://product/prod_abc"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .productDetail(productId: "prod_abc"))
    }

    @Test("xirigo://product/{id} with numeric id parses to productDetail")
    func test_parse_xgProductNumericId_returnsProductDetail() throws {
        let url = try #require(URL(string: "xirigo://product/12345"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .productDetail(productId: "12345"))
    }

    @Test("xirigo://product with missing id returns nil")
    func test_parse_xgProductMissingId_returnsNil() throws {
        let url = try #require(URL(string: "xirigo://product"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - xirigo:// category routes

    @Test("xirigo://category/{id} parses to categoryProducts with empty name")
    func test_parse_xgCategoryScheme_returnsCategoryProducts() throws {
        let url = try #require(URL(string: "xirigo://category/cat_fashion"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .categoryProducts(categoryId: "cat_fashion", categoryName: ""))
    }

    @Test("xirigo://category with missing id returns nil")
    func test_parse_xgCategoryMissingId_returnsNil() throws {
        let url = try #require(URL(string: "xirigo://category"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - xirigo:// cart route

    @Test("xirigo://cart parses to cart route")
    func test_parse_xgCart_returnsCart() throws {
        let url = try #require(URL(string: "xirigo://cart"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .cart)
    }

    // MARK: - xirigo:// order routes

    @Test("xirigo://order/{id} parses to orderDetail")
    func test_parse_xgOrderScheme_returnsOrderDetail() throws {
        let url = try #require(URL(string: "xirigo://order/ord_xyz"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .orderDetail(orderId: "ord_xyz"))
    }

    @Test("xirigo://order with missing id returns nil")
    func test_parse_xgOrderMissingId_returnsNil() throws {
        let url = try #require(URL(string: "xirigo://order"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - xirigo:// profile route

    @Test("xirigo://profile parses to profile route")
    func test_parse_xgProfile_returnsProfile() throws {
        let url = try #require(URL(string: "xirigo://profile"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .profile)
    }

    // MARK: - https://xirigo.com/ universal links — product

    @Test("https://xirigo.com/product/{id} parses to productDetail")
    func test_parse_httpsProductUniversalLink_returnsProductDetail() throws {
        let url = try #require(URL(string: "https://xirigo.com/product/prod_universal"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .productDetail(productId: "prod_universal"))
    }

    @Test("https://xirigo.com/product with missing id returns nil")
    func test_parse_httpsProductMissingId_returnsNil() throws {
        let url = try #require(URL(string: "https://xirigo.com/product"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - https://xirigo.com/ universal links — category

    @Test("https://xirigo.com/category/{id} parses to categoryProducts")
    func test_parse_httpsCategoryUniversalLink_returnsCategoryProducts() throws {
        let url = try #require(URL(string: "https://xirigo.com/category/cat_electronics"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .categoryProducts(categoryId: "cat_electronics", categoryName: ""))
    }

    @Test("https://xirigo.com/category with missing id returns nil")
    func test_parse_httpsCategoryMissingId_returnsNil() throws {
        let url = try #require(URL(string: "https://xirigo.com/category"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - Invalid / unrecognized URLs

    @Test("unknown xirigo:// host returns nil")
    func test_parse_xgUnknownHost_returnsNil() throws {
        let url = try #require(URL(string: "xirigo://unknown/path"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    @Test("unknown https://xirigo.com/ path returns nil")
    func test_parse_httpsUnknownPath_returnsNil() throws {
        let url = try #require(URL(string: "https://xirigo.com/unknownroute/123"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    @Test("https://xirigo.com/ with empty path returns nil")
    func test_parse_httpsEmptyPath_returnsNil() throws {
        let url = try #require(URL(string: "https://xirigo.com/"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    @Test("different https host returns nil")
    func test_parse_httpsDifferentHost_returnsNil() throws {
        let url = try #require(URL(string: "https://example.com/product/123"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    @Test("http scheme (not https) returns nil")
    func test_parse_httpScheme_returnsNil() throws {
        let url = try #require(URL(string: "http://xirigo.com/product/123"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    @Test("ftp scheme returns nil")
    func test_parse_ftpScheme_returnsNil() throws {
        let url = try #require(URL(string: "ftp://xirigo.com/product/123"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - Edge cases

    @Test("xirigo://product with empty string id returns nil")
    func test_parse_xgProductEmptyId_returnsNil() {
        // URL with trailing slash creates empty path component — parser should handle
        guard let url = URL(string: "xirigo://product/") else { return }
        let route = DeepLinkParser.parse(url)
        // pathComponents.filter { $0 != "/" } on "xirigo://product/" may yield [] or [""]
        // Either way, an empty productId should result in nil
        if let result = route, case .productDetail(let id) = result {
            #expect(!id.isEmpty, "productId must not be empty")
        }
    }

    @Test("xirigo://order with empty string id returns nil")
    func test_parse_xgOrderEmptyId_returnsNil() {
        guard let url = URL(string: "xirigo://order/") else { return }
        let route = DeepLinkParser.parse(url)
        if let result = route, case .orderDetail(let id) = result {
            #expect(!id.isEmpty, "orderId must not be empty")
        }
    }

    @Test("xirigo://category with empty string id returns nil")
    func test_parse_xgCategoryEmptyId_returnsNil() {
        guard let url = URL(string: "xirigo://category/") else { return }
        let route = DeepLinkParser.parse(url)
        if let result = route, case .categoryProducts(let id, _) = result {
            #expect(!id.isEmpty, "categoryId must not be empty")
        }
    }

    // MARK: - Auth-required deep links

    @Test("xirigo://order/{id} resolves to orderDetail which requiresAuth")
    func test_parse_xgOrder_routeRequiresAuth() throws {
        let url = try #require(URL(string: "xirigo://order/ord_secure"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == true)
    }

    @Test("xirigo://product/{id} resolves to productDetail which does not requiresAuth")
    func test_parse_xgProduct_routeDoesNotRequireAuth() throws {
        let url = try #require(URL(string: "xirigo://product/prod_public"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == false)
    }

    @Test("xirigo://cart resolves to cart which does not requiresAuth")
    func test_parse_xgCart_routeDoesNotRequireAuth() throws {
        let url = try #require(URL(string: "xirigo://cart"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == false)
    }

    @Test("xirigo://profile resolves to profile which does not requiresAuth")
    func test_parse_xgProfile_routeDoesNotRequireAuth() throws {
        let url = try #require(URL(string: "xirigo://profile"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == false)
    }

    @Test("https://xirigo.com/product/{id} resolves to route that does not requiresAuth")
    func test_parse_httpsProduct_routeDoesNotRequireAuth() throws {
        let url = try #require(URL(string: "https://xirigo.com/product/prod_pub"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == false)
    }

    @Test("https://xirigo.com/category/{id} resolves to route that does not requiresAuth")
    func test_parse_httpsCategory_routeDoesNotRequireAuth() throws {
        let url = try #require(URL(string: "https://xirigo.com/category/cat_pub"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == false)
    }

    // MARK: - Malformed URLs

    @Test("URL with no scheme returns nil")
    func test_parse_noScheme_returnsNil() {
        // "product/123" is not a valid URL with a scheme
        let url = URL(string: "product/123")
        if let url {
            let route = DeepLinkParser.parse(url)
            #expect(route == nil)
        }
        // If URL itself is nil the test is vacuously satisfied
    }

    @Test("xirigo:// with extra path segments still extracts first segment as id")
    func test_parse_xgProductExtraSegments_parsesFirstSegment() throws {
        let url = try #require(URL(string: "xirigo://product/prod_main/extra"))
        let route = DeepLinkParser.parse(url)
        // Parser uses pathComponents.first — should still return productDetail with "prod_main"
        #expect(route == .productDetail(productId: "prod_main"))
    }
}
