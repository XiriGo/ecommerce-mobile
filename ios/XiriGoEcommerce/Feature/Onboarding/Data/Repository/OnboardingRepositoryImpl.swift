import Foundation

// MARK: - OnboardingRepositoryImpl

/// UserDefaults-backed implementation of `OnboardingRepository`.
/// Stores a simple boolean flag indicating whether onboarding has been shown.
final class OnboardingRepositoryImpl: OnboardingRepository, @unchecked Sendable {
    // MARK: - Lifecycle

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Internal

    // MARK: - OnboardingRepository

    func hasSeenOnboarding() async -> Bool {
        defaults.bool(forKey: Self.hasSeenOnboardingKey)
    }

    func setOnboardingSeen() async {
        defaults.set(true, forKey: Self.hasSeenOnboardingKey)
    }

    // MARK: - Private

    // MARK: - Constants

    private static let hasSeenOnboardingKey = "has_seen_onboarding"

    private let defaults: UserDefaults
}
