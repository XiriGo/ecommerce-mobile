import SwiftUI

/// Async image component with shimmer placeholder and error fallback.
/// Token source: `components/atoms/xg-image.json`.
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
        AsyncImage(url: url) { phase in
            switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .transition(.opacity.animation(.easeInOut(duration: XGMotion.Crossfade.imageFadeIn)))

                case .failure:
                    placeholderView

                case .empty:
                    placeholderView

                @unknown default:
                    placeholderView
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? "")
        .accessibilityHidden(accessibilityLabel == nil)
    }

    // MARK: - Private

    private let url: URL?
    private let contentMode: ContentMode
    private let accessibilityLabel: String?

    private var placeholderView: some View {
        Rectangle()
            .fill(XGColors.shimmer)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: XGSpacing.IconSize.large))
                    .foregroundStyle(XGColors.onSurfaceVariant.opacity(0.5))
                    .accessibilityHidden(true)
            }
    }
}

// MARK: - Previews

#Preview("XGImage Placeholder") {
    XGImage(url: nil)
        .frame(width: 200, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .xgTheme()
}

#Preview("XGImage with URL") {
    XGImage(url: nil, accessibilityLabel: "Product photo")
        .frame(width: 200, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        .xgTheme()
}
