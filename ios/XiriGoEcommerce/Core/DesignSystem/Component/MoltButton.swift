import SwiftUI

// MARK: - MoltButtonStyle

enum MoltButtonVariant {
    case primary
    case secondary
    case outlined
    case text
}

// MARK: - MoltButton

struct MoltButton: View {
    // MARK: - Properties

    private let title: String
    private let action: () -> Void
    private let variant: MoltButtonVariant
    private let isEnabled: Bool
    private let isLoading: Bool
    private let leadingIcon: String?
    private let fullWidth: Bool

    // MARK: - Init

    init(
        _ title: String,
        variant: MoltButtonVariant = .primary,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        leadingIcon: String? = nil,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
        self.variant = variant
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.leadingIcon = leadingIcon
        self.fullWidth = fullWidth
    }

    // MARK: - Body

    var body: some View {
        Button(action: buttonAction) {
            buttonContent
        }
        .buttonStyle(MoltButtonStyleModifier(variant: variant))
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.38)
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .frame(minHeight: MoltSpacing.minTouchTarget)
        .accessibilityLabel(title)
        .accessibilityValue(isLoading ? String(localized: "common_loading") : "")
    }

    // MARK: - Private

    private var buttonAction: () -> Void {
        isLoading ? {} : action
    }

    @ViewBuilder
    private var buttonContent: some View {
        HStack(spacing: MoltSpacing.sm) {
            if isLoading {
                ProgressView()
                    .tint(textColor)
            }
            if let leadingIcon, !isLoading {
                Image(systemName: leadingIcon)
                    .font(.system(size: MoltSpacing.IconSize.medium))
                    .accessibilityHidden(true)
            }
            Text(title)
                .font(MoltTypography.labelLarge)
        }
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .padding(.horizontal, MoltSpacing.base)
        .padding(.vertical, MoltSpacing.md)
    }

    private var textColor: Color {
        switch variant {
        case .primary:
            return MoltColors.onPrimary

        case .secondary, .outlined, .text:
            return MoltColors.primary
        }
    }
}

// MARK: - MoltButtonStyleModifier

private struct MoltButtonStyleModifier: ButtonStyle {
    let variant: MoltButtonVariant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(background(isPressed: configuration.isPressed))
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.full))
            .overlay(borderOverlay)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
    }

    // MARK: - Private

    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return MoltColors.onPrimary

        case .secondary, .outlined, .text:
            return MoltColors.primary
        }
    }

    @ViewBuilder
    private func background(isPressed: Bool) -> some View {
        switch variant {
        case .primary:
            RoundedRectangle(cornerRadius: MoltCornerRadius.full)
                .fill(MoltColors.primary)

        case .secondary:
            RoundedRectangle(cornerRadius: MoltCornerRadius.full)
                .fill(MoltColors.secondaryContainer)

        case .outlined, .text:
            Color.clear
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch variant {
        case .outlined:
            RoundedRectangle(cornerRadius: MoltCornerRadius.full)
                .stroke(MoltColors.outline, lineWidth: 1)

        case .primary, .secondary, .text:
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview("MoltButton Primary") {
    MoltButton("Add to Cart") {}
        .padding()
}

#Preview("MoltButton Variants") {
    VStack(spacing: MoltSpacing.base) {
        MoltButton("Primary", variant: .primary) {}
        MoltButton("Secondary", variant: .secondary) {}
        MoltButton("Outlined", variant: .outlined) {}
        MoltButton("Text", variant: .text, fullWidth: false) {}
    }
    .padding()
}

#Preview("MoltButton Loading") {
    MoltButton("Loading", isLoading: true) {}
        .padding()
}

#Preview("MoltButton Disabled") {
    MoltButton("Disabled", isEnabled: false) {}
        .padding()
}

#Preview("MoltButton with Icon") {
    MoltButton("Add to Cart", leadingIcon: "cart") {}
        .padding()
}
