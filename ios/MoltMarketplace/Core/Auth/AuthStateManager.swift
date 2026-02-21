import Foundation

// MARK: - AuthStateManager

@MainActor
protocol AuthStateManager {
    var authState: AuthState { get }
    func onLoginSuccess(token: String)
    func onLogout()
    func checkStoredToken() async
}
