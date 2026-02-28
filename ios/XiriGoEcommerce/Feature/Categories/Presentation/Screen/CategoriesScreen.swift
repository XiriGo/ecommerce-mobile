import SwiftUI

// MARK: - CategoriesScreen

/// Grid-based category browsing screen with search functionality.
struct CategoriesScreen: View {
    // MARK: - Constants

    private enum Constants {
        static let cardBorderOpacity: Double = 0.5
    }

    // MARK: - Properties

    @Environment(AppRouter.self)
    private var router
    @State private var searchText = ""

    private let categories = CategoryItem.samples

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: XGSpacing.sectionSpacing) {
                searchSection
                categoryGrid
            }
            .padding(.bottom, XGSpacing.xl)
        }
        .background(XGColors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "nav_tab_categories"))
    }

    // MARK: - Search Section

    private var searchSection: some View {
        HStack(spacing: XGSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(XGColors.onSurfaceVariant)
                .font(.system(size: XGSpacing.IconSize.medium))
                .accessibilityHidden(true)

            TextField(
                String(localized: "categories_search_placeholder"),
                text: $searchText
            )
            .font(XGTypography.bodyLarge)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(XGColors.onSurfaceVariant)
                }
                .accessibilityLabel(String(localized: "common_cancel_button"))
            }
        }
        .padding(.horizontal, XGSpacing.md)
        .padding(.vertical, XGSpacing.md)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.full))
        .overlay(
            RoundedRectangle(cornerRadius: XGCornerRadius.full)
                .stroke(XGColors.outlineVariant, lineWidth: 1)
        )
        .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
        .padding(.top, XGSpacing.sm)
    }

    // MARK: - Category Grid

    private var categoryGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: XGSpacing.md),
                GridItem(.flexible(), spacing: XGSpacing.md),
            ],
            spacing: XGSpacing.md
        ) {
            ForEach(filteredCategories, id: \.id) { category in
                categoryCard(category)
            }
        }
        .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
    }

    private func categoryCard(_ category: CategoryItem) -> some View {
        Button {
            router.navigate(to: .categoryProducts(categoryId: category.id, categoryName: category.name))
        } label: {
            VStack(spacing: XGSpacing.md) {
                Image(systemName: category.icon)
                    .font(.system(size: XGSpacing.IconSize.extraLarge))
                    .foregroundStyle(XGColors.primary)
                    .accessibilityHidden(true)

                VStack(spacing: XGSpacing.xxs) {
                    Text(category.name)
                        .font(XGTypography.titleMedium)
                        .foregroundStyle(XGColors.onSurface)

                    Text(String(localized: "categories_item_count \(category.itemCount)"))
                        .font(XGTypography.bodySmall)
                        .foregroundStyle(XGColors.onSurfaceVariant)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, XGSpacing.lg)
            .padding(.horizontal, XGSpacing.md)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: XGCornerRadius.large)
                    .stroke(XGColors.outlineVariant.opacity(Constants.cardBorderOpacity), lineWidth: 1)
            )
            .xgElevation(XGElevation.level1)
        }
        .accessibilityLabel(category.name)
        .accessibilityHint(String(localized: "categories_item_count \(category.itemCount)"))
    }

    // MARK: - Filtering

    private var filteredCategories: [CategoryItem] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - Sample Data

private struct CategoryItem: Identifiable {
    let id: String
    let name: String
    let icon: String
    let itemCount: Int

    private enum SampleCount {
        static let electronics = 245
        static let fashion = 532
        static let home = 189
        static let sports = 147
        static let books = 412
        static let beauty = 298
        static let toys = 176
        static let automotive = 93
    }

    static let samples: [Self] = [
        Self(
            id: "cat_1",
            name: String(localized: "home_category_electronics"),
            icon: "desktopcomputer",
            itemCount: SampleCount.electronics
        ),
        Self(
            id: "cat_2",
            name: String(localized: "home_category_fashion"),
            icon: "tshirt",
            itemCount: SampleCount.fashion
        ),
        Self(
            id: "cat_3",
            name: String(localized: "home_category_home"),
            icon: "house",
            itemCount: SampleCount.home
        ),
        Self(
            id: "cat_4",
            name: String(localized: "home_category_sports"),
            icon: "figure.run",
            itemCount: SampleCount.sports
        ),
        Self(
            id: "cat_5",
            name: String(localized: "home_category_books"),
            icon: "book",
            itemCount: SampleCount.books
        ),
        Self(
            id: "cat_6",
            name: String(localized: "categories_beauty"),
            icon: "sparkles",
            itemCount: SampleCount.beauty
        ),
        Self(
            id: "cat_7",
            name: String(localized: "categories_toys"),
            icon: "gamecontroller",
            itemCount: SampleCount.toys
        ),
        Self(
            id: "cat_8",
            name: String(localized: "categories_automotive"),
            icon: "car",
            itemCount: SampleCount.automotive
        ),
    ]
}

// MARK: - Previews

#Preview("CategoriesScreen") {
    NavigationStack {
        CategoriesScreen()
    }
    .environment(AppRouter())
}
