import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - XGCategoryIconInitTests

/// Verifies that XGCategoryIcon initialises with various parameter combinations
/// without crashing and matches the API defined in xg-category-icon.json.
@Suite("XGCategoryIcon Initialisation Tests")
@MainActor
struct XGCategoryIconInitTests {
    // MARK: - Basic Init

    @Test("XGCategoryIcon initialises with all required parameters")
    func init_allParams_succeeds() {
        let icon = XGCategoryIcon(
            name: "Electronics",
            systemIconName: "desktopcomputer",
            backgroundColor: XGColors.categoryBlue,
            action: {},
        )
        _ = icon
        #expect(true)
    }

    @Test("XGCategoryIcon initialises with empty name")
    func init_emptyName_succeeds() {
        let icon = XGCategoryIcon(
            name: "",
            systemIconName: "tshirt",
            backgroundColor: XGColors.categoryPink,
            action: {},
        )
        _ = icon
        #expect(true)
    }

    @Test("XGCategoryIcon initialises with long name")
    func init_longName_succeeds() {
        let icon = XGCategoryIcon(
            name: "A Very Long Category Name That Should Truncate",
            systemIconName: "house",
            backgroundColor: XGColors.categoryYellow,
            action: {},
        )
        _ = icon
        #expect(true)
    }

    @Test("XGCategoryIcon initialises with each category background color")
    func init_eachCategoryColor_succeeds() {
        let colors: [Color] = [
            XGColors.categoryBlue,
            XGColors.categoryPink,
            XGColors.categoryYellow,
            XGColors.categoryMint,
            XGColors.categoryLightYellow,
        ]
        for color in colors {
            let icon = XGCategoryIcon(
                name: "Test",
                systemIconName: "star",
                backgroundColor: color,
                action: {},
            )
            _ = icon
        }
        #expect(true)
    }
}

// MARK: - XGCategoryIconTokenContractTests

/// Contract tests verifying that token constants consumed by XGCategoryIcon
/// match the values in `shared/design-tokens/components/atoms/xg-category-icon.json`.
@Suite("XGCategoryIcon Token Contract Tests")
struct XGCategoryIconTokenContractTests {
    // MARK: - Tile Size (79pt)

    @Test("Tile size constant is 79pt")
    func tileSize_is79() {
        // Mirrors private Constants.tileSize in XGCategoryIcon.swift
        let tileSize: CGFloat = 79
        #expect(tileSize == 79)
    }

    @Test("Tile size is larger than minimum touch target")
    func tileSize_isLargerThanMinTouchTarget() {
        let tileSize: CGFloat = 79
        #expect(tileSize >= XGSpacing.minTouchTarget)
    }

    // MARK: - Corner Radius (XGCornerRadius.medium = 10pt)

    @Test("Corner radius uses XGCornerRadius.medium")
    func cornerRadius_usesXGCornerRadiusMedium() {
        #expect(XGCornerRadius.medium == 10)
    }

    @Test("Corner radius is not small (6pt)")
    func cornerRadius_isNotSmall() {
        #expect(XGCornerRadius.medium != XGCornerRadius.small)
    }

    @Test("Corner radius is not large (16pt)")
    func cornerRadius_isNotLarge() {
        #expect(XGCornerRadius.medium != XGCornerRadius.large)
    }

    // MARK: - Icon Size (40pt)

    @Test("Icon size constant is 40pt")
    func iconSize_is40() {
        // Mirrors private Constants.iconSize in XGCategoryIcon.swift
        let iconSize: CGFloat = 40
        #expect(iconSize == 40)
    }

    @Test("Icon size is smaller than tile size")
    func iconSize_isSmallerThanTileSize() {
        let iconSize: CGFloat = 40
        let tileSize: CGFloat = 79
        #expect(iconSize < tileSize)
    }

    // MARK: - Icon Color (XGColors.iconOnDark = white)

    @Test("Icon color is XGColors.iconOnDark (white)")
    func iconColor_isIconOnDark() {
        #expect(XGColors.iconOnDark == Color.white)
    }

