import Testing
@testable import XiriGoEcommerce

// MARK: - CheckOnboardingUseCaseTests

@Suite("CheckOnboardingUseCase Tests")
struct CheckOnboardingUseCaseTests {
    // MARK: - Returns false when onboarding not yet seen

    @Test("execute returns false when hasSeenOnboarding is false")
    func test_execute_returnsfalse_whenOnboardingNotSeen() async {
        let repository = FakeOnboardingRepository()
        repository.hasSeen = false
        let useCase = CheckOnboardingUseCase(repository: repository)

        let result = await useCase.execute()

        #expect(result == false)
    }

    // MARK: - Returns true when onboarding already seen

    @Test("execute returns true when hasSeenOnboarding is true")
    func test_execute_returnsTrue_whenOnboardingAlreadySeen() async {
        let repository = FakeOnboardingRepository()
        repository.hasSeen = true
        let useCase = CheckOnboardingUseCase(repository: repository)

        let result = await useCase.execute()

        #expect(result == true)
    }

    // MARK: - Delegates to repository

    @Test("execute delegates to repository.hasSeenOnboarding")
    func test_execute_delegatesToRepository() async {
        let repository = FakeOnboardingRepository()
        repository.hasSeen = true
        let useCase = CheckOnboardingUseCase(repository: repository)

        let resultFirst = await useCase.execute()
        repository.hasSeen = false
        let resultSecond = await useCase.execute()

        #expect(resultFirst == true)
        #expect(resultSecond == false)
    }
}
