import SwiftUI

/// Spacing, icon, and layout constants derived from `shared/design-tokens/foundations/spacing.json`.
/// All values must match the JSON source.
enum XGSpacing {
    // MARK: - Icon Sizes

    enum IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 27
        static let extraLarge: CGFloat = 32
    }

    // MARK: - Avatar Sizes

    enum AvatarSize {
        static let small: CGFloat = 32
        static let medium: CGFloat = 48
        static let large: CGFloat = 64
        static let extraLarge: CGFloat = 96
    }

    // MARK: - Base Spacing

    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48

    // MARK: - Layout Constants

    static let screenPaddingHorizontal: CGFloat = 20
    static let screenPaddingVertical: CGFloat = 16
    static let cardPadding: CGFloat = 12
    static let listItemSpacing: CGFloat = 10
    static let sectionSpacing: CGFloat = 24
    static let productGridSpacing: CGFloat = 10
    static let productGridColumns: Int = 2
    static let minTouchTarget: CGFloat = 48
}
