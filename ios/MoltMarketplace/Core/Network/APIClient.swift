import Foundation

// MARK: - APIClient

final class APIClient: Sendable {
    // MARK: - HTTP Status Code Constants

    private static let httpSuccessRange = 200 ... 299
    private static let httpUnauthorized = 401
    private static let httpForbidden = 403
    private static let httpNotFound = 404
    private static let httpTooManyRequests = 429
    private static let httpClientErrorRange = 400 ... 499
    private static let httpServerErrorRange = 500 ... 599
    private static let nanosecondsPerSecond: UInt64 = 1_000_000_000
    // MARK: - Lifecycle

    init(
        baseURL: URL,
        session: URLSession? = nil,
        tokenProvider: any TokenProvider = NoOpTokenProvider(),
        retryPolicy: RetryPolicy = .default,
        publishableApiKey: String? = nil
    ) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.retryPolicy = retryPolicy
        self.publishableApiKey = publishableApiKey
        self.tokenRefreshActor = TokenRefreshActor(tokenProvider: tokenProvider)

        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = NetworkConfig.timeoutIntervalForRequest
            config.timeoutIntervalForResource = NetworkConfig.timeoutIntervalForResource
            config.urlCache = URLCache(
                memoryCapacity: NetworkConfig.memoryCacheCapacity,
                diskCapacity: NetworkConfig.diskCacheCapacity
            )
            config.httpAdditionalHeaders = ["Accept": "application/json"]
            config.waitsForConnectivity = false
            self.session = URLSession(configuration: config)
        }
    }

    // MARK: - Internal

    /// Performs a network request and decodes the response as the specified type.
    ///
    /// Handles auth token injection, 401 token refresh + retry, and 5xx retry
    /// with exponential backoff. Non-success responses are mapped to `AppError`.
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        let urlRequest = try buildURLRequest(for: endpoint)
        return try await executeWithRetry(urlRequest, endpoint: endpoint)
    }

    // MARK: - Private

    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: any TokenProvider
    private let retryPolicy: RetryPolicy
    private let publishableApiKey: String?
    private let tokenRefreshActor: TokenRefreshActor

    // MARK: - Request Building

    private func buildURLRequest(for endpoint: any Endpoint) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.port = baseURL.port
        components.path = endpoint.path

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else {
            throw AppError.unknown(message: "Failed to build URL for path: \(endpoint.path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = endpoint.body {
            request.httpBody = try JSONEncoder.api.encode(AnyEncodable(body))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let publishableApiKey {
            request.setValue(publishableApiKey, forHTTPHeaderField: "x-publishable-api-key")
        }

        return request
    }

    // MARK: - Request Execution with Auth + Retry

    private func executeWithRetry<T: Decodable>(
        _ request: URLRequest,
        endpoint: any Endpoint
    ) async throws -> T {
        var mutableRequest = request

        // Inject auth token if required
        if endpoint.requiresAuth {
            if let token = await tokenProvider.getAccessToken() {
                mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        // First attempt
        let (data, response) = try await performRequest(mutableRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.unknown(message: "Invalid response type")
        }

        let statusCode = httpResponse.statusCode

        // Success
        if Self.httpSuccessRange.contains(statusCode) {
            return try decodeResponse(data)
        }

        // 401 - Attempt token refresh and retry once
        if statusCode == Self.httpUnauthorized && endpoint.requiresAuth {
            return try await handleUnauthorized(
                originalRequest: request,
                endpoint: endpoint,
                failedToken: mutableRequest.value(forHTTPHeaderField: "Authorization")?
                    .replacingOccurrences(of: "Bearer ", with: "")
            )
        }

        // 5xx - Retry with exponential backoff
        if retryPolicy.isRetryable(statusCode: statusCode) {
            return try await retryRequest(
                mutableRequest,
                endpoint: endpoint,
                lastStatusCode: statusCode,
                lastData: data
            )
        }

        // Other errors (4xx, etc.) - Map to AppError
        throw mapError(statusCode: statusCode, data: data)
    }

    // MARK: - Perform Request

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        #if DEBUG
        RequestLogger.logRequest(request)
        let startTime = CFAbsoluteTimeGetCurrent()
        #endif

        do {
            let (data, response) = try await session.data(for: request)

            #if DEBUG
            if let httpResponse = response as? HTTPURLResponse {
                let duration = CFAbsoluteTimeGetCurrent() - startTime
                RequestLogger.logResponse(httpResponse, data: data, duration: duration)
            }
            #endif

            return (data, response)
        } catch let urlError as URLError {
            #if DEBUG
            RequestLogger.logError(urlError, url: request.url?.absoluteString)
            #endif
            throw mapURLError(urlError)
        } catch {
            #if DEBUG
            RequestLogger.logError(error, url: request.url?.absoluteString)
            #endif
            throw AppError.unknown(message: error.localizedDescription)
        }
    }

    // MARK: - Token Refresh

    private func handleUnauthorized<T: Decodable>(
        originalRequest: URLRequest,
        endpoint: any Endpoint,
        failedToken: String?
    ) async throws -> T {
        do {
            guard let newToken = try await tokenRefreshActor.refreshIfNeeded(failedToken: failedToken) else {
                await tokenProvider.clearTokens()
                throw AppError.unauthorized()
            }

            // Retry with new token
            var retryRequest = originalRequest
            retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await performRequest(retryRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.unknown(message: "Invalid response type")
            }

            if Self.httpSuccessRange.contains(httpResponse.statusCode) {
                return try decodeResponse(data)
            }

            throw mapError(statusCode: httpResponse.statusCode, data: data)
        } catch let error as AppError {
            throw error
        } catch {
            await tokenProvider.clearTokens()
            throw AppError.unauthorized()
        }
    }

    // MARK: - Retry Logic

    private func retryRequest<T: Decodable>(
        _ request: URLRequest,
        endpoint: any Endpoint,
        lastStatusCode: Int,
        lastData: Data
    ) async throws -> T {
        var latestStatusCode = lastStatusCode
        var latestData = lastData

        for attempt in 0 ..< retryPolicy.maxRetries {
            let delay = retryPolicy.delay(forAttempt: attempt)
            try await Task.sleep(nanoseconds: UInt64(delay * Double(Self.nanosecondsPerSecond)))

            let (data, response) = try await performRequest(request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.unknown(message: "Invalid response type")
            }

            let statusCode = httpResponse.statusCode

            // Success
            if Self.httpSuccessRange.contains(statusCode) {
                return try decodeResponse(data)
            }

            // 401 during retry - handle token refresh
            if statusCode == Self.httpUnauthorized && endpoint.requiresAuth {
                return try await handleUnauthorized(
                    originalRequest: request,
                    endpoint: endpoint,
                    failedToken: request.value(forHTTPHeaderField: "Authorization")?
                        .replacingOccurrences(of: "Bearer ", with: "")
                )
            }

            // Non-retryable error during retry
            if !retryPolicy.isRetryable(statusCode: statusCode) {
                throw mapError(statusCode: statusCode, data: data)
            }

            latestStatusCode = statusCode
            latestData = data
        }

        // All retries exhausted
        throw mapError(statusCode: latestStatusCode, data: latestData)
    }

    // MARK: - Response Decoding

    private func decodeResponse<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try JSONDecoder.api.decode(T.self, from: data)
        } catch {
            throw AppError.unknown(message: "Failed to parse response")
        }
    }

    // MARK: - Error Mapping

    private func mapError(statusCode: Int, data: Data) -> AppError {
        let medusaError = try? JSONDecoder.api.decode(MedusaErrorDTO.self, from: data)

        switch statusCode {
        case Self.httpUnauthorized:
            return .unauthorized(message: medusaError?.message ?? "Unauthorized")

        case Self.httpForbidden:
            return .unauthorized(message: medusaError?.message ?? "Access denied")

        case Self.httpNotFound:
            return .notFound(message: medusaError?.message ?? "Not found")

        case Self.httpTooManyRequests:
            return .server(
                code: Self.httpTooManyRequests,
                message: medusaError?.message ?? "Too many requests. Please try again later."
            )

        case Self.httpClientErrorRange:
            return .server(code: statusCode, message: medusaError?.message ?? "Request error")

        case Self.httpServerErrorRange:
            return .server(code: statusCode, message: medusaError?.message ?? "Server error")

        default:
            return .unknown(message: medusaError?.message ?? "Unexpected error")
        }
    }

    private func mapURLError(_ error: URLError) -> AppError {
        switch error.code {
        case .notConnectedToInternet,
            .networkConnectionLost,
            .cannotFindHost,
            .cannotConnectToHost,
            .dnsLookupFailed,
            .timedOut:
            return .network(message: error.localizedDescription)

        default:
            return .network(message: error.localizedDescription)
        }
    }
}

// MARK: - AnyEncodable

/// Type-erasing wrapper for encoding `any Encodable` values.
private struct AnyEncodable: Encodable {
    // MARK: - Lifecycle

    init(_ value: any Encodable) {
        self.value = value
    }

    // MARK: - Internal

    func encode(to encoder: any Encoder) throws {
        try value.encode(to: encoder)
    }

    // MARK: - Private

    private let value: any Encodable
}
