import SwiftUI

/// Tappable search bar placeholder that navigates to the search screen.
/// Token source: `shared/design-tokens/components/atoms/xg-search-bar.json`.
///
/// - Background: `XGColors.inputBackground` (`colors.light.inputBackground`)
/// - Border: `XGColors.outlineVariant` (`colors.light.borderSubtle`), 1 pt
/// - Corner radius: `XGCornerRadius.pill` (`cornerRadius.pill` = 28 pt)
/// - Icon: magnifyingglass, `XGSpacing.IconSize.medium` (24 pt), `XGColors.onSurfaceVariant`
/// - Placeholder font: `XGTypography.bodyLarge` (16 pt Poppins Regular)
/// - Placeholder color: `XGColors.onSurfaceVariant` (`colors.light.textSecondary`)
/// - Padding: horizontal = `XGSpacing.md`, vertical = `XGSpacing.md`
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
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.pill))
            .overlay(
                RoundedRectangle(cornerRadius: XGCornerRadius.pill)
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
