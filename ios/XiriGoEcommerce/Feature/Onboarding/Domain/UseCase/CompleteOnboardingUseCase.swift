import Foundation

// MARK: - CompleteOnboardingUseCase

/// Marks onboarding as completed so it is not shown on subsequent launches.
struct CompleteOnboardingUseCase: Sendable {
    // MARK: - Properties

    private let repository: OnboardingRepository

    // MARK: - Init

    init(repository: OnboardingRepository) {
        self.repository = repository
    }

    // MARK: - Execute

    func execute() async {
        await repository.setOnboardingSeen()
    }
}
