import SwiftUI

// MARK: - OnboardingScreen

/// Horizontal pager with 4 onboarding pages, pagination dots, Skip button, and Get Started button.
/// Uses `TabView` with `.page` style for swipeable content.
struct OnboardingScreen: View {
    // MARK: - Properties

    @State private var viewModel: OnboardingViewModel

    // MARK: - Init

    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

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
                    Button {
                        Task { await viewModel.onSkip() }
                    } label: {
                        Text(String(localized: "onboarding_skip_button"))
                            .font(XGTypography.labelLarge)
                            .foregroundStyle(.white)
                            .padding(.horizontal, XGSpacing.base)
                            .padding(.vertical, XGSpacing.sm)
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
                pageCount: viewModel.pages.count,
                currentPage: viewModel.currentPage,
                activeColor: .white,
                inactiveColor: .white.opacity(0.4)
            )
            .padding(.bottom, XGSpacing.xl)
        }
    }

    // MARK: - Get Started Button

    private var getStartedButton: some View {
        Button {
            Task { await viewModel.onGetStarted() }
        } label: {
            Text(String(localized: "onboarding_get_started_button"))
                .font(XGTypography.labelLarge)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: "#6000FE"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(hex: "#94D63A"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, XGSpacing.xxl)
    }
}

// MARK: - Previews

#Preview("OnboardingScreen") {
    OnboardingScreen(
        viewModel: OnboardingViewModel(
            checkOnboarding: CheckOnboardingUseCase(
                repository: PreviewOnboardingRepository()
            ),
            completeOnboarding: CompleteOnboardingUseCase(
                repository: PreviewOnboardingRepository()
            )
        )
    )
}

// MARK: - Preview Helper

/// In-memory repository for SwiftUI previews.
private final class PreviewOnboardingRepository: OnboardingRepository, @unchecked Sendable {
    private var hasSeen = false

    func hasSeenOnboarding() async -> Bool {
        hasSeen
    }

    func setOnboardingSeen() async {
        hasSeen = true
    }
}
