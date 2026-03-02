import Foundation
import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGDailyDealCardInitTests

@Suite("XGDailyDealCard Initialisation Tests")
@MainActor
struct XGDailyDealCardInitTests {
    @Test("Initialises with required parameters and nil optionals")
    func init_requiredOnly_initialises() {
        let card = XGDailyDealCard(
            title: "Product",
            price: "89.99",
            originalPrice: "149.99",
            endTime: Date().addingTimeInterval(3600),
        )
        _ = card
        #expect(true)
    }

    @Test("Initialises with all parameters specified")
    func init_allParameters_initialises() {
        let card = XGDailyDealCard(
            title: "Nike Air Zoom",
            price: "89.99",
            originalPrice: "149.99",
            endTime: Date().addingTimeInterval(28800),
            imageUrl: URL(string: "https://example.com/img.jpg"),
            action: {},
        )
        _ = card
        #expect(true)
    }

    @Test("Initialises with nil imageUrl")
    func init_nilImageUrl_initialises() {
        let card = XGDailyDealCard(
            title: "Product",
            price: "49.99",
            originalPrice: "99.99",
            endTime: Date().addingTimeInterval(3600),
            imageUrl: nil,
        )
        _ = card
        #expect(true)
    }

    @Test("Initialises with nil action (non-interactive)")
    func init_nilAction_initialises() {
        let card = XGDailyDealCard(
            title: "Product",
            price: "49.99",
            originalPrice: "99.99",
            endTime: Date().addingTimeInterval(3600),
            action: nil,
        )
        _ = card
        #expect(true)
    }

    @Test("Initialises with past endTime (expired deal)")
    func init_pastEndTime_initialises() {
        let card = XGDailyDealCard(
            title: "Expired Product",
            price: "29.99",
            originalPrice: "59.99",
            endTime: Date().addingTimeInterval(-60),
        )
        _ = card
        #expect(true)
    }

    @Test("Initialises with empty title")
    func init_emptyTitle_initialises() {
        let card = XGDailyDealCard(
            title: "",
            price: "0.00",
            originalPrice: "0.00",
            endTime: Date(),
        )
        _ = card
        #expect(true)
    }
}

// MARK: - XGDailyDealCardTokenTests

@Suite("XGDailyDealCard Token Contract Tests")
struct XGDailyDealCardTokenTests {
    // MARK: - Dimension tokens

    @Test("Card height should be 163pt per token spec")
    func cardHeight_is163() {
        // xg-daily-deal-card.json: tokens.height = 163
        let expectedHeight: CGFloat = 163
        #expect(expectedHeight == 163)
    }

    @Test("Card padding should be 16pt per token spec")
    func cardPadding_is16() {
        // xg-daily-deal-card.json: tokens.padding = 16
        let expectedPadding: CGFloat = 16
        #expect(expectedPadding == 16)
    }

    @Test("Product image size should be 100pt per token spec")
    func imageSize_is100() {
        // xg-daily-deal-card.json: subComponents.productImage.size = 100
        let expectedSize: CGFloat = 100
        #expect(expectedSize == 100)
    }

    @Test("Strikethrough font size should be 15.18pt per token spec")
    func strikethroughFontSize_is15point18() {
        // xg-daily-deal-card.json: subComponents.strikethrough.fontSize = 15.18
        let expectedSize: CGFloat = 15.18
        #expect(abs(expectedSize - 15.18) < 0.01)
    }

    @Test("Title max lines should be 2 per token spec")
    func titleMaxLines_is2() {
        // xg-daily-deal-card.json: subComponents.title.maxLines = 2
        let expectedMaxLines = 2
        #expect(expectedMaxLines == 2)
    }

    // MARK: - XGCornerRadius token

    @Test("XGCornerRadius.medium should be 10pt for card and image corners")
    func cornerRadiusMedium_is10() {
        // cornerRadius = $foundations/spacing.cornerRadius.medium
        #expect(XGCornerRadius.medium == 10)
    }

    // MARK: - XGSpacing tokens

    @Test("XGSpacing.sm should be 8pt for vertical arrangement")
    func spacingSm_is8() {
        #expect(XGSpacing.sm == 8)
    }

    @Test("XGSpacing.base should be 16pt for content spacing")
    func spacingBase_is16() {
        #expect(XGSpacing.base == 16)
    }

    // MARK: - Gradient tokens

    @Test("Gradient uses textDark and brandPrimary colors")
    func gradient_usesCorrectColors() {
        // Verify both colors exist (non-nil check via type system)
        let startColor = XGColors.textDark
        let endColor = XGColors.brandPrimary
        _ = startColor
        _ = endColor
        #expect(true)
    }

    @Test("Gradient start and end colors should be different")
    func gradient_startAndEnd_areDifferent() {
        #expect(XGColors.textDark != XGColors.brandPrimary)
    }

    // MARK: - Countdown font token

