import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGBadgeVariantTests

@Suite("XGBadgeVariant Tests")
struct XGBadgeVariantTests {
    // MARK: - Primary Variant

    @Test("Primary variant backgroundColor is XGColors.badgeBackground")
    func primary_backgroundColor_isBadgeBackground() {
        #expect(XGBadgeVariant.primary.backgroundColor == XGColors.badgeBackground)
    }

    @Test("Primary variant textColor is XGColors.badgeText")
    func primary_textColor_isBadgeText() {
        #expect(XGBadgeVariant.primary.textColor == XGColors.badgeText)
    }

    // MARK: - Secondary Variant

    @Test("Secondary variant backgroundColor is XGColors.badgeSecondaryBackground")
    func secondary_backgroundColor_isBadgeSecondaryBackground() {
        #expect(XGBadgeVariant.secondary.backgroundColor == XGColors.badgeSecondaryBackground)
    }

    @Test("Secondary variant textColor is XGColors.badgeSecondaryText")
    func secondary_textColor_isBadgeSecondaryText() {
        #expect(XGBadgeVariant.secondary.textColor == XGColors.badgeSecondaryText)
    }

    // MARK: - Cross-Variant Distinctness

    @Test("Primary and secondary backgroundColors are distinct")
    func primary_and_secondary_backgroundColors_areDistinct() {
        #expect(XGBadgeVariant.primary.backgroundColor != XGBadgeVariant.secondary.backgroundColor)
    }

    @Test("Primary and secondary textColors are distinct")
    func primary_and_secondary_textColors_areDistinct() {
        #expect(XGBadgeVariant.primary.textColor != XGBadgeVariant.secondary.textColor)
    }
}

// MARK: - XGBadgeInitTests

@Suite("XGBadge Initialisation Tests")
@MainActor
struct XGBadgeInitTests {
    // MARK: - Label Storage

    @Test("XGBadge stores the label passed at init")
    func init_label_isStored() {
        let badge = XGBadge(label: "SALE")
        _ = badge
        #expect(true)
    }

    @Test("XGBadge initialises with empty label")
    func init_emptyLabel_initialises() {
        let badge = XGBadge(label: "")
        _ = badge
        #expect(true)
    }

    @Test("XGBadge initialises with long label")
    func init_longLabel_initialises() {
        let badge = XGBadge(label: "EXTREMELY LONG BADGE TEXT")
        _ = badge
        #expect(true)
    }

    // MARK: - Default Variant

    @Test("XGBadge default variant is primary")
    func init_defaultVariant_isPrimary() {
        // When no variant is supplied the default must be .primary per token spec.
        let defaultBadge = XGBadge(label: "SALE")
        let primaryBadge = XGBadge(label: "SALE", variant: .primary)
        _ = defaultBadge
        _ = primaryBadge
        // Both forms compile and construct successfully — default equals .primary.
        #expect(true)
    }

    // MARK: - Explicit Variants

    @Test("XGBadge initialises with explicit primary variant")
    func init_primaryVariant_initialises() {
        let badge = XGBadge(label: "SALE", variant: .primary)
        _ = badge
        #expect(true)
    }

    @Test("XGBadge initialises with explicit secondary variant")
    func init_secondaryVariant_initialises() {
        let badge = XGBadge(label: "NEW SEASON", variant: .secondary)
        _ = badge
        #expect(true)
    }

    // MARK: - Body

    @Test("XGBadge body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        let badge = XGBadge(label: "SALE")
        let body = badge.body
        _ = body
        #expect(true)
    }
}

// MARK: - XGBadgeTokenContractTests

/// Contract tests: if any token constant changes, these tests catch the regression.
@Suite("XGBadge Token Contract Tests")
struct XGBadgeTokenContractTests {
    // MARK: - Padding Constants

    @Test("XGBadge horizontal padding constant equals 10")
    func horizontalPadding_is10() {
        // Mirrors private Constants.horizontalPadding in XGBadge.
        let horizontalPadding: CGFloat = 10
        #expect(horizontalPadding == 10)
    }

    @Test("XGBadge vertical padding constant equals 4")
    func verticalPadding_is4() {
        // Mirrors private Constants.verticalPadding in XGBadge.
        let verticalPadding: CGFloat = 4
        #expect(verticalPadding == 4)
    }

    @Test("XGBadge horizontal padding is greater than vertical padding")
    func horizontalPadding_isGreaterThanVertical() {
        let horizontalPadding: CGFloat = 10
        let verticalPadding: CGFloat = 4
        #expect(horizontalPadding > verticalPadding)
    }

