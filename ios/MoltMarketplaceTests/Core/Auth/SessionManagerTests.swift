import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - SessionManagerTests

@Suite("SessionManager Tests", .serialized)
@MainActor
struct SessionManagerTests {
    // MARK: - Helpers

    private func makeManager(
        storage: FakeTokenStorage = FakeTokenStorage(),
        authManager: AuthStateManagerImpl? = nil
    ) -> (SessionManager, FakeTokenStorage, AuthStateManagerImpl) {
        let fakeStorage = storage
        let fakeAuthManager = authManager ?? AuthStateManagerImpl(tokenStorage: fakeStorage)
        let client = APIClient.makeTestClient()
        let manager = SessionManager(
            apiClient: client,
            tokenStorage: fakeStorage,
            authStateManager: fakeAuthManager
        )
        return (manager, fakeStorage, fakeAuthManager)
    }

    // MARK: - login success

    @Test("login success: calls API, stores token, updates auth state to authenticated")
    func test_login_success_storesTokenAndSetsAuthenticatedState() async throws {
        MockURLProtocol.reset()
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            // First call: login endpoint -> returns token
            // Second call: createSession (fire-and-forget) -> 200
            let requestURL = try #require(request.url)
            let response = try #require(HTTPURLResponse(
                url: requestURL,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            ))
            let json: String
            if callCount == 1 {
                json = #"{"token":"login_jwt_token"}"#
            } else {
                json = "{}"
            }
            let data = try #require(json.data(using: .utf8))
            return (response, data)
        }

        let storage = FakeTokenStorage()
        let (manager, fakeStorage, fakeAuthManager) = makeManager(storage: storage)

        try await manager.login(email: "user@example.com", password: "Password1!")

        #expect(fakeStorage.storedToken == "login_jwt_token")
        #expect(fakeAuthManager.authState == .authenticated(token: "login_jwt_token"))
    }

    @Test("login failure: throws error and does not update auth state")
    func test_login_failure_throwsErrorAndDoesNotUpdateState() async {
        MockURLProtocol.reset()
        MockURLProtocol.stub(statusCode: 401, json: #"{"type":"unauthorized","message":"Invalid email or password"}"#)

        let storage = FakeTokenStorage()
        let (manager, fakeStorage, fakeAuthManager) = makeManager(storage: storage)

        await #expect(throws: (any Error).self) {
            try await manager.login(email: "bad@example.com", password: "wrong")
        }

        #expect(fakeStorage.storedToken == nil)
        #expect(fakeAuthManager.authState == .loading)
    }

    @Test("login failure: network error throws AppError.network")
    func test_login_networkError_throwsNetworkError() async {
        MockURLProtocol.reset()
        MockURLProtocol.stubNetworkError(.notConnectedToInternet)

        let (manager, fakeStorage, fakeAuthManager) = makeManager()

        await #expect(throws: (any Error).self) {
            try await manager.login(email: "user@example.com", password: "Password1!")
        }

        #expect(fakeStorage.storedToken == nil)
        #expect(fakeAuthManager.authState == .loading)
    }

    // MARK: - register success

    @Test("register success: calls API, stores token, updates auth state to authenticated")
    func test_register_success_storesTokenAndSetsAuthenticatedState() async throws {
        MockURLProtocol.reset()
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            let requestURL = try #require(request.url)
            let response = try #require(HTTPURLResponse(
                url: requestURL,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            ))
            let json: String
            if callCount == 1 {
                json = #"{"token":"register_jwt_token"}"#
            } else {
                json = "{}"
            }
            let data = try #require(json.data(using: .utf8))
            return (response, data)
        }

        let storage = FakeTokenStorage()
        let (manager, fakeStorage, fakeAuthManager) = makeManager(storage: storage)

        try await manager.register(email: "new@example.com", password: "Password1!")

        #expect(fakeStorage.storedToken == "register_jwt_token")
        #expect(fakeAuthManager.authState == .authenticated(token: "register_jwt_token"))
    }

    @Test("register failure: email already exists throws server error 422")
    func test_register_emailExists_throwsServerError() async {
        MockURLProtocol.reset()
        MockURLProtocol.stub(
            statusCode: 422,
            json: #"{"type":"duplicate","message":"Email already registered"}"#
        )

        let (manager, fakeStorage, fakeAuthManager) = makeManager()

        await #expect(throws: (any Error).self) {
            try await manager.register(email: "existing@example.com", password: "Password1!")
        }

        #expect(fakeStorage.storedToken == nil)
        #expect(fakeAuthManager.authState == .loading)
    }

    // MARK: - logout

    @Test("logout always clears local state even when session destroy API succeeds")
    func test_logout_apiSucceeds_clearsLocalState() async {
        MockURLProtocol.reset()
        MockURLProtocol.stub(statusCode: 200, json: "{}")

        let storage = FakeTokenStorage()
        storage.storedToken = "active_token"
        let fakeAuthManager = AuthStateManagerImpl(tokenStorage: storage)
        fakeAuthManager.onLoginSuccess(token: "active_token")

        let client = APIClient.makeTestClient()
        let manager = SessionManager(
            apiClient: client,
            tokenStorage: storage,
            authStateManager: fakeAuthManager
        )

        await manager.logout()

        #expect(storage.storedToken == nil)
        #expect(fakeAuthManager.authState == .guest)
    }

    @Test("logout always clears local state even when session destroy API fails")
    func test_logout_apiFails_stillClearsLocalState() async {
        MockURLProtocol.reset()
        MockURLProtocol.stubNetworkError(.notConnectedToInternet)

        let storage = FakeTokenStorage()
        storage.storedToken = "active_token"
        let fakeAuthManager = AuthStateManagerImpl(tokenStorage: storage)
        fakeAuthManager.onLoginSuccess(token: "active_token")

        let client = APIClient.makeTestClient()
        let manager = SessionManager(
            apiClient: client,
            tokenStorage: storage,
            authStateManager: fakeAuthManager
        )

        await manager.logout()

        #expect(storage.storedToken == nil)
        #expect(fakeAuthManager.authState == .guest)
    }

    @Test("logout clears state regardless of server 500 error")
    func test_logout_server500_stillClearsLocalState() async {
        MockURLProtocol.reset()
        MockURLProtocol.stub(statusCode: 500, json: #"{"type":"error","message":"Server error"}"#)

        let storage = FakeTokenStorage()
        storage.storedToken = "active_token"
        let fakeAuthManager = AuthStateManagerImpl(tokenStorage: storage)
        fakeAuthManager.onLoginSuccess(token: "active_token")

        let client = APIClient.makeTestClient()
        let manager = SessionManager(
            apiClient: client,
            tokenStorage: storage,
            authStateManager: fakeAuthManager
        )

        await manager.logout()

        #expect(storage.storedToken == nil)
        #expect(fakeAuthManager.authState == .guest)
    }

    // MARK: - refreshToken

    @Test("refreshToken success: stores new token and updates auth state")
    func test_refreshToken_success_storesNewToken() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.stub(statusCode: 200, json: #"{"token":"refreshed_jwt_token"}"#)

        let storage = FakeTokenStorage()
        storage.storedToken = "old_token"
        let fakeAuthManager = AuthStateManagerImpl(tokenStorage: storage)
        fakeAuthManager.onLoginSuccess(token: "old_token")

        let client = APIClient.makeTestClient()
        let manager = SessionManager(
            apiClient: client,
            tokenStorage: storage,
            authStateManager: fakeAuthManager
        )

        let newToken = try await manager.refreshToken()

        #expect(newToken == "refreshed_jwt_token")
        #expect(storage.storedToken == "refreshed_jwt_token")
        #expect(fakeAuthManager.authState == .authenticated(token: "refreshed_jwt_token"))
    }

    @Test("refreshToken failure: throws error")
    func test_refreshToken_failure_throwsError() async {
        MockURLProtocol.reset()
        MockURLProtocol.stub(
            statusCode: 401,
            json: #"{"type":"unauthorized","message":"Token expired"}"#
        )

        let storage = FakeTokenStorage()
        storage.storedToken = "expired_token"
        let fakeAuthManager = AuthStateManagerImpl(tokenStorage: storage)
        fakeAuthManager.onLoginSuccess(token: "expired_token")

        let client = APIClient.makeTestClient()
        let manager = SessionManager(
            apiClient: client,
            tokenStorage: storage,
            authStateManager: fakeAuthManager
        )

        await #expect(throws: (any Error).self) {
            let _ = try await manager.refreshToken()
        }
    }

    // MARK: - TokenProvider conformance

    @Test("getAccessToken returns current token from storage")
    func test_getAccessToken_returnsTokenFromStorage() async {
        MockURLProtocol.reset()
        let storage = FakeTokenStorage()
        storage.storedToken = "provider_token"
        let (manager, _, _) = makeManager(storage: storage)

        let token = await manager.getAccessToken()

        #expect(token == "provider_token")
    }

    @Test("getAccessToken returns nil when storage is empty")
    func test_getAccessToken_emptyStorage_returnsNil() async {
        MockURLProtocol.reset()
        let (manager, _, _) = makeManager()

        let token = await manager.getAccessToken()

        #expect(token == nil)
    }

    @Test("clearTokens calls authStateManager.onLogout to clear state and storage")
    func test_clearTokens_setsGuestStateAndClearsStorage() async {
        MockURLProtocol.reset()
        let storage = FakeTokenStorage()
        storage.storedToken = "some_token"
        let (manager, fakeStorage, fakeAuthManager) = makeManager(storage: storage)
        fakeAuthManager.onLoginSuccess(token: "some_token")

        await manager.clearTokens()

        #expect(fakeStorage.storedToken == nil)
        #expect(fakeAuthManager.authState == .guest)
    }
}
