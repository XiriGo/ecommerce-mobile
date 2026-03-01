import SwiftUI

// MARK: - XGFlashSaleBanner

/// A promotional banner card with accent stripes for flash sale events.
/// Token source: `components.json > XGCard.flashSale`, `colors.json > flashSale`.
///
/// - Height: 133pt
/// - Background: #FFD814 (bright yellow)
/// - Left accent stripe: #9EBDF4 (blue), diagonal
/// - Right accent stripe: #F60186 (pink), diagonal
/// - Text color: #1D1D1B (near-black)
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

                accentStripes

                VStack(spacing: XGSpacing.sm) {
                    Text(String(localized: "home_flash_sale_badge"))
                        .font(.custom("Poppins-Bold", size: Constants.badgeFontSize))
                        .foregroundStyle(XGColors.flashSaleText)

                    Text(title)
                        .font(.custom("Poppins-Bold", size: Constants.titleFontSize))
                        .foregroundStyle(XGColors.flashSaleText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
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
        static let badgeFontSize: CGFloat = 14
        static let titleFontSize: CGFloat = 20
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
}

#Preview("XGFlashSaleBanner no action") {
    XGFlashSaleBanner(
        title: "Limited Time Offer",
    )
    .padding()
}
