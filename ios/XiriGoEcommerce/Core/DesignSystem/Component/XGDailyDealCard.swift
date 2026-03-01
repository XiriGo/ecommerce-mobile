import SwiftUI

// MARK: - XGDailyDealCard

/// A gradient card displaying the daily deal with countdown timer and product info.
/// Token source: `components/molecules/xg-daily-deal-card.json`.
///
/// - Height: 163pt
/// - Background: linear gradient left-to-right from #111827 to #6000FE
/// - Badge: "DAILY DEAL", brand secondary bg, brand primary text
/// - Price: Source Sans 3 Black, brand secondary color (deal style)
/// - Countdown: HH:MM:SS format, ticks every second
struct XGDailyDealCard: View {
    // MARK: - Lifecycle

    init(
        title: String,
        price: String,
        originalPrice: String,
        endTime: Date,
        imageUrl: URL? = nil,
        action: (() -> Void)? = nil,
    ) {
        self.title = title
        self.price = price
        self.originalPrice = originalPrice
        self.endTime = endTime
        self.imageUrl = imageUrl
        self.action = action
    }

    // MARK: - Internal

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: XGSpacing.base) {
                leftContent
                Spacer()
                if imageUrl != nil {
                    rightImage
                }
            }
            .padding(Constants.cardPadding)
            .frame(height: Constants.cardHeight)
            .background(backgroundGradient)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Private

    private enum Constants {
        static let cardHeight: CGFloat = 163
        static let cardPadding: CGFloat = 16
        static let badgeFontSize: CGFloat = 12
        static let titleFontSize: CGFloat = 20
        static let countdownFontSize: CGFloat = 12
        static let imageSize: CGFloat = 100
        static let titleMaxLines = 2
        static let badgeHorizontalPadding: CGFloat = 10
        static let badgeVerticalPadding: CGFloat = 4
        static let strikethroughFontSize: CGFloat = 15.18
    }

    private enum TimeConstants {
        static let secondsPerHour = 3600
        static let secondsPerMinute = 60
    }

    private let title: String
    private let price: String
    private let originalPrice: String
    private let endTime: Date
    private let imageUrl: URL?
    private let action: (() -> Void)?

    private var accessibilityDescription: String {
        let remaining = endTime.timeIntervalSince(.now)
        let timeText = remaining > 0
            ? formattedCountdown(remaining)
            : String(localized: "home_daily_deal_ended")
        return String(localized: "home_daily_deal_badge") + ": " + title + ", " + price + ", " + timeText
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                XGColors.textDark,
                XGColors.brandPrimary,
            ],
            startPoint: .leading,
            endPoint: .trailing,
        )
    }

    private var leftContent: some View {
        VStack(alignment: .leading, spacing: XGSpacing.sm) {
            badgeView

            Text(title)
                .font(XGTypography.title)
                .foregroundStyle(XGColors.textOnDark)
                .lineLimit(Constants.titleMaxLines)

            countdownView

            HStack(alignment: .firstTextBaseline, spacing: XGSpacing.sm) {
                XGPriceText(
                    price: price,
                    style: .deal,
                )

                Text(originalPrice)
                    .font(XGTypography.strikethroughFont(size: Constants.strikethroughFontSize))
                    .foregroundStyle(XGColors.priceStrikethrough)
                    .strikethrough()
            }
        }
    }

    private var badgeView: some View {
        Text(String(localized: "home_daily_deal_badge"))
            .font(XGTypography.captionSemiBold)
            .foregroundStyle(XGColors.brandPrimary)
            .padding(.horizontal, Constants.badgeHorizontalPadding)
            .padding(.vertical, Constants.badgeVerticalPadding)
            .background(XGColors.brandSecondary)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
    }

    private var countdownView: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = endTime.timeIntervalSince(context.date)
            if remaining > 0 {
                Text(formattedCountdown(remaining))
                    .font(.system(size: Constants.countdownFontSize, design: .monospaced))
                    .foregroundStyle(XGColors.textOnDark)
            } else {
                Text(String(localized: "home_daily_deal_ended"))
                    .font(XGTypography.caption)
                    .foregroundStyle(XGColors.textOnDark)
            }
        }
    }

    private var rightImage: some View {
        XGImage(url: imageUrl)
            .aspectRatio(contentMode: .fill)
            .frame(
                width: Constants.imageSize,
                height: Constants.imageSize,
            )
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
    }

    private func formattedCountdown(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / TimeConstants.secondsPerHour
        let minutes = (totalSeconds % TimeConstants.secondsPerHour) / TimeConstants.secondsPerMinute
        let seconds = totalSeconds % TimeConstants.secondsPerMinute
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - Previews

#Preview("XGDailyDealCard") {
    XGDailyDealCard(
        title: "Nike Air Zoom Pegasus",
        price: "89.99",
        originalPrice: "149.99",
        endTime: Date().addingTimeInterval(28800),
        imageUrl: nil,
        action: {},
    )
    .padding()
    .xgTheme()
}

#Preview("XGDailyDealCard Ended") {
    XGDailyDealCard(
        title: "Expired Deal Product",
        price: "49.99",
        originalPrice: "99.99",
        endTime: Date().addingTimeInterval(-60),
    )
    .padding()
    .xgTheme()
}
