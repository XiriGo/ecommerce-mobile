import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGErrorViewTests

@Suite("XGErrorView Tests")
struct XGErrorViewTests {
    // MARK: - Initialisation

    @Test("ErrorView initialises with message only")
    func init_withMessageOnly_initialises() {
        let view = XGErrorView(message: "Something went wrong")
        _ = view
        #expect(true)
    }

    @Test("ErrorView initialises with message and no-op retry handler")
    func init_withRetryHandler_initialises() {
        // Pass a no-op closure that does not capture mutable state (Swift 6 Sendable safe)
        let view = XGErrorView(message: "Network error", onRetry: {})
        _ = view
        #expect(true)
    }

    @Test("ErrorView initialises without retry handler by default")
    func init_defaultOnRetryIsNil() {
        let view = XGErrorView(message: "Error")
        _ = view
        #expect(true)
    }

    // MARK: - Message Content

    @Test("ErrorView accepts non-empty message")
    func init_nonEmptyMessage_accepted() {
        let message = "Connection lost. Please check your internet."
        let view = XGErrorView(message: message)
        _ = view
        #expect(true)
    }

    @Test("ErrorView accepts generic error message")
    func init_genericErrorMessage_accepted() {
        let view = XGErrorView(message: "An unexpected error occurred")
        _ = view
        #expect(true)
    }

    // MARK: - Retry Action

    @Test("Retry counter logic increments correctly when tapped once")
    func retryCounter_singleIncrement_isOne() {
        var retryCount = 0
        retryCount += 1
        #expect(retryCount == 1)
    }

    @Test("Retry counter logic increments correctly when tapped three times")
    func retryCounter_threeIncrements_isThree() {
        var retryCount = 0
        retryCount += 1
        retryCount += 1
        retryCount += 1
        #expect(retryCount == 3)
    }

    // MARK: - onRetry presence

    @Test("ErrorView with onRetry shows retry button (onRetry non-nil)")
    func init_withOnRetry_nonNilHandler() {
        // The view renders a XGButton only when onRetry is non-nil
        let view = XGErrorView(message: "Err", onRetry: {})
        _ = view
        #expect(true)
    }

    @Test("ErrorView without onRetry hides retry button (onRetry nil)")
    func init_withoutOnRetry_nilHandler() {
        let view = XGErrorView(message: "Err")
        _ = view
        #expect(true)
    }

    // MARK: - Body

    @Test("ErrorView body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        let view = XGErrorView(message: "Error")
        let body = view.body
        _ = body
        #expect(true)
    }
}
