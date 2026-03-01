import Testing
@testable import XiriGoEcommerce

// MARK: - CompleteOnboardingUseCaseTests

@Suite("CompleteOnboardingUseCase Tests")
struct CompleteOnboardingUseCaseTests {
    // MARK: - Calls repository.setOnboardingSeen

    @Test("execute calls repository.setOnboardingSeen once")
    func execute_callsSetOnboardingSeenOnce() async {
        let repository = FakeOnboardingRepository()
        let useCase = CompleteOnboardingUseCase(repository: repository)

        await useCase.execute()

        #expect(repository.setOnboardingSeenCallCount == 1)
    }

    // MARK: - Marks flag as seen after execute

    @Test("execute causes hasSeenOnboarding to return true")
    func execute_marksOnboardingAsSeen() async {
        let repository = FakeOnboardingRepository()
        repository.hasSeen = false
        let useCase = CompleteOnboardingUseCase(repository: repository)

        await useCase.execute()

        #expect(repository.hasSeen == true)
    }

    // MARK: - Idempotent — calling twice still leaves flag set

    @Test("execute called twice increments callCount to 2 and hasSeen remains true")
    func execute_calledTwice_idempotent() async {
        let repository = FakeOnboardingRepository()
        let useCase = CompleteOnboardingUseCase(repository: repository)

        await useCase.execute()
        await useCase.execute()

        #expect(repository.setOnboardingSeenCallCount == 2)
        #expect(repository.hasSeen == true)
    }
}
