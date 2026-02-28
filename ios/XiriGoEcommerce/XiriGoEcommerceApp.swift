import Factory
import SwiftUI

// MARK: - XiriGoEcommerceApp

@main
struct XiriGoEcommerceApp: App {
    // MARK: - Properties

    @State private var viewModel = Container.shared.onboardingViewModel()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            rootView
                .task { await viewModel.checkOnboardingStatus() }
        }
    }

    // MARK: - Private

    @ViewBuilder
    private var rootView: some View {
        switch viewModel.uiState {
        case .loading:
            SplashScreen()

        case .showOnboarding:
            OnboardingScreen(viewModel: viewModel)

        case .onboardingComplete:
            MainTabView()
                .background(XGColors.background.ignoresSafeArea())
        }
    }
}
