import SwiftUI

// MARK: - XGPaginationDots

/// Animated pagination indicator with pill (active) and circle (inactive) dots.
/// Token source: `components/atoms/xg-pagination-dots.json`.
///
/// - Active dot: 18pt wide pill with corner radius 3
/// - Inactive dot: 6pt circle
/// - Gap: 4pt between dots
/// - Uses spring animation for width transitions
struct XGPaginationDots: View {
    // MARK: - Lifecycle

    init(
        totalPages: Int,
        currentPage: Int,
        activeColor: Color = XGColors.paginationDotsActive,
        inactiveColor: Color = XGColors.paginationDotsInactive,
    ) {
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
    }

    // MARK: - Internal

    var body: some View {
        HStack(spacing: Constants.dotGap) {
            ForEach(0 ..< totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? activeColor : inactiveColor)
                    .frame(
                        width: index == currentPage ? Constants.activeWidth : Constants.inactiveWidth,
                        height: Constants.dotHeight,
                    )
                    .animation(XGMotion.Easing.spring, value: currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "onboarding_page_indicator_a11y \(currentPage + 1) \(totalPages)"))
    }

    // MARK: - Private

    private enum Constants {
        static let activeWidth: CGFloat = 18
        static let inactiveWidth: CGFloat = 6
        static let dotHeight: CGFloat = 6
        static let dotCornerRadius: CGFloat = 3
        static let dotGap: CGFloat = 4
    }

    private let totalPages: Int
    private let currentPage: Int
    private let activeColor: Color
    private let inactiveColor: Color
}

// MARK: - Previews

#Preview("XGPaginationDots Page 0") {
    XGPaginationDots(totalPages: 4, currentPage: 0)
        .padding()
        .xgTheme()
}

#Preview("XGPaginationDots Page 2") {
    XGPaginationDots(totalPages: 4, currentPage: 2)
        .padding()
        .xgTheme()
}

#Preview("XGPaginationDots on Dark") {
    ZStack {
        Color(hex: "#6000FE")
            .ignoresSafeArea()
        XGPaginationDots(
            totalPages: 4,
            currentPage: 1,
            activeColor: .white,
            inactiveColor: .white.opacity(0.4),
        )
    }
    .xgTheme()
}

#Preview("XGPaginationDots 3 Pages") {
    XGPaginationDots(totalPages: 3, currentPage: 0)
        .padding()
        .xgTheme()
}
