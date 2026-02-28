import Foundation
import Testing
@testable import XiriGoEcommerce

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
            case let .success(token):
                return token

            case let .failure(error):
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
    func getAccessToken_always_returnsNil() async {
        let provider = NoOpTokenProvider()
        let token = await provider.getAccessToken()
        #expect(token == nil)
    }

    @Test("refreshToken always returns nil")
    func refreshToken_always_returnsNil() async throws {
        let provider = NoOpTokenProvider()
        let token = try await provider.refreshToken()
        #expect(token == nil)
    }

    @Test("clearTokens does nothing without error")
    func clearTokens_completes_withoutError() async {
        let provider = NoOpTokenProvider()
        await provider.clearTokens()
        // No assertion needed — just ensure it does not throw or crash
    }
}

// MARK: - FakeTokenProviderTests

@Suite("FakeTokenProvider Tests")
struct FakeTokenProviderTests {
    @Test("getAccessToken returns configured access token")
    func getAccessToken_withConfiguredToken_returnsToken() async {
        let provider = FakeTokenProvider()
        provider.accessToken = "access_token_123"

        let token = await provider.getAccessToken()

        #expect(token == "access_token_123")
    }

    @Test("getAccessToken returns nil when no token configured")
    func getAccessToken_noToken_returnsNil() async {
        let provider = FakeTokenProvider()
        let token = await provider.getAccessToken()
        #expect(token == nil)
    }

    @Test("refreshToken returns configured new token on success")
    func refreshToken_successResult_returnsNewToken() async throws {
        let provider = FakeTokenProvider()
        provider.refreshResult = .success("new_access_token")

        let token = try await provider.refreshToken()

        #expect(token == "new_access_token")
    }

    @Test("refreshToken throws configured error on failure")
    func refreshToken_failureResult_throwsError() async {
        let provider = FakeTokenProvider()
        provider.refreshResult = .failure(AppError.unauthorized())

        await #expect(throws: AppError.unauthorized()) {
            try await provider.refreshToken()
        }
    }

    @Test("clearTokens sets accessToken to nil")
    func clearTokens_setsAccessTokenToNil() async {
        let provider = FakeTokenProvider()
        provider.accessToken = "some_token"

        await provider.clearTokens()

        let token = await provider.getAccessToken()
        #expect(token == nil)
    }

    @Test("clearTokens increments call count")
    func clearTokens_incrementsCallCount() async {
        let provider = FakeTokenProvider()

        await provider.clearTokens()
        await provider.clearTokens()

        #expect(provider.clearTokensCallCount == 2)
    }

    @Test("getAccessToken increments call count")
    func getAccessToken_incrementsCallCount() async {
        let provider = FakeTokenProvider()

        _ = await provider.getAccessToken()
        _ = await provider.getAccessToken()
        _ = await provider.getAccessToken()

        #expect(provider.getAccessTokenCallCount == 3)
    }

    @Test("refreshToken increments call count")
    func refreshToken_incrementsCallCount() async throws {
        let provider = FakeTokenProvider()
        provider.refreshResult = .success("token")

        _ = try await provider.refreshToken()
        _ = try await provider.refreshToken()

        #expect(provider.refreshTokenCallCount == 2)
    }
}
