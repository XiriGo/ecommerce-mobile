import Foundation
@testable import XiriGoEcommerce

// MARK: - MockURLProtocol

/// URLProtocol subclass that intercepts all requests in a URLSession configured with it.
/// Allows tests to return pre-configured responses without a real network.
///
/// nonisolated(unsafe) is used for the static mutable state because URLProtocol
/// callbacks may occur on arbitrary threads. Tests must reset state before each run.
final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    // MARK: - Internal

    /// The handler block invoked for each intercepted request.
    /// Return (HTTPURLResponse, Data) for success, or throw for network-level errors.
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    /// Tracks all intercepted requests for assertion in tests.
    nonisolated(unsafe) static var capturedRequests: [URLRequest] = []

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.capturedRequests.append(request)

        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - MockURLProtocol Helpers

extension MockURLProtocol {
    /// Resets shared state. Call in each test's setup or teardown.
    static func reset() {
        requestHandler = nil
        capturedRequests = []
    }

    /// Default fallback URL used when no URL is provided to `stub(statusCode:json:url:)`.
    private static let defaultStubURL = URL(string: "https://test.example.com")

    /// Configures the handler to return a successful JSON response with the given status code.
    static func stub(statusCode: Int, json: String, url: URL? = nil) {
        requestHandler = { request in
            guard let responseURL = request.url ?? url ?? defaultStubURL else {
                throw URLError(.unknown)
            }
            guard let response = HTTPURLResponse(
                url: responseURL,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            ) else {
                throw URLError(.unknown)
            }
            guard let data = json.data(using: .utf8) else {
                throw URLError(.cannotDecodeContentData)
            }
            return (response, data)
        }
    }

    /// Configures the handler to throw a URLError.
    static func stubNetworkError(_ code: URLError.Code) {
        requestHandler = { _ in
            throw URLError(code)
        }
    }
}

// MARK: - APIClient + Test Session Factory

extension APIClient {
    /// Server error status codes used in test retry policies.
    private static let httpInternalServerError = 500
    private static let httpBadGateway = 502
    private static let httpServiceUnavailable = 503
    private static let httpGatewayTimeout = 504
    private static let testRetryableStatusCodes: Set<Int> = [
        httpInternalServerError, httpBadGateway, httpServiceUnavailable, httpGatewayTimeout,
    ]

    /// Default base URL for test clients.
    private static let testBaseURL: URL = {
        guard let url = URL(string: "https://api-test.xirigo.com") else {
            fatalError("Invalid test base URL constant — this is a programming error in test infrastructure.")
        }
        return url
    }()

    /// Creates an APIClient configured to use MockURLProtocol for intercepting requests.
    static func makeTestClient(
        baseURL: URL? = nil,
        tokenProvider: any TokenProvider = NoOpTokenProvider(),
        retryPolicy: RetryPolicy = RetryPolicy(
            maxRetries: 0,
            baseDelay: 0,
            backoffMultiplier: 1,
            maxDelay: 0,
            jitterFactor: 0,
            retryableStatusCodes: testRetryableStatusCodes
        ),
        publishableApiKey: String? = nil
    ) -> APIClient {
        let resolvedBaseURL = baseURL ?? testBaseURL
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return APIClient(
            baseURL: resolvedBaseURL,
            session: session,
            tokenProvider: tokenProvider,
            retryPolicy: retryPolicy,
            publishableApiKey: publishableApiKey
        )
    }
}
