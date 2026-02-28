import SwiftUI

// MARK: - XGButtonStyle

enum XGButtonVariant {
    case primary
    case secondary
    case outlined
    case text
}

// MARK: - XGButton

struct XGButton: View {
    // MARK: - Properties

    private let title: String
    private let action: () -> Void
    private let variant: XGButtonVariant
    private let isEnabled: Bool
    private let isLoading: Bool
    private let leadingIcon: String?
    private let fullWidth: Bool

    // MARK: - Init

    init(
        _ title: String,
        variant: XGButtonVariant = .primary,
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
        .buttonStyle(XGButtonStyleModifier(variant: variant))
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.38)
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .frame(minHeight: XGSpacing.minTouchTarget)
        .accessibilityLabel(title)
        .accessibilityValue(isLoading ? String(localized: "common_loading") : "")
    }

    // MARK: - Private

    private var buttonAction: () -> Void {
        isLoading ? {} : action
    }

    @ViewBuilder
    private var buttonContent: some View {
        HStack(spacing: XGSpacing.sm) {
            if isLoading {
                ProgressView()
                    .tint(textColor)
            }
            if let leadingIcon, !isLoading {
                Image(systemName: leadingIcon)
                    .font(.system(size: XGSpacing.IconSize.medium))
                    .accessibilityHidden(true)
            }
            Text(title)
                .font(XGTypography.labelLarge)
        }
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .padding(.horizontal, XGSpacing.base)
        .padding(.vertical, XGSpacing.md)
    }

    private var textColor: Color {
        switch variant {
        case .primary:
            return XGColors.onPrimary

        case .secondary, .outlined, .text:
            return XGColors.primary
        }
    }
}

// MARK: - XGButtonStyleModifier

private struct XGButtonStyleModifier: ButtonStyle {
    let variant: XGButtonVariant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(background(isPressed: configuration.isPressed))
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.full))
            .overlay(borderOverlay)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
    }

    // MARK: - Private

    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return XGColors.onPrimary

        case .secondary, .outlined, .text:
            return XGColors.primary
        }
    }

    @ViewBuilder
    private func background(isPressed: Bool) -> some View {
        switch variant {
        case .primary:
            RoundedRectangle(cornerRadius: XGCornerRadius.full)
                .fill(XGColors.primary)

        case .secondary:
            RoundedRectangle(cornerRadius: XGCornerRadius.full)
                .fill(XGColors.secondaryContainer)

        case .outlined, .text:
            Color.clear
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch variant {
        case .outlined:
            RoundedRectangle(cornerRadius: XGCornerRadius.full)
                .stroke(XGColors.outline, lineWidth: 1)

        case .primary, .secondary, .text:
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview("XGButton Primary") {
    XGButton("Add to Cart") {}
        .padding()
}

#Preview("XGButton Variants") {
    VStack(spacing: XGSpacing.base) {
        XGButton("Primary", variant: .primary) {}
        XGButton("Secondary", variant: .secondary) {}
        XGButton("Outlined", variant: .outlined) {}
        XGButton("Text", variant: .text, fullWidth: false) {}
    }
    .padding()
}

#Preview("XGButton Loading") {
    XGButton("Loading", isLoading: true) {}
        .padding()
}

#Preview("XGButton Disabled") {
    XGButton("Disabled", isEnabled: false) {}
        .padding()
}

#Preview("XGButton with Icon") {
    XGButton("Add to Cart", leadingIcon: "cart") {}
        .padding()
}
