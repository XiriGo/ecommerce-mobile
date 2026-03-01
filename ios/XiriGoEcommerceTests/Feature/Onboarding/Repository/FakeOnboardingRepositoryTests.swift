import Testing
@testable import XiriGoEcommerce

// MARK: - FakeOnboardingRepositoryTests

/// Tests to validate the fake's own behavior, ensuring tests built on it are reliable.
@Suite("FakeOnboardingRepository Tests")
struct FakeOnboardingRepositoryTests {
    // MARK: - Initial State

    @Test("hasSeenOnboarding returns false by default")
    func hasSeenOnboarding_returnsFalseByDefault() async {
        let repository = FakeOnboardingRepository()
        let result = await repository.hasSeenOnboarding()
        #expect(result == false)
    }

    // MARK: - Setting seen flag

    @Test("hasSeenOnboarding returns true after setOnboardingSeen")
    func hasSeenOnboarding_returnsTrueAfterSetOnboardingSeen() async {
        let repository = FakeOnboardingRepository()
        await repository.setOnboardingSeen()
        let result = await repository.hasSeenOnboarding()
        #expect(result == true)
    }

    @Test("setOnboardingSeenCallCount starts at 0")
    func setOnboardingSeenCallCount_startsAtZero() {
        let repository = FakeOnboardingRepository()
        #expect(repository.setOnboardingSeenCallCount == 0)
    }

    @Test("setOnboardingSeenCallCount increments on each call")
    func setOnboardingSeenCallCount_incrementsEachCall() async {
        let repository = FakeOnboardingRepository()
        await repository.setOnboardingSeen()
        await repository.setOnboardingSeen()
        #expect(repository.setOnboardingSeenCallCount == 2)
    }

    // MARK: - hasSeen direct property

    @Test("hasSeen can be preset to true before test")
    func hasSeen_canBePresetToTrue() async {
        let repository = FakeOnboardingRepository()
        repository.hasSeen = true
        let result = await repository.hasSeenOnboarding()
        #expect(result == true)
    }

    @Test("hasSeen can be preset to false before test")
    func hasSeen_canBePresetToFalse() async {
        let repository = FakeOnboardingRepository()
        repository.hasSeen = false
        let result = await repository.hasSeenOnboarding()
        #expect(result == false)
    }

    // MARK: - Test Isolation

    @Test("each FakeOnboardingRepository instance is independent")
    func independence_separateInstances() async {
        let repositoryA = FakeOnboardingRepository()
        let repositoryB = FakeOnboardingRepository()

        await repositoryA.setOnboardingSeen()

        let resultA = await repositoryA.hasSeenOnboarding()
        let resultB = await repositoryB.hasSeenOnboarding()

        #expect(resultA == true)
        #expect(resultB == false)
    }
}
