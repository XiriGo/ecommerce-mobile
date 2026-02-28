import SwiftUI

// MARK: - XGEmptyView

struct XGEmptyView: View {
    // MARK: - Properties

    private let message: String
    private let systemImage: String
    private let actionLabel: String?
    private let onAction: (() -> Void)?

    // MARK: - Init

    init(
        message: String,
        systemImage: String = "tray",
        actionLabel: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.message = message
        self.systemImage = systemImage
        self.actionLabel = actionLabel
        self.onAction = onAction
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: XGSpacing.base) {
            Image(systemName: systemImage)
                .font(.system(size: XGSpacing.xxxl))
                .foregroundStyle(XGColors.onSurfaceVariant)
                .accessibilityHidden(true)

            Text(message)
                .font(XGTypography.bodyLarge)
                .foregroundStyle(XGColors.onSurfaceVariant)
                .multilineTextAlignment(.center)

            if let actionLabel, let onAction {
                XGButton(
                    actionLabel,
                    variant: .outlined,
                    fullWidth: false,
                    action: onAction
                )
            }
        }
        .padding(XGSpacing.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("XGEmptyView Default") {
    XGEmptyView(
        message: String(localized: "common_empty_message")
    )
}

#Preview("XGEmptyView with Action") {
    XGEmptyView(
        message: "Your cart is empty",
        systemImage: "cart",
        actionLabel: "Browse Products",
        onAction: {}
    )
}