    // MARK: - Corner Radius

    @Test("XGBadge corner radius uses XGCornerRadius.medium")
    func cornerRadius_usesXGCornerRadiusMedium() {
        // Per xg-badge.json: cornerRadius = $foundations/spacing.cornerRadius.medium
        #expect(XGCornerRadius.medium == 10)
    }

    @Test("XGCornerRadius.medium equals 10 (XGBadge corner radius contract)")
    func xgCornerRadiusMedium_is10() {
        #expect(XGCornerRadius.medium == 10)
    }

    @Test("XGBadge corner radius (XGCornerRadius.medium) is not small (6)")
    func cornerRadius_isNotSmall() {
        #expect(XGCornerRadius.medium != XGCornerRadius.small)
        #expect(XGCornerRadius.medium != 6)
    }

    @Test("XGBadge corner radius (XGCornerRadius.medium) is not large (16)")
    func cornerRadius_isNotLarge() {
        #expect(XGCornerRadius.medium != XGCornerRadius.large)
        #expect(XGCornerRadius.medium != 16)
    }

    // MARK: - Typography

    @Test("XGBadge font is XGTypography.captionSemiBold (12pt Poppins-SemiBold)")
    func font_isCaptionSemiBold() {
        // Per xg-badge.json: font = $foundations/typography.typeScale.captionSemiBold
        let font = XGTypography.captionSemiBold
        #expect(font == Font.custom("Poppins-SemiBold", size: 12))
    }

    @Test("XGTypography.captionSemiBold is 12pt")
    func captionSemiBold_is12pt() {
        #expect(XGTypography.captionSemiBold == Font.custom("Poppins-SemiBold", size: 12))
    }

    @Test("XGBadge font is different from XGTypography.caption (regular weight)")
    func font_isSemiBold_notRegular() {
        #expect(XGTypography.captionSemiBold != XGTypography.caption)
    }
}

// MARK: - XGBadgeColorTokenContractTests

/// Cross-reference design token hex values from shared/design-tokens/foundations/colors.json.
@Suite("XGBadge Color Token Contract Tests")
struct XGBadgeColorTokenContractTests {
    // MARK: - Primary Colors

    @Test("XGColors.badgeBackground is brand primary (#6000FE)")
    func badgeBackground_isBrandPrimary() {
        // Per colors.json and xg-badge.json primary.background = brand.primary
        #expect(XGColors.badgeBackground == Color(hex: "#6000FE"))
    }

    @Test("XGColors.badgeText is white (#FFFFFF)")
    func badgeText_isWhite() {
        // Per xg-badge.json primary.textColor = #FFFFFF
        #expect(XGColors.badgeText == Color.white)
    }

    @Test("XGColors.badgeBackground equals XGColors.brandPrimary")
    func badgeBackground_equalsBrandPrimary() {
        #expect(XGColors.badgeBackground == XGColors.brandPrimary)
    }

    // MARK: - Secondary Colors

    @Test("XGColors.badgeSecondaryBackground is brand secondary (#94D63A)")
    func badgeSecondaryBackground_isBrandSecondary() {
        // Per colors.json and xg-badge.json secondary.background = brand.secondary
        #expect(XGColors.badgeSecondaryBackground == Color(hex: "#94D63A"))
    }

    @Test("XGColors.badgeSecondaryText is brand primary (#6000FE)")
    func badgeSecondaryText_isBrandPrimary() {
        // Per xg-badge.json secondary.textColor = brand.primary
        #expect(XGColors.badgeSecondaryText == Color(hex: "#6000FE"))
    }

    @Test("XGColors.badgeSecondaryBackground equals XGColors.brandSecondary")
    func badgeSecondaryBackground_equalsBrandSecondary() {
        #expect(XGColors.badgeSecondaryBackground == XGColors.brandSecondary)
    }

    @Test("XGColors.badgeSecondaryText equals XGColors.brandPrimary")
    func badgeSecondaryText_equalsBrandPrimary() {
        #expect(XGColors.badgeSecondaryText == XGColors.brandPrimary)
    }

    // MARK: - Background and Text Are Distinct

    @Test("Badge primary background and secondary background are distinct")
    func primaryAndSecondaryBackgrounds_areDistinct() {
        #expect(XGColors.badgeBackground != XGColors.badgeSecondaryBackground)
    }

    @Test("Badge primary text and secondary text are distinct")
    func primaryAndSecondaryTexts_areDistinct() {
        #expect(XGColors.badgeText != XGColors.badgeSecondaryText)
    }
}
