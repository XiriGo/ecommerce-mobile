import Foundation

// MARK: - RetryPolicy

struct RetryPolicy: Sendable {
    let maxRetries: Int
    let baseDelay: TimeInterval
    let backoffMultiplier: Double
    let maxDelay: TimeInterval
    let jitterFactor: Double
    let retryableStatusCodes: Set<Int>

    // MARK: - Internal

    static let `default` = RetryPolicy(
        maxRetries: 3,
        baseDelay: 1.0,
        backoffMultiplier: 2.0,
        maxDelay: 8.0,
        jitterFactor: 0.2,
        retryableStatusCodes: [500, 502, 503, 504]
    )

    func delay(forAttempt attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(backoffMultiplier, Double(attempt))
        let clampedDelay = min(exponentialDelay, maxDelay)
        let jitter = clampedDelay * Double.random(in: -jitterFactor ... jitterFactor)
        return clampedDelay + jitter
    }

    func isRetryable(statusCode: Int) -> Bool {
        retryableStatusCodes.contains(statusCode)
    }
}
