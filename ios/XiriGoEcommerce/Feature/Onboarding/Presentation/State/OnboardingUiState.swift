import Foundation

// MARK: - OnboardingUiState

/// Represents the three possible states of the onboarding flow.
enum OnboardingUiState: Equatable, Sendable {
    /// Checking if onboarding has been seen (shows splash screen).
    case loading

    /// First launch -- display the onboarding pager.
    case showOnboarding

    /// Onboarding flag is set -- navigate to main app.
    case onboardingComplete
}
