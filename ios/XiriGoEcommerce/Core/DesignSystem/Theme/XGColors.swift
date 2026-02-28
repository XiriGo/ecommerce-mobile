import SwiftUI

// MARK: - XGColors

enum XGColors {
    // MARK: - Primary Colors

    static let primary = Color(hex: "#6750A4")
    static let onPrimary = Color.white
    static let primaryContainer = Color(hex: "#EADDFF")
    static let onPrimaryContainer = Color(hex: "#21005D")

    // MARK: - Secondary Colors

    static let secondary = Color(hex: "#625B71")
    static let onSecondary = Color.white
    static let secondaryContainer = Color(hex: "#E8DEF8")
    static let onSecondaryContainer = Color(hex: "#1D192B")

    // MARK: - Tertiary Colors

    static let tertiary = Color(hex: "#7D5260")
    static let onTertiary = Color.white
    static let tertiaryContainer = Color(hex: "#FFD8E4")
    static let onTertiaryContainer = Color(hex: "#31111D")

    // MARK: - Error Colors

    static let error = Color(hex: "#B3261E")
    static let onError = Color.white
    static let errorContainer = Color(hex: "#F9DEDC")
    static let onErrorContainer = Color(hex: "#410E0B")

    // MARK: - Surface Colors

    static let surface = Color(hex: "#FFFBFE")
    static let onSurface = Color(hex: "#1C1B1F")
    static let surfaceVariant = Color(hex: "#E7E0EC")
    static let onSurfaceVariant = Color(hex: "#49454F")

    // MARK: - Outline Colors

    static let outline = Color(hex: "#79747E")
    static let outlineVariant = Color(hex: "#CAC4D0")

    // MARK: - Background Colors

    static let background = Color(hex: "#FFFBFE")
    static let onBackground = Color(hex: "#1C1B1F")

    // MARK: - Inverse Colors

    static let inverseSurface = Color(hex: "#313033")
    static let inverseOnSurface = Color(hex: "#F4EFF4")
    static let inversePrimary = Color(hex: "#D0BCFF")

    static let scrim = Color.black
    static let shadow = Color.black

    // MARK: - Semantic Colors (E-commerce)

    static let success = Color(hex: "#4CAF50")
    static let onSuccess = Color.white
    static let warning = Color(hex: "#FF9800")
    static let onWarning = Color.white
    static let info = Color(hex: "#2196F3")
    static let onInfo = Color.white
    static let priceRegular = Color(hex: "#1C1B1F")
    static let priceSale = Color(hex: "#B3261E")
    static let priceOriginal = Color(hex: "#79747E")
    static let ratingStarFilled = Color(hex: "#FFC107")
    static let ratingStarEmpty = Color(hex: "#E0E0E0")
    static let badgeBackground = Color(hex: "#B3261E")
    static let badgeText = Color.white
    static let divider = Color(hex: "#CAC4D0")
    static let shimmer = Color(hex: "#E7E0EC")

    // MARK: - Brand Colors

    static let brandPrimary = Color(hex: "#6000FE")
    static let brandOnPrimary = Color.white
    static let brandSecondary = Color(hex: "#94D63A")
    static let brandOnSecondary = Color(hex: "#6000FE")

    // MARK: - Pagination Dots

    static let paginationDotsActive = Color(hex: "#6000FE")
    static let paginationDotsInactive = Color(hex: "#D1D5DB")
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
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
