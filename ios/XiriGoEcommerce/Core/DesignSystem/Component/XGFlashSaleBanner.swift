import SwiftUI

// MARK: - XGFlashSaleBanner

/// A promotional banner card with accent stripes for flash sale events.
/// Token source: `components/molecules/xg-flash-sale-banner.json`.
///
/// Image loading shimmer is inherited from ``XGImage`` (DQ-07). All dimensions
/// and typography are driven by design tokens.
///
/// - Height: `Constants.bannerHeight` (133pt)
/// - Background: `XGColors.flashSaleBackground`
/// - Left accent stripe: `XGColors.flashSaleAccentBlue`, diagonal
/// - Right accent stripe: `XGColors.flashSaleAccentPink`, diagonal
/// - Text color: `XGColors.flashSaleText`
/// - Badge font: `XGTypography.bodySemiBold`
/// - Title font: `XGTypography.title`
struct XGFlashSaleBanner: View {
    // MARK: - Lifecycle

    init(
        title: String,
        imageUrl: URL? = nil,
        action: (() -> Void)? = nil,
    ) {
        self.title = title
        self.imageUrl = imageUrl
        self.action = action
    }

    // MARK: - Internal

    var body: some View {
        Button {
            action?()
        } label: {
            ZStack {
                XGColors.flashSaleBackground

                if let imageUrl {
                    XGImage(url: imageUrl)
                }

                accentStripes

                VStack(spacing: XGSpacing.sm) {
                    Text(String(localized: "home_flash_sale_badge"))
                        .font(XGTypography.bodySemiBold)
                        .foregroundStyle(XGColors.flashSaleText)

                    Text(title)
                        .font(XGTypography.title)
                        .foregroundStyle(XGColors.flashSaleText)
                        .multilineTextAlignment(.center)
                        .lineLimit(Constants.titleMaxLines)
                }
                .padding(XGSpacing.base)
            }
            .frame(height: Constants.bannerHeight)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            String(localized: "home_flash_sale_badge") + ": " + title,
        )
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Private

    private enum Constants {
        static let bannerHeight: CGFloat = 133
        static let titleMaxLines: Int = 2
    }

    private enum StripeLayout {
        static let leftTopEnd: CGFloat = 0.15
        static let leftBottomEnd: CGFloat = 0.08
        static let rightTopStart: CGFloat = 0.85
        static let rightBottomStart: CGFloat = 0.92
    }

    private let title: String
    private let imageUrl: URL?
    private let action: (() -> Void)?

    private var accentStripes: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            Canvas { context, _ in
                context.fill(
                    leftStripePath(width: width, height: height),
                    with: .color(XGColors.flashSaleAccentBlue),
                )
                context.fill(
                    rightStripePath(width: width, height: height),
                    with: .color(XGColors.flashSaleAccentPink),
                )
            }
        }
    }

    private func leftStripePath(width: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: width * StripeLayout.leftTopEnd, y: 0))
        path.addLine(to: CGPoint(x: width * StripeLayout.leftBottomEnd, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        return path
    }

    private func rightStripePath(width: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: width * StripeLayout.rightTopStart, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width * StripeLayout.rightBottomStart, y: height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Previews

#Preview("XGFlashSaleBanner") {
    XGFlashSaleBanner(
        title: "Up to 70% Off Selected Items",
        action: {},
    )
    .padding()
    .xgTheme()
}

#Preview("XGFlashSaleBanner with image") {
    XGFlashSaleBanner(
        title: "Limited Time Offer",
        imageUrl: URL(string: "https://picsum.photos/350/133"),
        action: {},
    )
    .padding()
    .xgTheme()
}

#Preview("XGFlashSaleBanner no action") {
    XGFlashSaleBanner(
        title: "Limited Time Offer",
    )
    .padding()
    .xgTheme()
}
