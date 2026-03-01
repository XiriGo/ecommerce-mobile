import Foundation

// MARK: - HomeSampleData

/// Centralized sample data for the Home feature fake repository.
/// Extracted to keep `FakeHomeRepository` methods short and focused.
enum HomeSampleData {
    // MARK: - Internal

    // MARK: - Banners

    static let banners: [HomeBanner] = [
        HomeBanner(
            id: "banner_1",
            title: String(localized: "home_banner_season_title"),
            subtitle: String(localized: "home_banner_season_subtitle"),
            imageUrl: nil,
            tag: "NEW SEASON",
            actionProductId: nil,
            actionCategoryId: "cat_2",
        ),
        HomeBanner(
            id: "banner_2",
            title: String(localized: "home_banner_new_title"),
            subtitle: String(localized: "home_banner_new_subtitle"),
            imageUrl: nil,
            tag: nil,
            actionProductId: nil,
            actionCategoryId: "cat_1",
        ),
        HomeBanner(
            id: "banner_3",
            title: String(localized: "home_banner_deals_title"),
            subtitle: String(localized: "home_banner_deals_subtitle"),
            imageUrl: nil,
            tag: "HOT DEALS",
            actionProductId: nil,
            actionCategoryId: nil,
        ),
    ]

    // MARK: - Categories

    static let categories: [HomeCategory] = [
        HomeCategory(
            id: "cat_1",
            name: String(localized: "home_category_electronics"),
            handle: "electronics",
            iconName: "desktopcomputer",
            colorHex: "#37B4F2",
        ),
        HomeCategory(
            id: "cat_2",
            name: String(localized: "home_category_fashion"),
            handle: "fashion",
            iconName: "tshirt",
            colorHex: "#FE75D4",
        ),
        HomeCategory(
            id: "cat_3",
            name: String(localized: "home_category_home"),
            handle: "home-garden",
            iconName: "house",
            colorHex: "#FDF29C",
        ),
        HomeCategory(
            id: "cat_4",
            name: String(localized: "home_category_sports"),
            handle: "sports",
            iconName: "figure.run",
            colorHex: "#90D3B1",
        ),
        HomeCategory(
            id: "cat_5",
            name: String(localized: "home_category_books"),
            handle: "books",
            iconName: "book",
            colorHex: "#FEF170",
        ),
        HomeCategory(
            id: "cat_6",
            name: String(localized: "home_category_gaming"),
            handle: "gaming",
            iconName: "gamecontroller",
            colorHex: "#37B4F2",
        ),
    ]

    // MARK: - Popular Products

    static let popularProducts: [HomeProduct] = [
        HomeProduct(
            id: "prod_1",
            title: String(localized: "home_product_headphones"),
            imageUrl: nil,
            price: "79.99",
            currencyCode: "eur",
            originalPrice: "129.99",
            vendor: "TechZone",
            rating: Rating.headphones,
            reviewCount: ReviewCount.headphones,
            isNew: false,
        ),
        HomeProduct(
            id: "prod_2",
            title: String(localized: "home_product_sneakers"),
            imageUrl: nil,
            price: "59.99",
            currencyCode: "eur",
            originalPrice: nil,
            vendor: "SportStyle",
            rating: Rating.sneakers,
            reviewCount: ReviewCount.sneakers,
            isNew: false,
        ),
        HomeProduct(
            id: "prod_3",
            title: String(localized: "home_product_watch"),
            imageUrl: nil,
            price: "199.99",
            currencyCode: "eur",
            originalPrice: "249.99",
            vendor: "LuxTime",
            rating: Rating.watch,
            reviewCount: ReviewCount.watch,
            isNew: false,
        ),
        HomeProduct(
            id: "prod_4",
            title: String(localized: "home_product_backpack"),
            imageUrl: nil,
            price: "39.99",
            currencyCode: "eur",
            originalPrice: nil,
            vendor: "TravelGear",
            rating: Rating.backpack,
            reviewCount: ReviewCount.backpack,
            isNew: false,
        ),
    ]

    // MARK: - New Arrivals

    static let newArrivals: [HomeProduct] = [
        HomeProduct(
            id: "new_1",
            title: String(localized: "home_product_keyboard"),
            imageUrl: nil,
            price: "149.99",
            currencyCode: "eur",
            originalPrice: nil,
            vendor: "TechZone",
            rating: nil,
            reviewCount: nil,
            isNew: true,
        ),
        HomeProduct(
            id: "new_2",
            title: String(localized: "home_product_jacket"),
            imageUrl: nil,
            price: "89.99",
            currencyCode: "eur",
            originalPrice: nil,
            vendor: "UrbanWear",
            rating: nil,
            reviewCount: nil,
            isNew: true,
        ),
        HomeProduct(
            id: "new_3",
            title: String(localized: "home_product_lamp"),
            imageUrl: nil,
            price: "44.99",
            currencyCode: "eur",
            originalPrice: nil,
            vendor: "HomeDesign",
            rating: nil,
            reviewCount: nil,
            isNew: true,
        ),
        HomeProduct(
            id: "new_4",
            title: "Bluetooth Speaker",
            imageUrl: nil,
            price: "34.99",
            currencyCode: "eur",
            originalPrice: "49.99",
            vendor: "SoundWave",
            rating: nil,
            reviewCount: nil,
            isNew: true,
        ),
        HomeProduct(
            id: "new_5",
            title: "Yoga Mat Premium",
            imageUrl: nil,
            price: "29.99",
            currencyCode: "eur",
            originalPrice: nil,
            vendor: "FitLife",
            rating: nil,
            reviewCount: nil,
            isNew: true,
        ),
        HomeProduct(
            id: "new_6",
            title: "Ceramic Vase Set",
            imageUrl: nil,
            price: "54.99",
            currencyCode: "eur",
            originalPrice: nil,
            vendor: "HomeDesign",
            rating: nil,
            reviewCount: nil,
            isNew: true,
        ),
    ]

    // MARK: - Flash Sale

    static let flashSale = FlashSale(
        id: "flash_1",
        title: String(localized: "home_flash_sale_title"),
        imageUrl: nil,
        actionUrl: nil,
    )

    // MARK: - Daily Deal

    static var dailyDeal: DailyDeal {
        DailyDeal(
            productId: "deal_1",
            title: "Nike Air Zoom Pegasus",
            imageUrl: nil,
            price: "89.99",
            originalPrice: "149.99",
            currencyCode: "eur",
            endTime: Date().addingTimeInterval(Timing.dealDurationSeconds),
        )
    }

    // MARK: - Private

    // MARK: - Private Constants

    private enum Rating {
        static let headphones: Double = 4.5
        static let sneakers: Double = 4.2
        static let watch: Double = 4.8
        static let backpack: Double = 4.0
    }

    private enum ReviewCount {
        static let headphones = 234
        static let sneakers = 89
        static let watch = 456
        static let backpack = 67
    }

    private enum Timing {
        static let dealDurationSeconds: TimeInterval = 28_800
    }
}
