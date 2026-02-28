import Foundation

// MARK: - AuthStateManagerImpl

@MainActor
@Observable
final class AuthStateManagerImpl: AuthStateManager, @unchecked Sendable {
    // MARK: - Lifecycle

    nonisolated init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
    }

    // MARK: - AuthStateManager

    private(set) var authState: AuthState = .loading

    func onLoginSuccess(token: String) {
        tokenStorage.saveAccessToken(token)
        authState = .authenticated(token: token)
    }

    func onLogout() {
        tokenStorage.clearTokens()
        authState = .guest
    }

    func checkStoredToken() async {
        guard let token = tokenStorage.getAccessToken() else {
            authState = .guest
            return
        }
        authState = .authenticated(token: token)
    }

    // MARK: - Private

    @ObservationIgnored private let tokenStorage: TokenStorage
}