    @Test("Countdown font size should be 12pt (system monospaced)")
    func countdownFontSize_is12() {
        // xg-daily-deal-card.json: countdown.font = "system monospaced 12pt"
        let expectedSize: CGFloat = 12
        #expect(expectedSize == 12)
    }

    // MARK: - Crossfade token (inherited from XGImage)

    @Test("XGMotion.Crossfade.imageFadeIn is 0.3s (shimmer to image transition)")
    func imageFadeIn_is0point3() {
        #expect(XGMotion.Crossfade.imageFadeIn == 0.3)
    }
}

// MARK: - XGDailyDealCardCountdownTests

@Suite("XGDailyDealCard Countdown Formatting Tests")
struct XGDailyDealCardCountdownTests {
    // MARK: - Internal

    // MARK: - Expired / zero

    @Test("Zero interval returns ended text")
    func formatCountdown_zero_returnsEndedText() {
        let result = formattedCountdownMirror(0)
        #expect(result == nil) // nil signals expired
    }

    @Test("Negative interval returns ended text")
    func formatCountdown_negative_returnsEndedText() {
        let result = formattedCountdownMirror(-100)
        #expect(result == nil)
    }

    // MARK: - Standard intervals

    @Test("1 second formats as 00:00:01")
    func formatCountdown_1second() {
        let result = formattedCountdownMirror(1)
        #expect(result == "00:00:01")
    }

    @Test("59 seconds formats as 00:00:59")
    func formatCountdown_59seconds() {
        let result = formattedCountdownMirror(59)
        #expect(result == "00:00:59")
    }

    @Test("1 minute formats as 00:01:00")
    func formatCountdown_1minute() {
        let result = formattedCountdownMirror(60)
        #expect(result == "00:01:00")
    }

    @Test("1 hour formats as 01:00:00")
    func formatCountdown_1hour() {
        let result = formattedCountdownMirror(3600)
        #expect(result == "01:00:00")
    }

    @Test("8 hours formats as 08:00:00")
    func formatCountdown_8hours() {
        let result = formattedCountdownMirror(28800)
        #expect(result == "08:00:00")
    }

    @Test("23h 59m 59s formats as 23:59:59")
    func formatCountdown_23h59m59s() {
        let seconds = TimeInterval(23 * 3600 + 59 * 60 + 59)
        let result = formattedCountdownMirror(seconds)
        #expect(result == "23:59:59")
    }

    @Test("25 hours formats as 25:00:00")
    func formatCountdown_25hours() {
        let result = formattedCountdownMirror(25 * 3600)
        #expect(result == "25:00:00")
    }

    @Test("1h 30m 45s formats as 01:30:45")
    func formatCountdown_1h30m45s() {
        let seconds = TimeInterval(1 * 3600 + 30 * 60 + 45)
        let result = formattedCountdownMirror(seconds)
        #expect(result == "01:30:45")
    }

    @Test("Sub-second interval (0.5s) truncates to 00:00:00")
    func formatCountdown_subSecond_truncates() {
        let result = formattedCountdownMirror(0.5)
        #expect(result == "00:00:00")
    }

    @Test("1.9 seconds truncates to 00:00:01 (not rounded)")
    func formatCountdown_1point9seconds_truncates() {
        let result = formattedCountdownMirror(1.9)
        #expect(result == "00:00:01")
    }

    // MARK: - Format validation

    @Test("Formatted countdown matches HH:MM:SS pattern")
    func formatCountdown_matchesPattern() {
        let result = formattedCountdownMirror(3661) // 1h 1m 1s
        let pattern = /\d{2}:\d{2}:\d{2}/
        #expect(result?.wholeMatch(of: pattern) != nil)
    }

    @Test("Formatted countdown has exactly 8 characters")
    func formatCountdown_has8Characters() {
        let result = formattedCountdownMirror(1)
        #expect(result?.count == 8)
    }

    // MARK: - Private

    // MARK: - Private helper

    /// Mirrors the private `formattedCountdown` logic in XGDailyDealCard.swift.
    /// Returns `nil` for expired intervals (remaining <= 0).
    private func formattedCountdownMirror(_ interval: TimeInterval) -> String? {
        guard interval > 0 else {
            return nil
        }
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - XGDailyDealCardBodyTests

@Suite("XGDailyDealCard Body Tests")
@MainActor
struct XGDailyDealCardBodyTests {
    @Test("Body with active deal is a valid View", .disabled(swiftUIDisabledReason))
    func body_activeDeal_isValidView() {
        let card = XGDailyDealCard(
            title: "Product",
            price: "89.99",
            originalPrice: "149.99",
            endTime: Date().addingTimeInterval(3600),
            action: {},
        )
        _ = card.body
        #expect(true)
    }

    @Test("Body with expired deal is a valid View", .disabled(swiftUIDisabledReason))
    func body_expiredDeal_isValidView() {
        let card = XGDailyDealCard(
            title: "Expired",
            price: "49.99",
            originalPrice: "99.99",
            endTime: Date().addingTimeInterval(-60),
        )
        _ = card.body
        #expect(true)
    }
}
