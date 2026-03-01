import SwiftUI

// MARK: - XGHeroBanner

/// Hero banner card with async image background, gradient overlay, tag badge, and text content.
/// Token source: `components.json > XGCard.heroBanner`, `gradients.json > heroBannerOverlay`.
///
/// - Width: full width (350dp design reference)
/// - Height: 192pt
/// - Overlay: linear gradient from left (brand primary 90%) to right (transparent)
struct XGHeroBanner: View {
    // MARK: - Lifecycle

    init(
        title: String,
        subtitle: String,
        imageUrl: URL? = nil,
        tag: String? = nil,
        action: (() -> Void)? = nil,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.tag = tag
        self.action = action
    }

    // MARK: - Internal

    var body: some View {
        Button {
            action?()
        } label: {
            ZStack(alignment: .bottomLeading) {
                backgroundLayer

                gradientOverlay

                textContent
            }
            .frame(height: Constants.bannerHeight)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(String(localized: "common_double_tap_to_view"))
    }

    // MARK: - Private

    private enum Constants {
        static let bannerHeight: CGFloat = 192
        static let tagFontSize: CGFloat = 12
        static let headlineFontSize: CGFloat = 24
        static let subtitleFontSize: CGFloat = 14
        static let overlayStartOpacity: Double = 0.90
        static let titleMaxLines = 2
    }

    private let title: String
    private let subtitle: String
    private let imageUrl: URL?
    private let tag: String?
    private let action: (() -> Void)?

    private var accessibilityDescription: String {
        var parts: [String] = []
        if let tag {
            parts.append(tag)
        }
        parts.append(title)
        parts.append(subtitle)
        return parts.joined(separator: ". ")
    }

    private var backgroundLayer: some View {
        Group {
            if let imageUrl {
                XGImage(url: imageUrl)
                    .aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(
                    colors: [XGColors.brandPrimary, XGColors.tertiary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing,
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var gradientOverlay: some View {
        LinearGradient(
            stops: [
                .init(
                    color: XGColors.brandPrimary.opacity(Constants.overlayStartOpacity),
                    location: 0,
                ),
                .init(
                    color: XGColors.brandPrimary.opacity(0),
                    location: 1,
                ),
            ],
            startPoint: .leading,
            endPoint: .trailing,
        )
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let tag {
                tagBadge(tag)
                    .padding(.bottom, XGSpacing.sm)
            }

            Spacer()

            Text(title)
                .font(.system(size: Constants.headlineFontSize, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(Constants.titleMaxLines)

            Text(subtitle)
                .font(.system(size: Constants.subtitleFontSize))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(XGSpacing.base)
    }

    private func tagBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: Constants.tagFontSize, weight: .semibold))
            .foregroundStyle(XGColors.brandPrimary)
            .padding(.horizontal, XGSpacing.sm)
            .padding(.vertical, XGSpacing.xs)
            .background(XGColors.brandSecondary)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
    }
}

// MARK: - Previews

#Preview("XGHeroBanner with image") {
    XGHeroBanner(
        title: "Urban Fashion Collection",
        subtitle: "Explore the latest trends",
        imageUrl: nil,
        tag: "NEW SEASON",
        action: {},
    )
    .padding()
}

#Preview("XGHeroBanner fallback gradient") {
    XGHeroBanner(
        title: "Summer Deals",
        subtitle: "Up to 50% off selected items",
        action: {},
    )
    .padding()
}
