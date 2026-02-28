import SwiftUI

// MARK: - XGFilterChip

struct XGFilterChip: View {
    // MARK: - Properties

    private let label: String
    private let isSelected: Bool
    private let leadingIcon: String?
    private let action: () -> Void

    // MARK: - Init

    init(
        label: String,
        isSelected: Bool = false,
        leadingIcon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.isSelected = isSelected
        self.leadingIcon = leadingIcon
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: XGSpacing.xs) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: XGSpacing.IconSize.small))
                } else if let leadingIcon {
                    Image(systemName: leadingIcon)
                        .font(.system(size: XGSpacing.IconSize.small))
                }

                Text(label)
                    .font(XGTypography.labelLarge)
            }
            .padding(.horizontal, XGSpacing.md)
            .padding(.vertical, XGSpacing.sm)
            .foregroundStyle(chipForeground)
            .background(chipBackground)
            .clipShape(Capsule())
            .overlay(chipBorder)
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Private

    private var chipForeground: Color {
        isSelected ? XGColors.onSecondaryContainer : XGColors.onSurfaceVariant
    }

    private var chipBackground: Color {
        isSelected ? XGColors.secondaryContainer : XGColors.surfaceVariant
    }

    @ViewBuilder
    private var chipBorder: some View {
        if !isSelected {
            Capsule()
                .stroke(XGColors.outline, lineWidth: 1)
        }
    }
}

// MARK: - XGCategoryChip

struct XGCategoryChip: View {
    // MARK: - Properties

    private let label: String
    private let iconUrl: URL?
    private let action: () -> Void

    // MARK: - Init

    init(
        label: String,
        iconUrl: URL? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.iconUrl = iconUrl
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: XGSpacing.sm) {
                if let iconUrl {
                    XGImage(url: iconUrl)
                        .frame(
                            width: XGSpacing.IconSize.medium,
                            height: XGSpacing.IconSize.medium
                        )
                        .clipShape(Circle())
                }

                Text(label)
                    .font(XGTypography.labelLarge)
                    .foregroundStyle(XGColors.onSurface)
            }
            .padding(.horizontal, XGSpacing.md)
            .padding(.vertical, XGSpacing.sm)
            .background(XGColors.surfaceVariant)
            .clipShape(Capsule())
        }
        .accessibilityLabel(label)
    }
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
