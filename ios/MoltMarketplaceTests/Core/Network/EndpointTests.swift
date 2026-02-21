import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - Test Endpoint Implementations

private struct GetProductsEndpoint: Endpoint {
    let offset: Int
    let limit: Int

    var path: String { "/store/products" }
    var method: HTTPMethod { .get }
    var queryItems: [URLQueryItem]? {
        [
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]
    }
}

private struct GetProductDetailEndpoint: Endpoint {
    let id: String
    var path: String { "/store/products/\(id)" }
    var method: HTTPMethod { .get }
    var requiresAuth: Bool { false }
}

private struct CreateCartEndpoint: Endpoint {
    struct Body: Encodable, Sendable {
        let regionId: String
    }

    let regionId: String
    var path: String { "/store/carts" }
    var method: HTTPMethod { .post }
    var body: (any Encodable & Sendable)? { Body(regionId: regionId) }
}

private struct GetOrdersEndpoint: Endpoint {
    var path: String { "/store/orders" }
    var method: HTTPMethod { .get }
    var requiresAuth: Bool { true }
}

private struct CustomHeaderEndpoint: Endpoint {
    var path: String { "/store/custom" }
    var method: HTTPMethod { .get }
    var headers: [String: String] { ["X-Custom-Header": "custom-value"] }
}

// MARK: - EndpointTests

@Suite("Endpoint Tests")
struct EndpointTests {
    // swiftlint:disable:next force_unwrapping
    private let baseURL = URL(string: "https://api-test.molt.mt")!

    // MARK: - Path

    @Test("endpoint path is set correctly")
    func test_path_isSetCorrectly() {
        let endpoint = GetProductsEndpoint(offset: 0, limit: 20)
        #expect(endpoint.path == "/store/products")
    }

    @Test("endpoint path includes dynamic segment")
    func test_path_withDynamicSegment_includesId() {
        let endpoint = GetProductDetailEndpoint(id: "prod_123")
        #expect(endpoint.path == "/store/products/prod_123")
    }

    // MARK: - HTTP Method

    @Test("GET endpoint has GET method")
    func test_method_getEndpoint_isGet() {
        let endpoint = GetProductsEndpoint(offset: 0, limit: 20)
        #expect(endpoint.method == .get)
    }

    @Test("POST endpoint has POST method")
    func test_method_postEndpoint_isPost() {
        let endpoint = CreateCartEndpoint(regionId: "region_01")
        #expect(endpoint.method == .post)
    }

    // MARK: - Query Items

    @Test("query items are set with correct names and values")
    func test_queryItems_areSetWithCorrectNamesAndValues() {
        let endpoint = GetProductsEndpoint(offset: 20, limit: 10)
        let items = endpoint.queryItems

        #expect(items != nil)
        #expect(items?.count == 2)
        #expect(items?.first(where: { $0.name == "offset" })?.value == "20")
        #expect(items?.first(where: { $0.name == "limit" })?.value == "10")
    }

    @Test("endpoint without query items returns nil")
    func test_queryItems_endpointWithNoQueryItems_returnsNil() {
        let endpoint = CreateCartEndpoint(regionId: "region_01")
        #expect(endpoint.queryItems == nil)
    }

    // MARK: - Body

    @Test("POST endpoint has a body")
    func test_body_postEndpoint_hasBody() {
        let endpoint = CreateCartEndpoint(regionId: "region_eu")
        #expect(endpoint.body != nil)
    }

    @Test("GET endpoint has no body by default")
    func test_body_getEndpoint_isNilByDefault() {
        let endpoint = GetProductsEndpoint(offset: 0, limit: 20)
        #expect(endpoint.body == nil)
    }

    // MARK: - requiresAuth

    @Test("endpoint requiresAuth defaults to false")
    func test_requiresAuth_defaultImplementation_isFalse() {
        let endpoint = GetProductsEndpoint(offset: 0, limit: 20)
        #expect(endpoint.requiresAuth == false)
    }

    @Test("endpoint with requiresAuth true reports true")
    func test_requiresAuth_whenExplicitlyTrue_isTrue() {
        let endpoint = GetOrdersEndpoint()
        #expect(endpoint.requiresAuth == true)
    }

    @Test("endpoint with requiresAuth false reports false")
    func test_requiresAuth_whenExplicitlyFalse_isFalse() {
        let endpoint = GetProductDetailEndpoint(id: "prod_1")
        #expect(endpoint.requiresAuth == false)
    }

    // MARK: - Headers

    @Test("headers default implementation returns empty dictionary")
    func test_headers_defaultImplementation_returnsEmptyDictionary() {
        let endpoint = GetProductsEndpoint(offset: 0, limit: 20)
        #expect(endpoint.headers.isEmpty)
    }

    @Test("custom headers are returned correctly")
    func test_headers_customHeaders_areReturnedCorrectly() {
        let endpoint = CustomHeaderEndpoint()
        #expect(endpoint.headers["X-Custom-Header"] == "custom-value")
    }

    // MARK: - URLRequest Construction via APIClient

    @Test("GET endpoint builds URLRequest with correct URL")
    func test_urlRequest_getEndpoint_hasCorrectURL() throws {
        let endpoint = GetProductsEndpoint(offset: 0, limit: 20)
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.port = baseURL.port
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems

        let url = components.url
        #expect(url != nil)
        #expect(url?.host == "api-test.molt.mt")
        #expect(url?.path == "/store/products")
    }

    @Test("GET endpoint URL includes query parameters")
    func test_urlRequest_getEndpoint_includesQueryParams() throws {
        let endpoint = GetProductsEndpoint(offset: 40, limit: 20)
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.port = baseURL.port
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems

        let urlString = components.url?.absoluteString ?? ""
        #expect(urlString.contains("offset=40"))
        #expect(urlString.contains("limit=20"))
    }

    @Test("HTTPMethod rawValues match expected HTTP verbs")
    func test_httpMethod_rawValues_matchExpectedVerbs() {
        #expect(HTTPMethod.get.rawValue == "GET")
        #expect(HTTPMethod.post.rawValue == "POST")
        #expect(HTTPMethod.put.rawValue == "PUT")
        #expect(HTTPMethod.delete.rawValue == "DELETE")
        #expect(HTTPMethod.patch.rawValue == "PATCH")
    }
}
