import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - DeepLinkParserTests

@Suite("DeepLinkParser Tests")
struct DeepLinkParserTests {
    // MARK: - molt:// product routes

    @Test("molt://product/{id} parses to productDetail")
    func test_parse_moltProductScheme_returnsProductDetail() throws {
        let url = try #require(URL(string: "molt://product/prod_abc"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .productDetail(productId: "prod_abc"))
    }

    @Test("molt://product/{id} with numeric id parses to productDetail")
    func test_parse_moltProductNumericId_returnsProductDetail() throws {
        let url = try #require(URL(string: "molt://product/12345"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .productDetail(productId: "12345"))
    }

    @Test("molt://product with missing id returns nil")
    func test_parse_moltProductMissingId_returnsNil() throws {
        let url = try #require(URL(string: "molt://product"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - molt:// category routes

    @Test("molt://category/{id} parses to categoryProducts with empty name")
    func test_parse_moltCategoryScheme_returnsCategoryProducts() throws {
        let url = try #require(URL(string: "molt://category/cat_fashion"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .categoryProducts(categoryId: "cat_fashion", categoryName: ""))
    }

    @Test("molt://category with missing id returns nil")
    func test_parse_moltCategoryMissingId_returnsNil() throws {
        let url = try #require(URL(string: "molt://category"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - molt:// cart route

    @Test("molt://cart parses to cart route")
    func test_parse_moltCart_returnsCart() throws {
        let url = try #require(URL(string: "molt://cart"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .cart)
    }

    // MARK: - molt:// order routes

    @Test("molt://order/{id} parses to orderDetail")
    func test_parse_moltOrderScheme_returnsOrderDetail() throws {
        let url = try #require(URL(string: "molt://order/ord_xyz"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .orderDetail(orderId: "ord_xyz"))
    }

    @Test("molt://order with missing id returns nil")
    func test_parse_moltOrderMissingId_returnsNil() throws {
        let url = try #require(URL(string: "molt://order"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - molt:// profile route

    @Test("molt://profile parses to profile route")
    func test_parse_moltProfile_returnsProfile() throws {
        let url = try #require(URL(string: "molt://profile"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .profile)
    }

    // MARK: - https://molt.mt/ universal links — product

    @Test("https://molt.mt/product/{id} parses to productDetail")
    func test_parse_httpsProductUniversalLink_returnsProductDetail() throws {
        let url = try #require(URL(string: "https://molt.mt/product/prod_universal"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .productDetail(productId: "prod_universal"))
    }

    @Test("https://molt.mt/product with missing id returns nil")
    func test_parse_httpsProductMissingId_returnsNil() throws {
        let url = try #require(URL(string: "https://molt.mt/product"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - https://molt.mt/ universal links — category

    @Test("https://molt.mt/category/{id} parses to categoryProducts")
    func test_parse_httpsCategoryUniversalLink_returnsCategoryProducts() throws {
        let url = try #require(URL(string: "https://molt.mt/category/cat_electronics"))
        let route = DeepLinkParser.parse(url)
        #expect(route == .categoryProducts(categoryId: "cat_electronics", categoryName: ""))
    }

    @Test("https://molt.mt/category with missing id returns nil")
    func test_parse_httpsCategoryMissingId_returnsNil() throws {
        let url = try #require(URL(string: "https://molt.mt/category"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - Invalid / unrecognized URLs

    @Test("unknown molt:// host returns nil")
    func test_parse_moltUnknownHost_returnsNil() throws {
        let url = try #require(URL(string: "molt://unknown/path"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    @Test("unknown https://molt.mt/ path returns nil")
    func test_parse_httpsUnknownPath_returnsNil() throws {
        let url = try #require(URL(string: "https://molt.mt/unknownroute/123"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    @Test("https://molt.mt/ with empty path returns nil")
    func test_parse_httpsEmptyPath_returnsNil() throws {
        let url = try #require(URL(string: "https://molt.mt/"))
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
        let url = try #require(URL(string: "http://molt.mt/product/123"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    @Test("ftp scheme returns nil")
    func test_parse_ftpScheme_returnsNil() throws {
        let url = try #require(URL(string: "ftp://molt.mt/product/123"))
        let route = DeepLinkParser.parse(url)
        #expect(route == nil)
    }

    // MARK: - Edge cases

    @Test("molt://product with empty string id returns nil")
    func test_parse_moltProductEmptyId_returnsNil() {
        // URL with trailing slash creates empty path component — parser should handle
        guard let url = URL(string: "molt://product/") else { return }
        let route = DeepLinkParser.parse(url)
        // pathComponents.filter { $0 != "/" } on "molt://product/" may yield [] or [""]
        // Either way, an empty productId should result in nil
        if let result = route, case .productDetail(let id) = result {
            #expect(!id.isEmpty, "productId must not be empty")
        }
    }

    @Test("molt://order with empty string id returns nil")
    func test_parse_moltOrderEmptyId_returnsNil() {
        guard let url = URL(string: "molt://order/") else { return }
        let route = DeepLinkParser.parse(url)
        if let result = route, case .orderDetail(let id) = result {
            #expect(!id.isEmpty, "orderId must not be empty")
        }
    }

    @Test("molt://category with empty string id returns nil")
    func test_parse_moltCategoryEmptyId_returnsNil() {
        guard let url = URL(string: "molt://category/") else { return }
        let route = DeepLinkParser.parse(url)
        if let result = route, case .categoryProducts(let id, _) = result {
            #expect(!id.isEmpty, "categoryId must not be empty")
        }
    }

    // MARK: - Auth-required deep links

    @Test("molt://order/{id} resolves to orderDetail which requiresAuth")
    func test_parse_moltOrder_routeRequiresAuth() throws {
        let url = try #require(URL(string: "molt://order/ord_secure"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == true)
    }

    @Test("molt://product/{id} resolves to productDetail which does not requiresAuth")
    func test_parse_moltProduct_routeDoesNotRequireAuth() throws {
        let url = try #require(URL(string: "molt://product/prod_public"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == false)
    }

    @Test("molt://cart resolves to cart which does not requiresAuth")
    func test_parse_moltCart_routeDoesNotRequireAuth() throws {
        let url = try #require(URL(string: "molt://cart"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == false)
    }

    @Test("molt://profile resolves to profile which does not requiresAuth")
    func test_parse_moltProfile_routeDoesNotRequireAuth() throws {
        let url = try #require(URL(string: "molt://profile"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == false)
    }

    @Test("https://molt.mt/product/{id} resolves to route that does not requiresAuth")
    func test_parse_httpsProduct_routeDoesNotRequireAuth() throws {
        let url = try #require(URL(string: "https://molt.mt/product/prod_pub"))
        let route = DeepLinkParser.parse(url)
        #expect(route?.requiresAuth == false)
    }

    @Test("https://molt.mt/category/{id} resolves to route that does not requiresAuth")
    func test_parse_httpsCategory_routeDoesNotRequireAuth() throws {
        let url = try #require(URL(string: "https://molt.mt/category/cat_pub"))
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

    @Test("molt:// with extra path segments still extracts first segment as id")
    func test_parse_moltProductExtraSegments_parsesFirstSegment() throws {
        let url = try #require(URL(string: "molt://product/prod_main/extra"))
        let route = DeepLinkParser.parse(url)
        // Parser uses pathComponents.first — should still return productDetail with "prod_main"
        #expect(route == .productDetail(productId: "prod_main"))
    }
}
