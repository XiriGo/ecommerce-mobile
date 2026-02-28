import Foundation
@testable import XiriGoEcommerce

// MARK: - FakeOnboardingRepository

/// In-memory fake implementation of `OnboardingRepository` for use in unit tests.
/// Avoids touching UserDefaults — each test instance starts with a clean state.
final class FakeOnboardingRepository: OnboardingRepository, @unchecked Sendable {
    // MARK: - Configurable State

    var hasSeen: Bool = false
    var setOnboardingSeenCallCount: Int = 0

    // MARK: - OnboardingRepository

    func hasSeenOnboarding() async -> Bool {
        hasSeen
    }

    func setOnboardingSeen() async {
        hasSeen = true
        setOnboardingSeenCallCount += 1
    }
}
