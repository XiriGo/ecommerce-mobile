import SwiftUI

// MARK: - FilterChipTokens

// Token source: shared/design-tokens/components/atoms/xg-chip.json

private enum FilterChipTokens {
    /// Height from token `variants.filter.height` = 36.
    static let height: CGFloat = 36

    /// Corner radius from token `variants.filter.cornerRadius` = 18.
    static let cornerRadius: CGFloat = 18

    /// Horizontal padding from token `variants.filter.horizontalPadding` = 16.
    static let horizontalPadding: CGFloat = XGSpacing.base

    /// Gap between icon and text from token `variants.filter.gap` = 8.
    static let gap: CGFloat = XGSpacing.sm
}

// MARK: - XGFilterChip

struct XGFilterChip: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        label: String,
        isSelected: Bool = false,
        leadingIcon: String? = nil,
        action: @escaping () -> Void,
    ) {
        self.label = label
        self.isSelected = isSelected
        self.leadingIcon = leadingIcon
        self.action = action
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: FilterChipTokens.gap) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: XGSpacing.IconSize.small))
                } else if let leadingIcon {
                    Image(systemName: leadingIcon)
                        .font(.system(size: XGSpacing.IconSize.small))
                }

                Text(label)
                    .font(XGTypography.bodyMedium)
            }
            .padding(.horizontal, FilterChipTokens.horizontalPadding)
            .frame(height: FilterChipTokens.height)
            .foregroundStyle(chipForeground)
            .background(chipBackground)
            .clipShape(RoundedRectangle(cornerRadius: FilterChipTokens.cornerRadius))
            .overlay(chipBorder)
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Private

    private let label: String
    private let isSelected: Bool
    private let leadingIcon: String?
    private let action: () -> Void

    private var chipForeground: Color {
        isSelected ? XGColors.filterPillTextActive : XGColors.filterPillText
    }

    private var chipBackground: Color {
        isSelected ? XGColors.filterPillBackgroundActive : XGColors.filterPillBackground
    }

    @ViewBuilder
    private var chipBorder: some View {
        if !isSelected {
            RoundedRectangle(cornerRadius: FilterChipTokens.cornerRadius)
                .stroke(XGColors.outline, lineWidth: 1)
        }
    }
}

// MARK: - XGCategoryChip

struct XGCategoryChip: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        label: String,
        iconUrl: URL? = nil,
        action: @escaping () -> Void,
    ) {
        self.label = label
        self.iconUrl = iconUrl
        self.action = action
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: XGSpacing.sm) {
                if let iconUrl {
                    XGImage(url: iconUrl)
                        .frame(
                            width: XGSpacing.IconSize.medium,
                            height: XGSpacing.IconSize.medium,
                        )
                        .clipShape(Circle())
                }

                Text(label)
                    .font(XGTypography.labelLarge)
                    .foregroundStyle(XGColors.onSurface)
            }
            .padding(.horizontal, XGSpacing.md)
            .padding(.vertical, XGSpacing.sm)
            .background(XGColors.surfaceTertiary)
            .clipShape(Capsule())
        }
        .accessibilityLabel(label)
    }

    // MARK: - Private

    private let label: String
    private let iconUrl: URL?
    private let action: () -> Void
}

// MARK: - Previews

#Preview("XGFilterChip") {
    HStack(spacing: XGSpacing.sm) {
        XGFilterChip(label: "All", isSelected: true) {}
        XGFilterChip(label: "Electronics") {}
        XGFilterChip(label: "Fashion", leadingIcon: "tag") {}
    }
    .padding()
}

#Preview("XGCategoryChip") {
    HStack(spacing: XGSpacing.sm) {
        XGCategoryChip(label: "Electronics") {}
        XGCategoryChip(label: "Fashion") {}
    }
    .padding()
}
