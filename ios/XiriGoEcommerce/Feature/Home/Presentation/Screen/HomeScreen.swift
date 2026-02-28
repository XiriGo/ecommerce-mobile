import SwiftUI

// MARK: - HomeScreen

/// Main home screen displaying featured content, categories, and product sections.
struct HomeScreen: View {
    // MARK: - Constants

    private enum Constants {
        static let bannerSubtitleOpacity: Double = 0.85
        static let bannerWidth: CGFloat = 280
        static let bannerHeight: CGFloat = 160
        static let categoryBorderOpacity: Double = 0.5
        static let newArrivalCardWidth: CGFloat = 180
    }

    // MARK: - Properties

    @Environment(AppRouter.self)
    private var router

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: XGSpacing.sectionSpacing) {
                welcomeHeader
                searchBar
                featuredBanners
                categoriesSection
                popularProductsSection
                newArrivalsSection
            }
            .padding(.bottom, XGSpacing.xl)
        }
        .background(XGColors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "nav_tab_home"))
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: XGSpacing.xs) {
            Text(String(localized: "home_welcome_title"))
                .font(XGTypography.headlineMedium)
                .foregroundStyle(XGColors.onSurface)

            Text(String(localized: "home_welcome_subtitle"))
                .font(XGTypography.bodyLarge)
                .foregroundStyle(XGColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
        .padding(.top, XGSpacing.sm)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        Button {
            router.navigate(to: .productSearch)
        } label: {
            HStack(spacing: XGSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .font(.system(size: XGSpacing.IconSize.medium))
                    .accessibilityHidden(true)

                Text(String(localized: "home_search_placeholder"))
                    .font(XGTypography.bodyLarge)
                    .foregroundStyle(XGColors.onSurfaceVariant)

                Spacer()
            }
            .padding(.horizontal, XGSpacing.md)
            .padding(.vertical, XGSpacing.md)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.full))
            .overlay(
                RoundedRectangle(cornerRadius: XGCornerRadius.full)
                    .stroke(XGColors.outlineVariant, lineWidth: 1)
            )
        }
        .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
        .accessibilityLabel(String(localized: "home_search_placeholder"))
    }

    // MARK: - Featured Banners

    private var featuredBanners: some View {
        VStack(alignment: .leading, spacing: XGSpacing.md) {
            sectionHeader(String(localized: "home_featured_title"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: XGSpacing.md) {
                    ForEach(HomeBanner.samples, id: \.id) { banner in
                        featuredBannerCard(banner)
                    }
                }
                .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
            }
        }
    }

    private func featuredBannerCard(_ banner: HomeBanner) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: banner.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: XGSpacing.xs) {
                Text(banner.title)
                    .font(XGTypography.headlineSmall)
                    .foregroundStyle(.white)

                Text(banner.subtitle)
                    .font(XGTypography.bodyMedium)
                    .foregroundStyle(.white.opacity(Constants.bannerSubtitleOpacity))
            }
            .padding(XGSpacing.lg)
        }
        .frame(width: Constants.bannerWidth, height: Constants.bannerHeight)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.large))
        .xgElevation(XGElevation.level2)
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: XGSpacing.md) {
            sectionHeader(String(localized: "home_categories_title"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: XGSpacing.base) {
                    ForEach(HomeCategory.samples, id: \.id) { category in
                        categoryItem(category)
                    }
                }
                .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
            }
        }
    }

    private func categoryItem(_ category: HomeCategory) -> some View {
        Button {
            router.navigate(to: .categoryProducts(categoryId: category.id, categoryName: category.name))
        } label: {
            VStack(spacing: XGSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: XGSpacing.AvatarSize.extraLarge, height: XGSpacing.AvatarSize.extraLarge)
                        .overlay(
                            Circle()
                                .stroke(XGColors.outlineVariant.opacity(Constants.categoryBorderOpacity), lineWidth: 1)
                        )

                    Image(systemName: category.icon)
                        .font(.system(size: XGSpacing.IconSize.large))
                        .foregroundStyle(XGColors.primary)
                }

                Text(category.name)
                    .font(XGTypography.labelMedium)
                    .foregroundStyle(XGColors.onSurface)
                    .lineLimit(1)
            }
            .frame(width: XGSpacing.AvatarSize.extraLarge)
        }
        .accessibilityLabel(category.name)
    }

    // MARK: - Popular Products Section

    private var popularProductsSection: some View {
        VStack(alignment: .leading, spacing: XGSpacing.md) {
            sectionHeader(String(localized: "home_popular_title"))

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: XGSpacing.productGridSpacing),
                    GridItem(.flexible(), spacing: XGSpacing.productGridSpacing),
                ],
                spacing: XGSpacing.productGridSpacing
            ) {
                ForEach(HomeProduct.popularSamples, id: \.id) { product in
                    XGProductCard(
                        imageUrl: nil,
                        title: product.title,
                        price: product.price,
                        originalPrice: product.originalPrice,
                        vendorName: product.vendor,
                        rating: product.rating,
                        reviewCount: product.reviewCount,
                        action: {
                            router.navigate(to: .productDetail(productId: product.id))
                        }
                    )
                }
            }
            .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
        }
    }

    // MARK: - New Arrivals Section

    private var newArrivalsSection: some View {
        VStack(alignment: .leading, spacing: XGSpacing.md) {
            sectionHeader(String(localized: "home_new_arrivals_title"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: XGSpacing.md) {
                    ForEach(HomeProduct.newArrivalSamples, id: \.id) { product in
                        XGProductCard(
                            imageUrl: nil,
                            title: product.title,
                            price: product.price,
                            vendorName: product.vendor,
                            action: {
                                router.navigate(to: .productDetail(productId: product.id))
                            }
                        )
                        .frame(width: Constants.newArrivalCardWidth)
                    }
                }
                .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(XGTypography.titleLarge)
            .foregroundStyle(XGColors.onSurface)
            .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
    }
}

// MARK: - Previews

#Preview("HomeScreen") {
    NavigationStack {
        HomeScreen()
    }
    .environment(AppRouter())
}
