import SwiftUI

// MARK: - OnboardingPageContent

/// Single onboarding page view displaying an illustration, title, and description.
/// Content is driven by localized string keys from `OnboardingPage`.
struct OnboardingPageContent: View {
    // MARK: - Constants

    private enum Constants {
        static let illustrationSize: CGFloat = 200
        static let placeholderFontSize: CGFloat = 80
        static let placeholderOpacity: Double = 0.6
        static let titleLineLimit = 2
        static let descriptionOpacity: Double = 0.8
        static let descriptionLineLimit = 3
    }

    // MARK: - Properties

    private let page: OnboardingPage

    // MARK: - Init

    init(page: OnboardingPage) {
        self.page = page
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: XGSpacing.md) {
            Spacer()

            illustration

            Spacer()
                .frame(height: XGSpacing.lg)

            title

            description
        }
        .padding(.horizontal, XGSpacing.xl)
    }

    // MARK: - Private

    @ViewBuilder
    private var illustration: some View {
        if let uiImage = UIImage(named: page.illustrationName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(
                    width: Constants.illustrationSize,
                    height: Constants.illustrationSize
                )
                .accessibilityLabel(illustrationAccessibilityLabel)
        } else {
            Image(systemName: placeholderSystemImage)
                .font(.system(size: Constants.placeholderFontSize))
                .foregroundStyle(.white.opacity(Constants.placeholderOpacity))
                .frame(
                    width: Constants.illustrationSize,
                    height: Constants.illustrationSize
                )
                .accessibilityLabel(illustrationAccessibilityLabel)
        }
    }

    private var title: some View {
        Text(String(localized: page.titleKey))
            .font(XGTypography.headlineSmall)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineLimit(Constants.titleLineLimit)
            .accessibilityAddTraits(.isHeader)
    }

    private var description: some View {
        Text(String(localized: page.descriptionKey))
            .font(XGTypography.bodyLarge)
            .foregroundStyle(.white.opacity(Constants.descriptionOpacity))
            .multilineTextAlignment(.center)
            .lineLimit(Constants.descriptionLineLimit)
    }

    /// SF Symbol fallback for when illustration assets are not yet provided.
    private var placeholderSystemImage: String {
        switch page.id {
        case 0: return "bag"

        case 1: return "scalemass"

        case 2: return "lock.shield"

        case 3: return "shippingbox"

        default: return "photo"
        }
    }

    private var illustrationAccessibilityLabel: String {
        switch page.id {
        case 0:
            return String(localized: "onboarding_illustration_a11y_browse")

        case 1:
            return String(localized: "onboarding_illustration_a11y_compare")

        case 2:
            return String(localized: "onboarding_illustration_a11y_checkout")

        case 3:
            return String(localized: "onboarding_illustration_a11y_track")

        default:
            return ""
        }
    }
}

// MARK: - Previews

#Preview("OnboardingPageContent Browse") {
    ZStack {
        Color(hex: "#6000FE")
            .ignoresSafeArea()
        OnboardingPageContent(page: OnboardingPage.allPages[0])
    }
}

#Preview("OnboardingPageContent Track") {
    ZStack {
        Color(hex: "#6000FE")
            .ignoresSafeArea()
        OnboardingPageContent(page: OnboardingPage.allPages[3])
    }
}
