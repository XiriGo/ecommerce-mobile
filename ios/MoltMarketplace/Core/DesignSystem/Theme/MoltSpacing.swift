import SwiftUI

// swiftlint:disable no_magic_numbers

enum MoltSpacing {
    // MARK: - Base Spacing

    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64

    // MARK: - Layout Constants

    static let screenPaddingHorizontal: CGFloat = 16
    static let screenPaddingVertical: CGFloat = 16
    static let cardPadding: CGFloat = 12
    static let listItemSpacing: CGFloat = 8
    static let sectionSpacing: CGFloat = 24
    static let productGridSpacing: CGFloat = 8
    static let productGridColumns: Int = 2
    static let minTouchTarget: CGFloat = 44 // Apple HIG: 44pt minimum

    // MARK: - Icon Sizes

    enum IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 32
        static let extraLarge: CGFloat = 48
    }

    // MARK: - Avatar Sizes

    enum AvatarSize {
        static let small: CGFloat = 32
        static let medium: CGFloat = 48
        static let large: CGFloat = 64
        static let extraLarge: CGFloat = 96
    }
}

// swiftlint:enable no_magic_numbers
