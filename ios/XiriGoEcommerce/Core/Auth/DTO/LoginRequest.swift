import Foundation

// MARK: - LoginRequest

struct LoginRequest: Encodable, Sendable {
    let email: String
    let password: String
}
