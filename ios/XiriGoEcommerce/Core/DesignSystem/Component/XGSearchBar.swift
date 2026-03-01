import SwiftUI

/// Tappable search bar placeholder that navigates to the search screen.
/// Token source: `components/atoms/xg-search-bar.json`.
///
/// - Background: inputBackground
/// - Border: outlineVariant
/// - Corner radius: full (pill)
/// - Icon: magnifyingglass, onSurfaceVariant
/// - Placeholder font: bodyLarge
struct XGSearchBar: View {
    // MARK: - Lifecycle

    init(
        placeholder: String,
        action: @escaping () -> Void,
    ) {
        self.placeholder = placeholder
        self.action = action
    }

    // MARK: - Internal

    var body: some View {
        Button(action: action) {
            HStack(spacing: XGSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .font(.system(size: XGSpacing.IconSize.medium))
                    .accessibilityHidden(true)

                Text(placeholder)
                    .font(XGTypography.bodyLarge)
                    .foregroundStyle(XGColors.onSurfaceVariant)

                Spacer()
            }
            .padding(.horizontal, XGSpacing.md)
            .padding(.vertical, XGSpacing.md)
            .background(XGColors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.full))
            .overlay(
                RoundedRectangle(cornerRadius: XGCornerRadius.full)
                    .stroke(XGColors.outlineVariant, lineWidth: 1),
            )
        }
        .accessibilityLabel(placeholder)
    }

    // MARK: - Private

    private let placeholder: String
    private let action: () -> Void
}

// MARK: - Previews

#Preview("XGSearchBar") {
    XGSearchBar(
        placeholder: "Search products...",
        action: {},
    )
    .padding()
    .xgTheme()
}
