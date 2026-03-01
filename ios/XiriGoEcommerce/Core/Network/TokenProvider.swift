import Foundation

// MARK: - TokenProvider

/// Abstraction for auth token management. The concrete implementation
/// is provided by M0-06 (Auth Infrastructure). During M0-03, a no-op
/// placeholder is registered in the DI container.
protocol TokenProvider: Sendable {
    func getAccessToken() async -> String?
    func refreshToken() async throws -> String?
    func clearTokens() async
}

// MARK: - NoOpTokenProvider

/// Placeholder implementation that always returns nil. Replaced by the
/// real Keychain-backed implementation in M0-06.
final class NoOpTokenProvider: TokenProvider, @unchecked Sendable {
    func getAccessToken() async -> String? {
        nil
    }

    func refreshToken() async throws -> String? {
        nil
    }

    func clearTokens() async {}
}
