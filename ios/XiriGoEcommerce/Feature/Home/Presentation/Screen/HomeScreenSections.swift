import Combine
import SwiftUI

// MARK: - HomeScreen + Sections

/// Extracted section views for HomeScreen to keep individual files under 300 lines.
extension HomeScreen {
    // MARK: - Internal

    enum BannerConstants {
        static let carouselHeight: CGFloat = 210
        static let autoScrollInterval: TimeInterval = 5
    }

    // MARK: - Banner Auto-Scroll

    var bannerTimer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: BannerConstants.autoScrollInterval, on: .main, in: .common).autoconnect()
    }

    // MARK: - Search Bar

    var searchBar: some View {
        XGSearchBar(
            placeholder: String(localized: "home_search_placeholder"),
            action: { router.navigate(to: .productSearch) },
        )
        .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
    }

    // MARK: - Hero Banner Carousel

    func heroBannerCarousel(_ banners: [HomeBanner]) -> some View {
        VStack(spacing: XGSpacing.md) {
            if !banners.isEmpty {
                TabView(selection: $viewModel.currentBannerPage) {
                    ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                        XGHeroBanner(
                            title: banner.title,
                            subtitle: banner.subtitle,
                            imageUrl: banner.imageUrl.flatMap { URL(string: $0) },
                            tag: banner.tag,
                            action: { handleBannerTap(banner) },
                        )
                        .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
                        .tag(index)
                    }
                }
                .frame(height: BannerConstants.carouselHeight)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onReceive(bannerTimer) { _ in
                    advanceBannerPage(totalBanners: banners.count)
                }

                XGPaginationDots(
                    totalPages: banners.count,
                    currentPage: viewModel.currentBannerPage,
                )
            }
        }
    }

    // MARK: - Categories Section

    func categoriesSection(_ categories: [HomeCategory]) -> some View {
        VStack(alignment: .leading, spacing: XGSpacing.md) {
            XGSectionHeader(title: String(localized: "home_categories_title"))

            if !categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: XGSpacing.base) {
                        ForEach(categories) { category in
                            XGCategoryIcon(
                                name: category.name,
                                systemIconName: category.iconName,
                                backgroundColor: Color(hex: category.colorHex),
                                action: {
                                    router.navigate(
                                        to: .categoryProducts(
                                            categoryId: category.id,
                                            categoryName: category.name,
                                        ),
                                    )
                                },
                            )
                        }
                    }
                    .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
                }
            }
        }
    }

    // MARK: - Popular Products Section

    func popularProductsSection(_ data: HomeScreenData) -> some View {
        VStack(alignment: .leading, spacing: XGSpacing.md) {
            if !data.popularProducts.isEmpty {
                XGSectionHeader(
                    title: String(localized: "home_popular_title"),
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: XGSpacing.productGridSpacing) {
                        ForEach(data.popularProducts) { product in
                            popularProductCard(product: product, data: data)
                                .frame(width: PopularProductConstants.cardWidth)
                        }
                    }
                    .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
                }
            }
        }
    }

    // MARK: - Daily Deal Section

    func dailyDealSection(_ dailyDeal: DailyDeal?) -> some View {
        Group {
            if let deal = dailyDeal {
                VStack(spacing: XGSpacing.md) {
                    XGSectionHeader(
                        title: String(localized: "home_daily_deal_title"),
                    )

                    XGDailyDealCard(
                        title: deal.title,
                        price: deal.price,
                        originalPrice: deal.originalPrice,
                        endTime: deal.endTime,
                        imageUrl: deal.imageUrl.flatMap { URL(string: $0) },
                        action: {
                            router.navigate(to: .productDetail(productId: deal.productId))
                        },
                    )
                    .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
                }
            }
        }
    }

    // MARK: - New Arrivals Section

    func newArrivalsSection(_ data: HomeScreenData) -> some View {
        VStack(alignment: .leading, spacing: XGSpacing.md) {
            if !data.newArrivals.isEmpty {
                XGSectionHeader(
                    title: String(localized: "home_new_arrivals_title"),
                    onSeeAllAction: {
                        router.navigate(
                            to: .productList(categoryId: nil, query: "new"),
                        )
                    },
                )

                newArrivalsGrid(data: data)
                    .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
            }
        }
    }

    // MARK: - Flash Sale Section

    func flashSaleSection(_ flashSale: FlashSale?) -> some View {
        Group {
            if let sale = flashSale {
                XGFlashSaleBanner(
                    title: sale.title,
                    imageUrl: sale.imageUrl.flatMap { URL(string: $0) },
                    action: {},
                )
                .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
            }
        }
    }

    func advanceBannerPage(totalBanners: Int) {
        guard totalBanners > 0 else {
            return
        }
        withAnimation {
            viewModel.currentBannerPage = (viewModel.currentBannerPage + 1) % totalBanners
        }
    }

    func handleBannerTap(_ banner: HomeBanner) {
        if let productId = banner.actionProductId {
            router.navigate(to: .productDetail(productId: productId))
        } else if let categoryId = banner.actionCategoryId {
            router.navigate(
                to: .categoryProducts(categoryId: categoryId, categoryName: banner.title),
            )
        }
    }

    // MARK: - Private

    private enum PopularProductConstants {
        static let cardWidth: CGFloat = 160
    }

    private enum NewArrivalConstants {
        static let strikethroughFontSize: CGFloat = 14
    }

    private func popularProductCard(
        product: HomeProduct,
        data: HomeScreenData,
    ) -> some View {
        XGProductCard(
            imageUrl: product.imageUrl.flatMap { URL(string: $0) },
            title: product.title,
            price: product.price,
            originalPrice: product.originalPrice,
            rating: product.rating,
            reviewCount: product.reviewCount,
            isWishlisted: data.wishedProductIds.contains(product.id),
            onWishlistToggle: {
                viewModel.onEvent(.wishlistToggled(productId: product.id))
            },
            priceLayout: .stacked,
            showRatingAbovePrice: true,
            action: {
                router.navigate(to: .productDetail(productId: product.id))
            },
        )
    }

    private func newArrivalsGrid(data: HomeScreenData) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: XGSpacing.productGridSpacing),
                GridItem(.flexible(), spacing: XGSpacing.productGridSpacing),
            ],
            spacing: XGSpacing.productGridSpacing,
        ) {
            ForEach(data.newArrivals) { product in
                newArrivalCard(product: product, data: data)
            }
        }
    }

    private func newArrivalCard(
        product: HomeProduct,
        data: HomeScreenData,
    ) -> some View {
        XGProductCard(
            imageUrl: product.imageUrl.flatMap { URL(string: $0) },
            title: product.title,
            price: product.price,
            originalPrice: product.originalPrice,
            rating: product.rating,
            reviewCount: product.reviewCount,
            isWishlisted: data.wishedProductIds.contains(product.id),
            onWishlistToggle: {
                viewModel.onEvent(.wishlistToggled(productId: product.id))
            },
            deliveryLabel: product.isNew
                ? String(localized: "home_delivery_badge_sample")
                : nil,
            deliveryBoldRange: product.isNew
                ? String(localized: "home_delivery_badge_bold_part")
                : nil,
            priceStyle: .standard,
            strikethroughFontSize: NewArrivalConstants.strikethroughFontSize,
            priceLayout: .stacked,
            showRatingAbovePrice: true,
            showDeliveryAbovePrice: true,
            onAddToCartAction: {},
            action: {
                router.navigate(to: .productDetail(productId: product.id))
            },
        )
    }
}
