import SwiftUI

// MARK: - MoltErrorView

struct MoltErrorView: View {
    // MARK: - Properties

    private let message: String
    private let onRetry: (() -> Void)?

    // MARK: - Init

    init(
        message: String,
        onRetry: (() -> Void)? = nil
    ) {
        self.message = message
        self.onRetry = onRetry
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: MoltSpacing.base) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: MoltSpacing.IconSize.extraLarge))
                .foregroundStyle(MoltColors.error)
                .accessibilityHidden(true)

            Text(message)
                .font(MoltTypography.bodyLarge)
                .foregroundStyle(MoltColors.onSurface)
                .multilineTextAlignment(.center)

            if let onRetry {
                MoltButton(
                    String(localized: "common_retry_button"),
                    variant: .outlined,
                    fullWidth: false,
                    action: onRetry
                )
            }
        }
        .padding(MoltSpacing.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("MoltErrorView with Retry") {
    MoltErrorView(
        message: String(localized: "common_error_generic"),
        onRetry: {}
    )
}

#Preview("MoltErrorView without Retry") {
    MoltErrorView(
        message: "Network connection lost"
    )
}
