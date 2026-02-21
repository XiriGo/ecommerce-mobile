import Foundation

// MARK: - TokenStorage

protocol TokenStorage: Sendable {
    func getAccessToken() -> String?
    func saveAccessToken(_ token: String)
    func clearTokens()
}
