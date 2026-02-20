import SwiftUI

// MARK: - MoltFilterChip

struct MoltFilterChip: View {
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
            HStack(spacing: MoltSpacing.xs) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: MoltSpacing.IconSize.small))
                } else if let leadingIcon {
                    Image(systemName: leadingIcon)
                        .font(.system(size: MoltSpacing.IconSize.small))
                }

                Text(label)
                    .font(MoltTypography.labelLarge)
            }
            .padding(.horizontal, MoltSpacing.md)
            .padding(.vertical, MoltSpacing.sm)
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
        isSelected ? MoltColors.onSecondaryContainer : MoltColors.onSurfaceVariant
    }

    private var chipBackground: Color {
        isSelected ? MoltColors.secondaryContainer : MoltColors.surfaceVariant
    }

    @ViewBuilder
    private var chipBorder: some View {
        if !isSelected {
            Capsule()
                .stroke(MoltColors.outline, lineWidth: 1)
        }
    }
}

// MARK: - MoltCategoryChip

struct MoltCategoryChip: View {
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
            HStack(spacing: MoltSpacing.sm) {
                if let iconUrl {
                    MoltImage(url: iconUrl)
                        .frame(
                            width: MoltSpacing.IconSize.medium,
                            height: MoltSpacing.IconSize.medium
                        )
                        .clipShape(Circle())
                }

                Text(label)
                    .font(MoltTypography.labelLarge)
                    .foregroundStyle(MoltColors.onSurface)
            }
            .padding(.horizontal, MoltSpacing.md)
            .padding(.vertical, MoltSpacing.sm)
            .background(MoltColors.surfaceVariant)
            .clipShape(Capsule())
        }
        .accessibilityLabel(label)
    }
}

// MARK: - Previews

#Preview("MoltFilterChip") {
    HStack(spacing: MoltSpacing.sm) {
        MoltFilterChip(label: "All", isSelected: true) {}
        MoltFilterChip(label: "Electronics") {}
        MoltFilterChip(label: "Fashion", leadingIcon: "tag") {}
    }
    .padding()
}

#Preview("MoltCategoryChip") {
    HStack(spacing: MoltSpacing.sm) {
        MoltCategoryChip(label: "Electronics") {}
        MoltCategoryChip(label: "Fashion") {}
    }
    .padding()
}
