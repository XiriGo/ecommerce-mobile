import Foundation

// MARK: - AuthEndpoint

enum AuthEndpoint: Endpoint {
    case login(email: String, password: String)
    case register(email: String, password: String)
    case createSession
    case destroySession
    case refreshToken

    // MARK: - Endpoint

    var path: String {
        switch self {
        case .login:
            "/auth/customer/emailpass"
        case .register:
            "/auth/customer/emailpass/register"
        case .createSession:
            "/auth/session"
        case .destroySession:
            "/auth/session"
        case .refreshToken:
            "/auth/token/refresh"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .register, .createSession, .refreshToken:
            .post
        case .destroySession:
            .delete
        }
    }

    var body: (any Encodable & Sendable)? {
        switch self {
        case let .login(email, password):
            LoginRequest(email: email, password: password)
        case let .register(email, password):
            RegisterRequest(email: email, password: password)
        case .createSession, .destroySession, .refreshToken:
            nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login, .register:
            false
        case .createSession, .destroySession, .refreshToken:
            true
        }
    }
}
