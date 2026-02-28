import Testing
@testable import XiriGoEcommerce

// MARK: - OnboardingUiStateTests

@Suite("OnboardingUiState Tests")
struct OnboardingUiStateTests {
    // MARK: - Equatable

    @Test("loading state equals loading state")
    func test_loading_equalsLoading() {
        let state: OnboardingUiState = .loading
        #expect(state == .loading)
    }

    @Test("showOnboarding state equals showOnboarding state")
    func test_showOnboarding_equalsShowOnboarding() {
        let state: OnboardingUiState = .showOnboarding
        #expect(state == .showOnboarding)
    }

    @Test("onboardingComplete state equals onboardingComplete state")
    func test_onboardingComplete_equalsOnboardingComplete() {
        let state: OnboardingUiState = .onboardingComplete
        #expect(state == .onboardingComplete)
    }

    @Test("loading is not equal to showOnboarding")
    func test_loading_isNotEqualToShowOnboarding() {
        #expect(OnboardingUiState.loading != .showOnboarding)
    }

    @Test("showOnboarding is not equal to onboardingComplete")
    func test_showOnboarding_isNotEqualToOnboardingComplete() {
        #expect(OnboardingUiState.showOnboarding != .onboardingComplete)
    }

    @Test("loading is not equal to onboardingComplete")
    func test_loading_isNotEqualToOnboardingComplete() {
        #expect(OnboardingUiState.loading != .onboardingComplete)
    }

    // MARK: - Pattern Matching

    @Test("loading case can be matched with switch")
    func test_loadingCase_matchedBySwitch() {
        let state: OnboardingUiState = .loading
        var matched = false
        switch state {
        case .loading: matched = true
        case .showOnboarding, .onboardingComplete: break
        }
        #expect(matched)
    }

    @Test("showOnboarding case can be matched with switch")
    func test_showOnboardingCase_matchedBySwitch() {
        let state: OnboardingUiState = .showOnboarding
        var matched = false
        switch state {
        case .showOnboarding: matched = true
        case .loading, .onboardingComplete: break
        }
        #expect(matched)
    }

    @Test("onboardingComplete case can be matched with switch")
    func test_onboardingCompleteCase_matchedBySwitch() {
        let state: OnboardingUiState = .onboardingComplete
        var matched = false
        switch state {
        case .onboardingComplete: matched = true
        case .loading, .showOnboarding: break
        }
        #expect(matched)
    }
}
