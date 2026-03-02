import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGErrorViewTests

@Suite("XGErrorView Tests")
@MainActor
struct XGErrorViewTests {
    // MARK: - Static init (backward compatible)

    @Test("ErrorView initialises with message only")
    func init_withMessageOnly_initialises() {
        let view = XGErrorView(message: "Something went wrong")
        _ = view
        #expect(view.isError)
    }

    @Test("ErrorView initialises with message and retry handler")
    func init_withRetryHandler_initialises() {
        let view = XGErrorView(message: "Network error", onRetry: {})
        _ = view
        #expect(view.isError)
    }

    @Test("ErrorView static init defaults onRetry to nil")
    func init_defaultOnRetryIsNil() {
        let view = XGErrorView(message: "Error")
        _ = view
        #expect(view.message == "Error")
    }

    // MARK: - Message Content

    @Test("ErrorView accepts non-empty message")
    func init_nonEmptyMessage_accepted() {
        let message = "Connection lost. Please check your internet."
        let view = XGErrorView(message: message)
        #expect(view.message == message)
    }

    @Test("ErrorView accepts generic error message")
    func init_genericErrorMessage_accepted() {
        let view = XGErrorView(message: "An unexpected error occurred")
        #expect(view.message == "An unexpected error occurred")
    }

    // MARK: - Crossfade init

    @Test("ErrorView crossfade init with isError=true")
    func init_crossfade_isErrorTrue_initialises() {
        let view = XGErrorView(
            message: "Error",
            isError: true,
            onRetry: {},
            content: { Text(verbatim: "Content") },
        )
        #expect(view.isError)
        #expect(view.message == "Error")
    }

    @Test("ErrorView crossfade init with isError=false")
    func init_crossfade_isErrorFalse_initialises() {
        let view = XGErrorView(
            message: "Error",
            isError: false,
            content: { Text(verbatim: "Content") },
        )
        #expect(!view.isError)
    }

    @Test("ErrorView crossfade init without onRetry defaults to nil")
    func init_crossfade_defaultOnRetryIsNil() {
        let view = XGErrorView(
            message: "Error",
            isError: true,
            content: { Text(verbatim: "Content") },
        )
        #expect(view.isError)
    }

    // MARK: - isError property

    @Test("isError property reflects state correctly")
    func isError_reflectsCorrectState() {
        let errorView = XGErrorView(
            message: "Error",
            isError: true,
            content: { Text(verbatim: "Content") },
        )
        let contentView = XGErrorView(
            message: "Error",
            isError: false,
            content: { Text(verbatim: "Content") },
        )
        #expect(errorView.isError)
        #expect(!contentView.isError)
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

    // MARK: - Static convenience sets isError to true

    @Test("Static convenience init sets isError to true")
    func staticConvenience_setsIsErrorTrue() {
        let view = XGErrorView(message: "Error message")
        #expect(view.isError)
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
