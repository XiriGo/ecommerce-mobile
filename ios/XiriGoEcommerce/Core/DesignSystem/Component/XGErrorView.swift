import SwiftUI

// MARK: - XGErrorView

struct XGErrorView: View {
    // MARK: - Lifecycle

    // MARK: - Init

    init(
        message: String,
        onRetry: (() -> Void)? = nil,
    ) {
        self.message = message
        self.onRetry = onRetry
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        VStack(spacing: XGSpacing.base) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: XGSpacing.IconSize.extraLarge))
                .foregroundStyle(XGColors.error)
                .accessibilityHidden(true)

            Text(message)
                .font(XGTypography.bodyLarge)
                .foregroundStyle(XGColors.onSurface)
                .multilineTextAlignment(.center)

            if let onRetry {
                XGButton(
                    String(localized: "common_retry_button"),
                    variant: .outlined,
                    fullWidth: false,
                    action: onRetry,
                )
            }
        }
        .padding(XGSpacing.base)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Private

    private let message: String
    private let onRetry: (() -> Void)?
}

// MARK: - Previews

#Preview("XGErrorView with Retry") {
    XGErrorView(
        message: String(localized: "common_error_generic"),
        onRetry: {},
    )
    .xgTheme()
}

#Preview("XGErrorView without Retry") {
    XGErrorView(
        message: "Network connection lost",
    )
    .xgTheme()
}
