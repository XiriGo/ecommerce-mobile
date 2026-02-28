import Foundation
import Testing
@testable import XiriGoEcommerce

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

// MARK: - APIClientRetryTests

@Suite("APIClient Retry Tests")
struct APIClientRetryTests {
    init() {
        MockURLProtocol.reset()
    }

    // MARK: - Helpers

    private func makeRetryPolicy(maxRetries: Int) -> RetryPolicy {
        RetryPolicy(
            maxRetries: maxRetries,
            baseDelay: 0,
            backoffMultiplier: 1,
            maxDelay: 0,
            jitterFactor: 0,
            retryableStatusCodes: [500, 502, 503, 504]
        )
    }

    // MARK: - 5xx Retry

    @Test("5xx response with retry policy exhausted throws server AppError")
    func test_request_500ResponseRetryExhausted_throwsServerError() async {
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            let requestURL = try #require(request.url)
            let response = try #require(HTTPURLResponse(
                url: requestURL,
                statusCode: 500,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            ))
            let data = Data("""
            { "type": "internal_server_error", "message": "Server error" }
            """.utf8)
            return (response, data)
        }

        let client = APIClient.makeTestClient(retryPolicy: makeRetryPolicy(maxRetries: 2))
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
            let requestURL = try #require(request.url)
            if callCount == 1 {
                let response = try #require(HTTPURLResponse(
                    url: requestURL,
                    statusCode: 500,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                ))
                let data = Data(
                    "{ \"type\": \"error\", \"message\": \"temp error\" }".utf8
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
                    "{ \"id\": \"prod_456\", \"title\": \"Recovered\" }".utf8
                )
                return (response, data)
            }
        }

        let client = APIClient.makeTestClient(retryPolicy: makeRetryPolicy(maxRetries: 2))
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
            let requestURL = try #require(request.url)
            let response = try #require(HTTPURLResponse(
                url: requestURL,
                statusCode: 404,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            ))
            let data = Data(
                "{ \"type\": \"not_found\", \"message\": \"Not found\" }".utf8
            )
            return (response, data)
        }

        let client = APIClient.makeTestClient(retryPolicy: makeRetryPolicy(maxRetries: 3))
        let endpoint = TestEndpoint(path: "/store/products/missing", method: .get)

        await #expect(throws: (any Error).self) {
            let _: ProductResponse = try await client.request(endpoint)
        }

        #expect(callCount == 1)
    }
}
