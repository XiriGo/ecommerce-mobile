import Foundation

// MARK: - LoginRequest

struct LoginRequest: Encodable {
    let email: String
    let password: String
}
