import Foundation

// MARK: - TokenRefreshActor

/// Serializes concurrent token refresh attempts using Swift actor isolation.
/// When multiple requests receive 401 simultaneously, only one refresh is
/// performed; the others wait and reuse the new token.
actor TokenRefreshActor {
    // MARK: - Lifecycle

    init(tokenProvider: any TokenProvider) {
        self.tokenProvider = tokenProvider
    }

    // MARK: - Internal

    /// Attempts to refresh the token. If a refresh is already in progress,
    /// waits for that result instead of triggering a second refresh.
    ///
    /// - Parameter failedToken: The token that caused the 401. If the current
    ///   token differs (already refreshed by another request), the current
    ///   token is returned without a new refresh call.
    /// - Returns: The new access token, or nil if refresh failed.
    func refreshIfNeeded(failedToken: String?) async throws -> String? {
        // Check if token was already refreshed by another concurrent request
        let currentToken = await tokenProvider.getAccessToken()
        if let currentToken, currentToken != failedToken {
            return currentToken
        }

        // If a refresh is already in progress, wait for it
        if let activeTask = activeRefreshTask {
            return try await activeTask.value
        }

        // Start a new refresh
        let task = Task<String?, Error> {
            defer { activeRefreshTask = nil }
            do {
                let newToken = try await tokenProvider.refreshToken()
                return newToken
            } catch {
                await tokenProvider.clearTokens()
                throw error
            }
        }

        activeRefreshTask = task
        return try await task.value
    }

    // MARK: - Private

    private let tokenProvider: any TokenProvider
    private var activeRefreshTask: Task<String?, Error>?
}
