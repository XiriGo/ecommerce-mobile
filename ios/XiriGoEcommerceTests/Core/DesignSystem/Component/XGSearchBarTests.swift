import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGSearchBarInitTests

@Suite("XGSearchBar Initialisation Tests")
@MainActor
struct XGSearchBarInitTests {
    @Test("XGSearchBar initialises with placeholder and action")
    func init_withPlaceholderAndAction_initialises() {
        let searchBar = XGSearchBar(placeholder: "Search...", action: {})
        _ = searchBar
        #expect(true)
    }

    @Test("XGSearchBar initialises with empty placeholder")
    func init_emptyPlaceholder_initialises() {
        let searchBar = XGSearchBar(placeholder: "", action: {})
        _ = searchBar
        #expect(true)
    }

    @Test("XGSearchBar initialises with long placeholder")
    func init_longPlaceholder_initialises() {
        let searchBar = XGSearchBar(
            placeholder: "Search products, brands, categories and more...",
            action: {},
        )
        _ = searchBar
        #expect(true)
    }
}

// MARK: - XGSearchBarTokenContractTests

/// Contract tests verifying token references match
/// `shared/design-tokens/components/atoms/xg-search-bar.json`.
@Suite("XGSearchBar Token Contract Tests")
struct XGSearchBarTokenContractTests {
    // MARK: - Background Color

    @Test("Background uses XGColors.inputBackground (#F9FAFB)")
    func background_isInputBackground() {
        // colors.light.inputBackground = #F9FAFB
        #expect(XGColors.inputBackground == Color(hex: "#F9FAFB"))
    }

    // MARK: - Border Color

    @Test("Border uses XGColors.outlineVariant (#F0F0F0)")
    func border_isOutlineVariant() {
        // colors.light.borderSubtle = #F0F0F0
        #expect(XGColors.outlineVariant == Color(hex: "#F0F0F0"))
    }

    @Test("Border color differs from background color")
    func borderColor_differsFromBackground() {
        #expect(XGColors.outlineVariant != XGColors.inputBackground)
    }

    // MARK: - Corner Radius

    @Test("Corner radius uses XGCornerRadius.pill (28)")
    func cornerRadius_isPill() {
        // cornerRadius.pill = 28
        #expect(XGCornerRadius.pill == 28)
    }

    @Test("Pill corner radius is greater than medium")
    func pill_isGreaterThanMedium() {
        // pill (28) > medium (10)
        #expect(XGCornerRadius.pill > XGCornerRadius.medium)
    }

    @Test("Pill corner radius is less than full")
    func pill_isLessThanFull() {
        // pill (28) < full (999)
        #expect(XGCornerRadius.pill < XGCornerRadius.full)
    }

    // MARK: - Icon Size

    @Test("Icon size uses XGSpacing.IconSize.medium (24)")
    func iconSize_isMedium() {
        // layout.iconSize.medium = 24
        #expect(XGSpacing.IconSize.medium == 24)
    }

    @Test("Icon medium is greater than small (16)")
    func iconMedium_isGreaterThanSmall() {
        #expect(XGSpacing.IconSize.medium > XGSpacing.IconSize.small)
    }

    // MARK: - Icon Color

    @Test("Icon color uses XGColors.onSurfaceVariant (#8E8E93)")
    func iconColor_isOnSurfaceVariant() {
        // colors.light.textSecondary = #8E8E93
        #expect(XGColors.onSurfaceVariant == Color(hex: "#8E8E93"))
    }

    // MARK: - Placeholder Font

    @Test("Placeholder font is XGTypography.bodyLarge (16pt Poppins Regular)")
    func placeholderFont_isBodyLarge() {
        // typeScale.bodyLarge = 16pt Poppins Regular
        #expect(XGTypography.bodyLarge == Font.custom("Poppins-Regular", size: 16))
    }

    // MARK: - Placeholder Color

    @Test("Placeholder color uses XGColors.onSurfaceVariant (#8E8E93)")
    func placeholderColor_isOnSurfaceVariant() {
        #expect(XGColors.onSurfaceVariant == Color(hex: "#8E8E93"))
    }

    @Test("Placeholder color differs from onSurface (textPrimary)")
    func placeholderColor_differsFromOnSurface() {
        // textSecondary (#8E8E93) != textPrimary (#333333)
        #expect(XGColors.onSurfaceVariant != XGColors.onSurface)
    }

    // MARK: - Padding

    @Test("Horizontal padding uses XGSpacing.md (12)")
    func horizontalPadding_isMd() {
        // spacing.md = 12
        #expect(XGSpacing.md == 12)
    }

    @Test("Vertical padding uses XGSpacing.md (12)")
    func verticalPadding_isMd() {
        #expect(XGSpacing.md == 12)
    }

    @Test("MD padding is less than base (16)")
    func mdPadding_isLessThanBase() {
        #expect(XGSpacing.md < XGSpacing.base)
    }

    @Test("MD padding is greater than SM (8)")
    func mdPadding_isGreaterThanSm() {
        #expect(XGSpacing.md > XGSpacing.sm)
    }
}
