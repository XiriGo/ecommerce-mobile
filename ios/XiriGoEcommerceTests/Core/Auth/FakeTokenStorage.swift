import Foundation
@testable import XiriGoEcommerce

// MARK: - FakeTokenStorage

/// In-memory TokenStorage implementation for unit testing.
/// Avoids real Keychain access so tests run without device entitlements.
final class FakeTokenStorage: TokenStorage, @unchecked Sendable {
    // MARK: - Internal

    var storedToken: String?
    var saveCallCount = 0
    var clearCallCount = 0
    var getCallCount = 0

    // MARK: - TokenStorage

    func getAccessToken() -> String? {
        getCallCount += 1
        return storedToken
    }

    func saveAccessToken(_ token: String) {
        saveCallCount += 1
        storedToken = token
    }

    func clearTokens() {
        clearCallCount += 1
        storedToken = nil
    }
}
