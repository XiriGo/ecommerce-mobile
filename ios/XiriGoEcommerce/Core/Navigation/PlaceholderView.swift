import SwiftUI

// MARK: - PlaceholderView

/// Temporary placeholder view for unimplemented screens.
/// Displays an icon, screen title, and "Coming soon" text.
struct PlaceholderView: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        VStack(spacing: XGSpacing.base) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: XGSpacing.xxxl))
                .foregroundStyle(XGColors.onSurfaceVariant)
                .accessibilityHidden(true)

            Text(title)
                .font(XGTypography.headlineSmall)
                .foregroundStyle(XGColors.onSurface)

            Text(String(localized: "nav_placeholder_coming_soon"))
                .font(XGTypography.bodyMedium)
                .foregroundStyle(XGColors.onSurfaceVariant)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(XGColors.background.ignoresSafeArea())
        .navigationTitle(title)
    }

    // MARK: - Private

    private let title: String
    private let systemImage: String
}

// MARK: - Previews

#Preview("PlaceholderView") {
    NavigationStack {
        PlaceholderView(title: "Home", systemImage: "house")
    }
}
