import SwiftUI

// MARK: - HomeScreenSkeletonConstants

/// Layout constants for HomeScreenSkeleton, derived from home-screen.json design tokens.
private enum HomeScreenSkeletonConstants {
    static let searchBarHeight: CGFloat = 43
    static let heroBannerHeight: CGFloat = 210
    static let categoryCircleSize: CGFloat = 56
    static let categoryLabelWidth: CGFloat = 48
    static let categoryLabelHeight: CGFloat = 10
    static let sectionHeaderLineWidth: CGFloat = 120
    static let sectionHeaderLineHeight: CGFloat = 18
    static let popularSectionHeaderWidth: CGFloat = 140
    static let featuredCardWidth: CGFloat = 160
    static let categoryPlaceholderCount = 5
    static let popularProductPlaceholderCount = 3
    static let newArrivalGridColumns = 2
    static let newArrivalGridRows = 2
    static let newArrivalTotalCards = newArrivalGridColumns * newArrivalGridRows
}

// MARK: - HomeScreenSkeleton

/// Full-screen skeleton placeholder that mirrors the HomeScreen layout.
///
/// Displays shimmer placeholders for: search bar, hero banner, categories,
/// popular products, and new arrivals grid -- matching the real HomeScreen
/// section order and spacing.
///
/// Used during initial load and pull-to-refresh.
struct HomeScreenSkeleton: View {
    // MARK: - Internal

    var body: some View {
        ScrollView {
            VStack(spacing: XGSpacing.sectionSpacing) {
                searchBarSkeleton
                heroBannerSkeleton
                categorySectionSkeleton
                popularProductsSectionSkeleton
                newArrivalsSectionSkeleton
            }
            .padding(.top, XGSpacing.base)
            .padding(.bottom, XGSpacing.sectionSpacing)
        }
        .accessibilityLabel(Text("skeleton_loading_placeholder"))
    }

    // MARK: - Private

    private var searchBarSkeleton: some View {
        RoundedRectangle(cornerRadius: XGCornerRadius.pill)
            .fill(XGColors.shimmer)
            .frame(maxWidth: .infinity)
            .frame(height: HomeScreenSkeletonConstants.searchBarHeight)
            .shimmerEffect()
            .accessibilityHidden(true)
            .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
    }

    private var heroBannerSkeleton: some View {
        RoundedRectangle(cornerRadius: XGCornerRadius.medium)
            .fill(XGColors.shimmer)
            .frame(maxWidth: .infinity)
            .frame(height: HomeScreenSkeletonConstants.heroBannerHeight)
            .shimmerEffect()
            .accessibilityHidden(true)
            .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
    }

    private var categorySectionSkeleton: some View {
        VStack(alignment: .leading, spacing: XGSpacing.sm) {
            // Section header skeleton
            SkeletonLine(
                width: HomeScreenSkeletonConstants.sectionHeaderLineWidth,
                height: HomeScreenSkeletonConstants.sectionHeaderLineHeight,
            )
            .padding(.horizontal, XGSpacing.screenPaddingHorizontal)

            // Horizontal category placeholders
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: XGSpacing.base) {
                    ForEach(
                        0 ..< HomeScreenSkeletonConstants.categoryPlaceholderCount,
                        id: \.self,
                    ) { _ in
                        categoryItemSkeleton
                    }
                }
                .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
            }
        }
    }

    private var categoryItemSkeleton: some View {
        VStack(spacing: XGSpacing.xs) {
            SkeletonCircle(size: HomeScreenSkeletonConstants.categoryCircleSize)
            SkeletonLine(
                width: HomeScreenSkeletonConstants.categoryLabelWidth,
                height: HomeScreenSkeletonConstants.categoryLabelHeight,
            )
        }
    }

    private var popularProductsSectionSkeleton: some View {
        VStack(alignment: .leading, spacing: XGSpacing.sm) {
            // Section header skeleton
            SkeletonLine(
                width: HomeScreenSkeletonConstants.popularSectionHeaderWidth,
                height: HomeScreenSkeletonConstants.sectionHeaderLineHeight,
            )
            .padding(.horizontal, XGSpacing.screenPaddingHorizontal)

            // Horizontal product card skeletons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: XGSpacing.productGridSpacing) {
                    ForEach(
                        0 ..< HomeScreenSkeletonConstants.popularProductPlaceholderCount,
                        id: \.self,
                    ) { _ in
                        ProductCardSkeleton()
                            .frame(width: HomeScreenSkeletonConstants.featuredCardWidth)
                    }
                }
                .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
            }
        }
    }

    private var newArrivalsSectionSkeleton: some View {
        VStack(alignment: .leading, spacing: XGSpacing.sm) {
            // Section header skeleton
            SkeletonLine(
                width: HomeScreenSkeletonConstants.sectionHeaderLineWidth,
                height: HomeScreenSkeletonConstants.sectionHeaderLineHeight,
            )
            .padding(.horizontal, XGSpacing.screenPaddingHorizontal)

            // 2-column product grid skeleton
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: XGSpacing.productGridSpacing),
                    GridItem(.flexible(), spacing: XGSpacing.productGridSpacing),
                ],
                spacing: XGSpacing.productGridSpacing,
            ) {
                ForEach(
                    0 ..< HomeScreenSkeletonConstants.newArrivalTotalCards,
                    id: \.self,
                ) { _ in
                    ProductCardSkeleton()
                }
            }
            .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
        }
    }
}

// MARK: - Preview

#Preview("HomeScreenSkeleton") {
    HomeScreenSkeleton()
        .xgTheme()
}
