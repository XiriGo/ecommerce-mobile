import SwiftUI

// MARK: - CategoriesScreen

/// Grid-based category browsing screen with search functionality.
struct CategoriesScreen: View {
    // MARK: - Properties

    @Environment(AppRouter.self) private var router
    @State private var searchText = ""

    private let categories = CategoryItem.samples

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: MoltSpacing.sectionSpacing) {
                searchSection
                categoryGrid
            }
            .padding(.bottom, MoltSpacing.xl)
        }
        .background(MoltColors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "nav_tab_categories"))
    }

    // MARK: - Search Section

    private var searchSection: some View {
        HStack(spacing: MoltSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(MoltColors.onSurfaceVariant)
                .font(.system(size: MoltSpacing.IconSize.medium))

            TextField(
                String(localized: "categories_search_placeholder"),
                text: $searchText
            )
            .font(MoltTypography.bodyLarge)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(MoltColors.onSurfaceVariant)
                }
                .accessibilityLabel(String(localized: "common_cancel_button"))
            }
        }
        .padding(.horizontal, MoltSpacing.md)
        .padding(.vertical, MoltSpacing.md)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.full))
        .overlay(
            RoundedRectangle(cornerRadius: MoltCornerRadius.full)
                .stroke(MoltColors.outlineVariant, lineWidth: 1)
        )
        .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
        .padding(.top, MoltSpacing.sm)
    }

    // MARK: - Category Grid

    private var categoryGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: MoltSpacing.md),
                GridItem(.flexible(), spacing: MoltSpacing.md),
            ],
            spacing: MoltSpacing.md
        ) {
            ForEach(filteredCategories, id: \.id) { category in
                categoryCard(category)
            }
        }
        .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
    }

    private func categoryCard(_ category: CategoryItem) -> some View {
        Button {
            router.navigate(to: .categoryProducts(categoryId: category.id, categoryName: category.name))
        } label: {
            VStack(spacing: MoltSpacing.md) {
                Image(systemName: category.icon)
                    .font(.system(size: MoltSpacing.IconSize.extraLarge))
                    .foregroundStyle(MoltColors.primary)
                    .accessibilityHidden(true)

                VStack(spacing: MoltSpacing.xxs) {
                    Text(category.name)
                        .font(MoltTypography.titleMedium)
                        .foregroundStyle(MoltColors.onSurface)

                    Text(String(localized: "categories_item_count \(category.itemCount)"))
                        .font(MoltTypography.bodySmall)
                        .foregroundStyle(MoltColors.onSurfaceVariant)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, MoltSpacing.lg)
            .padding(.horizontal, MoltSpacing.md)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: MoltCornerRadius.large)
                    .stroke(MoltColors.outlineVariant.opacity(0.5), lineWidth: 1)
            )
            .moltElevation(MoltElevation.level1)
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

    static let samples: [CategoryItem] = [
        CategoryItem(id: "cat_1", name: String(localized: "home_category_electronics"), icon: "desktopcomputer", itemCount: 245),
        CategoryItem(id: "cat_2", name: String(localized: "home_category_fashion"), icon: "tshirt", itemCount: 532),
        CategoryItem(id: "cat_3", name: String(localized: "home_category_home"), icon: "house", itemCount: 189),
        CategoryItem(id: "cat_4", name: String(localized: "home_category_sports"), icon: "figure.run", itemCount: 147),
        CategoryItem(id: "cat_5", name: String(localized: "home_category_books"), icon: "book", itemCount: 412),
        CategoryItem(id: "cat_6", name: String(localized: "categories_beauty"), icon: "sparkles", itemCount: 298),
        CategoryItem(id: "cat_7", name: String(localized: "categories_toys"), icon: "gamecontroller", itemCount: 176),
        CategoryItem(id: "cat_8", name: String(localized: "categories_automotive"), icon: "car", itemCount: 93),
    ]
}

// MARK: - Previews

#Preview("CategoriesScreen") {
    NavigationStack {
        CategoriesScreen()
    }
    .environment(AppRouter())
}
