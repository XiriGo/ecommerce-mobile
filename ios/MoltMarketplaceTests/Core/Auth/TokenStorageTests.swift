import Testing
@testable import MoltMarketplace

// MARK: - TokenStorageTests

@Suite("FakeTokenStorage Tests")
struct TokenStorageTests {
    // MARK: - getAccessToken

    @Test("getAccessToken returns nil when storage is empty")
    func test_getAccessToken_emptyStorage_returnsNil() {
        let storage = FakeTokenStorage()
        let token = storage.getAccessToken()
        #expect(token == nil)
    }

    @Test("getAccessToken returns saved token after saveAccessToken")
    func test_getAccessToken_afterSave_returnsToken() {
        let storage = FakeTokenStorage()
        storage.saveAccessToken("jwt_token_abc")
        let token = storage.getAccessToken()
        #expect(token == "jwt_token_abc")
    }

    // MARK: - saveAccessToken

    @Test("saveAccessToken overwrites previously stored token")
    func test_saveAccessToken_calledTwice_returnsLastToken() {
        let storage = FakeTokenStorage()
        storage.saveAccessToken("first_token")
        storage.saveAccessToken("second_token")
        let token = storage.getAccessToken()
        #expect(token == "second_token")
    }

    @Test("saveAccessToken increments call count")
    func test_saveAccessToken_incrementsSaveCallCount() {
        let storage = FakeTokenStorage()
        storage.saveAccessToken("token_1")
        storage.saveAccessToken("token_2")
        #expect(storage.saveCallCount == 2)
    }

    // MARK: - clearTokens

    @Test("clearTokens removes stored token so getAccessToken returns nil")
    func test_clearTokens_removesStoredToken() {
        let storage = FakeTokenStorage()
        storage.saveAccessToken("jwt_token_xyz")
        storage.clearTokens()
        let token = storage.getAccessToken()
        #expect(token == nil)
    }

    @Test("clearTokens on empty storage does not crash")
    func test_clearTokens_onEmptyStorage_doesNotCrash() {
        let storage = FakeTokenStorage()
        storage.clearTokens()
        #expect(storage.clearCallCount == 1)
    }

    @Test("clearTokens increments call count")
    func test_clearTokens_incrementsClearCallCount() {
        let storage = FakeTokenStorage()
        storage.clearTokens()
        storage.clearTokens()
        #expect(storage.clearCallCount == 2)
    }

    // MARK: - Call Count Tracking

    @Test("getAccessToken increments get call count")
    func test_getAccessToken_incrementsGetCallCount() {
        let storage = FakeTokenStorage()
        _ = storage.getAccessToken()
        _ = storage.getAccessToken()
        #expect(storage.getCallCount == 2)
    }

    @Test("multiple operations are tracked independently")
    func test_multipleMixedOperations_trackCallCountsIndependently() {
        let storage = FakeTokenStorage()
        storage.saveAccessToken("t1")
        storage.saveAccessToken("t2")
        _ = storage.getAccessToken()
        storage.clearTokens()
        _ = storage.getAccessToken()

        #expect(storage.saveCallCount == 2)
        #expect(storage.getCallCount == 2)
        #expect(storage.clearCallCount == 1)
    }
}
