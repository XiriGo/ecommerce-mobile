import Foundation

// MARK: - OnboardingRepository

/// Repository interface for onboarding persistence.
/// Manages the "has seen onboarding" flag in local storage.
protocol OnboardingRepository: Sendable {
    /// Returns whether the user has previously completed or skipped onboarding.
    func hasSeenOnboarding() async -> Bool

    /// Marks onboarding as seen so it is not shown on subsequent launches.
    func setOnboardingSeen() async
}
