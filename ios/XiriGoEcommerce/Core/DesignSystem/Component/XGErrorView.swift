import SwiftUI

// MARK: - XGErrorView

/// Full-screen error state with crossfade transition.
///
/// Crossfades between content and the error layout (icon + message + retry button)
/// using ``XGMotion/Crossfade/contentSwitch`` (0.2s). When `isError` is `true`,
/// the error layout is shown. When `false`, the content slot is shown.
///
/// Usage with crossfade:
/// ```swift
/// XGErrorView(
///     message: "Something went wrong",
///     isError: viewModel.hasError,
///     onRetry: { viewModel.retry() }
/// ) {
///     ProductDetailContent(product: product)
/// }
/// ```
///
/// Usage without crossfade (backward compatible):
/// ```swift
/// XGErrorView(message: "Something went wrong", onRetry: { viewModel.retry() })
/// ```
struct XGErrorView<Content: View>: View {
    // MARK: - Lifecycle

    /// Creates an error view with crossfade transition.
    ///
    /// - Parameters:
    ///   - message: Error message to display.
    ///   - isError: When `true`, shows the error layout. When `false`, shows content.
    ///   - onRetry: Optional retry callback. When non-nil, a retry button is shown.
    ///   - content: Content to show when `isError` is `false`.
    init(
        message: String,
        isError: Bool,
        onRetry: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
    ) {
        self.message = message
        self.isError = isError
        self.onRetry = onRetry
        self.content = content()
    }

    // MARK: - Internal

    var body: some View {
        Group {
            if isError {
                ErrorContent(message: message, onRetry: onRetry)
                    .transition(.opacity)
            } else {
                content
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: XGMotion.Crossfade.contentSwitch),
            value: isError,
        )
    }

    // MARK: - Private

    private let message: String
    private let isError: Bool
    private let onRetry: (() -> Void)?
    private let content: Content
}

// MARK: - XGErrorView convenience (no crossfade)

extension XGErrorView where Content == EmptyView {
    /// Creates a static error view without crossfade (backward compatible).
    ///
    /// - Parameters:
    ///   - message: Error message to display.
    ///   - onRetry: Optional retry callback. When non-nil, a retry button is shown.
    init(
        message: String,
        onRetry: (() -> Void)? = nil,
    ) {
        self.message = message
        isError = true
        self.onRetry = onRetry
        content = EmptyView()
    }
}

// MARK: - ErrorContent

/// Internal error content layout: icon + message + optional retry button.
private struct ErrorContent: View {
    let message: String
    let onRetry: (() -> Void)?

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

#Preview("XGErrorView — Crossfade Error") {
    XGErrorView(
        message: "Something went wrong",
        isError: true,
        onRetry: {},
        content: {
            Text(verbatim: "Content loaded!")
                .padding(XGSpacing.base)
        },
    )
    .xgTheme()
}

#Preview("XGErrorView — Crossfade Content") {
    XGErrorView(
        message: "Something went wrong",
        isError: false,
        onRetry: {},
        content: {
            Text(verbatim: "Content loaded!")
                .padding(XGSpacing.base)
        },
    )
    .xgTheme()
}

// MARK: - XGErrorViewInteractiveDemo

/// Interactive demo showing the crossfade transition between content and error.
private struct XGErrorViewInteractiveDemo: View {
    // MARK: - Internal

    var body: some View {
        VStack {
            XGErrorView(
                message: "Something went wrong",
                isError: isError,
                onRetry: { isError = false },
                content: {
                    Text(verbatim: "Real content loaded!")
                        .padding(XGSpacing.base)
                },
            )

            Button {
                isError.toggle()
            } label: {
                Text(verbatim: isError ? "Show Content" : "Show Error")
            }
            .padding(XGSpacing.base)
        }
    }

    // MARK: - Private

    @State private var isError = false
}

#Preview("XGErrorView — Interactive Toggle") {
    XGErrorViewInteractiveDemo()
        .xgTheme()
}
