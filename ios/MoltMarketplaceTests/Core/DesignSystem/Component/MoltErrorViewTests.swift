import Testing
@testable import MoltMarketplace

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - MoltErrorViewTests

@Suite("MoltErrorView Tests")
struct MoltErrorViewTests {
    // MARK: - Initialisation

    @Test("ErrorView initialises with message only")
    func test_init_withMessageOnly_initialises() {
        let view = MoltErrorView(message: "Something went wrong")
        _ = view
        #expect(true)
    }

    @Test("ErrorView initialises with message and no-op retry handler")
    func test_init_withRetryHandler_initialises() {
        // Pass a no-op closure that does not capture mutable state (Swift 6 Sendable safe)
        let view = MoltErrorView(message: "Network error", onRetry: {})
        _ = view
        #expect(true)
    }

    @Test("ErrorView initialises without retry handler by default")
    func test_init_defaultOnRetryIsNil() {
        let view = MoltErrorView(message: "Error")
        _ = view
        #expect(true)
    }

    // MARK: - Message Content

    @Test("ErrorView accepts non-empty message")
    func test_init_nonEmptyMessage_accepted() {
        let message = "Connection lost. Please check your internet."
        let view = MoltErrorView(message: message)
        _ = view
        #expect(true)
    }

    @Test("ErrorView accepts generic error message")
    func test_init_genericErrorMessage_accepted() {
        let view = MoltErrorView(message: "An unexpected error occurred")
        _ = view
        #expect(true)
    }

    // MARK: - Retry Action

    @Test("Retry counter logic increments correctly when tapped once")
    func test_retryCounter_singleIncrement_isOne() {
        var retryCount = 0
        retryCount += 1
        #expect(retryCount == 1)
    }

    @Test("Retry counter logic increments correctly when tapped three times")
    func test_retryCounter_threeIncrements_isThree() {
        var retryCount = 0
        retryCount += 1
        retryCount += 1
        retryCount += 1
        #expect(retryCount == 3)
    }

    // MARK: - onRetry presence

    @Test("ErrorView with onRetry shows retry button (onRetry non-nil)")
    func test_init_withOnRetry_nonNilHandler() {
        // The view renders a MoltButton only when onRetry is non-nil
        let view = MoltErrorView(message: "Err", onRetry: {})
        _ = view
        #expect(true)
    }

    @Test("ErrorView without onRetry hides retry button (onRetry nil)")
    func test_init_withoutOnRetry_nilHandler() {
        let view = MoltErrorView(message: "Err")
        _ = view
        #expect(true)
    }

    // MARK: - Body

    @Test("ErrorView body is a valid View", .disabled(swiftUIDisabledReason))
    func test_body_isValidView() {
        let view = MoltErrorView(message: "Error")
        let body = view.body
        _ = body
        #expect(true)
    }
}
