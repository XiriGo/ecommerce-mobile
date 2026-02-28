import Foundation

import os

// MARK: - SessionManager

/// Coordinates end-to-end auth flows by combining API calls, token storage,
/// and auth state management. Conforms to `TokenProvider` so the network
/// layer can use it for auth header injection and token refresh.
final class SessionManager: TokenProvider, @unchecked Sendable {
    // MARK: - Lifecycle

    init(
        apiClient: APIClient,
        tokenStorage: TokenStorage,
        authStateManager: AuthStateManagerImpl
    ) {
        self.apiClient = apiClient
        self.tokenStorage = tokenStorage
        self.authStateManager = authStateManager
    }

    // MARK: - Internal

    /// Full login flow: authenticate, save token, create session, update state.
    func login(email: String, password: String) async throws {
        let response: AuthTokenResponse = try await apiClient.request(
            AuthEndpoint.login(email: email, password: password)
        )

        guard !response.token.isEmpty else {
            throw AppError.unknown(message: "Empty token received")
        }

        tokenStorage.saveAccessToken(response.token)
        await createSessionSilently(token: response.token)
        await authStateManager.onLoginSuccess(token: response.token)
    }

    /// Full registration flow: register, save token, create session, update state.
    func register(email: String, password: String) async throws {
        let response: AuthTokenResponse = try await apiClient.request(
            AuthEndpoint.register(email: email, password: password)
        )

        guard !response.token.isEmpty else {
            throw AppError.unknown(message: "Empty token received")
        }

        tokenStorage.saveAccessToken(response.token)
        await createSessionSilently(token: response.token)
        await authStateManager.onLoginSuccess(token: response.token)
    }

    /// Full logout flow: destroy session (fire-and-forget), clear local state.
    func logout() async {
        await destroySessionSilently()
        await authStateManager.onLogout()
    }

    // MARK: - TokenProvider

    func getAccessToken() async -> String? {
        tokenStorage.getAccessToken()
    }

    func refreshToken() async throws -> String? {
        try await refreshActor.refresh { [apiClient, tokenStorage, authStateManager] in
            let response: AuthTokenResponse = try await apiClient.request(
                AuthEndpoint.refreshToken
            )

            guard !response.token.isEmpty else {
                throw AppError.unknown(message: "Empty token received from refresh")
            }

            tokenStorage.saveAccessToken(response.token)
            await authStateManager.onLoginSuccess(token: response.token)
            return response.token
        }
    }

    func clearTokens() async {
        await authStateManager.onLogout()
    }

    // MARK: - Private

    private let apiClient: APIClient
    private let tokenStorage: TokenStorage
    private let authStateManager: AuthStateManagerImpl
    private let refreshActor = RefreshActor()
    private static let logger = Logger(
        subsystem: "com.xirigo.ecommerce",
        category: "Auth"
    )

    /// Creates a session on the server. Failure is logged but does not
    /// propagate -- the token is already valid at this point.
    private func createSessionSilently(token: String) async {
        do {
            let _: EmptyResponse = try await apiClient.request(
                AuthEndpoint.createSession
            )
        } catch {
            Self.logger.warning("Session creation failed (non-blocking): \(error.localizedDescription)")
        }
    }

    /// Destroys the server session. Fire-and-forget -- logout always
    /// succeeds locally regardless of API result.
    private func destroySessionSilently() async {
        do {
            let _: EmptyResponse = try await apiClient.request(
                AuthEndpoint.destroySession
            )
        } catch {
            Self.logger.warning("Session destruction failed (non-blocking): \(error.localizedDescription)")
        }
    }
}

// MARK: - EmptyResponse

/// Decodable type for API endpoints that return empty or minimal JSON bodies.
private struct EmptyResponse: Decodable {}

// MARK: - RefreshActor

/// Serializes token refresh calls so only one refresh is in-flight at a time.
private actor RefreshActor {
    private var activeTask: Task<String?, Error>?

    func refresh(using operation: @Sendable @escaping () async throws -> String?) async throws -> String? {
        if let activeTask {
            return try await activeTask.value
        }

        let task = Task<String?, Error> {
            defer { activeTask = nil }
            return try await operation()
        }

        activeTask = task
        return try await task.value
    }
}
