import SwiftUI

/// Typography tokens derived from `shared/design-tokens/foundations/typography.json`.
/// All font styles use Poppins (primary) or Source Sans 3 (price).
/// Values must match the JSON source — never use Font.system().
enum XGTypography {
    // MARK: - Micro

    /// 10pt Regular — delivery deadline text, micro labels
    static let micro = Font.custom("Poppins-Regular", size: 10)

    // MARK: - Caption

    /// 12pt Regular — product card title, review count, badge labels
    static let caption = Font.custom("Poppins-Regular", size: 12)

    /// 12pt Medium — divider text
    static let captionMedium = Font.custom("Poppins-Medium", size: 12)

    /// 12pt SemiBold — product card name on grid cards
    static let captionSemiBold = Font.custom("Poppins-SemiBold", size: 12)

    // MARK: - Body

    /// 14pt Regular — form labels, body text, banner subtitle
    static let body = Font.custom("Poppins-Regular", size: 14)

    /// 14pt Medium — links, filter pill text, "See All"
    static let bodyMedium = Font.custom("Poppins-Medium", size: 14)

    /// 14pt SemiBold — subtitle text, tag text
    static let bodySemiBold = Font.custom("Poppins-SemiBold", size: 14)

    // MARK: - Body Large

    /// 16pt Regular — search placeholder, welcome text
    static let bodyLarge = Font.custom("Poppins-Regular", size: 16)

    // MARK: - Subtitle

    /// 18pt SemiBold — section headings
    static let subtitle = Font.custom("Poppins-SemiBold", size: 18)

    /// 18pt Bold — CTA button text
    static let subtitleBold = Font.custom("Poppins-Bold", size: 18)

    // MARK: - Title

    /// 20pt SemiBold — deal card product name
    static let title = Font.custom("Poppins-SemiBold", size: 20)

    // MARK: - Headline

    /// 24pt SemiBold — hero banner headline
    static let headline = Font.custom("Poppins-SemiBold", size: 24)

    // MARK: - Display

    /// 28pt Bold — large display text, promotional headers
    static let display = Font.custom("Poppins-Bold", size: 28)

    // MARK: - Legacy Aliases (mapped to design token equivalents)

    static let displayLarge = Font.custom("Poppins-Bold", size: 28)
    static let displayMedium = Font.custom("Poppins-Bold", size: 28)
    static let displaySmall = Font.custom("Poppins-Bold", size: 28)
    static let headlineLarge = Font.custom("Poppins-SemiBold", size: 24)
    static let headlineMedium = Font.custom("Poppins-SemiBold", size: 24)
    static let headlineSmall = Font.custom("Poppins-SemiBold", size: 24)
    static let titleLarge = Font.custom("Poppins-SemiBold", size: 20)
    static let titleMedium = Font.custom("Poppins-Medium", size: 16)
    static let titleSmall = Font.custom("Poppins-Medium", size: 14)
    static let bodySmall = Font.custom("Poppins-Regular", size: 12)
    static let labelLarge = Font.custom("Poppins-Medium", size: 14)
    static let labelMedium = Font.custom("Poppins-Medium", size: 12)
    static let labelSmall = Font.custom("Poppins-Medium", size: 11)

    // MARK: - Price Font Helper

    /// Source Sans 3 Black for price display components.
    static func priceFont(size: CGFloat) -> Font {
        .custom("SourceSans3-Black", size: size)
    }

    /// Poppins Medium for strikethrough original prices.
    static func strikethroughFont(size: CGFloat) -> Font {
        .custom("Poppins-Medium", size: size)
    }
}
