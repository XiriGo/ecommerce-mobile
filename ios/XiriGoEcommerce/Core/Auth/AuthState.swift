import Foundation

// MARK: - AuthState

enum AuthState: Equatable, Sendable {
    case loading
    case authenticated(token: String)
    case guest
}
