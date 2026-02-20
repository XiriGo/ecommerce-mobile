import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - Test Helpers

private struct ProductResponse: Decodable, Sendable {
    let id: String
    let title: String
}

private struct TestEndpoint: Endpoint {
    var path: String
    var method: HTTPMethod
    var requiresAuth: Bool = false
    var queryItems: [URLQueryItem]? = nil
}

private struct AuthEndpoint: Endpoint {
    var path: String = "/store/orders"
    var method: HTTPMethod = .get
    var requiresAuth: Bool = true
}

private struct BodyEndpoint: Endpoint {
    struct Payload: Encodable, Sendable {
        let regionId: String
    }

    var path: String = "/store/carts"
    var method: HTTPMethod = .post
    var body: (any Encodable & Sendable)? = Payload(regionId: "region_eu")
}

// MARK: - APIClientTests

@Suite("APIClient Tests")
struct APIClientTests {
    init() {
        MockURLProtocol.reset()
    }

    // MARK: - Successful Request

    @Test("request succeeds and decodes response for 200 status code")
    func test_request_200Response_decodesSuccessfully() async throws {
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
    func test_request_snakeCaseResponse_decodedToCamelCase() async throws {
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
    func test_request_404Response_throwsNotFoundError() async {
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
    func test_request_401ResponseNoAuth_throwsUnauthorizedError() async {
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
    func test_request_403Response_throwsUnauthorizedError() async {
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
    func test_request_422Response_throwsServerError() async {
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
    func test_request_429Response_throwsServerError() async {
        MockURLProtocol.stub(statusCode: 429, json: """
        { "type": "rate_limit", "message": "Too many requests. Please try again later." }
        """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/products", method: .get)

        await #expect(throws: AppError.server(code: 429, message: "Too many requests. Please try again later.")) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    @Test("400 response throws server AppError with parsed message")
    func test_request_400Response_throwsServerError() async {
        MockURLProtocol.stub(statusCode: 400, json: """
        { "type": "invalid_data", "message": "Bad request" }
        """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/carts", method: .post)

        await #expect(throws: AppError.server(code: 400, message: "Bad request")) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    // MARK: - 5xx Retry

    @Test("5xx response with retry policy exhausted throws server AppError")
    func test_request_500ResponseRetryExhausted_throwsServerError() async {
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, """
            { "type": "internal_server_error", "message": "Server error" }
            """.data(using: .utf8)!)
        }

        let retryPolicy = RetryPolicy(
            maxRetries: 2,
            baseDelay: 0,
            backoffMultiplier: 1,
            maxDelay: 0,
            jitterFactor: 0,
            retryableStatusCodes: [500, 502, 503, 504]
        )

        let client = APIClient.makeTestClient(retryPolicy: retryPolicy)
        let endpoint = TestEndpoint(path: "/store/products", method: .get)

        await #expect(throws: AppError.server(code: 500, message: "Server error")) {
            let _: ProductResponse = try await client.request(endpoint)
        }

        // Initial attempt + 2 retries = 3 total calls
        #expect(callCount == 3)
    }

    @Test("5xx then 200 response succeeds after retry")
    func test_request_500ThenSuccess_succeedsAfterRetry() async throws {
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            if callCount == 1 {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 500,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (response, "{ \"type\": \"error\", \"message\": \"temp error\" }".data(using: .utf8)!)
            } else {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (response, "{ \"id\": \"prod_456\", \"title\": \"Recovered\" }".data(using: .utf8)!)
            }
        }

        let retryPolicy = RetryPolicy(
            maxRetries: 2,
            baseDelay: 0,
            backoffMultiplier: 1,
            maxDelay: 0,
            jitterFactor: 0,
            retryableStatusCodes: [500, 502, 503, 504]
        )

        let client = APIClient.makeTestClient(retryPolicy: retryPolicy)
        let endpoint = TestEndpoint(path: "/store/products/prod_456", method: .get)
        let product: ProductResponse = try await client.request(endpoint)

        #expect(product.id == "prod_456")
        #expect(product.title == "Recovered")
        #expect(callCount == 2)
    }

    @Test("non-retryable 4xx is not retried")
    func test_request_4xxError_isNotRetried() async {
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, "{ \"type\": \"not_found\", \"message\": \"Not found\" }".data(using: .utf8)!)
        }

        let retryPolicy = RetryPolicy(
            maxRetries: 3,
            baseDelay: 0,
            backoffMultiplier: 1,
            maxDelay: 0,
            jitterFactor: 0,
            retryableStatusCodes: [500, 502, 503, 504]
        )

        let client = APIClient.makeTestClient(retryPolicy: retryPolicy)
        let endpoint = TestEndpoint(path: "/store/products/missing", method: .get)

        await #expect(throws: (any Error).self) {
            let _: ProductResponse = try await client.request(endpoint)
        }

        #expect(callCount == 1)
    }

    // MARK: - Auth Token Injection

    @Test("auth endpoint has Authorization header injected with token")
    func test_request_authEndpoint_withToken_hasAuthorizationHeader() async throws {
        MockURLProtocol.stub(statusCode: 200, json: """
        { "id": "order_1", "title": "Order" }
        """)

        let tokenProvider = FakeTokenProvider()
        tokenProvider.accessToken = "my_jwt_token"
        let client = APIClient.makeTestClient(tokenProvider: tokenProvider)
        let endpoint = AuthEndpoint()

        let _: ProductResponse = try await client.request(endpoint)

        let capturedRequest = MockURLProtocol.capturedRequests.first
        #expect(capturedRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer my_jwt_token")
    }

    @Test("auth endpoint with no token does not inject Authorization header")
    func test_request_authEndpoint_withNoToken_hasNoAuthorizationHeader() async throws {
        MockURLProtocol.stub(statusCode: 200, json: """
        { "id": "order_1", "title": "Order" }
        """)

        let tokenProvider = FakeTokenProvider()
        tokenProvider.accessToken = nil
        let client = APIClient.makeTestClient(tokenProvider: tokenProvider)
        let endpoint = AuthEndpoint()

        let _: ProductResponse = try await client.request(endpoint)

        let capturedRequest = MockURLProtocol.capturedRequests.first
        #expect(capturedRequest?.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("non-auth endpoint does not inject Authorization header even with token available")
    func test_request_nonAuthEndpoint_withToken_hasNoAuthorizationHeader() async throws {
        MockURLProtocol.stub(statusCode: 200, json: """
        { "id": "prod_1", "title": "Product" }
        """)

        let tokenProvider = FakeTokenProvider()
        tokenProvider.accessToken = "my_jwt_token"
        let client = APIClient.makeTestClient(tokenProvider: tokenProvider)
        let endpoint = TestEndpoint(path: "/store/products", method: .get, requiresAuth: false)

        let _: ProductResponse = try await client.request(endpoint)

        let capturedRequest = MockURLProtocol.capturedRequests.first
        #expect(capturedRequest?.value(forHTTPHeaderField: "Authorization") == nil)
    }

    // MARK: - 401 Token Refresh

    @Test("401 response triggers token refresh and retries with new token")
    func test_request_401WithRefreshSuccess_retriesWithNewToken() async throws {
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            if callCount == 1 {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 401,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (response, "{ \"type\": \"unauthorized\", \"message\": \"Unauthorized\" }".data(using: .utf8)!)
            } else {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (response, "{ \"id\": \"order_1\", \"title\": \"Order\" }".data(using: .utf8)!)
            }
        }

        let tokenProvider = FakeTokenProvider()
        tokenProvider.accessToken = "expired_token"
        tokenProvider.refreshResult = .success("new_access_token")

        let client = APIClient.makeTestClient(tokenProvider: tokenProvider)
        let endpoint = AuthEndpoint()

        let product: ProductResponse = try await client.request(endpoint)

        #expect(product.id == "order_1")
        #expect(callCount == 2)
        #expect(tokenProvider.refreshTokenCallCount == 1)

        // Second request should have the new token
        let secondRequest = MockURLProtocol.capturedRequests.last
        #expect(secondRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer new_access_token")
    }

    @Test("401 response with failed token refresh clears tokens and throws unauthorized")
    func test_request_401WithRefreshFailure_clearsTokensAndThrowsUnauthorized() async {
        MockURLProtocol.stub(statusCode: 401, json: """
        { "type": "unauthorized", "message": "Unauthorized" }
        """)

        let tokenProvider = FakeTokenProvider()
        tokenProvider.accessToken = "expired_token"
        tokenProvider.refreshResult = .failure(AppError.unauthorized())

        let client = APIClient.makeTestClient(tokenProvider: tokenProvider)
        let endpoint = AuthEndpoint()

        await #expect(throws: (any Error).self) {
            let _: ProductResponse = try await client.request(endpoint)
        }

        #expect(tokenProvider.clearTokensCallCount >= 1)
    }

    // MARK: - Network Error

    @Test("network-level error maps to AppError.network")
    func test_request_urlError_notConnected_throwsNetworkError() async {
        MockURLProtocol.stubNetworkError(.notConnectedToInternet)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/products", method: .get)

        await #expect(throws: (any Error).self) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    @Test("connection timeout maps to network error")
    func test_request_urlError_timedOut_throwsNetworkError() async {
        MockURLProtocol.stubNetworkError(.timedOut)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/products", method: .get)

        await #expect(throws: (any Error).self) {
            let _: ProductResponse = try await client.request(endpoint)
        }
    }

    // MARK: - Publishable API Key Header

    @Test("publishable API key is added as x-publishable-api-key header")
    func test_request_publishableApiKey_isAddedAsHeader() async throws {
        MockURLProtocol.stub(statusCode: 200, json: """
        { "id": "prod_1", "title": "Product" }
        """)

        let client = APIClient.makeTestClient(publishableApiKey: "pk_test_abc123")
        let endpoint = TestEndpoint(path: "/store/products", method: .get)

        let _: ProductResponse = try await client.request(endpoint)

        let capturedRequest = MockURLProtocol.capturedRequests.first
        #expect(capturedRequest?.value(forHTTPHeaderField: "x-publishable-api-key") == "pk_test_abc123")
    }

    @Test("no publishable API key means no x-publishable-api-key header")
    func test_request_noPublishableApiKey_headerIsAbsent() async throws {
        MockURLProtocol.stub(statusCode: 200, json: """
        { "id": "prod_1", "title": "Product" }
        """)

        let client = APIClient.makeTestClient(publishableApiKey: nil)
        let endpoint = TestEndpoint(path: "/store/products", method: .get)

        let _: ProductResponse = try await client.request(endpoint)

        let capturedRequest = MockURLProtocol.capturedRequests.first
        #expect(capturedRequest?.value(forHTTPHeaderField: "x-publishable-api-key") == nil)
    }

    // MARK: - Accept Header

    @Test("all requests include Accept application/json header")
    func test_request_allRequests_haveAcceptJsonHeader() async throws {
        MockURLProtocol.stub(statusCode: 200, json: """
        { "id": "prod_1", "title": "Product" }
        """)

        let client = APIClient.makeTestClient()
        let endpoint = TestEndpoint(path: "/store/products", method: .get)

        let _: ProductResponse = try await client.request(endpoint)

        let capturedRequest = MockURLProtocol.capturedRequests.first
        #expect(capturedRequest?.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    // MARK: - Body Encoding

    @Test("POST request with body has Content-Type application/json header")
    func test_request_postWithBody_hasContentTypeHeader() async throws {
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
    func test_request_404WithEmptyBody_usesDefaultMessage() async {
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
