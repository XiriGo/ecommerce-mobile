import SwiftUI

// MARK: - XGImage

/// Async image component with animated shimmer loading and branded error fallback.
/// Token source: `components/atoms/xg-image.json`.
///
/// - Loading (`.empty`): Animated shimmer placeholder, no icon.
/// - Error (`.failure`): Static branded fallback with photo icon.
/// - Success: Fades in with `XGMotion.Crossfade.imageFadeIn`.
struct XGImage: View {
    // MARK: - Lifecycle

    init(
        url: URL?,
        contentMode: ContentMode = .fill,
        accessibilityLabel: String? = nil,
    ) {
        self.url = url
        self.contentMode = contentMode
        self.accessibilityLabel = accessibilityLabel
    }

    // MARK: - Internal

    var body: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                            .transition(.opacity.animation(.easeInOut(duration: XGMotion.Crossfade.imageFadeIn)))

                    case .failure:
                        errorFallbackView

                    case .empty:
                        loadingView

                    @unknown default:
                        loadingView
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel ?? "")
            .accessibilityHidden(accessibilityLabel == nil)
        } else {
            errorFallbackView
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityLabel ?? "")
                .accessibilityHidden(accessibilityLabel == nil)
        }
    }

    // MARK: - Private

    /// Opacity applied to the error fallback icon.
    private static let errorIconOpacity: Double = 0.5

    private let url: URL?
    private let contentMode: ContentMode
    private let accessibilityLabel: String?

    /// Animated shimmer placeholder shown while the image is loading.
    private var loadingView: some View {
        Rectangle()
            .fill(XGColors.shimmer)
            .shimmerEffect()
            .accessibilityHidden(true)
    }

    /// Static branded fallback shown when the image fails to load.
    private var errorFallbackView: some View {
        Rectangle()
            .fill(XGColors.surfaceVariant)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: XGSpacing.IconSize.large))
                    .foregroundStyle(XGColors.onSurfaceVariant.opacity(Self.errorIconOpacity))
                    .accessibilityHidden(true)
            }
    }
}

// MARK: - PreviewConstants

private enum PreviewConstants {
    static let width: CGFloat = 200
    static let height: CGFloat = 150
}

// MARK: - Previews

#Preview("XGImage Loading") {
    XGImage(url: nil)
        .frame(width: PreviewConstants.width, height: PreviewConstants.height)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .xgTheme()
}

#Preview("XGImage with URL") {
    XGImage(url: nil, accessibilityLabel: "Product photo")
        .frame(width: PreviewConstants.width, height: PreviewConstants.height)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .xgTheme()
}

#Preview("XGImage Error") {
    // Simulates the error fallback by using a broken URL scheme.
    XGImage(
        url: URL(string: "invalid://broken"),
        accessibilityLabel: "Failed product photo",
    )
    .frame(width: PreviewConstants.width, height: PreviewConstants.height)
    .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
    .xgTheme()
}
