import SwiftUI

// MARK: - XGDailyDealCard

/// A gradient card displaying the daily deal with countdown timer and product info.
/// Token source: `components.json > XGCard.dailyDeal`, `gradients.json > dailyDealCard`.
///
/// - Height: 163pt
/// - Background: linear gradient left-to-right from #111827 to #6000FE
/// - Badge: "DAILY DEAL", brand secondary bg, brand primary text
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
            .padding(XGSpacing.base)
            .frame(height: Constants.cardHeight)
            .background(backgroundGradient)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.large))
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
        static let badgeFontSize: CGFloat = 12
        static let titleFontSize: CGFloat = 20
        static let countdownFontSize: CGFloat = 12
        static let imageSize: CGFloat = 100
        static let titleMaxLines = 2
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
                Color(hex: "#111827"),
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
                .font(.system(size: Constants.titleFontSize, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(Constants.titleMaxLines)

            countdownView

            HStack(spacing: XGSpacing.sm) {
                Text(price)
                    .font(.system(size: Constants.titleFontSize, weight: .bold))
                    .foregroundStyle(XGColors.brandSecondary)

                Text(originalPrice)
                    .font(XGTypography.bodySmall)
                    .foregroundStyle(Color(hex: "#8E8E93"))
                    .strikethrough()
            }
        }
    }

    private var badgeView: some View {
        Text(String(localized: "home_daily_deal_badge"))
            .font(.system(size: Constants.badgeFontSize, weight: .semibold))
            .foregroundStyle(XGColors.brandPrimary)
            .padding(.horizontal, XGSpacing.sm)
            .padding(.vertical, XGSpacing.xs)
            .background(XGColors.brandSecondary)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
    }

    private var countdownView: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = endTime.timeIntervalSince(context.date)
            if remaining > 0 {
                Text(formattedCountdown(remaining))
                    .font(.system(size: Constants.countdownFontSize, design: .monospaced))
                    .foregroundStyle(.white)
            } else {
                Text(String(localized: "home_daily_deal_ended"))
                    .font(.system(size: Constants.countdownFontSize, weight: .bold))
                    .foregroundStyle(.white)
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
        endTime: Date().addingTimeInterval(28_800),
        imageUrl: URL(string: "https://picsum.photos/seed/deal/400/400"),
        action: {},
    )
    .padding()
}

#Preview("XGDailyDealCard Ended") {
    XGDailyDealCard(
        title: "Expired Deal Product",
        price: "49.99",
        originalPrice: "99.99",
        endTime: Date().addingTimeInterval(-60),
    )
    .padding()
}
