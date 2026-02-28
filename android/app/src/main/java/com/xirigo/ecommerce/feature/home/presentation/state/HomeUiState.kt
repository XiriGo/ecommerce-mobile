package com.xirigo.ecommerce.feature.home.presentation.state

import androidx.compose.runtime.Stable
import com.xirigo.ecommerce.feature.home.domain.model.DailyDeal
import com.xirigo.ecommerce.feature.home.domain.model.FlashSale
import com.xirigo.ecommerce.feature.home.domain.model.HomeBanner
import com.xirigo.ecommerce.feature.home.domain.model.HomeCategory
import com.xirigo.ecommerce.feature.home.domain.model.HomeProduct

@Stable
sealed interface HomeUiState {
    data object Loading : HomeUiState
    data class Success(val data: HomeScreenData) : HomeUiState
    data class Error(val message: String) : HomeUiState
}

@Stable
data class HomeScreenData(
    val banners: List<HomeBanner>,
    val categories: List<HomeCategory>,
    val popularProducts: List<HomeProduct>,
    val dailyDeal: DailyDeal?,
    val newArrivals: List<HomeProduct>,
    val flashSale: FlashSale?,
    val wishedProductIds: Set<String>,
)
