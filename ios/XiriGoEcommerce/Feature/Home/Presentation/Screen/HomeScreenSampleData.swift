import SwiftUI

// MARK: - Home Sample Data Models

// Sample data models for HomeScreen placeholder content.
// These will be replaced by real API data when the Home feature is implemented.

// MARK: - HomeBanner

struct HomeBanner: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]

    static let samples: [Self] = [
        Self(
            id: "1",
            title: String(localized: "home_banner_season_title"),
            subtitle: String(localized: "home_banner_season_subtitle"),
            gradientColors: [XGColors.primary, XGColors.tertiary]
        ),
        Self(
            id: "2",
            title: String(localized: "home_banner_new_title"),
            subtitle: String(localized: "home_banner_new_subtitle"),
            gradientColors: [XGColors.secondary, XGColors.primary]
        ),
        Self(
            id: "3",
            title: String(localized: "home_banner_deals_title"),
            subtitle: String(localized: "home_banner_deals_subtitle"),
            gradientColors: [XGColors.tertiary, XGColors.secondary]
        ),
    ]
}

// MARK: - HomeCategory

struct HomeCategory: Identifiable {
    let id: String
    let name: String
    let icon: String

    static let samples: [Self] = [
        Self(id: "cat_1", name: String(localized: "home_category_electronics"), icon: "desktopcomputer"),
        Self(id: "cat_2", name: String(localized: "home_category_fashion"), icon: "tshirt"),
        Self(id: "cat_3", name: String(localized: "home_category_home"), icon: "house"),
        Self(id: "cat_4", name: String(localized: "home_category_sports"), icon: "figure.run"),
        Self(id: "cat_5", name: String(localized: "home_category_books"), icon: "book"),
    ]
}

// MARK: - HomeProduct

struct HomeProduct: Identifiable {
    let id: String
    let title: String
    let price: String
    let originalPrice: String?
    let vendor: String
    let rating: Double?
    let reviewCount: Int?

    private enum SampleRating {
        static let headphones: Double = 4.5
        static let sneakers: Double = 4.2
        static let watch: Double = 4.8
        static let backpack: Double = 4.0
    }

    private enum SampleReviewCount {
        static let headphones = 234
        static let sneakers = 89
        static let watch = 456
        static let backpack = 67
    }

    static let popularSamples: [Self] = [
        Self(
            id: "prod_1",
            title: String(localized: "home_product_headphones"),
            price: "$79.99",
            originalPrice: "$129.99",
            vendor: "TechZone",
            rating: SampleRating.headphones,
            reviewCount: SampleReviewCount.headphones
        ),
        Self(
            id: "prod_2",
            title: String(localized: "home_product_sneakers"),
            price: "$59.99",
            originalPrice: nil,
            vendor: "SportStyle",
            rating: SampleRating.sneakers,
            reviewCount: SampleReviewCount.sneakers
        ),
        Self(
            id: "prod_3",
            title: String(localized: "home_product_watch"),
            price: "$199.99",
            originalPrice: "$249.99",
            vendor: "LuxTime",
            rating: SampleRating.watch,
            reviewCount: SampleReviewCount.watch
        ),
        Self(
            id: "prod_4",
            title: String(localized: "home_product_backpack"),
            price: "$39.99",
            originalPrice: nil,
            vendor: "TravelGear",
            rating: SampleRating.backpack,
            reviewCount: SampleReviewCount.backpack
        ),
    ]

    static let newArrivalSamples: [Self] = [
        Self(
            id: "new_1",
            title: String(localized: "home_product_keyboard"),
            price: "$149.99",
            originalPrice: nil,
            vendor: "TechZone",
            rating: nil,
            reviewCount: nil
        ),
        Self(
            id: "new_2",
            title: String(localized: "home_product_jacket"),
            price: "$89.99",
            originalPrice: nil,
            vendor: "UrbanWear",
            rating: nil,
            reviewCount: nil
        ),
        Self(
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
