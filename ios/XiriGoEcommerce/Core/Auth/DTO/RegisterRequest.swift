import Foundation

// MARK: - RegisterRequest

struct RegisterRequest: Encodable {
    let email: String
    let password: String
}
