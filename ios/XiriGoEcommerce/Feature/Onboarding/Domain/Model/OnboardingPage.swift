import Foundation

// MARK: - OnboardingPage

/// Represents a single onboarding page with localized content references.
/// Content is driven by localized string keys and bundled illustration asset names.
struct OnboardingPage: Identifiable, Sendable, Equatable {
    let id: Int
    let titleKey: String.LocalizationValue
    let descriptionKey: String.LocalizationValue
    let illustrationName: String

    // MARK: - Page Indices

    enum Index {
        static let browse = 0
        static let compare = 1
        static let checkout = 2
        static let track = 3
    }
}

// MARK: - Static Pages

extension OnboardingPage {
    /// The four onboarding pages displayed to first-launch users.
    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            id: Index.browse,
            titleKey: "onboarding_page_browse_title",
            descriptionKey: "onboarding_page_browse_description",
            illustrationName: "onboarding_illustration_browse"
        ),
        OnboardingPage(
            id: Index.compare,
            titleKey: "onboarding_page_compare_title",
            descriptionKey: "onboarding_page_compare_description",
            illustrationName: "onboarding_illustration_compare"
        ),
        OnboardingPage(
            id: Index.checkout,
            titleKey: "onboarding_page_checkout_title",
            descriptionKey: "onboarding_page_checkout_description",
            illustrationName: "onboarding_illustration_checkout"
        ),
        OnboardingPage(
            id: Index.track,
            titleKey: "onboarding_page_track_title",
            descriptionKey: "onboarding_page_track_description",
            illustrationName: "onboarding_illustration_track"
        ),
    ]
}
