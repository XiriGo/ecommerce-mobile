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
}

private struct AuthEndpoint: Endpoint {
    var path: String = "/store/orders"
    var method: HTTPMethod = .get
    var requiresAuth: Bool = true
}

// MARK: - APIClientAuthTests

@Suite("APIClient Auth Tests")
struct APIClientAuthTests {
    init() {
        MockURLProtocol.reset()
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
            let requestURL = try #require(request.url)
            if callCount == 1 {
                let response = try #require(HTTPURLResponse(
                    url: requestURL,
                    statusCode: 401,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                ))
                let data = Data(
                    "{ \"type\": \"unauthorized\", \"message\": \"Unauthorized\" }".utf8
                )
                return (response, data)
            } else {
                let response = try #require(HTTPURLResponse(
                    url: requestURL,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                ))
                let data = Data(
                    "{ \"id\": \"order_1\", \"title\": \"Order\" }".utf8
                )
                return (response, data)
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
}
