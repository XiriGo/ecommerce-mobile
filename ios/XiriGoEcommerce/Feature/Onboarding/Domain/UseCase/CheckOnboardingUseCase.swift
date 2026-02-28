import Foundation

// MARK: - CheckOnboardingUseCase

/// Returns whether onboarding has been previously shown to the user.
struct CheckOnboardingUseCase: Sendable {
    // MARK: - Properties

    private let repository: OnboardingRepository

    // MARK: - Init

    init(repository: OnboardingRepository) {
        self.repository = repository
    }

    // MARK: - Execute

    func execute() async -> Bool {
        await repository.hasSeenOnboarding()
    }
}
