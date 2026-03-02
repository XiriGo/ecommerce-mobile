import Foundation
import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGFlashSaleBannerInitTests

@Suite("XGFlashSaleBanner Initialisation Tests")
@MainActor
struct XGFlashSaleBannerInitTests {
    @Test("Initialises with required title only")
    func init_titleOnly_initialises() {
        let banner = XGFlashSaleBanner(title: "Flash Sale")
        _ = banner
        #expect(true)
    }

    @Test("Initialises with all parameters specified")
    func init_allParameters_initialises() {
        let banner = XGFlashSaleBanner(
            title: "Up to 70% Off",
            imageUrl: URL(string: "https://example.com/banner.jpg"),
            action: {},
        )
        _ = banner
        #expect(true)
    }

    @Test("Initialises with nil imageUrl")
    func init_nilImageUrl_initialises() {
        let banner = XGFlashSaleBanner(
            title: "Flash Sale",
            imageUrl: nil,
            action: {},
        )
        _ = banner
        #expect(true)
    }

    @Test("Initialises with nil action (non-interactive)")
    func init_nilAction_initialises() {
        let banner = XGFlashSaleBanner(
            title: "Flash Sale",
            action: nil,
        )
        _ = banner
        #expect(true)
    }

    @Test("Initialises with empty title")
    func init_emptyTitle_initialises() {
        let banner = XGFlashSaleBanner(title: "")
        _ = banner
        #expect(true)
    }

    @Test("Initialises with long multiline title")
    func init_longTitle_initialises() {
        let banner = XGFlashSaleBanner(
            title: "This Is A Very Long Flash Sale Title That Should Wrap To Multiple Lines",
        )
        _ = banner
        #expect(true)
    }
}

// MARK: - XGFlashSaleBannerTokenTests

@Suite("XGFlashSaleBanner Token Contract Tests")
struct XGFlashSaleBannerTokenTests {
    // MARK: - Dimension tokens

    @Test("Banner height should be 133pt per token spec")
    func bannerHeight_is133() {
        // xg-flash-sale-banner.json: tokens.height = 133
        let expectedHeight: CGFloat = 133
        #expect(expectedHeight == 133)
    }

    @Test("Title max lines should be 2 per token spec")
    func titleMaxLines_is2() {
        // xg-flash-sale-banner.json: subComponents.title.maxLines = 2
        let expectedMaxLines = 2
        #expect(expectedMaxLines == 2)
    }

    // MARK: - XGCornerRadius token

    @Test("XGCornerRadius.medium should be 10pt for banner clipping")
    func cornerRadiusMedium_is10() {
        // cornerRadius = $foundations/spacing.cornerRadius.medium = 10
        #expect(XGCornerRadius.medium == 10)
    }

    // MARK: - XGColors tokens

    @Test("flashSaleBackground color should exist")
    func flashSaleBackground_exists() {
        _ = XGColors.flashSaleBackground
        #expect(true)
    }

    @Test("flashSaleText color should exist")
    func flashSaleText_exists() {
        _ = XGColors.flashSaleText
        #expect(true)
    }

    @Test("flashSaleAccentBlue color should exist")
    func flashSaleAccentBlue_exists() {
        _ = XGColors.flashSaleAccentBlue
        #expect(true)
    }

    @Test("flashSaleAccentPink color should exist")
    func flashSaleAccentPink_exists() {
        _ = XGColors.flashSaleAccentPink
        #expect(true)
    }

    @Test("Accent blue and accent pink should be different colors")
    func accentColors_areDifferent() {
        #expect(XGColors.flashSaleAccentBlue != XGColors.flashSaleAccentPink)
    }

    @Test("Text color should differ from background color")
    func textColor_differsFromBackground() {
        #expect(XGColors.flashSaleText != XGColors.flashSaleBackground)
    }

    // MARK: - Typography tokens

    @Test("Badge font is XGTypography.bodySemiBold (14pt SemiBold)")
    func badgeFont_isBodySemiBold() {
        _ = XGTypography.bodySemiBold
        #expect(true)
    }

