import SwiftUI

// MARK: - XGColors

/// Design system color tokens derived from `shared/design-tokens/foundations/colors.json`.
/// All values must match the JSON source — never use Material 3 defaults.
enum XGColors {
    // MARK: - Brand Colors

    static let brandPrimary = Color(hex: "#6000FE")
    static let brandPrimaryLight = Color(hex: "#9000FE")
    static let brandPrimaryDark = Color(hex: "#3C00D2")
    static let brandSecondary = Color(hex: "#94D63A")
    static let brandOnPrimary = Color.white
    static let brandOnSecondary = Color(hex: "#6000FE")

    // MARK: - Primary / Secondary (Alias for brand usage in generic components)

    static let primary = Color(hex: "#6000FE")
    static let onPrimary = Color.white
    static let secondary = Color(hex: "#94D63A")
    static let onSecondary = Color(hex: "#6000FE")
    static let secondaryContainer = Color(hex: "#6200FF")
    static let onSecondaryContainer = Color.white

    // MARK: - Surface Colors

    static let background = Color(hex: "#F8F9FC")
    static let onBackground = Color(hex: "#333333")
    static let surface = Color(hex: "#FFFFFF")
    static let onSurface = Color(hex: "#333333")
    static let surfaceSecondary = Color(hex: "#F9FAFB")
    static let surfaceVariant = Color(hex: "#F9FAFB")
    static let onSurfaceVariant = Color(hex: "#8E8E93")
    static let surfaceElevated = Color(hex: "#FFFFFF")

    // MARK: - Border / Outline Colors

    static let outline = Color(hex: "#E5E7EB")
    static let outlineVariant = Color(hex: "#F0F0F0")
    static let borderStrong = Color(hex: "#D1D5DB")

    // MARK: - Text Colors

    static let textDark = Color(hex: "#111827")
    static let textDarkSecondary = Color(hex: "#374151")
    static let textOnDark = Color.white
    static let textLink = Color(hex: "#6000FE")
    static let textPlaceholder = Color(hex: "#9CA3AF")
    static let textTertiary = Color(hex: "#9CA3AF")

    // MARK: - Icon Colors

    static let iconActive = Color(hex: "#6000FE")
    static let iconInactive = Color(hex: "#8E8E93")
    static let iconOnDark = Color.white
    static let iconButtonBackground = Color(hex: "#F3F4F6")

    // MARK: - Input Colors

    static let inputBackground = Color(hex: "#F9FAFB")
    static let inputBorder = Color(hex: "#E5E7EB")
    static let inputPlaceholder = Color(hex: "#9CA3AF")
    static let inputLabel = Color(hex: "#9CA3AF")

    // MARK: - Divider

    static let divider = Color(hex: "#E5E7EB")

    // MARK: - Error Colors

    static let error = Color(hex: "#EF4444")
    static let onError = Color.white

    // MARK: - Semantic Status Colors

    static let success = Color(hex: "#22C55E")
    static let onSuccess = Color.white
    static let warning = Color(hex: "#FACC15")
    static let onWarning = Color(hex: "#1D1D1B")
    static let info = Color(hex: "#3B82F6")
    static let onInfo = Color.white

    // MARK: - Price Colors

    static let priceRegular = Color(hex: "#333333")
    static let priceSale = Color(hex: "#6000FE")
    static let priceOriginal = Color(hex: "#8E8E93")
    static let priceStrikethrough = Color(hex: "#8E8E93")

    // MARK: - Rating Colors

    static let ratingStarFilled = Color(hex: "#6000FE")
    static let ratingStarEmpty = Color(hex: "#8E8E93")
    static let ratingStarDeal = Color(hex: "#FACC15")

    // MARK: - Badge Colors

    static let badgeBackground = Color(hex: "#6000FE")
    static let badgeText = Color.white
    static let badgeSecondaryBackground = Color(hex: "#94D63A")
    static let badgeSecondaryText = Color(hex: "#6000FE")

    // MARK: - Delivery & Cart

    static let deliveryText = Color(hex: "#94D63A")
    static let addToCart = Color(hex: "#94D63A")

    // MARK: - Shimmer

    static let shimmer = Color(hex: "#F1F5F9")

    // MARK: - Flash Sale Colors

    static let flashSaleBackground = Color(hex: "#FFD814")
    static let flashSaleAccentBlue = Color(hex: "#9EBDF4")
    static let flashSaleAccentPink = Color(hex: "#F60186")
    static let flashSaleText = Color(hex: "#1D1D1B")

    // MARK: - Pagination Dots

    static let paginationDotsActive = Color(hex: "#6000FE")
    static let paginationDotsInactive = Color(hex: "#D1D5DB")

    // MARK: - Bottom Navigation

    static let bottomNavBackground = Color.white
    static let bottomNavIconActive = Color(hex: "#6000FE")
    static let bottomNavIconInactive = Color(hex: "#8E8E93")

    // MARK: - Scrim & Shadow

    static let scrim = Color.black
    static let shadow = Color.black

    // MARK: - Tertiary (fallback gradients)

    static let tertiary = Color(hex: "#3C00D2")

    // MARK: - Social Auth Colors

    static let socialGoogleBlue = Color(hex: "#4285F4")
    static let socialGoogleGreen = Color(hex: "#34A853")
    static let socialGoogleYellow = Color(hex: "#FBBC05")
    static let socialGoogleRed = Color(hex: "#EA4335")
    static let socialAppleBlack = Color(hex: "#000000")
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0,
        )
    }
}
