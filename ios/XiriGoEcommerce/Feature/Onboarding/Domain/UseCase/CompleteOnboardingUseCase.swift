import Foundation

// MARK: - CompleteOnboardingUseCase

/// Marks onboarding as completed so it is not shown on subsequent launches.
struct CompleteOnboardingUseCase: Sendable {
    // MARK: - Lifecycle

    // MARK: - Init

    init(repository: OnboardingRepository) {
        self.repository = repository
    }

    // MARK: - Internal

    // MARK: - Execute

    func execute() async {
        await repository.setOnboardingSeen()
    }

    // MARK: - Private

    private let repository: OnboardingRepository
}
