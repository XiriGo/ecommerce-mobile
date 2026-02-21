import Foundation

// MARK: - AuthTokenResponse

struct AuthTokenResponse: Decodable, Sendable {
    let token: String
}
