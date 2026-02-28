import Testing
@testable import XiriGoEcommerce

// MARK: - AuthStateManagerTests

@Suite("AuthStateManagerImpl Tests", .serialized)
@MainActor
struct AuthStateManagerTests {
    // MARK: - Initial State

    @Test("initial authState is loading")
    func test_initialState_isLoading() {
        let storage = FakeTokenStorage()
        let manager = AuthStateManagerImpl(tokenStorage: storage)
        #expect(manager.authState == .loading)
    }

    // MARK: - checkStoredToken

    @Test("checkStoredToken with no stored token transitions to guest")
    func test_checkStoredToken_noToken_setsGuestState() async {
        let storage = FakeTokenStorage()
        let manager = AuthStateManagerImpl(tokenStorage: storage)

        await manager.checkStoredToken()

        #expect(manager.authState == .guest)
    }

    @Test("checkStoredToken with stored token transitions to authenticated")
    func test_checkStoredToken_withToken_setsAuthenticatedState() async {
        let storage = FakeTokenStorage()
        storage.storedToken = "stored_jwt_token"
        let manager = AuthStateManagerImpl(tokenStorage: storage)

        await manager.checkStoredToken()

        #expect(manager.authState == .authenticated(token: "stored_jwt_token"))
    }

    // MARK: - onLoginSuccess

    @Test("onLoginSuccess transitions state to authenticated with provided token")
    func test_onLoginSuccess_setsAuthenticatedState() {
        let storage = FakeTokenStorage()
        let manager = AuthStateManagerImpl(tokenStorage: storage)

        manager.onLoginSuccess(token: "new_jwt_token")

        #expect(manager.authState == .authenticated(token: "new_jwt_token"))
    }

    @Test("onLoginSuccess saves token to storage")
    func test_onLoginSuccess_savesTokenToStorage() {
        let storage = FakeTokenStorage()
        let manager = AuthStateManagerImpl(tokenStorage: storage)

        manager.onLoginSuccess(token: "new_jwt_token")

        #expect(storage.storedToken == "new_jwt_token")
        #expect(storage.saveCallCount == 1)
    }

    @Test("onLoginSuccess called twice uses latest token")
    func test_onLoginSuccess_calledTwice_statesReflectsLastToken() {
        let storage = FakeTokenStorage()
        let manager = AuthStateManagerImpl(tokenStorage: storage)

        manager.onLoginSuccess(token: "first_token")
        manager.onLoginSuccess(token: "second_token")

        #expect(manager.authState == .authenticated(token: "second_token"))
        #expect(storage.storedToken == "second_token")
    }

    // MARK: - onLogout

    @Test("onLogout transitions state to guest")
    func test_onLogout_setsGuestState() {
        let storage = FakeTokenStorage()
        storage.storedToken = "existing_token"
        let manager = AuthStateManagerImpl(tokenStorage: storage)
        manager.onLoginSuccess(token: "existing_token")

        manager.onLogout()

        #expect(manager.authState == .guest)
    }

    @Test("onLogout clears token from storage")
    func test_onLogout_clearsTokenFromStorage() {
        let storage = FakeTokenStorage()
        storage.storedToken = "some_token"
        let manager = AuthStateManagerImpl(tokenStorage: storage)
        manager.onLoginSuccess(token: "some_token")

        manager.onLogout()

        #expect(storage.storedToken == nil)
        #expect(storage.clearCallCount == 1)
    }

    @Test("onLogout from loading state still sets guest")
    func test_onLogout_fromLoadingState_setsGuest() {
        let storage = FakeTokenStorage()
        let manager = AuthStateManagerImpl(tokenStorage: storage)

        manager.onLogout()

        #expect(manager.authState == .guest)
    }

    // MARK: - State Transition Sequence

    @Test("full login-then-logout cycle transitions correctly through states")
    func test_loginThenLogout_cycleTransitionsCorrectly() {
        let storage = FakeTokenStorage()
        let manager = AuthStateManagerImpl(tokenStorage: storage)

        #expect(manager.authState == .loading)

        manager.onLoginSuccess(token: "cycle_token")
        #expect(manager.authState == .authenticated(token: "cycle_token"))

        manager.onLogout()
        #expect(manager.authState == .guest)
    }

    @Test("login after logout transitions back to authenticated")
    func test_loginAfterLogout_transitionsBackToAuthenticated() {
        let storage = FakeTokenStorage()
        let manager = AuthStateManagerImpl(tokenStorage: storage)

        manager.onLoginSuccess(token: "token_v1")
        manager.onLogout()
        manager.onLoginSuccess(token: "token_v2")

        #expect(manager.authState == .authenticated(token: "token_v2"))
    }
}