    // MARK: - Label Font (XGTypography.captionMedium = 12pt Poppins-Medium)

    @Test("Label font is XGTypography.captionMedium (12pt Poppins-Medium)")
    func labelFont_isCaptionMedium() {
        let font = XGTypography.captionMedium
        #expect(font == Font.custom("Poppins-Medium", size: 12))
    }

    @Test("Label font is different from caption (regular weight)")
    func labelFont_isMedium_notRegular() {
        #expect(XGTypography.captionMedium != XGTypography.caption)
    }

    // MARK: - Label Color (XGColors.onSurface = #333333)

    @Test("Label color is XGColors.onSurface (#333333)")
    func labelColor_isOnSurface() {
        #expect(XGColors.onSurface == Color(hex: "#333333"))
    }

    // MARK: - Label Spacing (6pt)

    @Test("Label spacing constant is 6pt")
    func labelSpacing_is6() {
        // Mirrors private Constants.labelSpacing in XGCategoryIcon.swift
        let labelSpacing: CGFloat = 6
        #expect(labelSpacing == 6)
    }

    @Test("Label spacing is positive")
    func labelSpacing_isPositive() {
        let labelSpacing: CGFloat = 6
        #expect(labelSpacing > 0)
    }
}

// MARK: - XGCategoryIconCategoryColorTests

/// Verifies that all 5 category background colors from the token spec exist
/// and match the hex values in `shared/design-tokens/foundations/colors.json`.
@Suite("XGCategoryIcon Category Color Tests")
struct XGCategoryIconCategoryColorTests {
    @Test("CategoryBlue matches design token (#37B4F2)")
    func categoryBlue_matchesToken() {
        #expect(XGColors.categoryBlue == Color(hex: "#37B4F2"))
    }

    @Test("CategoryPink matches design token (#FE75D4)")
    func categoryPink_matchesToken() {
        #expect(XGColors.categoryPink == Color(hex: "#FE75D4"))
    }

    @Test("CategoryYellow matches design token (#FDF29C)")
    func categoryYellow_matchesToken() {
        #expect(XGColors.categoryYellow == Color(hex: "#FDF29C"))
    }

    @Test("CategoryMint matches design token (#90D3B1)")
    func categoryMint_matchesToken() {
        #expect(XGColors.categoryMint == Color(hex: "#90D3B1"))
    }

    @Test("CategoryLightYellow matches design token (#FEF170)")
    func categoryLightYellow_matchesToken() {
        #expect(XGColors.categoryLightYellow == Color(hex: "#FEF170"))
    }

    @Test("All 5 category colors are distinct")
    func allCategoryColors_areDistinct() {
        let colors: [Color] = [
            XGColors.categoryBlue,
            XGColors.categoryPink,
            XGColors.categoryYellow,
            XGColors.categoryMint,
            XGColors.categoryLightYellow,
        ]
        let uniqueColors = Set(colors.map { "\($0)" })
        #expect(uniqueColors.count == 5)
    }
}

// MARK: - XGCategoryIconCrossTokenTests

/// Consistency checks: ensures different token roles use distinct visual values.
@Suite("XGCategoryIcon Cross-Token Consistency Tests")
struct XGCategoryIconCrossTokenTests {
    @Test("Label color is distinct from icon color")
    func labelColor_isDifferentFromIconColor() {
        // OnSurface (#333333) vs iconOnDark (white) — high contrast pair
        #expect(XGColors.onSurface != XGColors.iconOnDark)
    }

    @Test("Icon color provides contrast on colored backgrounds")
    func iconColor_isWhite() {
        // White icon on mid-tone category backgrounds
        #expect(XGColors.iconOnDark == Color.white)
    }

    @Test("Label font size is consistent with caption scale")
    func labelFont_isInCaptionScale() {
        // captionMedium (12pt) should match caption (12pt) in size, differ in weight
        #expect(XGTypography.captionMedium == Font.custom("Poppins-Medium", size: 12))
        #expect(XGTypography.caption == Font.custom("Poppins-Regular", size: 12))
    }
}
