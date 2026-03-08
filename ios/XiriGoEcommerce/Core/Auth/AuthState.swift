import Foundation

// MARK: - AuthState

enum AuthState: Equatable {
    case loading
    case authenticated(token: String)
    case guest
}
