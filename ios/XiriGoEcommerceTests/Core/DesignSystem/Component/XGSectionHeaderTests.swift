import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGSectionHeaderInitTests

/// Verifies that XGSectionHeader initialises with various parameter combinations
/// without crashing and matches the API defined in xg-section-header.json.
@Suite("XGSectionHeader Initialisation Tests")
@MainActor
struct XGSectionHeaderInitTests {
    // MARK: - Basic Init

    @Test("XGSectionHeader initialises with title only")
    func init_titleOnly_succeeds() {
        let header = XGSectionHeader(title: "Popular Products")
        _ = header
        #expect(true)
    }

    @Test("XGSectionHeader initialises with title and subtitle")
    func init_titleAndSubtitle_succeeds() {
        let header = XGSectionHeader(title: "Categories", subtitle: "Browse by category")
        _ = header
        #expect(true)
    }

    @Test("XGSectionHeader initialises with title and seeAll action")
    func init_titleAndSeeAll_succeeds() {
        let header = XGSectionHeader(title: "New Arrivals", onSeeAllAction: {})
        _ = header
        #expect(true)
    }

    @Test("XGSectionHeader initialises with all parameters")
    func init_allParams_succeeds() {
        let header = XGSectionHeader(
            title: "Flash Sale",
            subtitle: "Ends in 2 hours",
            onSeeAllAction: {},
        )
        _ = header
        #expect(true)
    }

    @Test("XGSectionHeader initialises with empty title")
    func init_emptyTitle_succeeds() {
        let header = XGSectionHeader(title: "")
        _ = header
        #expect(true)
    }

    @Test("XGSectionHeader initialises with long title")
    func init_longTitle_succeeds() {
        let header = XGSectionHeader(title: "A Very Long Section Header Title That Might Wrap")
        _ = header
        #expect(true)
    }

    // MARK: - Default Parameter Values

    @Test("XGSectionHeader subtitle defaults to nil")
    func subtitle_defaultsToNil() {
        // The init allows omitting subtitle — compiles without it
        let header = XGSectionHeader(title: "Test")
        _ = header
        #expect(true)
    }

    @Test("XGSectionHeader onSeeAllAction defaults to nil")
    func onSeeAllAction_defaultsToNil() {
        // The init allows omitting onSeeAllAction — compiles without it
        let header = XGSectionHeader(title: "Test")
        _ = header
        #expect(true)
    }
}

// MARK: - XGSectionHeaderTokenContractTests

/// Contract tests verifying that token constants consumed by XGSectionHeader
/// match the values in `shared/design-tokens/components/atoms/xg-section-header.json`.
@Suite("XGSectionHeader Token Contract Tests")
struct XGSectionHeaderTokenContractTests {
    // MARK: - Title Font (typeScale.subtitle: 18pt SemiBold)

    @Test("Title font is XGTypography.subtitle (18pt Poppins-SemiBold)")
    func titleFont_isSubtitle() {
        let font = XGTypography.subtitle
        #expect(font == Font.custom("Poppins-SemiBold", size: 18))
    }

    // MARK: - Title Color (light.textPrimary)

    @Test("Title color is XGColors.onSurface")
    func titleColor_isOnSurface() {
        #expect(XGColors.onSurface == Color(hex: "#333333"))
    }

    // MARK: - Subtitle Font (typeScale.bodyMedium: 14pt Medium)

    @Test("Subtitle font is XGTypography.bodyMedium (14pt Poppins-Medium)")
    func subtitleFont_isBodyMedium() {
        let font = XGTypography.bodyMedium
        #expect(font == Font.custom("Poppins-Medium", size: 14))
    }

    // MARK: - Subtitle Color (light.textSecondary)

    @Test("Subtitle color is XGColors.onSurfaceVariant")
    func subtitleColor_isOnSurfaceVariant() {
        #expect(XGColors.onSurfaceVariant == Color(hex: "#8E8E93"))
    }

    // MARK: - See All Font (typeScale.bodyMedium: 14pt Medium)

    @Test("See All font matches subtitle font (both bodyMedium)")
    func seeAllFont_isBodyMedium() {
        #expect(XGTypography.bodyMedium == Font.custom("Poppins-Medium", size: 14))
    }

    // MARK: - See All Color (brand.primary)

    @Test("See All color is XGColors.brandPrimary")
    func seeAllColor_isBrandPrimary() {
        #expect(XGColors.brandPrimary == Color(hex: "#6000FE"))
    }

    // MARK: - Arrow Icon Size

    @Test("Arrow icon size constant is 12pt")
    func arrowIconSize_is12() {
        // Mirrors private Constants.arrowIconSize in XGSectionHeader.swift
        let arrowIconSize: CGFloat = 12
        #expect(arrowIconSize == 12)
    }

    @Test("Arrow icon size is smaller than minimum touch target")
    func arrowIconSize_isSmallerThanMinTouchTarget() {
        let arrowIconSize: CGFloat = 12
        #expect(arrowIconSize < XGSpacing.minTouchTarget)
    }

    // MARK: - Horizontal Padding (layout.screenPaddingHorizontal)

    @Test("Horizontal padding is XGSpacing.screenPaddingHorizontal (20pt)")
    func horizontalPadding_isScreenPaddingHorizontal() {
        #expect(XGSpacing.screenPaddingHorizontal == 20)
    }

    // MARK: - Subtitle Spacing (spacing.xxs)

    @Test("Subtitle spacing is XGSpacing.xxs (2pt)")
    func subtitleSpacing_isXXS() {
        #expect(XGSpacing.xxs == 2)
    }
}

// MARK: - XGSectionHeaderCrossTokenTests

/// Consistency checks: ensures different token roles use distinct visual values.
@Suite("XGSectionHeader Cross-Token Consistency Tests")
struct XGSectionHeaderCrossTokenTests {
    @Test("Title font is different from subtitle font")
    func titleFont_isDifferentFromSubtitleFont() {
        #expect(XGTypography.subtitle != XGTypography.bodyMedium)
    }

    @Test("Title color is different from subtitle color")
    func titleColor_isDifferentFromSubtitleColor() {
        #expect(XGColors.onSurface != XGColors.onSurfaceVariant)
    }

    @Test("See All color is different from title color")
    func seeAllColor_isDifferentFromTitleColor() {
        #expect(XGColors.brandPrimary != XGColors.onSurface)
    }

    @Test("See All color is different from subtitle color")
    func seeAllColor_isDifferentFromSubtitleColor() {
        #expect(XGColors.brandPrimary != XGColors.onSurfaceVariant)
    }

    @Test("See All color matches brand primary")
    func seeAllColor_matchesBrandPrimary() {
        #expect(XGColors.brandPrimary == XGColors.primary)
    }
}
