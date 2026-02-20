import SwiftUI

internal enum MoltSpacing {
    // MARK: - Base Spacing
    internal static let xxs: CGFloat = 2
    internal static let xs: CGFloat = 4
    internal static let sm: CGFloat = 8
    internal static let md: CGFloat = 12
    internal static let base: CGFloat = 16
    internal static let lg: CGFloat = 24
    internal static let xl: CGFloat = 32
    internal static let xxl: CGFloat = 48
    internal static let xxxl: CGFloat = 64

    // MARK: - Layout Constants
    internal static let screenPaddingHorizontal: CGFloat = 16
    internal static let screenPaddingVertical: CGFloat = 16
    internal static let cardPadding: CGFloat = 12
    internal static let listItemSpacing: CGFloat = 8
    internal static let sectionSpacing: CGFloat = 24
    internal static let productGridSpacing: CGFloat = 8
    internal static let productGridColumns: Int = 2
    internal static let minTouchTarget: CGFloat = 44  // Apple HIG: 44pt minimum
}