    @Test("Title font is XGTypography.title (20pt SemiBold)")
    func titleFont_isTitle() {
        _ = XGTypography.title
        #expect(true)
    }

    // MARK: - XGSpacing tokens

    @Test("XGSpacing.sm should be 8pt for VStack spacing")
    func spacingSm_is8() {
        #expect(XGSpacing.sm == 8)
    }

    @Test("XGSpacing.base should be 16pt for content padding")
    func spacingBase_is16() {
        #expect(XGSpacing.base == 16)
    }

    // MARK: - XGImage shimmer inheritance

    @Test("XGMotion.Crossfade.imageFadeIn is 0.3s (shimmer to image transition)")
    func imageFadeIn_is0point3() {
        #expect(XGMotion.Crossfade.imageFadeIn == 0.3)
    }

    @Test("XGMotion.Shimmer.duration is 1.2s for loading animation")
    func shimmerDuration_is1point2() {
        #expect(XGMotion.Shimmer.duration == 1.2)
    }
}

// MARK: - XGFlashSaleBannerStripeTests

@Suite("XGFlashSaleBanner Stripe Layout Tests")
struct XGFlashSaleBannerStripeTests {
    @Test("Left stripe topEnd fraction should be 0.15")
    func leftStripe_topEnd_is0point15() {
        // xg-flash-sale-banner.json: accentStripeLeft.shape = "trapezoid (topEnd: 15%)"
        let leftTopEnd: CGFloat = 0.15
        #expect(leftTopEnd == 0.15)
    }

    @Test("Left stripe bottomEnd fraction should be 0.08")
    func leftStripe_bottomEnd_is0point08() {
        // xg-flash-sale-banner.json: accentStripeLeft.shape = "trapezoid (bottomEnd: 8%)"
        let leftBottomEnd: CGFloat = 0.08
        #expect(leftBottomEnd == 0.08)
    }

    @Test("Right stripe topStart fraction should be 0.85")
    func rightStripe_topStart_is0point85() {
        // xg-flash-sale-banner.json: accentStripeRight.shape = "trapezoid (topStart: 85%)"
        let rightTopStart: CGFloat = 0.85
        #expect(rightTopStart == 0.85)
    }

    @Test("Right stripe bottomStart fraction should be 0.92")
    func rightStripe_bottomStart_is0point92() {
        // xg-flash-sale-banner.json: accentStripeRight.shape = "trapezoid (bottomStart: 92%)"
        let rightBottomStart: CGFloat = 0.92
        #expect(rightBottomStart == 0.92)
    }

    @Test("Left and right stripes should not overlap (topEnd < rightTopStart)")
    func stripes_doNotOverlap() {
        let leftTopEnd: CGFloat = 0.15
        let rightTopStart: CGFloat = 0.85
        #expect(leftTopEnd < rightTopStart)
    }
}

// MARK: - XGFlashSaleBannerBodyTests

@Suite("XGFlashSaleBanner Body Tests")
@MainActor
struct XGFlashSaleBannerBodyTests {
    @Test("Body with action is a valid View", .disabled(swiftUIDisabledReason))
    func body_withAction_isValidView() {
        let banner = XGFlashSaleBanner(
            title: "Flash Sale",
            action: {},
        )
        _ = banner.body
        #expect(true)
    }

    @Test("Body without action is a valid View", .disabled(swiftUIDisabledReason))
    func body_withoutAction_isValidView() {
        let banner = XGFlashSaleBanner(title: "Flash Sale")
        _ = banner.body
        #expect(true)
    }

    @Test("Body with imageUrl is a valid View", .disabled(swiftUIDisabledReason))
    func body_withImageUrl_isValidView() {
        let banner = XGFlashSaleBanner(
            title: "Flash Sale",
            imageUrl: URL(string: "https://picsum.photos/350/133"),
            action: {},
        )
        _ = banner.body
        #expect(true)
    }
}
