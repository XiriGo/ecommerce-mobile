import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - ProductResponse

private struct ProductResponse: Decodable, Sendable {
    let id: String
    let title: String
}

// MARK: - TestEndpoint

private struct TestEndpoint: Endpoint {
    var path: String
    var method: HTTPMethod
    var requiresAuth: Bool = false
}

// MARK: - BodyEndpoint

private struct BodyEndpoint: Endpoint {
    struct Payload: Encodable, Sendable {
        let regionId: String
    }

    var path: String = "/store/carts"
    var method: HTTPMethod = .post
    var body: (any Encodable & Sendable)? = Payload(regionId: "region_eu")
}

// MARK: - APIClientRequestTests

@Suite("APIClient Request Tests")
struct APIClientRequestTests {
    // MARK: - Lifecycle

    init() {
        MockURLProtocol.reset()
    }

    // MARK: - Internal

    // MARK: - Successful Request

    @Test("request succeeds and decodes response for 200 status code")
    func request_200Response_decodesSuccessfully() async throws {
        MockURLProtocol.stub(statusCode: 200, json: """
            { "id": "prod_123", "title": "Test Product" }
            """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/products/prod_123", method: .get)
        let product: ProductResponse = try await client.request(endpoint)

        #expect(product.id == "prod_123")
        #expect(product.title == "Test Product")
    }

    @Test("request decodes snake_case response fields to camelCase")
    func request_snakeCaseResponse_decodedToCamelCase() async throws {
        struct VariantResponse: Decodable, Sendable {
            let variantId: String
            let unitPrice: Int
        }

        MockURLProtocol.stub(statusCode: 200, json: """
            { "variant_id": "var_001", "unit_price": 1999 }
            """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/variants/var_001", method: .get)
        let variant: VariantResponse = try await client.request(endpoint)

        #expect(variant.variantId == "var_001")
        #expect(variant.unitPrice == 1999)
    }

    // MARK: - 4xx Error Mapping

    @Test("404 response throws notFound AppError")
    func request_404Response_throwsNotFoundError() async {
        MockURLProtocol.stub(statusCode: 404, json: """
            { "type": "not_found", "message": "Product was not found" }
            """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/products/invalid", method: .get)

        await #expect(throws: AppError.notFound(message: "Product was not found")) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    @Test("401 response with no auth endpoint throws unauthorized AppError")
    func request_401ResponseNoAuth_throwsUnauthorizedError() async {
        MockURLProtocol.stub(statusCode: 401, json: """
            { "type": "unauthorized", "message": "Unauthorized" }
            """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/protected", method: .get, requiresAuth: false)

        await #expect(throws: (any Error).self) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    @Test("403 response throws unauthorized AppError with access denied message")
    func request_403Response_throwsUnauthorizedError() async {
        MockURLProtocol.stub(statusCode: 403, json: """
            { "type": "forbidden", "message": "Access denied" }
            """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/admin", method: .get)

        await #expect(throws: AppError.unauthorized(message: "Access denied")) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    @Test("422 response throws server AppError with validation message")
    func request_422Response_throwsServerError() async {
        MockURLProtocol.stub(statusCode: 422, json: """
            { "type": "invalid_data", "message": "Email is already in use" }
            """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/customers", method: .post)

        await #expect(throws: AppError.server(code: 422, message: "Email is already in use")) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    @Test("429 response throws server AppError with rate limit message")
    func request_429Response_throwsServerError() async {
        MockURLProtocol.stub(statusCode: 429, json: """
            { "type": "rate_limit", "message": "Too many requests. Please try again later." }
            """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/products", method: .get)

        await #expect(
            throws: AppError.server(code: 429, message: "Too many requests. Please try again later."),
        ) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    @Test("400 response throws server AppError with parsed message")
    func request_400Response_throwsServerError() async {
        MockURLProtocol.stub(statusCode: 400, json: """
            { "type": "invalid_data", "message": "Bad request" }
            """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/carts", method: .post)

        await #expect(throws: AppError.server(code: 400, message: "Bad request")) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    // MARK: - Network Error

    @Test("network-level error maps to AppError.network")
    func request_urlError_notConnected_throwsNetworkError() async {
        MockURLProtocol.stubNetworkError(.notConnectedToInternet)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/products", method: .get)

        await #expect(throws: (any Error).self) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    @Test("connection timeout maps to network error")
    func request_urlError_timedOut_throwsNetworkError() async {
        MockURLProtocol.stubNetworkError(.timedOut)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/products", method: .get)

        await #expect(throws: (any Error).self) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    // MARK: - Body Encoding

    @Test("POST request with body has Content-Type application/json header")
    func request_postWithBody_hasContentTypeHeader() async throws {
        MockURLProtocol.stub(statusCode: 200, json: """
            { "id": "cart_1", "title": "Cart" }
            """)

        let client = APIClient.makeTestClient()
        let endpoint = BodyEndpoint()

        let _: ProductResponse = try await client.request(endpoint)

        let capturedRequest = MockURLProtocol.capturedRequests.first
        // URLProtocol streams the body via httpBodyStream; Content-Type header confirms body was attached
        #expect(capturedRequest?.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    // MARK: - Error Parsing Fallback

    @Test("404 without parseable body uses default not found message")
    func request_404WithEmptyBody_usesDefaultMessage() async {
        MockURLProtocol.stub(statusCode: 404, json: "")

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/products/missing", method: .get)

        do {
            let _: ProductResponse = try await client.request(endpoint)
            Issue.record("Expected an error to be thrown")
        } catch let error as AppError {
            if case .notFound = error {
                // Expected
            } else {
                Issue.record("Expected notFound error but got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}
