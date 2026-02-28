import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - RetryPolicyTests

@Suite("RetryPolicy Tests")
struct RetryPolicyTests {
    // MARK: - Default Values

    @Test("default policy has maxRetries of 3")
    func test_defaultPolicy_maxRetries_isThree() {
        #expect(RetryPolicy.default.maxRetries == 3)
    }

    @Test("default policy has baseDelay of 1.0")
    func test_defaultPolicy_baseDelay_isOneSecond() {
        #expect(RetryPolicy.default.baseDelay == 1.0)
    }

    @Test("default policy has backoffMultiplier of 2.0")
    func test_defaultPolicy_backoffMultiplier_isTwo() {
        #expect(RetryPolicy.default.backoffMultiplier == 2.0)
    }

    @Test("default policy has maxDelay of 8.0")
    func test_defaultPolicy_maxDelay_isEightSeconds() {
        #expect(RetryPolicy.default.maxDelay == 8.0)
    }

    @Test("default policy has jitterFactor of 0.2")
    func test_defaultPolicy_jitterFactor_isTwentyPercent() {
        #expect(RetryPolicy.default.jitterFactor == 0.2)
    }

    @Test("default policy retryable status codes are 500 502 503 504")
    func test_defaultPolicy_retryableStatusCodes_containsExpected() {
        let codes = RetryPolicy.default.retryableStatusCodes
        #expect(codes.contains(500))
        #expect(codes.contains(502))
        #expect(codes.contains(503))
        #expect(codes.contains(504))
        #expect(codes.count == 4)
    }

    // MARK: - isRetryable

    @Test("isRetryable returns true for 500")
    func test_isRetryable_500_returnsTrue() {
        #expect(RetryPolicy.default.isRetryable(statusCode: 500))
    }

    @Test("isRetryable returns true for 502")
    func test_isRetryable_502_returnsTrue() {
        #expect(RetryPolicy.default.isRetryable(statusCode: 502))
    }

    @Test("isRetryable returns true for 503")
    func test_isRetryable_503_returnsTrue() {
        #expect(RetryPolicy.default.isRetryable(statusCode: 503))
    }

    @Test("isRetryable returns true for 504")
    func test_isRetryable_504_returnsTrue() {
        #expect(RetryPolicy.default.isRetryable(statusCode: 504))
    }

    @Test("isRetryable returns false for 400")
    func test_isRetryable_400_returnsFalse() {
        #expect(!RetryPolicy.default.isRetryable(statusCode: 400))
    }

    @Test("isRetryable returns false for 401")
    func test_isRetryable_401_returnsFalse() {
        #expect(!RetryPolicy.default.isRetryable(statusCode: 401))
    }

    @Test("isRetryable returns false for 403")
    func test_isRetryable_403_returnsFalse() {
        #expect(!RetryPolicy.default.isRetryable(statusCode: 403))
    }

    @Test("isRetryable returns false for 404")
    func test_isRetryable_404_returnsFalse() {
        #expect(!RetryPolicy.default.isRetryable(statusCode: 404))
    }

    @Test("isRetryable returns false for 422")
    func test_isRetryable_422_returnsFalse() {
        #expect(!RetryPolicy.default.isRetryable(statusCode: 422))
    }

    @Test("isRetryable returns false for 429")
    func test_isRetryable_429_returnsFalse() {
        #expect(!RetryPolicy.default.isRetryable(statusCode: 429))
    }

    @Test("isRetryable returns false for 200")
    func test_isRetryable_200_returnsFalse() {
        #expect(!RetryPolicy.default.isRetryable(statusCode: 200))
    }

    @Test("isRetryable returns false for 501")
    func test_isRetryable_501_notInDefaultSet_returnsFalse() {
        #expect(!RetryPolicy.default.isRetryable(statusCode: 501))
    }

    // MARK: - Delay Calculation

    @Test("delay for attempt 0 is within jitter bounds of base delay")
    func test_delay_attempt0_isWithinBaseDelayJitterBounds() {
        let policy = RetryPolicy.default
        // attempt=0: exponential = 1.0 * 2^0 = 1.0, clamped = 1.0, jitter range ±20% = [0.8, 1.2]
        let minDelay = 1.0 * (1.0 - policy.jitterFactor)
        let maxDelayBound = 1.0 * (1.0 + policy.jitterFactor)
        for _ in 0 ..< 20 {
            let delay = policy.delay(forAttempt: 0)
            #expect(delay >= minDelay, "Delay \(delay) is below minimum \(minDelay)")
            #expect(delay <= maxDelayBound, "Delay \(delay) exceeds maximum \(maxDelayBound)")
        }
    }

