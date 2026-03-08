import Foundation

// MARK: - RetryPolicy

struct RetryPolicy {
    // MARK: - Internal

    static let `default` = Self(
        maxRetries: defaultMaxRetries,
        baseDelay: defaultBaseDelay,
        backoffMultiplier: defaultBackoffMultiplier,
        maxDelay: defaultMaxDelay,
        jitterFactor: defaultJitterFactor,
        retryableStatusCodes: defaultRetryableStatusCodes,
    )

    let maxRetries: Int
    let baseDelay: TimeInterval
    let backoffMultiplier: Double
    let maxDelay: TimeInterval
    let jitterFactor: Double
    let retryableStatusCodes: Set<Int>

    func delay(forAttempt attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(backoffMultiplier, Double(attempt))
        let clampedDelay = min(exponentialDelay, maxDelay)
        let jitter = clampedDelay * Double.random(in: -jitterFactor ... jitterFactor)
        return clampedDelay + jitter
    }

    func isRetryable(statusCode: Int) -> Bool {
        retryableStatusCodes.contains(statusCode)
    }

    // MARK: - Private

    // MARK: - Default Constants

    private static let defaultMaxRetries = 3
    private static let defaultBaseDelay: TimeInterval = 1.0
    private static let defaultBackoffMultiplier: Double = 2.0
    private static let defaultMaxDelay: TimeInterval = 8.0
    private static let defaultJitterFactor: Double = 0.2
    private static let httpInternalServerError = 500
    private static let httpBadGateway = 502
    private static let httpServiceUnavailable = 503
    private static let httpGatewayTimeout = 504
    private static let defaultRetryableStatusCodes: Set<Int> = [
        httpInternalServerError, httpBadGateway, httpServiceUnavailable, httpGatewayTimeout,
    ]
}
