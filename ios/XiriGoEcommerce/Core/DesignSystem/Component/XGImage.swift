import SwiftUI

// MARK: - XGImage

struct XGImage: View {
    // MARK: - Properties

    private let url: URL?
    private let contentMode: ContentMode

    // MARK: - Init

    init(
        url: URL?,
        contentMode: ContentMode = .fill
    ) {
        self.url = url
        self.contentMode = contentMode
    }

    // MARK: - Body

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity.animation(.easeInOut(duration: 0.25)))

            case .failure:
                placeholderView

            case .empty:
                placeholderView

            @unknown default:
                placeholderView
            }
        }
    }

    // MARK: - Private

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
}

#Preview("XGImage with URL") {
    XGImage(url: URL(string: "https://picsum.photos/400/300"))
        .frame(width: 200, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
}
