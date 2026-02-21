import SwiftUI

// MARK: - PlaceholderView

/// Temporary placeholder view for unimplemented screens.
/// Displays an icon, screen title, and "Coming soon" text.
struct PlaceholderView: View {
    // MARK: - Properties

    private let title: String
    private let systemImage: String

    // MARK: - Init

    init(title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: MoltSpacing.base) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: MoltSpacing.xxxl))
                .foregroundStyle(MoltColors.onSurfaceVariant)
                .accessibilityHidden(true)

            Text(title)
                .font(MoltTypography.headlineSmall)
                .foregroundStyle(MoltColors.onSurface)

            Text(String(localized: "nav_placeholder_coming_soon"))
                .font(MoltTypography.bodyMedium)
                .foregroundStyle(MoltColors.onSurfaceVariant)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MoltColors.background.ignoresSafeArea())
        .navigationTitle(title)
    }
}

// MARK: - Previews

#Preview("PlaceholderView") {
    NavigationStack {
        PlaceholderView(title: "Home", systemImage: "house")
    }
}
