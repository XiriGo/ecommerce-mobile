import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - AuthEndpointTests

@Suite("AuthEndpoint Tests")
struct AuthEndpointTests {
    // MARK: - login

    @Test("login endpoint has correct path")
    func test_login_hasCorrectPath() {
        let endpoint = AuthEndpoint.login(email: "user@example.com", password: "pass123")
        #expect(endpoint.path == "/auth/customer/emailpass")
    }

    @Test("login endpoint uses POST method")
    func test_login_usesPostMethod() {
        let endpoint = AuthEndpoint.login(email: "user@example.com", password: "pass123")
        #expect(endpoint.method == .post)
    }

    @Test("login endpoint has non-nil body containing email and password")
    func test_login_hasBodyWithCredentials() throws {
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
    func test_login_doesNotRequireAuth() {
        let endpoint = AuthEndpoint.login(email: "user@example.com", password: "pass")
        #expect(endpoint.requiresAuth == false)
    }

    // MARK: - register

    @Test("register endpoint has correct path")
    func test_register_hasCorrectPath() {
        let endpoint = AuthEndpoint.register(email: "new@example.com", password: "pass123")
        #expect(endpoint.path == "/auth/customer/emailpass/register")
    }

    @Test("register endpoint uses POST method")
    func test_register_usesPostMethod() {
        let endpoint = AuthEndpoint.register(email: "new@example.com", password: "pass123")
        #expect(endpoint.method == .post)
    }

    @Test("register endpoint has non-nil body containing email and password")
    func test_register_hasBodyWithCredentials() throws {
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
    func test_register_doesNotRequireAuth() {
        let endpoint = AuthEndpoint.register(email: "new@example.com", password: "pass")
        #expect(endpoint.requiresAuth == false)
    }

    // MARK: - createSession

    @Test("createSession endpoint has correct path")
    func test_createSession_hasCorrectPath() {
        let endpoint = AuthEndpoint.createSession
        #expect(endpoint.path == "/auth/session")
    }

    @Test("createSession endpoint uses POST method")
    func test_createSession_usesPostMethod() {
        let endpoint = AuthEndpoint.createSession
        #expect(endpoint.method == .post)
    }

    @Test("createSession endpoint has nil body")
    func test_createSession_hasNilBody() {
        let endpoint = AuthEndpoint.createSession
        #expect(endpoint.body == nil)
    }

    @Test("createSession endpoint requires authentication")
    func test_createSession_requiresAuth() {
        let endpoint = AuthEndpoint.createSession
        #expect(endpoint.requiresAuth == true)
    }

    // MARK: - destroySession

    @Test("destroySession endpoint has correct path")
    func test_destroySession_hasCorrectPath() {
        let endpoint = AuthEndpoint.destroySession
        #expect(endpoint.path == "/auth/session")
    }

    @Test("destroySession endpoint uses DELETE method")
    func test_destroySession_usesDeleteMethod() {
        let endpoint = AuthEndpoint.destroySession
        #expect(endpoint.method == .delete)
    }

    @Test("destroySession endpoint has nil body")
    func test_destroySession_hasNilBody() {
        let endpoint = AuthEndpoint.destroySession
        #expect(endpoint.body == nil)
    }

    @Test("destroySession endpoint requires authentication")
    func test_destroySession_requiresAuth() {
        let endpoint = AuthEndpoint.destroySession
        #expect(endpoint.requiresAuth == true)
    }

    // MARK: - refreshToken

    @Test("refreshToken endpoint has correct path")
    func test_refreshToken_hasCorrectPath() {
        let endpoint = AuthEndpoint.refreshToken
        #expect(endpoint.path == "/auth/token/refresh")
    }

    @Test("refreshToken endpoint uses POST method")
    func test_refreshToken_usesPostMethod() {
        let endpoint = AuthEndpoint.refreshToken
        #expect(endpoint.method == .post)
    }

    @Test("refreshToken endpoint has nil body")
    func test_refreshToken_hasNilBody() {
        let endpoint = AuthEndpoint.refreshToken
        #expect(endpoint.body == nil)
    }

    @Test("refreshToken endpoint requires authentication")
    func test_refreshToken_requiresAuth() {
        let endpoint = AuthEndpoint.refreshToken
        #expect(endpoint.requiresAuth == true)
    }

    // MARK: - createSession vs destroySession path equality

    @Test("createSession and destroySession share same path but different methods")
    func test_createAndDestroySession_samePath_differentMethods() {
        let create = AuthEndpoint.createSession
        let destroy = AuthEndpoint.destroySession
        #expect(create.path == destroy.path)
        #expect(create.method != destroy.method)
    }

    // MARK: - Default header and queryItems

    @Test("all endpoints have empty headers by default")
    func test_allEndpoints_haveEmptyHeaders() {
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

    @Test("all endpoints have nil queryItems by default")
    func test_allEndpoints_haveNilQueryItems() {
        let endpoints: [AuthEndpoint] = [
            .login(email: "e@e.com", password: "p"),
            .register(email: "e@e.com", password: "p"),
            .createSession,
            .destroySession,
            .refreshToken,
        ]
        for endpoint in endpoints {
            #expect(endpoint.queryItems == nil)
        }
    }
}
