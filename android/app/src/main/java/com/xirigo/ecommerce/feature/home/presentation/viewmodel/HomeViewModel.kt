package com.xirigo.ecommerce.feature.home.presentation.viewmodel

import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.IOException
import javax.inject.Inject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.xirigo.ecommerce.feature.home.domain.usecase.GetDailyDealUseCase
import com.xirigo.ecommerce.feature.home.domain.usecase.GetFlashSaleUseCase
import com.xirigo.ecommerce.feature.home.domain.usecase.GetHomeBannersUseCase
import com.xirigo.ecommerce.feature.home.domain.usecase.GetHomeCategoriesUseCase
import com.xirigo.ecommerce.feature.home.domain.usecase.GetNewArrivalsUseCase
import com.xirigo.ecommerce.feature.home.domain.usecase.GetPopularProductsUseCase
import com.xirigo.ecommerce.feature.home.presentation.state.HomeEvent
import com.xirigo.ecommerce.feature.home.presentation.state.HomeScreenData
import com.xirigo.ecommerce.feature.home.presentation.state.HomeUiState

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val getBanners: GetHomeBannersUseCase,
    private val getCategories: GetHomeCategoriesUseCase,
    private val getPopularProducts: GetPopularProductsUseCase,
    private val getDailyDeal: GetDailyDealUseCase,
    private val getNewArrivals: GetNewArrivalsUseCase,
    private val getFlashSale: GetFlashSaleUseCase,
) : ViewModel() {

    private val _uiState = MutableStateFlow<HomeUiState>(HomeUiState.Loading)
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

    init {
        loadHomeData()
    }

    fun onEvent(event: HomeEvent) {
        when (event) {
            is HomeEvent.Refresh -> refresh()
            is HomeEvent.WishlistToggled -> toggleWishlist(event.productId)
            is HomeEvent.RetryTapped -> loadHomeData()
            is HomeEvent.BannerTapped,
            is HomeEvent.CategoryTapped,
            is HomeEvent.ProductTapped,
            is HomeEvent.DailyDealTapped,
            is HomeEvent.SeeAllPopularTapped,
            is HomeEvent.SeeAllNewArrivalsTapped,
            is HomeEvent.SearchBarTapped,
            -> Unit
        }
    }

    private fun loadHomeData() {
        viewModelScope.launch {
            _uiState.value = HomeUiState.Loading
            try {
                val data = coroutineScope {
                    val bannersDeferred = async { getBanners() }
                    val categoriesDeferred = async { getCategories() }
                    val popularDeferred = async { getPopularProducts() }
                    val dealDeferred = async { getDailyDeal() }
                    val arrivalsDeferred = async { getNewArrivals() }
                    val flashDeferred = async { getFlashSale() }

                    HomeScreenData(
                        banners = bannersDeferred.await(),
                        categories = categoriesDeferred.await(),
                        popularProducts = popularDeferred.await(),
                        dailyDeal = dealDeferred.await(),
                        newArrivals = arrivalsDeferred.await(),
                        flashSale = flashDeferred.await(),
                        wishedProductIds = emptySet(),
                    )
                }
                _uiState.value = HomeUiState.Success(data = data)
            } catch (e: IOException) {
                _uiState.value = HomeUiState.Error(
                    message = e.message ?: "A network error occurred",
                )
            }
        }
    }

    private fun refresh() {
        viewModelScope.launch {
            _isRefreshing.value = true
            try {
                val currentWished = (_uiState.value as? HomeUiState.Success)
                    ?.data
                    ?.wishedProductIds
                    ?: emptySet()

                val data = coroutineScope {
                    val bannersDeferred = async { getBanners() }
                    val categoriesDeferred = async { getCategories() }
                    val popularDeferred = async { getPopularProducts() }
                    val dealDeferred = async { getDailyDeal() }
                    val arrivalsDeferred = async { getNewArrivals() }
                    val flashDeferred = async { getFlashSale() }

                    HomeScreenData(
                        banners = bannersDeferred.await(),
                        categories = categoriesDeferred.await(),
                        popularProducts = popularDeferred.await(),
                        dailyDeal = dealDeferred.await(),
                        newArrivals = arrivalsDeferred.await(),
                        flashSale = flashDeferred.await(),
                        wishedProductIds = currentWished,
                    )
                }
                _uiState.value = HomeUiState.Success(data = data)
            } catch (e: IOException) {
                _uiState.value = HomeUiState.Error(
                    message = e.message ?: "A network error occurred",
                )
            } finally {
                _isRefreshing.value = false
            }
        }
    }

    private fun toggleWishlist(productId: String) {
        val current = (_uiState.value as? HomeUiState.Success)?.data ?: return
        val updatedIds = if (productId in current.wishedProductIds) {
            current.wishedProductIds - productId
        } else {
            current.wishedProductIds + productId
        }
        _uiState.value = HomeUiState.Success(
            data = current.copy(wishedProductIds = updatedIds),
        )
    }
}
