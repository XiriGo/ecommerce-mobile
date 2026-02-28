import Foundation

// MARK: - Endpoint

protocol Endpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
    var body: (any Encodable & Sendable)? { get }
    var requiresAuth: Bool { get }
}

// MARK: - Default Implementations

extension Endpoint {
    var headers: [String: String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: (any Encodable & Sendable)? { nil }
    var requiresAuth: Bool { false }
}