    @Test("delay for attempt 1 is within jitter bounds of 2s")
    func test_delay_attempt1_isWithinTwoSecondJitterBounds() {
        let policy = RetryPolicy.default
        // attempt=1: exponential = 1.0 * 2^1 = 2.0, clamped = 2.0, jitter range ±20% = [1.6, 2.4]
        let minDelay = 2.0 * (1.0 - policy.jitterFactor)
        let maxDelayBound = 2.0 * (1.0 + policy.jitterFactor)
        for _ in 0 ..< 20 {
            let delay = policy.delay(forAttempt: 1)
            #expect(delay >= minDelay, "Delay \(delay) is below minimum \(minDelay)")
            #expect(delay <= maxDelayBound, "Delay \(delay) exceeds maximum \(maxDelayBound)")
        }
    }

    @Test("delay for attempt 2 is within jitter bounds of 4s")
    func test_delay_attempt2_isWithinFourSecondJitterBounds() {
        let policy = RetryPolicy.default
        // attempt=2: exponential = 1.0 * 2^2 = 4.0, clamped = 4.0, jitter range ±20% = [3.2, 4.8]
        let minDelay = 4.0 * (1.0 - policy.jitterFactor)
        let maxDelayBound = 4.0 * (1.0 + policy.jitterFactor)
        for _ in 0 ..< 20 {
            let delay = policy.delay(forAttempt: 2)
            #expect(delay >= minDelay, "Delay \(delay) is below minimum \(minDelay)")
            #expect(delay <= maxDelayBound, "Delay \(delay) exceeds maximum \(maxDelayBound)")
        }
    }

    @Test("delay is clamped at maxDelay even for large attempt numbers")
    func test_delay_largeAttempt_isClampedAtMaxDelay() {
        let policy = RetryPolicy.default
        // attempt=10: exponential = 1.0 * 2^10 = 1024, clamped to 8.0, jitter ±20% = [6.4, 9.6]
        let maxDelayWithJitter = policy.maxDelay * (1.0 + policy.jitterFactor)
        for _ in 0 ..< 20 {
            let delay = policy.delay(forAttempt: 10)
            #expect(delay <= maxDelayWithJitter, "Delay \(delay) exceeds clamped maximum \(maxDelayWithJitter)")
        }
    }

    @Test("delay is always positive")
    func test_delay_allAttempts_isPositive() {
        let policy = RetryPolicy.default
        for attempt in 0 ..< 10 {
            for _ in 0 ..< 5 {
                let delay = policy.delay(forAttempt: attempt)
                #expect(delay > 0, "Delay for attempt \(attempt) must be positive, got \(delay)")
            }
        }
    }

    @Test("delay for attempt 0 with zero jitter equals baseDelay")
    func test_delay_zeroJitter_attempt0_equalsBaseDelay() {
        let policy = RetryPolicy(
            maxRetries: 3,
            baseDelay: 1.0,
            backoffMultiplier: 2.0,
            maxDelay: 8.0,
            jitterFactor: 0.0,
            retryableStatusCodes: [500]
        )
        let delay = policy.delay(forAttempt: 0)
        #expect(delay == 1.0)
    }

    @Test("delay for attempt 1 with zero jitter equals 2x base")
    func test_delay_zeroJitter_attempt1_equalsTwoTimesBase() {
        let policy = RetryPolicy(
            maxRetries: 3,
            baseDelay: 1.0,
            backoffMultiplier: 2.0,
            maxDelay: 8.0,
            jitterFactor: 0.0,
            retryableStatusCodes: [500]
        )
        let delay = policy.delay(forAttempt: 1)
        #expect(delay == 2.0)
    }

    @Test("delay for attempt 2 with zero jitter equals 4x base")
    func test_delay_zeroJitter_attempt2_equalsFourTimesBase() {
        let policy = RetryPolicy(
            maxRetries: 3,
            baseDelay: 1.0,
            backoffMultiplier: 2.0,
            maxDelay: 8.0,
            jitterFactor: 0.0,
            retryableStatusCodes: [500]
        )
        let delay = policy.delay(forAttempt: 2)
        #expect(delay == 4.0)
    }

    @Test("delay is clamped at maxDelay with zero jitter")
    func test_delay_zeroJitter_highAttempt_isClampedAtMaxDelay() {
        let policy = RetryPolicy(
            maxRetries: 3,
            baseDelay: 1.0,
            backoffMultiplier: 2.0,
            maxDelay: 8.0,
            jitterFactor: 0.0,
            retryableStatusCodes: [500]
        )
        let delay = policy.delay(forAttempt: 10)
        #expect(delay == 8.0)
    }

    // MARK: - Custom Policy

    @Test("custom policy with custom status codes respects those codes only")
    func test_customPolicy_customStatusCodes_onlyThoseAreRetryable() {
        let policy = RetryPolicy(
            maxRetries: 2,
            baseDelay: 0.5,
            backoffMultiplier: 3.0,
            maxDelay: 5.0,
            jitterFactor: 0.1,
            retryableStatusCodes: [500, 503]
        )
        #expect(policy.isRetryable(statusCode: 500))
        #expect(policy.isRetryable(statusCode: 503))
        #expect(!policy.isRetryable(statusCode: 502))
        #expect(!policy.isRetryable(statusCode: 504))
    }
}
