package com.xirigo.ecommerce.feature.home.viewmodel

import app.cash.turbine.test
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import java.io.IOException
import com.xirigo.ecommerce.R
import com.xirigo.ecommerce.feature.home.domain.model.FlashSale
import com.xirigo.ecommerce.feature.home.domain.usecase.GetDailyDealUseCase
import com.xirigo.ecommerce.feature.home.domain.usecase.GetFlashSaleUseCase
import com.xirigo.ecommerce.feature.home.domain.usecase.GetHomeBannersUseCase
import com.xirigo.ecommerce.feature.home.domain.usecase.GetHomeCategoriesUseCase
import com.xirigo.ecommerce.feature.home.domain.usecase.GetNewArrivalsUseCase
import com.xirigo.ecommerce.feature.home.domain.usecase.GetPopularProductsUseCase
import com.xirigo.ecommerce.feature.home.presentation.state.HomeEvent
import com.xirigo.ecommerce.feature.home.presentation.state.HomeUiState
import com.xirigo.ecommerce.feature.home.presentation.viewmodel.HomeViewModel
import com.xirigo.ecommerce.feature.home.repository.FakeHomeRepository

@OptIn(ExperimentalCoroutinesApi::class)
class HomeViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private lateinit var fakeRepository: FakeHomeRepository
    private lateinit var getBanners: GetHomeBannersUseCase
    private lateinit var getCategories: GetHomeCategoriesUseCase
    private lateinit var getPopularProducts: GetPopularProductsUseCase
    private lateinit var getDailyDeal: GetDailyDealUseCase
    private lateinit var getNewArrivals: GetNewArrivalsUseCase
    private lateinit var getFlashSale: GetFlashSaleUseCase

    @Before
    fun setUp() {
        fakeRepository = FakeHomeRepository()
        getBanners = GetHomeBannersUseCase(fakeRepository)
        getCategories = GetHomeCategoriesUseCase(fakeRepository)
        getPopularProducts = GetPopularProductsUseCase(fakeRepository)
        getDailyDeal = GetDailyDealUseCase(fakeRepository)
        getNewArrivals = GetNewArrivalsUseCase(fakeRepository)
        getFlashSale = GetFlashSaleUseCase(fakeRepository)
    }

    private fun createViewModel(): HomeViewModel = HomeViewModel(
        getBanners = getBanners,
        getCategories = getCategories,
        getPopularProducts = getPopularProducts,
        getDailyDeal = getDailyDeal,
        getNewArrivals = getNewArrivals,
        getFlashSale = getFlashSale,
    )

    // region initial state

    @Test
    fun `uiState initial value is Loading`() {
        val viewModel = createViewModel()

        assertThat(viewModel.uiState.value).isEqualTo(HomeUiState.Loading)
    }

    @Test
    fun `Success state has isRefreshing false by default`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success
        assertThat(state.isRefreshing).isFalse()
    }

    // endregion

    // region load home data — success

    @Test
    fun `uiState transitions to Success after init completes`() = runTest {
        val viewModel = createViewModel()

        advanceUntilIdle()

        assertThat(viewModel.uiState.value).isInstanceOf(HomeUiState.Success::class.java)
    }

    @Test
    fun `uiState emits Loading then Success on initial load`() = runTest {
        val viewModel = createViewModel()

        viewModel.uiState.test {
            assertThat(awaitItem()).isEqualTo(HomeUiState.Loading)
            advanceUntilIdle()
            assertThat(awaitItem()).isInstanceOf(HomeUiState.Success::class.java)
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `Success state contains banners from repository`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        assertThat(state.data.banners).isEqualTo(fakeRepository.banners)
    }

    @Test
    fun `Success state contains categories from repository`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        assertThat(state.data.categories).isEqualTo(fakeRepository.categories)
    }

    @Test
    fun `Success state contains popular products from repository`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        assertThat(state.data.popularProducts).isEqualTo(fakeRepository.popularProducts)
    }

    @Test
    fun `Success state contains daily deal from repository`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        assertThat(state.data.dailyDeal).isEqualTo(fakeRepository.dailyDeal)
    }

    @Test
    fun `Success state contains new arrivals from repository`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        assertThat(state.data.newArrivals).isEqualTo(fakeRepository.newArrivals)
    }

    @Test
    fun `Success state contains flash sale from repository`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        assertThat(state.data.flashSale).isEqualTo(fakeRepository.flashSale)
    }

    @Test
    fun `Success state has empty wishedProductIds on first load`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        assertThat(state.data.wishedProductIds).isEmpty()
    }

    @Test
    fun `Success state has null dailyDeal when repository returns null`() = runTest {
        fakeRepository.dailyDeal = null
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        assertThat(state.data.dailyDeal).isNull()
    }

    @Test
    fun `Success state has null flashSale when repository returns null`() = runTest {
        fakeRepository.flashSale = null
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        assertThat(state.data.flashSale).isNull()
    }

    // endregion

    // region load home data — error

    @Test
    fun `uiState transitions to Error when repository throws IOException`() = runTest {
        fakeRepository.shouldThrow = IOException("Network error")
        val viewModel = createViewModel()

        advanceUntilIdle()

        assertThat(viewModel.uiState.value).isInstanceOf(HomeUiState.Error::class.java)
    }

    @Test
    fun `Error state contains network error resource when IOException thrown`() = runTest {
        fakeRepository.shouldThrow = IOException("Connection refused")
        val viewModel = createViewModel()

        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Error
        assertThat(state.messageResId).isEqualTo(R.string.common_error_network)
    }

    @Test
    fun `Error state contains network error resource when IOException has null message`() = runTest {
        fakeRepository.shouldThrow = IOException()
        val viewModel = createViewModel()

        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Error
        assertThat(state.messageResId).isEqualTo(R.string.common_error_network)
    }

    @Test
    fun `uiState emits Loading then Error on network failure`() = runTest {
        fakeRepository.shouldThrow = IOException("Timeout")
        val viewModel = createViewModel()

        viewModel.uiState.test {
            assertThat(awaitItem()).isEqualTo(HomeUiState.Loading)
            advanceUntilIdle()
            assertThat(awaitItem()).isInstanceOf(HomeUiState.Error::class.java)
            cancelAndIgnoreRemainingEvents()
        }
    }

    // endregion

    // region RetryTapped event

    @Test
    fun `onEvent RetryTapped reloads data and transitions to Success`() = runTest {
        fakeRepository.shouldThrow = IOException("Initial error")
        val viewModel = createViewModel()
        advanceUntilIdle()
        assertThat(viewModel.uiState.value).isInstanceOf(HomeUiState.Error::class.java)

        fakeRepository.shouldThrow = null
        viewModel.onEvent(HomeEvent.RetryTapped)
        advanceUntilIdle()

        assertThat(viewModel.uiState.value).isInstanceOf(HomeUiState.Success::class.java)
    }

    @Test
    fun `onEvent RetryTapped shows Loading before reloading`() = runTest {
        fakeRepository.shouldThrow = IOException("error")
        val viewModel = createViewModel()
        advanceUntilIdle()

        fakeRepository.shouldThrow = null
        viewModel.uiState.test {
            assertThat(awaitItem()).isInstanceOf(HomeUiState.Error::class.java)
            viewModel.onEvent(HomeEvent.RetryTapped)
            assertThat(awaitItem()).isEqualTo(HomeUiState.Loading)
            advanceUntilIdle()
            assertThat(awaitItem()).isInstanceOf(HomeUiState.Success::class.java)
            cancelAndIgnoreRemainingEvents()
        }
    }

    // endregion

    // region Refresh event

    @Test
    fun `onEvent Refresh reloads data and keeps Success state`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        viewModel.onEvent(HomeEvent.Refresh)
        advanceUntilIdle()

        assertThat(viewModel.uiState.value).isInstanceOf(HomeUiState.Success::class.java)
    }

    @Test
    fun `onEvent Refresh sets isRefreshing to true then false`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        viewModel.uiState.test {
            val initial = awaitItem() as HomeUiState.Success
            assertThat(initial.isRefreshing).isFalse()
            viewModel.onEvent(HomeEvent.Refresh)
            val refreshing = awaitItem() as HomeUiState.Success
            assertThat(refreshing.isRefreshing).isTrue()
            advanceUntilIdle()
            val done = awaitItem() as HomeUiState.Success
            assertThat(done.isRefreshing).isFalse()
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `onEvent Refresh preserves wishedProductIds across reload`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val productId = fakeRepository.popularProducts.first().id
        viewModel.onEvent(HomeEvent.WishlistToggled(productId))

        viewModel.onEvent(HomeEvent.Refresh)
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success
        assertThat(state.data.wishedProductIds).contains(productId)
    }

    @Test
    fun `onEvent Refresh resets isRefreshing to false on error`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        fakeRepository.shouldThrow = IOException("error on refresh")
        viewModel.onEvent(HomeEvent.Refresh)
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success
        assertThat(state.isRefreshing).isFalse()
    }

    @Test
    fun `onEvent Refresh stays in Success when reload fails`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        fakeRepository.shouldThrow = IOException("Refresh failed")
        viewModel.onEvent(HomeEvent.Refresh)
        advanceUntilIdle()

        assertThat(viewModel.uiState.value).isInstanceOf(HomeUiState.Success::class.java)
    }

    // endregion

    // region WishlistToggled event

    @Test
    fun `onEvent WishlistToggled adds productId to wishedProductIds`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val productId = "prod-1"

        viewModel.onEvent(HomeEvent.WishlistToggled(productId))

        val state = viewModel.uiState.value as HomeUiState.Success
        assertThat(state.data.wishedProductIds).contains(productId)
    }

    @Test
    fun `onEvent WishlistToggled removes productId when already wished`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val productId = "prod-1"
        viewModel.onEvent(HomeEvent.WishlistToggled(productId))

        viewModel.onEvent(HomeEvent.WishlistToggled(productId))

        val state = viewModel.uiState.value as HomeUiState.Success
        assertThat(state.data.wishedProductIds).doesNotContain(productId)
    }

    @Test
    fun `onEvent WishlistToggled toggles multiple products independently`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val productId1 = "prod-1"
        val productId2 = "prod-2"

        viewModel.onEvent(HomeEvent.WishlistToggled(productId1))
        viewModel.onEvent(HomeEvent.WishlistToggled(productId2))

        val state = viewModel.uiState.value as HomeUiState.Success
        assertThat(state.data.wishedProductIds).containsExactly(productId1, productId2)
    }

    @Test
    fun `onEvent WishlistToggled has no effect when uiState is not Success`() = runTest {
        fakeRepository.shouldThrow = IOException("error")
        val viewModel = createViewModel()
        advanceUntilIdle()
        assertThat(viewModel.uiState.value).isInstanceOf(HomeUiState.Error::class.java)

        viewModel.onEvent(HomeEvent.WishlistToggled("prod-1"))

        assertThat(viewModel.uiState.value).isInstanceOf(HomeUiState.Error::class.java)
    }

    @Test
    fun `onEvent WishlistToggled emits new state via flow`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val productId = "prod-wishlist"

        viewModel.uiState.test {
            val initial = awaitItem() as HomeUiState.Success
            assertThat(initial.data.wishedProductIds).doesNotContain(productId)

            viewModel.onEvent(HomeEvent.WishlistToggled(productId))

            val updated = awaitItem() as HomeUiState.Success
            assertThat(updated.data.wishedProductIds).contains(productId)
            cancelAndIgnoreRemainingEvents()
        }
    }

    // endregion

    // region no-op navigation events

    @Test
    fun `onEvent BannerTapped does not change uiState`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val stateBefore = viewModel.uiState.value

        val banner = fakeRepository.banners.first()
        viewModel.onEvent(HomeEvent.BannerTapped(banner))

        assertThat(viewModel.uiState.value).isEqualTo(stateBefore)
    }

    @Test
    fun `onEvent CategoryTapped does not change uiState`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val stateBefore = viewModel.uiState.value

        val category = fakeRepository.categories.first()
        viewModel.onEvent(HomeEvent.CategoryTapped(category))

        assertThat(viewModel.uiState.value).isEqualTo(stateBefore)
    }

    @Test
    fun `onEvent ProductTapped does not change uiState`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val stateBefore = viewModel.uiState.value

        viewModel.onEvent(HomeEvent.ProductTapped("prod-1"))

        assertThat(viewModel.uiState.value).isEqualTo(stateBefore)
    }

    @Test
    fun `onEvent DailyDealTapped does not change uiState`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val stateBefore = viewModel.uiState.value

        viewModel.onEvent(HomeEvent.DailyDealTapped("prod-deal-1"))

        assertThat(viewModel.uiState.value).isEqualTo(stateBefore)
    }

    @Test
    fun `onEvent SeeAllPopularTapped does not change uiState`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val stateBefore = viewModel.uiState.value

        viewModel.onEvent(HomeEvent.SeeAllPopularTapped)

        assertThat(viewModel.uiState.value).isEqualTo(stateBefore)
    }

    @Test
    fun `onEvent SeeAllNewArrivalsTapped does not change uiState`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val stateBefore = viewModel.uiState.value

        viewModel.onEvent(HomeEvent.SeeAllNewArrivalsTapped)

        assertThat(viewModel.uiState.value).isEqualTo(stateBefore)
    }

    @Test
    fun `onEvent SearchBarTapped does not change uiState`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()
        val stateBefore = viewModel.uiState.value

        viewModel.onEvent(HomeEvent.SearchBarTapped)

        assertThat(viewModel.uiState.value).isEqualTo(stateBefore)
    }

    // endregion

    // region data integrity

    @Test
    fun `Success state banners contain valid ids and titles`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        state.data.banners.forEach { banner ->
            assertThat(banner.id).isNotEmpty()
            assertThat(banner.title).isNotEmpty()
        }
    }

    @Test
    fun `Success state categories contain valid ids and names`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        state.data.categories.forEach { category ->
            assertThat(category.id).isNotEmpty()
            assertThat(category.name).isNotEmpty()
        }
    }

    @Test
    fun `Success state popularProducts contain valid ids and prices`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        state.data.popularProducts.forEach { product ->
            assertThat(product.id).isNotEmpty()
            assertThat(product.price).isNotEmpty()
        }
    }

    @Test
    fun `Success state newArrivals all have isNew true`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success

        state.data.newArrivals.forEach { product ->
            assertThat(product.isNew).isTrue()
        }
    }

    @Test
    fun `Success state is updated with fresh data after repository changes and refresh`() = runTest {
        val viewModel = createViewModel()
        advanceUntilIdle()

        val newFlashSale = FlashSale(
            id = "flash-updated",
            title = "Updated Flash Sale",
            imageUrl = null,
            actionUrl = null,
        )
        fakeRepository.flashSale = newFlashSale
        viewModel.onEvent(HomeEvent.Refresh)
        advanceUntilIdle()

        val state = viewModel.uiState.value as HomeUiState.Success
        assertThat(state.data.flashSale).isEqualTo(newFlashSale)
    }

    // endregion
}
