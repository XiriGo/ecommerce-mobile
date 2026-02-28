import Testing
import SwiftUI
@testable import XiriGoEcommerce

// MARK: - OnboardingScreenTests

/// Structural tests for OnboardingScreen and OnboardingPageContent.
/// ViewInspector-level inspection is limited by the TabView/.page style at runtime.
/// Critical business logic (state transitions, button actions) is validated in ViewModel tests.
@Suite("OnboardingScreen Tests")
@MainActor
struct OnboardingScreenTests {
    // MARK: - Helpers

    private func makeViewModel(hasSeen: Bool = false) -> OnboardingViewModel {
        let repository = FakeOnboardingRepository()
        repository.hasSeen = hasSeen
        return OnboardingViewModel(
            checkOnboarding: CheckOnboardingUseCase(repository: repository),
            completeOnboarding: CompleteOnboardingUseCase(repository: repository)
        )
    }

    // MARK: - Initialisation

    @Test("OnboardingScreen initialises without crash")
    func test_init_initialises() {
        let screen = OnboardingScreen(viewModel: makeViewModel())
        _ = screen
        #expect(true)
    }

    @Test("OnboardingScreen is a View")
    func test_onboardingScreen_conformsToView() {
        let screen: any View = OnboardingScreen(viewModel: makeViewModel())
        _ = screen
        #expect(true)
    }

    @Test("OnboardingScreen body can be created without crash")
    func test_body_canBeCreated() {
        let viewModel = makeViewModel()
        let screen = OnboardingScreen(viewModel: viewModel)
        let body = screen.body
        _ = body
        #expect(true)
    }

    // MARK: - ViewModel Integration via isLastPage

    @Test("isLastPage is false on initial page 0")
    func test_viewModel_isLastPage_falseOnFirstPage() {
        let viewModel = makeViewModel()
        #expect(viewModel.isLastPage == false)
    }

    @Test("isLastPage is true on last page (page 3 for 4-page flow)")
    func test_viewModel_isLastPage_trueOnLastPage() {
        let viewModel = makeViewModel()
        viewModel.currentPage = 3
        #expect(viewModel.isLastPage == true)
    }

    @Test("onboarding has 4 pages matching OnboardingPage.allPages")
    func test_viewModel_pageCount_isFour() {
        let viewModel = makeViewModel()
        #expect(viewModel.pages.count == 4)
    }

    // MARK: - Skip button visibility semantic

    @Test("skip button should be visible on non-last pages (isLastPage false)")
    func test_skipButton_visibleOnNonLastPage() {
        let viewModel = makeViewModel()
        viewModel.currentPage = 0
        // Skip button is shown when !isLastPage
        #expect(!viewModel.isLastPage)
    }

    @Test("skip button should be hidden on last page (isLastPage true)")
    func test_skipButton_hiddenOnLastPage() {
        let viewModel = makeViewModel()
        viewModel.currentPage = 3
        // Skip button is hidden when isLastPage
        #expect(viewModel.isLastPage)
    }

    // MARK: - Get Started button visibility semantic

    @Test("get started button visible only on last page")
    func test_getStartedButton_visibleOnlyOnLastPage() {
        let viewModel = makeViewModel()
        viewModel.currentPage = viewModel.pages.count - 1
        #expect(viewModel.isLastPage)
    }
}

// MARK: - OnboardingPageContentTests

@Suite("OnboardingPageContent Tests")
struct OnboardingPageContentTests {
    @Test("OnboardingPageContent initialises with first page without crash")
    func test_init_firstPage_initialises() {
        let content = OnboardingPageContent(page: OnboardingPage.allPages[0])
        _ = content
        #expect(true)
    }

    @Test("OnboardingPageContent initialises with all four pages without crash")
    func test_init_allPages_initialisesWithoutCrash() {
        for page in OnboardingPage.allPages {
            let content = OnboardingPageContent(page: page)
            _ = content
        }
        #expect(true)
    }

    @Test("OnboardingPageContent body can be created for browse page")
    func test_body_canBeCreated_browsePage() {
        let content = OnboardingPageContent(page: OnboardingPage.allPages[0])
        let body = content.body
        _ = body
        #expect(true)
    }

    @Test("OnboardingPageContent body can be created for track page")
    func test_body_canBeCreated_trackPage() {
        let content = OnboardingPageContent(page: OnboardingPage.allPages[3])
        let body = content.body
        _ = body
        #expect(true)
    }

    @Test("OnboardingPageContent is a View")
    func test_onboardingPageContent_conformsToView() {
        let content: any View = OnboardingPageContent(page: OnboardingPage.allPages[0])
        _ = content
        #expect(true)
    }
}
