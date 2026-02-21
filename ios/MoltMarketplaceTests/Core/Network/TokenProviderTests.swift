import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - FakeTokenProvider

/// In-memory token provider for testing. Supports configurable access token,
/// refresh result, and tracking method calls.
final class FakeTokenProvider: TokenProvider, @unchecked Sendable {
    var accessToken: String?
    var refreshResult: Result<String?, any Error> = .success(nil)
    var clearTokensCallCount = 0
    var getAccessTokenCallCount = 0
    var refreshTokenCallCount = 0

    func getAccessToken() async -> String? {
        getAccessTokenCallCount += 1
        return accessToken
    }

    func refreshToken() async throws -> String? {
        refreshTokenCallCount += 1
        switch refreshResult {
        case .success(let token):
            return token

        case .failure(let error):
            throw error
        }
    }

    func clearTokens() async {
        clearTokensCallCount += 1
        accessToken = nil
    }
}

// MARK: - NoOpTokenProviderTests

@Suite("NoOpTokenProvider Tests")
struct NoOpTokenProviderTests {
    @Test("getAccessToken always returns nil")
    func test_getAccessToken_always_returnsNil() async {
        let provider = NoOpTokenProvider()
        let token = await provider.getAccessToken()
        #expect(token == nil)
    }

    @Test("refreshToken always returns nil")
    func test_refreshToken_always_returnsNil() async throws {
        let provider = NoOpTokenProvider()
        let token = try await provider.refreshToken()
        #expect(token == nil)
    }

    @Test("clearTokens does nothing without error")
    func test_clearTokens_completes_withoutError() async {
        let provider = NoOpTokenProvider()
        await provider.clearTokens()
        // No assertion needed — just ensure it does not throw or crash
    }
}

// MARK: - FakeTokenProviderTests (validates fake used in tests)

@Suite("FakeTokenProvider Tests")
struct FakeTokenProviderTests {
    @Test("getAccessToken returns configured access token")
    func test_getAccessToken_withConfiguredToken_returnsToken() async {
        let provider = FakeTokenProvider()
        provider.accessToken = "access_token_123"

        let token = await provider.getAccessToken()

        #expect(token == "access_token_123")
    }

    @Test("getAccessToken returns nil when no token configured")
    func test_getAccessToken_noToken_returnsNil() async {
        let provider = FakeTokenProvider()
        let token = await provider.getAccessToken()
        #expect(token == nil)
    }

    @Test("refreshToken returns configured new token on success")
    func test_refreshToken_successResult_returnsNewToken() async throws {
        let provider = FakeTokenProvider()
        provider.refreshResult = .success("new_access_token")

        let token = try await provider.refreshToken()

        #expect(token == "new_access_token")
    }

    @Test("refreshToken throws configured error on failure")
    func test_refreshToken_failureResult_throwsError() async {
        let provider = FakeTokenProvider()
        provider.refreshResult = .failure(AppError.unauthorized())

        await #expect(throws: AppError.unauthorized()) {
            try await provider.refreshToken()
        }
    }

    @Test("clearTokens sets accessToken to nil")
    func test_clearTokens_setsAccessTokenToNil() async {
        let provider = FakeTokenProvider()
        provider.accessToken = "some_token"

        await provider.clearTokens()

        let token = await provider.getAccessToken()
        #expect(token == nil)
    }

    @Test("clearTokens increments call count")
    func test_clearTokens_incrementsCallCount() async {
        let provider = FakeTokenProvider()

        await provider.clearTokens()
        await provider.clearTokens()

        #expect(provider.clearTokensCallCount == 2)
    }

    @Test("getAccessToken increments call count")
    func test_getAccessToken_incrementsCallCount() async {
        let provider = FakeTokenProvider()

        _ = await provider.getAccessToken()
        _ = await provider.getAccessToken()
        _ = await provider.getAccessToken()

        #expect(provider.getAccessTokenCallCount == 3)
    }

    @Test("refreshToken increments call count")
    func test_refreshToken_incrementsCallCount() async throws {
        let provider = FakeTokenProvider()
        provider.refreshResult = .success("token")

        _ = try await provider.refreshToken()
        _ = try await provider.refreshToken()

        #expect(provider.refreshTokenCallCount == 2)
    }
}
