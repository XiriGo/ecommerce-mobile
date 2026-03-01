package com.xirigo.ecommerce.feature.home.presentation.viewmodel

import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.serialization.SerializationException
import timber.log.Timber
import java.io.IOException
import javax.inject.Inject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.xirigo.ecommerce.R
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
                val data = fetchHomeData(wishedProductIds = emptySet())
                _uiState.value = HomeUiState.Success(data = data)
            } catch (e: IOException) {
                Timber.e(e, "Network error loading home data")
                _uiState.value = HomeUiState.Error(messageResId = R.string.common_error_network)
            } catch (e: retrofit2.HttpException) {
                Timber.e(e, "Server error loading home data")
                _uiState.value = HomeUiState.Error(messageResId = R.string.common_error_server)
            } catch (e: SerializationException) {
                Timber.e(e, "Serialization error loading home data")
                _uiState.value = HomeUiState.Error(messageResId = R.string.common_error_server)
            }
        }
    }

    private fun refresh() {
        val currentState = _uiState.value as? HomeUiState.Success ?: return
        viewModelScope.launch {
            _uiState.value = currentState.copy(isRefreshing = true)
            try {
                val data = fetchHomeData(
                    wishedProductIds = currentState.data.wishedProductIds,
                )
                _uiState.value = HomeUiState.Success(data = data)
            } catch (e: IOException) {
                Timber.e(e, "Network error refreshing home data")
                _uiState.value = currentState.copy(isRefreshing = false)
            } catch (e: retrofit2.HttpException) {
                Timber.e(e, "Server error refreshing home data")
                _uiState.value = currentState.copy(isRefreshing = false)
            } catch (e: SerializationException) {
                Timber.e(e, "Serialization error refreshing home data")
                _uiState.value = currentState.copy(isRefreshing = false)
            }
        }
    }

    private suspend fun fetchHomeData(wishedProductIds: Set<String>): HomeScreenData = coroutineScope {
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
            wishedProductIds = wishedProductIds,
        )
    }

    private fun toggleWishlist(productId: String) {
        val current = _uiState.value as? HomeUiState.Success ?: return
        val updatedIds = if (productId in current.data.wishedProductIds) {
            current.data.wishedProductIds - productId
        } else {
            current.data.wishedProductIds + productId
        }
        _uiState.value = current.copy(
            data = current.data.copy(wishedProductIds = updatedIds),
        )
    }
}
