import Factory

// MARK: - Container + Onboarding

extension Container {
    // MARK: - Repository

    var onboardingRepository: Factory<OnboardingRepository> {
        self { OnboardingRepositoryImpl() }
            .singleton
    }

    // MARK: - Use Cases

    var checkOnboardingUseCase: Factory<CheckOnboardingUseCase> {
        self { CheckOnboardingUseCase(repository: self.onboardingRepository()) }
    }

    var completeOnboardingUseCase: Factory<CompleteOnboardingUseCase> {
        self { CompleteOnboardingUseCase(repository: self.onboardingRepository()) }
    }

    // MARK: - ViewModel

    var onboardingViewModel: Factory<OnboardingViewModel> {
        self {
            MainActor.assumeIsolated {
                OnboardingViewModel(
                    checkOnboarding: self.checkOnboardingUseCase(),
                    completeOnboarding: self.completeOnboardingUseCase(),
                )
            }
        }
    }
}
