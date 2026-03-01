import Foundation

// MARK: - BiometricTokenStorage

/// Stub protocol for biometric-protected token storage.
/// Implementation deferred to M3 (Biometric Authentication).
protocol BiometricTokenStorage: Sendable {
    func storeRefreshToken(_ token: String) async throws
    func retrieveRefreshToken() async throws -> String?
    func clearBiometricToken() async
    func isBiometricAvailable() -> Bool
}
