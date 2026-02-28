import Foundation

// MARK: - OnboardingViewModel

/// Manages onboarding state, page navigation, skip, and get-started actions.
/// Coordinates `CheckOnboardingUseCase` and `CompleteOnboardingUseCase`.
@MainActor
@Observable
final class OnboardingViewModel {
    // MARK: - Properties

    private enum Constants {
        static let splashDurationSeconds: Int = 2
    }

    @ObservationIgnored private let checkOnboarding: CheckOnboardingUseCase
    @ObservationIgnored private let completeOnboarding: CompleteOnboardingUseCase

    private(set) var uiState: OnboardingUiState = .loading
    var currentPage: Int = 0

    let pages: [OnboardingPage] = OnboardingPage.allPages

    // MARK: - Computed

    /// Whether the current page is the last onboarding page.
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    // MARK: - Init

    init(
        checkOnboarding: CheckOnboardingUseCase,
        completeOnboarding: CompleteOnboardingUseCase
    ) {
        self.checkOnboarding = checkOnboarding
        self.completeOnboarding = completeOnboarding
    }

    // MARK: - Actions

    /// Checks whether onboarding has been previously shown and updates state accordingly.
    /// Shows the splash screen for a minimum duration before transitioning.
    func checkOnboardingStatus() async {
        let hasSeen = await checkOnboarding.execute()
        try? await Task.sleep(for: .seconds(Constants.splashDurationSeconds))
        uiState = hasSeen ? .onboardingComplete : .showOnboarding
    }

    /// Skips onboarding, marks it as seen, and navigates to the main app.
    func onSkip() async {
        await completeOnboarding.execute()
        uiState = .onboardingComplete
    }

    /// Completes onboarding from the last page, marks it as seen, and navigates to the main app.
    func onGetStarted() async {
        await completeOnboarding.execute()
        uiState = .onboardingComplete
    }
}
