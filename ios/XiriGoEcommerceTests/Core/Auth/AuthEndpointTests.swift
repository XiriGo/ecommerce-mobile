import Foundation
import Testing
@testable import XiriGoEcommerce

// MARK: - AuthEndpointTests

@Suite("AuthEndpoint Tests")
struct AuthEndpointTests {
    @Test("login endpoint has correct path")
    func login_hasCorrectPath() {
        let endpoint = AuthEndpoint.login(email: "user@example.com", password: "pass123")
        #expect(endpoint.path == "/auth/customer/emailpass")
    }

    @Test("login endpoint uses POST method")
    func login_usesPostMethod() {
        let endpoint = AuthEndpoint.login(email: "user@example.com", password: "pass123")
        #expect(endpoint.method == .post)
    }

    @Test("login endpoint has non-nil body containing email and password")
    func login_hasBodyWithCredentials() {
        let endpoint = AuthEndpoint.login(email: "user@test.com", password: "secret")
        #expect(endpoint.body != nil)

        guard let loginRequest = endpoint.body as? LoginRequest else {
            Issue.record("Expected body to be LoginRequest")
            return
        }
        #expect(loginRequest.email == "user@test.com")
        #expect(loginRequest.password == "secret")
    }

    @Test("login endpoint does not require authentication")
    func login_doesNotRequireAuth() {
        let endpoint = AuthEndpoint.login(email: "user@example.com", password: "pass")
        #expect(endpoint.requiresAuth == false)
    }

    // MARK: - register

    @Test("register endpoint has correct path")
    func register_hasCorrectPath() {
        let endpoint = AuthEndpoint.register(email: "new@example.com", password: "pass123")
        #expect(endpoint.path == "/auth/customer/emailpass/register")
    }

    @Test("register endpoint uses POST method")
    func register_usesPostMethod() {
        let endpoint = AuthEndpoint.register(email: "new@example.com", password: "pass123")
        #expect(endpoint.method == .post)
    }

    @Test("register endpoint has non-nil body containing email and password")
    func register_hasBodyWithCredentials() {
        let endpoint = AuthEndpoint.register(email: "new@test.com", password: "mypassword")
        #expect(endpoint.body != nil)

        guard let registerRequest = endpoint.body as? RegisterRequest else {
            Issue.record("Expected body to be RegisterRequest")
            return
        }
        #expect(registerRequest.email == "new@test.com")
        #expect(registerRequest.password == "mypassword")
    }

    @Test("register endpoint does not require authentication")
    func register_doesNotRequireAuth() {
        let endpoint = AuthEndpoint.register(email: "new@example.com", password: "pass")
        #expect(endpoint.requiresAuth == false)
    }

    // MARK: - createSession

    @Test("createSession endpoint has correct path")
    func createSession_hasCorrectPath() {
        let endpoint = AuthEndpoint.createSession
        #expect(endpoint.path == "/auth/session")
    }

    @Test("createSession endpoint uses POST method")
    func createSession_usesPostMethod() {
        let endpoint = AuthEndpoint.createSession
        #expect(endpoint.method == .post)
    }

    @Test("createSession endpoint has nil body")
    func createSession_hasNilBody() {
        let endpoint = AuthEndpoint.createSession
        #expect(endpoint.body == nil)
    }

    @Test("createSession endpoint requires authentication")
    func createSession_requiresAuth() {
        let endpoint = AuthEndpoint.createSession
        #expect(endpoint.requiresAuth == true)
    }

    // MARK: - destroySession

    @Test("destroySession endpoint has correct path")
    func destroySession_hasCorrectPath() {
        let endpoint = AuthEndpoint.destroySession
        #expect(endpoint.path == "/auth/session")
    }

    @Test("destroySession endpoint uses DELETE method")
    func destroySession_usesDeleteMethod() {
        let endpoint = AuthEndpoint.destroySession
        #expect(endpoint.method == .delete)
    }

    @Test("destroySession endpoint has nil body")
    func destroySession_hasNilBody() {
        let endpoint = AuthEndpoint.destroySession
        #expect(endpoint.body == nil)
    }

    @Test("destroySession endpoint requires authentication")
    func destroySession_requiresAuth() {
        let endpoint = AuthEndpoint.destroySession
        #expect(endpoint.requiresAuth == true)
    }

    // MARK: - refreshToken

    @Test("refreshToken endpoint has correct path")
    func refreshToken_hasCorrectPath() {
        let endpoint = AuthEndpoint.refreshToken
        #expect(endpoint.path == "/auth/token/refresh")
    }

    @Test("refreshToken endpoint uses POST method")
    func refreshToken_usesPostMethod() {
        let endpoint = AuthEndpoint.refreshToken
        #expect(endpoint.method == .post)
    }

    @Test("refreshToken endpoint has nil body")
    func refreshToken_hasNilBody() {
        let endpoint = AuthEndpoint.refreshToken
        #expect(endpoint.body == nil)
    }

    @Test("refreshToken endpoint requires authentication")
    func refreshToken_requiresAuth() {
        let endpoint = AuthEndpoint.refreshToken
        #expect(endpoint.requiresAuth == true)
    }

    // MARK: - createSession vs destroySession path equality

    @Test("createSession and destroySession share same path but different methods")
    func createAndDestroySession_samePath_differentMethods() {
        let create = AuthEndpoint.createSession
        let destroy = AuthEndpoint.destroySession
        #expect(create.path == destroy.path)
        #expect(create.method != destroy.method)
    }

    // MARK: - Default header and queryItems

    @Test("all endpoints have empty headers by default")
    func allEndpoints_haveEmptyHeaders() {
        let endpoints: [AuthEndpoint] = [
            .login(email: "e@e.com", password: "p"),
            .register(email: "e@e.com", password: "p"),
            .createSession,
            .destroySession,
            .refreshToken,
        ]
        for endpoint in endpoints {
            #expect(endpoint.headers.isEmpty)
        }
    }

    @Test("all endpoints have empty queryItems by default")
    func allEndpoints_haveEmptyQueryItems() {
        let endpoints: [AuthEndpoint] = [
            .login(email: "e@e.com", password: "p"),
            .register(email: "e@e.com", password: "p"),
            .createSession,
            .destroySession,
            .refreshToken,
        ]
        for endpoint in endpoints {
            #expect(endpoint.queryItems.isEmpty)
        }
    }
}
