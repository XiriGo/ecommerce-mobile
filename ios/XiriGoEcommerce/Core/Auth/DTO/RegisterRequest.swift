import Foundation

// MARK: - RegisterRequest

struct RegisterRequest: Encodable, Sendable {
    let email: String
    let password: String
}
