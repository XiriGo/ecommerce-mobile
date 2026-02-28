import SwiftUI

// MARK: - HomeScreen

/// Main home screen displaying featured content, categories, and product sections.
struct HomeScreen: View {
    // MARK: - Properties

    @Environment(AppRouter.self) private var router

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: MoltSpacing.sectionSpacing) {
                welcomeHeader
                searchBar
                featuredBanners
                categoriesSection
                popularProductsSection
                newArrivalsSection
            }
            .padding(.bottom, MoltSpacing.xl)
        }
        .background(MoltColors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "nav_tab_home"))
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: MoltSpacing.xs) {
            Text(String(localized: "home_welcome_title"))
                .font(MoltTypography.headlineMedium)
                .foregroundStyle(MoltColors.onSurface)

            Text(String(localized: "home_welcome_subtitle"))
                .font(MoltTypography.bodyLarge)
                .foregroundStyle(MoltColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
        .padding(.top, MoltSpacing.sm)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        Button {
            router.navigate(to: .productSearch)
        } label: {
            HStack(spacing: MoltSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(MoltColors.onSurfaceVariant)
                    .font(.system(size: MoltSpacing.IconSize.medium))

                Text(String(localized: "home_search_placeholder"))
                    .font(MoltTypography.bodyLarge)
                    .foregroundStyle(MoltColors.onSurfaceVariant)

                Spacer()
            }
            .padding(.horizontal, MoltSpacing.md)
            .padding(.vertical, MoltSpacing.md)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.full))
            .overlay(
                RoundedRectangle(cornerRadius: MoltCornerRadius.full)
                    .stroke(MoltColors.outlineVariant, lineWidth: 1)
            )
        }
        .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
        .accessibilityLabel(String(localized: "home_search_placeholder"))
    }

    // MARK: - Featured Banners

    private var featuredBanners: some View {
        VStack(alignment: .leading, spacing: MoltSpacing.md) {
            sectionHeader(String(localized: "home_featured_title"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MoltSpacing.md) {
                    ForEach(HomeBanner.samples, id: \.id) { banner in
                        featuredBannerCard(banner)
                    }
                }
                .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
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

            VStack(alignment: .leading, spacing: MoltSpacing.xs) {
                Text(banner.title)
                    .font(MoltTypography.headlineSmall)
                    .foregroundStyle(.white)

                Text(banner.subtitle)
                    .font(MoltTypography.bodyMedium)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(MoltSpacing.lg)
        }
        .frame(width: 280, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.large))
        .moltElevation(MoltElevation.level2)
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: MoltSpacing.md) {
            sectionHeader(String(localized: "home_categories_title"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MoltSpacing.base) {
                    ForEach(HomeCategory.samples, id: \.id) { category in
                        categoryItem(category)
                    }
                }
                .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
            }
        }
    }

    private func categoryItem(_ category: HomeCategory) -> some View {
        Button {
            router.navigate(to: .categoryProducts(categoryId: category.id, categoryName: category.name))
        } label: {
            VStack(spacing: MoltSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: MoltSpacing.AvatarSize.extraLarge, height: MoltSpacing.AvatarSize.extraLarge)
                        .overlay(
                            Circle()
                                .stroke(MoltColors.outlineVariant.opacity(0.5), lineWidth: 1)
                        )

                    Image(systemName: category.icon)
                        .font(.system(size: MoltSpacing.IconSize.large))
                        .foregroundStyle(MoltColors.primary)
                }

                Text(category.name)
                    .font(MoltTypography.labelMedium)
                    .foregroundStyle(MoltColors.onSurface)
                    .lineLimit(1)
            }
            .frame(width: MoltSpacing.AvatarSize.extraLarge)
        }
        .accessibilityLabel(category.name)
    }

    // MARK: - Popular Products Section

    private var popularProductsSection: some View {
        VStack(alignment: .leading, spacing: MoltSpacing.md) {
            sectionHeader(String(localized: "home_popular_title"))

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: MoltSpacing.productGridSpacing),
                    GridItem(.flexible(), spacing: MoltSpacing.productGridSpacing),
                ],
                spacing: MoltSpacing.productGridSpacing
            ) {
                ForEach(HomeProduct.popularSamples, id: \.id) { product in
                    MoltProductCard(
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
            .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
        }
    }

    // MARK: - New Arrivals Section

    private var newArrivalsSection: some View {
        VStack(alignment: .leading, spacing: MoltSpacing.md) {
            sectionHeader(String(localized: "home_new_arrivals_title"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MoltSpacing.md) {
                    ForEach(HomeProduct.newArrivalSamples, id: \.id) { product in
                        MoltProductCard(
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
                .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(MoltTypography.titleLarge)
            .foregroundStyle(MoltColors.onSurface)
            .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
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
            gradientColors: [MoltColors.primary, MoltColors.tertiary]
        ),
        HomeBanner(
            id: "2",
            title: String(localized: "home_banner_new_title"),
            subtitle: String(localized: "home_banner_new_subtitle"),
            gradientColors: [MoltColors.secondary, MoltColors.primary]
        ),
        HomeBanner(
            id: "3",
            title: String(localized: "home_banner_deals_title"),
            subtitle: String(localized: "home_banner_deals_subtitle"),
            gradientColors: [MoltColors.tertiary, MoltColors.secondary]
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
