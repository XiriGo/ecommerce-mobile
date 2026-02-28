import SwiftUI

// MARK: - XGPaginationDots

/// Animated pagination indicator with pill (active) and circle (inactive) dots.
/// Token source: `components.json > XGPaginationDots`.
///
/// - Active dot: 18pt wide pill with corner radius 3
/// - Inactive dot: 6pt circle
/// - Gap: 4pt between dots
/// - Uses spring animation for width transitions
struct XGPaginationDots: View {
    // MARK: - Properties

    private let pageCount: Int
    private let currentPage: Int
    private let activeColor: Color
    private let inactiveColor: Color

    // MARK: - Constants

    private let activeWidth: CGFloat = 18
    private let inactiveWidth: CGFloat = 6
    private let dotHeight: CGFloat = 6
    private let dotCornerRadius: CGFloat = 3
    private let dotGap: CGFloat = 4

    // MARK: - Init

    init(
        pageCount: Int,
        currentPage: Int,
        activeColor: Color = Color(hex: "#6000FE"),
        inactiveColor: Color = Color(hex: "#D1D5DB")
    ) {
        self.pageCount = pageCount
        self.currentPage = currentPage
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: dotGap) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? activeColor : inactiveColor)
                    .frame(
                        width: index == currentPage ? activeWidth : inactiveWidth,
                        height: dotHeight
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "onboarding_page_indicator_a11y \(currentPage + 1) \(pageCount)"))
    }
}

// MARK: - Previews

#Preview("XGPaginationDots Page 0") {
    XGPaginationDots(pageCount: 4, currentPage: 0)
        .padding()
}

#Preview("XGPaginationDots Page 2") {
    XGPaginationDots(pageCount: 4, currentPage: 2)
        .padding()
}

#Preview("XGPaginationDots on Dark") {
    ZStack {
        Color(hex: "#6000FE")
            .ignoresSafeArea()
        XGPaginationDots(
            pageCount: 4,
            currentPage: 1,
            activeColor: .white,
            inactiveColor: .white.opacity(0.4)
        )
    }
}

#Preview("XGPaginationDots 3 Pages") {
    XGPaginationDots(pageCount: 3, currentPage: 0)
        .padding()
}
