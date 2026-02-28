import SwiftUI

// MARK: - OnboardingScreen

/// Horizontal pager with 4 onboarding pages, pagination dots, Skip button, and Get Started button.
/// Uses `TabView` with `.page` style for swipeable content.
struct OnboardingScreen: View {
    // MARK: - Internal

    @Bindable var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        XGBrandGradient {
            ZStack {
                pagerContent

                skipButton

                bottomControls
            }
        }
    }

    // MARK: - Private

    // MARK: - Constants

    private enum Constants {
        static let inactiveDotOpacity: Double = 0.4
        static let getStartedHorizontalPadding: CGFloat = 20
    }

    // MARK: - Pager

    private var pagerContent: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(viewModel.pages) { page in
                OnboardingPageContent(page: page)
                    .tag(page.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    // MARK: - Skip Button

    @ViewBuilder
    private var skipButton: some View {
        if !viewModel.isLastPage {
            VStack {
                HStack {
                    Spacer()
                    XGButton(
                        String(localized: "onboarding_skip_button"),
                        variant: .text,
                        fullWidth: false,
                    ) {
                        Task { await viewModel.onSkip() }
                    }
                    .accessibilityLabel(String(localized: "onboarding_skip_button_a11y"))
                    .padding(.trailing, XGSpacing.xs)
                    .padding(.top, XGSpacing.base)
                }
                Spacer()
            }
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack {
            Spacer()

            if viewModel.isLastPage {
                getStartedButton
            }

            XGPaginationDots(
                totalPages: viewModel.pages.count,
                currentPage: viewModel.currentPage,
                activeColor: .white,
                inactiveColor: .white.opacity(Constants.inactiveDotOpacity),
            )
            .padding(.bottom, XGSpacing.xl)
        }
    }

    // MARK: - Get Started Button

    private var getStartedButton: some View {
        XGButton(
            String(localized: "onboarding_get_started_button"),
            variant: .primary,
        ) {
            Task { await viewModel.onGetStarted() }
        }
        .padding(.horizontal, Constants.getStartedHorizontalPadding)
        .padding(.bottom, XGSpacing.xxl)
    }
}

// MARK: - Previews

#Preview("OnboardingScreen") {
    OnboardingScreen(
        viewModel: OnboardingViewModel(
            checkOnboarding: CheckOnboardingUseCase(
                repository: PreviewOnboardingRepository(),
            ),
            completeOnboarding: CompleteOnboardingUseCase(
                repository: PreviewOnboardingRepository(),
            ),
        ),
    )
}

// MARK: - PreviewOnboardingRepository

/// In-memory repository for SwiftUI previews.
private final class PreviewOnboardingRepository: OnboardingRepository, @unchecked Sendable {
    // MARK: - Internal

    func hasSeenOnboarding() async -> Bool {
        hasSeen
    }

    func setOnboardingSeen() async {
        hasSeen = true
    }

    // MARK: - Private

    private var hasSeen = false
}
