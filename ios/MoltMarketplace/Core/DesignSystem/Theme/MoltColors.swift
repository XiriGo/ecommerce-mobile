// swiftlint:disable no_magic_numbers
import SwiftUI

internal enum MoltColors {
    // MARK: - Primary Colors
    internal static let primary = Color(hex: "#6750A4")
    internal static let onPrimary = Color.white
    internal static let primaryContainer = Color(hex: "#EADDFF")
    internal static let onPrimaryContainer = Color(hex: "#21005D")

    // MARK: - Secondary Colors
    internal static let secondary = Color(hex: "#625B71")
    internal static let onSecondary = Color.white
    internal static let secondaryContainer = Color(hex: "#E8DEF8")
    internal static let onSecondaryContainer = Color(hex: "#1D192B")

    // MARK: - Tertiary Colors
    internal static let tertiary = Color(hex: "#7D5260")
    internal static let onTertiary = Color.white
    internal static let tertiaryContainer = Color(hex: "#FFD8E4")
    internal static let onTertiaryContainer = Color(hex: "#31111D")

    // MARK: - Error Colors
    internal static let error = Color(hex: "#B3261E")
    internal static let onError = Color.white
    internal static let errorContainer = Color(hex: "#F9DEDC")
    internal static let onErrorContainer = Color(hex: "#410E0B")

    // MARK: - Surface Colors
    internal static let surface = Color(hex: "#FFFBFE")
    internal static let onSurface = Color(hex: "#1C1B1F")
    internal static let surfaceVariant = Color(hex: "#E7E0EC")
    internal static let onSurfaceVariant = Color(hex: "#49454F")

    // MARK: - Outline Colors
    internal static let outline = Color(hex: "#79747E")
    internal static let outlineVariant = Color(hex: "#CAC4D0")

    // MARK: - Background Colors
    internal static let background = Color(hex: "#FFFBFE")
    internal static let onBackground = Color(hex: "#1C1B1F")

    // MARK: - Inverse Colors
    internal static let inverseSurface = Color(hex: "#313033")
    internal static let inverseOnSurface = Color(hex: "#F4EFF4")
    internal static let inversePrimary = Color(hex: "#D0BCFF")

    // MARK: - Other
    internal static let scrim = Color.black

    // MARK: - Semantic Colors (E-commerce)
    internal static let success = Color(hex: "#4CAF50")
    internal static let onSuccess = Color.white
    internal static let warning = Color(hex: "#FF9800")
    internal static let priceRegular = Color(hex: "#1C1B1F")
    internal static let priceSale = Color(hex: "#B3261E")
    internal static let priceOriginal = Color(hex: "#79747E")
    internal static let ratingStarFilled = Color(hex: "#FFC107")
    internal static let ratingStarEmpty = Color(hex: "#E0E0E0")
    internal static let badgeBackground = Color(hex: "#B3261E")
    internal static let badgeText = Color.white
    internal static let divider = Color(hex: "#CAC4D0")
    internal static let shimmer = Color(hex: "#E7E0EC")
}

// MARK: - Color Extension for Hex Support
extension Color {
    internal init(hex: String) {
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
// swiftlint:enable no_magic_numbers
