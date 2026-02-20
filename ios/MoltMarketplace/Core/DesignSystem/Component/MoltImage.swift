import SwiftUI

// MARK: - MoltImage

struct MoltImage: View {
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
            .fill(MoltColors.shimmer)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: MoltSpacing.IconSize.large))
                    .foregroundStyle(MoltColors.onSurfaceVariant.opacity(0.5))
            }
    }
}

// MARK: - Previews

#Preview("MoltImage Placeholder") {
    MoltImage(url: nil)
        .frame(width: 200, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.medium))
}

#Preview("MoltImage with URL") {
    MoltImage(url: URL(string: "https://picsum.photos/400/300"))
        .frame(width: 200, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.medium))
}
