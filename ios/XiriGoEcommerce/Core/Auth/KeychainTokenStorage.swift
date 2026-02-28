import Foundation
import KeychainAccess

// MARK: - KeychainTokenStorage

final class KeychainTokenStorage: TokenStorage, @unchecked Sendable {
    // MARK: - Lifecycle

    init() {
        self.keychain = Keychain(service: Constants.service)
            .accessibility(.whenUnlockedThisDeviceOnly)
    }

    // MARK: - TokenStorage

    func getAccessToken() -> String? {
        try? keychain.get(Constants.accessTokenKey)
    }

    func saveAccessToken(_ token: String) {
        try? keychain.set(token, key: Constants.accessTokenKey)
    }

    func clearTokens() {
        try? keychain.remove(Constants.accessTokenKey)
    }

    // MARK: - Private

    private let keychain: Keychain

    private enum Constants {
        static let service = "com.xirigo.ecommerce.auth"
        static let accessTokenKey = "access_token"
    }
}
