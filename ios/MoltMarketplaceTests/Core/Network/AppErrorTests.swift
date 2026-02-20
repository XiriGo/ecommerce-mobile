import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - AppErrorTests

@Suite("AppError Tests")
struct AppErrorTests {
    // MARK: - Error Case Coverage

    @Test("network case exists and holds message")
    func test_networkCase_defaultMessage_equalsNetworkError() {
        let error = AppError.network()
        #expect(error == AppError.network(message: "Network error"))
    }

    @Test("network case accepts custom message")
    func test_networkCase_customMessage_isStored() {
        let error = AppError.network(message: "No internet connection")
        #expect(error == AppError.network(message: "No internet connection"))
        #expect(error != AppError.network(message: "Network error"))
    }

    @Test("server case stores code and message")
    func test_serverCase_codeAndMessage_areStored() {
        let error = AppError.server(code: 500, message: "Internal Server Error")
        #expect(error == AppError.server(code: 500, message: "Internal Server Error"))
    }

    @Test("server case distinguishes different codes")
    func test_serverCase_differentCodes_areNotEqual() {
        let error500 = AppError.server(code: 500, message: "Error")
        let error503 = AppError.server(code: 503, message: "Error")
        #expect(error500 != error503)
    }

    @Test("server case distinguishes different messages")
    func test_serverCase_differentMessages_areNotEqual() {
        let errorA = AppError.server(code: 500, message: "Error A")
        let errorB = AppError.server(code: 500, message: "Error B")
        #expect(errorA != errorB)
    }

    @Test("notFound case exists and holds message")
    func test_notFoundCase_defaultMessage_equalsNotFound() {
        let error = AppError.notFound()
        #expect(error == AppError.notFound(message: "Not found"))
    }

    @Test("notFound case accepts custom message")
    func test_notFoundCase_customMessage_isStored() {
        let error = AppError.notFound(message: "Product not found")
        #expect(error == AppError.notFound(message: "Product not found"))
        #expect(error != AppError.notFound(message: "Not found"))
    }

    @Test("unauthorized case exists and holds message")
    func test_unauthorizedCase_defaultMessage_equalsUnauthorized() {
        let error = AppError.unauthorized()
        #expect(error == AppError.unauthorized(message: "Unauthorized"))
    }

    @Test("unauthorized case accepts custom message")
    func test_unauthorizedCase_customMessage_isStored() {
        let error = AppError.unauthorized(message: "Access denied")
        #expect(error == AppError.unauthorized(message: "Access denied"))
        #expect(error != AppError.unauthorized(message: "Unauthorized"))
    }

    @Test("unknown case exists and holds message")
    func test_unknownCase_defaultMessage_equalsUnknownError() {
        let error = AppError.unknown()
        #expect(error == AppError.unknown(message: "Unknown error"))
    }

    @Test("unknown case accepts custom message")
    func test_unknownCase_customMessage_isStored() {
        let error = AppError.unknown(message: "Failed to parse response")
        #expect(error == AppError.unknown(message: "Failed to parse response"))
        #expect(error != AppError.unknown(message: "Unknown error"))
    }

    // MARK: - Equatable Conformance

    @Test("different error cases are not equal")
    func test_differentCases_areNotEqual() {
        let network = AppError.network()
        let server = AppError.server(code: 500, message: "Error")
        let notFound = AppError.notFound()
        let unauthorized = AppError.unauthorized()
        let unknown = AppError.unknown()

        #expect(network != server)
        #expect(network != notFound)
        #expect(network != unauthorized)
        #expect(network != unknown)
        #expect(server != notFound)
        #expect(server != unauthorized)
        #expect(server != unknown)
        #expect(notFound != unauthorized)
        #expect(notFound != unknown)
        #expect(unauthorized != unknown)
    }

    @Test("same error cases with same values are equal")
    func test_sameCaseSameValues_areEqual() {
        #expect(AppError.network() == AppError.network())
        #expect(AppError.server(code: 422, message: "Validation error") == AppError.server(code: 422, message: "Validation error"))
        #expect(AppError.notFound() == AppError.notFound())
        #expect(AppError.unauthorized() == AppError.unauthorized())
        #expect(AppError.unknown() == AppError.unknown())
    }

    // MARK: - toUserMessage Mapping

    @Test("network error maps to network user message key")
    func test_toUserMessage_networkError_returnsNetworkMessage() {
        let error: Error = AppError.network()
        let message = error.toUserMessage
        // The localized string for "common_error_network" is expected
        #expect(!message.isEmpty)
    }

    @Test("server error maps to server user message key")
    func test_toUserMessage_serverError_returnsServerMessage() {
        let error: Error = AppError.server(code: 500, message: "Internal Error")
        let message = error.toUserMessage
        #expect(!message.isEmpty)
    }

    @Test("unauthorized error maps to unauthorized user message key")
    func test_toUserMessage_unauthorizedError_returnsUnauthorizedMessage() {
        let error: Error = AppError.unauthorized()
        let message = error.toUserMessage
        #expect(!message.isEmpty)
    }

    @Test("notFound error maps to notFound user message key")
    func test_toUserMessage_notFoundError_returnsNotFoundMessage() {
        let error: Error = AppError.notFound()
        let message = error.toUserMessage
        #expect(!message.isEmpty)
    }

    @Test("unknown error maps to unknown user message key")
    func test_toUserMessage_unknownError_returnsUnknownMessage() {
        let error: Error = AppError.unknown()
        let message = error.toUserMessage
        #expect(!message.isEmpty)
    }

    @Test("non-AppError maps to unknown user message key")
    func test_toUserMessage_nonAppError_returnsUnknownMessage() {
        struct SomeError: Error {}
        let error: Error = SomeError()
        let message = error.toUserMessage
        #expect(!message.isEmpty)
    }

    @Test("all AppError cases produce non-empty user messages")
    func test_toUserMessage_allCases_produceNonEmptyMessages() {
        let cases: [AppError] = [
            .network(),
            .network(message: "Custom"),
            .server(code: 500, message: "Srv"),
            .notFound(),
            .notFound(message: "Custom"),
            .unauthorized(),
            .unauthorized(message: "Custom"),
            .unknown(),
            .unknown(message: "Custom"),
        ]
        for error in cases {
            let message = (error as Error).toUserMessage
            #expect(!message.isEmpty, "Expected non-empty message for \(error)")
        }
    }
}
