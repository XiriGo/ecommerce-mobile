package com.xirigo.ecommerce.feature.home.presentation.component

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.core.designsystem.component.ProductCardSkeleton
import com.xirigo.ecommerce.core.designsystem.component.SkeletonBox
import com.xirigo.ecommerce.core.designsystem.component.SkeletonCircle
import com.xirigo.ecommerce.core.designsystem.component.SkeletonLine
import com.xirigo.ecommerce.core.designsystem.theme.XGCornerRadius
import com.xirigo.ecommerce.core.designsystem.theme.XGSpacing
import com.xirigo.ecommerce.core.designsystem.theme.XGTheme

// Skeleton dimension constants — derived from home-screen.json design tokens
private val SearchBarSkeletonHeight = 43.dp
private val HeroBannerSkeletonHeight = 210.dp
private val CategoryCircleSize = 56.dp
private val CategoryLabelWidth = 48.dp
private val CategoryLabelHeight = 10.dp
private val SectionHeaderLineWidth = 120.dp
private val SectionHeaderLineHeight = 18.dp
private val PopularSectionHeaderWidth = 140.dp
private val FeaturedCardWidth = 160.dp
private const val CATEGORY_PLACEHOLDER_COUNT = 5
private const val POPULAR_PRODUCT_PLACEHOLDER_COUNT = 3
private const val NEW_ARRIVAL_GRID_COLUMNS = 2
private const val NEW_ARRIVAL_GRID_ROWS = 2

/**
 * Full-screen skeleton placeholder that mirrors the HomeScreen layout.
 *
 * Displays shimmer placeholders for: search bar, hero banner, categories,
 * popular products, and new arrivals grid — matching the real HomeScreen
 * section order and spacing.
 *
 * Used during initial load and pull-to-refresh.
 */
@Composable
fun HomeScreenSkeleton(modifier: Modifier = Modifier) {
    val loadingDescription = stringResource(R.string.skeleton_loading_placeholder)

    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .semantics { contentDescription = loadingDescription }
            .padding(top = XGSpacing.Base, bottom = XGSpacing.SectionSpacing),
        verticalArrangement = Arrangement.spacedBy(XGSpacing.SectionSpacing),
    ) {
        SearchBarSkeleton()
        HeroBannerSkeleton()
        CategorySectionSkeleton()
        PopularProductsSectionSkeleton()
        NewArrivalsSectionSkeleton()
    }
}

// region Section Skeletons

@Composable
private fun SearchBarSkeleton() {
    SkeletonBox(
        width = 0.dp,
        height = SearchBarSkeletonHeight,
        cornerRadius = XGCornerRadius.Pill,
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
    )
}

@Composable
private fun HeroBannerSkeleton() {
    SkeletonBox(
        width = 0.dp,
        height = HeroBannerSkeletonHeight,
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
    )
}

@Composable
private fun CategorySectionSkeleton() {
    Column(verticalArrangement = Arrangement.spacedBy(XGSpacing.SM)) {
        // Section header skeleton
        SkeletonLine(
            width = SectionHeaderLineWidth,
            height = SectionHeaderLineHeight,
            modifier = Modifier.padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
        )

        // Horizontal category placeholders
        LazyRow(
            contentPadding = PaddingValues(horizontal = XGSpacing.ScreenPaddingHorizontal),
            horizontalArrangement = Arrangement.spacedBy(XGSpacing.Base),
        ) {
            items(CATEGORY_PLACEHOLDER_COUNT) {
                CategoryItemSkeleton()
            }
        }
    }
}

@Composable
private fun CategoryItemSkeleton() {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(XGSpacing.XS),
    ) {
        SkeletonCircle(size = CategoryCircleSize)
        SkeletonLine(width = CategoryLabelWidth, height = CategoryLabelHeight)
    }
}

@Composable
private fun PopularProductsSectionSkeleton() {
    Column(verticalArrangement = Arrangement.spacedBy(XGSpacing.SM)) {
        // Section header skeleton
        SkeletonLine(
            width = PopularSectionHeaderWidth,
            height = SectionHeaderLineHeight,
            modifier = Modifier.padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
        )

        // Horizontal product card skeletons
        LazyRow(
            contentPadding = PaddingValues(horizontal = XGSpacing.ScreenPaddingHorizontal),
            horizontalArrangement = Arrangement.spacedBy(XGSpacing.ProductGridSpacing),
        ) {
            items(POPULAR_PRODUCT_PLACEHOLDER_COUNT) {
                ProductCardSkeleton(modifier = Modifier.width(FeaturedCardWidth))
            }
        }
    }
}

@Composable
private fun NewArrivalsSectionSkeleton() {
    Column(verticalArrangement = Arrangement.spacedBy(XGSpacing.SM)) {
        // Section header skeleton
        SkeletonLine(
            width = SectionHeaderLineWidth,
            height = SectionHeaderLineHeight,
            modifier = Modifier.padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
        )

        // 2-column product grid skeleton
        Column(
            modifier = Modifier.padding(horizontal = XGSpacing.ScreenPaddingHorizontal),
            verticalArrangement = Arrangement.spacedBy(XGSpacing.ProductGridSpacing),
        ) {
            repeat(NEW_ARRIVAL_GRID_ROWS) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(XGSpacing.ProductGridSpacing),
                ) {
                    repeat(NEW_ARRIVAL_GRID_COLUMNS) {
                        ProductCardSkeleton(modifier = Modifier.weight(1f))
                    }
                }
            }
        }
    }
}

// endregion

// region Preview

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun HomeScreenSkeletonPreview() {
    XGTheme {
        HomeScreenSkeleton()
    }
}

// endregion
