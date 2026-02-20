import Foundation
@testable import MoltMarketplace

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

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        MockURLProtocol.capturedRequests.append(request)

        guard let handler = MockURLProtocol.requestHandler else {
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

    /// Configures the handler to return a successful JSON response with the given status code.
    static func stub(statusCode: Int, json: String, url: URL = URL(string: "https://test.example.com")!) {
        requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url ?? url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, json.data(using: .utf8)!)
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
    /// Creates an APIClient configured to use MockURLProtocol for intercepting requests.
    static func makeTestClient(
        baseURL: URL = URL(string: "https://api-test.molt.mt")!,
        tokenProvider: any TokenProvider = NoOpTokenProvider(),
        retryPolicy: RetryPolicy = RetryPolicy(
            maxRetries: 0,
            baseDelay: 0,
            backoffMultiplier: 1,
            maxDelay: 0,
            jitterFactor: 0,
            retryableStatusCodes: [500, 502, 503, 504]
        ),
        publishableApiKey: String? = nil
    ) -> APIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return APIClient(
            baseURL: baseURL,
            session: session,
            tokenProvider: tokenProvider,
            retryPolicy: retryPolicy,
            publishableApiKey: publishableApiKey
        )
    }
}
