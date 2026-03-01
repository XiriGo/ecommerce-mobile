import Foundation

// MARK: - CheckOnboardingUseCase

/// Returns whether onboarding has been previously shown to the user.
struct CheckOnboardingUseCase: Sendable {
    // MARK: - Lifecycle

    // MARK: - Init

    init(repository: OnboardingRepository) {
        self.repository = repository
    }

    // MARK: - Internal

    // MARK: - Execute

    func execute() async -> Bool {
        await repository.hasSeenOnboarding()
    }

    // MARK: - Private

    private let repository: OnboardingRepository
}
