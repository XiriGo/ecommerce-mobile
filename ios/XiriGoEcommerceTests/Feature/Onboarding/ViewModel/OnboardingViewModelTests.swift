import Testing
@testable import XiriGoEcommerce

// MARK: - OnboardingViewModelTests

@Suite("OnboardingViewModel Tests")
@MainActor
struct OnboardingViewModelTests {
    // MARK: - Helpers

    private func makeViewModel(hasSeen: Bool) -> (OnboardingViewModel, FakeOnboardingRepository) {
        let repository = FakeOnboardingRepository()
        repository.hasSeen = hasSeen
        let viewModel = OnboardingViewModel(
            checkOnboarding: CheckOnboardingUseCase(repository: repository),
            completeOnboarding: CompleteOnboardingUseCase(repository: repository)
        )
        return (viewModel, repository)
    }

    // MARK: - Initial State

    @Test("initial uiState is loading")
    func test_initialUiState_isLoading() {
        let (viewModel, _) = makeViewModel(hasSeen: false)
        #expect(viewModel.uiState == .loading)
    }

    @Test("initial currentPage is 0")
    func test_initialCurrentPage_isZero() {
        let (viewModel, _) = makeViewModel(hasSeen: false)
        #expect(viewModel.currentPage == 0)
    }

    @Test("pages contains all four onboarding pages")
    func test_pages_containsFourPages() {
        let (viewModel, _) = makeViewModel(hasSeen: false)
        #expect(viewModel.pages.count == 4)
    }

    // MARK: - checkOnboardingStatus: first launch

    @Test("checkOnboardingStatus transitions to showOnboarding when not seen")
    func test_checkOnboardingStatus_transitionsToShowOnboarding_whenNotSeen() async {
        let (viewModel, _) = makeViewModel(hasSeen: false)

        await viewModel.checkOnboardingStatus()

        #expect(viewModel.uiState == .showOnboarding)
    }

    // MARK: - checkOnboardingStatus: returning user

    @Test("checkOnboardingStatus transitions to onboardingComplete when already seen")
    func test_checkOnboardingStatus_transitionsToComplete_whenAlreadySeen() async {
        let (viewModel, _) = makeViewModel(hasSeen: true)

        await viewModel.checkOnboardingStatus()

        #expect(viewModel.uiState == .onboardingComplete)
    }

    // MARK: - checkOnboardingStatus: loading intermediate

    @Test("uiState begins as loading before async check completes")
    func test_checkOnboardingStatus_startsFromLoading() {
        let (viewModel, _) = makeViewModel(hasSeen: false)
        // Before awaiting, state is still .loading
        #expect(viewModel.uiState == .loading)
    }

    // MARK: - onSkip

    @Test("onSkip transitions uiState to onboardingComplete")
    func test_onSkip_setsStateToComplete() async {
        let (viewModel, _) = makeViewModel(hasSeen: false)

        await viewModel.onSkip()

        #expect(viewModel.uiState == .onboardingComplete)
    }

    @Test("onSkip calls setOnboardingSeen on repository")
    func test_onSkip_callsSetOnboardingSeen() async {
        let (viewModel, repository) = makeViewModel(hasSeen: false)

        await viewModel.onSkip()

        #expect(repository.setOnboardingSeenCallCount == 1)
    }

    // MARK: - onGetStarted

    @Test("onGetStarted transitions uiState to onboardingComplete")
    func test_onGetStarted_setsStateToComplete() async {
        let (viewModel, _) = makeViewModel(hasSeen: false)

        await viewModel.onGetStarted()

        #expect(viewModel.uiState == .onboardingComplete)
    }

    @Test("onGetStarted calls setOnboardingSeen on repository")
    func test_onGetStarted_callsSetOnboardingSeen() async {
        let (viewModel, repository) = makeViewModel(hasSeen: false)

        await viewModel.onGetStarted()

        #expect(repository.setOnboardingSeenCallCount == 1)
    }

    // MARK: - isLastPage

    @Test("isLastPage is false when currentPage is 0")
    func test_isLastPage_isFalse_whenOnFirstPage() {
        let (viewModel, _) = makeViewModel(hasSeen: false)
        viewModel.currentPage = 0
        #expect(viewModel.isLastPage == false)
    }

    @Test("isLastPage is false when currentPage is in the middle")
    func test_isLastPage_isFalse_whenOnMiddlePage() {
        let (viewModel, _) = makeViewModel(hasSeen: false)
        viewModel.currentPage = 2
        #expect(viewModel.isLastPage == false)
    }

    @Test("isLastPage is true when currentPage equals pages.count - 1")
    func test_isLastPage_isTrue_whenOnLastPage() {
        let (viewModel, _) = makeViewModel(hasSeen: false)
        viewModel.currentPage = viewModel.pages.count - 1
        #expect(viewModel.isLastPage == true)
    }

    // MARK: - Page Navigation

    @Test("currentPage can be set to any valid page index")
    func test_currentPage_canBeUpdatedToAnyValidIndex() {
        let (viewModel, _) = makeViewModel(hasSeen: false)

        viewModel.currentPage = 3
        #expect(viewModel.currentPage == 3)

        viewModel.currentPage = 1
        #expect(viewModel.currentPage == 1)
    }

    // MARK: - onSkip vs onGetStarted both produce onboardingComplete

    @Test("onSkip and onGetStarted both result in onboardingComplete state")
    func test_onSkipAndOnGetStarted_bothProduceCompleteState() async {
        let (viewModelSkip, _) = makeViewModel(hasSeen: false)
        let (viewModelGetStarted, _) = makeViewModel(hasSeen: false)

        await viewModelSkip.onSkip()
        await viewModelGetStarted.onGetStarted()

        #expect(viewModelSkip.uiState == .onboardingComplete)
        #expect(viewModelGetStarted.uiState == .onboardingComplete)
    }
}
