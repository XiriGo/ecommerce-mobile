import SwiftUI

// MARK: - HomeScreen

/// Main home screen displaying featured content, categories, and product sections.
struct HomeScreen: View {
    // MARK: - Properties

    @Environment(AppRouter.self) private var router

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
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(XGSpacing.lg)
        }
        .frame(width: 280, height: 160)
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
                                .stroke(XGColors.outlineVariant.opacity(0.5), lineWidth: 1)
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
                        .frame(width: 180)
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

// MARK: - Sample Data Models

private struct HomeBanner: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]

    static let samples: [HomeBanner] = [
        HomeBanner(
            id: "1",
            title: String(localized: "home_banner_season_title"),
            subtitle: String(localized: "home_banner_season_subtitle"),
            gradientColors: [XGColors.primary, XGColors.tertiary]
        ),
        HomeBanner(
            id: "2",
            title: String(localized: "home_banner_new_title"),
            subtitle: String(localized: "home_banner_new_subtitle"),
            gradientColors: [XGColors.secondary, XGColors.primary]
        ),
        HomeBanner(
            id: "3",
            title: String(localized: "home_banner_deals_title"),
            subtitle: String(localized: "home_banner_deals_subtitle"),
            gradientColors: [XGColors.tertiary, XGColors.secondary]
        ),
    ]
}

private struct HomeCategory: Identifiable {
    let id: String
    let name: String
    let icon: String

    static let samples: [HomeCategory] = [
        HomeCategory(id: "cat_1", name: String(localized: "home_category_electronics"), icon: "desktopcomputer"),
        HomeCategory(id: "cat_2", name: String(localized: "home_category_fashion"), icon: "tshirt"),
        HomeCategory(id: "cat_3", name: String(localized: "home_category_home"), icon: "house"),
        HomeCategory(id: "cat_4", name: String(localized: "home_category_sports"), icon: "figure.run"),
        HomeCategory(id: "cat_5", name: String(localized: "home_category_books"), icon: "book"),
    ]
}

private struct HomeProduct: Identifiable {
    let id: String
    let title: String
    let price: String
    let originalPrice: String?
    let vendor: String
    let rating: Double?
    let reviewCount: Int?

    static let popularSamples: [HomeProduct] = [
        HomeProduct(
            id: "prod_1",
            title: String(localized: "home_product_headphones"),
            price: "$79.99",
            originalPrice: "$129.99",
            vendor: "TechZone",
            rating: 4.5,
            reviewCount: 234
        ),
        HomeProduct(
            id: "prod_2",
            title: String(localized: "home_product_sneakers"),
            price: "$59.99",
            originalPrice: nil,
            vendor: "SportStyle",
            rating: 4.2,
            reviewCount: 89
        ),
        HomeProduct(
            id: "prod_3",
            title: String(localized: "home_product_watch"),
            price: "$199.99",
            originalPrice: "$249.99",
            vendor: "LuxTime",
            rating: 4.8,
            reviewCount: 456
        ),
        HomeProduct(
            id: "prod_4",
            title: String(localized: "home_product_backpack"),
            price: "$39.99",
            originalPrice: nil,
            vendor: "TravelGear",
            rating: 4.0,
            reviewCount: 67
        ),
    ]

    static let newArrivalSamples: [HomeProduct] = [
        HomeProduct(
            id: "new_1",
            title: String(localized: "home_product_keyboard"),
            price: "$149.99",
            originalPrice: nil,
            vendor: "TechZone",
            rating: nil,
            reviewCount: nil
        ),
        HomeProduct(
            id: "new_2",
            title: String(localized: "home_product_jacket"),
            price: "$89.99",
            originalPrice: nil,
            vendor: "UrbanWear",
            rating: nil,
            reviewCount: nil
        ),
        HomeProduct(
            id: "new_3",
            title: String(localized: "home_product_lamp"),
            price: "$44.99",
            originalPrice: nil,
            vendor: "HomeDesign",
            rating: nil,
            reviewCount: nil
        ),
    ]
}

// MARK: - Previews

#Preview("HomeScreen") {
    NavigationStack {
        HomeScreen()
    }
    .environment(AppRouter())
}
