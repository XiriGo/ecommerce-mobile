import SwiftUI

// MARK: - MoltEmptyView

struct MoltEmptyView: View {
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
        VStack(spacing: MoltSpacing.base) {
            Image(systemName: systemImage)
                .font(.system(size: MoltSpacing.xxxl))
                .foregroundStyle(MoltColors.onSurfaceVariant)
                .accessibilityHidden(true)

            Text(message)
                .font(MoltTypography.bodyLarge)
                .foregroundStyle(MoltColors.onSurfaceVariant)
                .multilineTextAlignment(.center)

            if let actionLabel, let onAction {
                MoltButton(
                    actionLabel,
                    variant: .outlined,
                    fullWidth: false,
                    action: onAction
                )
            }
        }
        .padding(MoltSpacing.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("MoltEmptyView Default") {
    MoltEmptyView(
        message: String(localized: "common_empty_message")
    )
}

#Preview("MoltEmptyView with Action") {
    MoltEmptyView(
        message: "Your cart is empty",
        systemImage: "cart",
        actionLabel: "Browse Products",
        onAction: {}
    )
}
