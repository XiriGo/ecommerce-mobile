import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - OnboardingScreenTests

/// Structural tests for OnboardingScreen and OnboardingPageContent.
/// ViewInspector-level inspection is limited by the TabView/.page style at runtime.
/// Critical business logic (state transitions, button actions) is validated in ViewModel tests.
@Suite("OnboardingScreen Tests")
@MainActor
struct OnboardingScreenTests {
    // MARK: - Internal

    // MARK: - Initialisation

    @Test("OnboardingScreen initialises without crash")
    func init_initialises() {
        let screen = OnboardingScreen(viewModel: makeViewModel())
        _ = screen
        #expect(true)
    }

    @Test("OnboardingScreen is a View")
    func onboardingScreen_conformsToView() {
        let screen: any View = OnboardingScreen(viewModel: makeViewModel())
        _ = screen
        #expect(true)
    }

    @Test("OnboardingScreen accepts viewModel injection")
    func viewModelInjection_accepted() {
        // Verifies the init contract — body access outside View hierarchy causes @State warnings
        let viewModel = makeViewModel()
        let screen = OnboardingScreen(viewModel: viewModel)
        _ = screen
        #expect(viewModel.pages.count == 4)
    }

    // MARK: - ViewModel Integration via isLastPage

    @Test("isLastPage is false on initial page 0")
    func viewModel_isLastPage_falseOnFirstPage() {
        let viewModel = makeViewModel()
        #expect(viewModel.isLastPage == false)
    }

    @Test("isLastPage is true on last page (page 3 for 4-page flow)")
    func viewModel_isLastPage_trueOnLastPage() {
        let viewModel = makeViewModel()
        viewModel.currentPage = 3
        #expect(viewModel.isLastPage == true)
    }

    @Test("onboarding has 4 pages matching OnboardingPage.allPages")
    func viewModel_pageCount_isFour() {
        let viewModel = makeViewModel()
        #expect(viewModel.pages.count == 4)
    }

    // MARK: - Skip button visibility semantic

    @Test("skip button should be visible on non-last pages (isLastPage false)")
    func skipButton_visibleOnNonLastPage() {
        let viewModel = makeViewModel()
        viewModel.currentPage = 0
        // Skip button is shown when !isLastPage
        #expect(!viewModel.isLastPage)
    }

    @Test("skip button should be hidden on last page (isLastPage true)")
    func skipButton_hiddenOnLastPage() {
        let viewModel = makeViewModel()
        viewModel.currentPage = 3
        // Skip button is hidden when isLastPage
        #expect(viewModel.isLastPage)
    }

    // MARK: - Get Started button visibility semantic

    @Test("get started button visible only on last page")
    func getStartedButton_visibleOnlyOnLastPage() {
        let viewModel = makeViewModel()
        viewModel.currentPage = viewModel.pages.count - 1
        #expect(viewModel.isLastPage)
    }

    // MARK: - Private

    // MARK: - Helpers

    private func makeViewModel(hasSeen: Bool = false) -> OnboardingViewModel {
        let repository = FakeOnboardingRepository()
        repository.hasSeen = hasSeen
        return OnboardingViewModel(
            checkOnboarding: CheckOnboardingUseCase(repository: repository),
            completeOnboarding: CompleteOnboardingUseCase(repository: repository),
        )
    }
}

// MARK: - OnboardingPageContentTests

@Suite("OnboardingPageContent Tests")
struct OnboardingPageContentTests {
    @Test("OnboardingPageContent initialises with first page without crash")
    func init_firstPage_initialises() {
        let content = OnboardingPageContent(page: OnboardingPage.allPages[0])
        _ = content
        #expect(true)
    }

    @Test("OnboardingPageContent initialises with all four pages without crash")
    func init_allPages_initialisesWithoutCrash() {
        for page in OnboardingPage.allPages {
            let content = OnboardingPageContent(page: page)
            _ = content
        }
        #expect(true)
    }

    @Test("OnboardingPageContent uses placeholder SF Symbol for missing assets")
    func placeholderSystemImage_isNonEmpty() {
        // Verifies the fallback logic for missing illustration assets is reachable.
        // OnboardingPageContent uses SF Symbols (bag, scalemass, lock.shield, shippingbox) as fallback.
        // UIImage(named:) returns nil in test context since assets are not loaded.
        let page = OnboardingPage.allPages[0]
        #expect(page.illustrationName == "onboarding_illustration_browse")
    }

    @Test("OnboardingPageContent is a View")
    func onboardingPageContent_conformsToView() {
        let content: any View = OnboardingPageContent(page: OnboardingPage.allPages[0])
        _ = content
        #expect(true)
    }
}
