package com.xirigo.ecommerce.feature.home.usecase

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import java.io.IOException
import com.xirigo.ecommerce.feature.home.domain.model.HomeBanner
import com.xirigo.ecommerce.feature.home.domain.usecase.GetHomeBannersUseCase
import com.xirigo.ecommerce.feature.home.repository.FakeHomeRepository

class GetHomeBannersUseCaseTest {

    private lateinit var fakeRepository: FakeHomeRepository
    private lateinit var useCase: GetHomeBannersUseCase

    @Before
    fun setUp() {
        fakeRepository = FakeHomeRepository()
        useCase = GetHomeBannersUseCase(fakeRepository)
    }

    @Test
    fun `invoke returns banners from repository`() = runTest {
        val result = useCase()

        assertThat(result).isEqualTo(fakeRepository.banners)
    }

    @Test
    fun `invoke returns non-empty list when repository has banners`() = runTest {
        val result = useCase()

        assertThat(result).isNotEmpty()
    }

    @Test
    fun `invoke returns empty list when repository has no banners`() = runTest {
        fakeRepository.banners = emptyList()

        val result = useCase()

        assertThat(result).isEmpty()
    }

    @Test
    fun `invoke returns custom banners set on repository`() = runTest {
        val customBanner = HomeBanner(
            id = "test-banner",
            title = "Test",
            subtitle = "Subtitle",
            imageUrl = null,
            tag = "TEST",
            actionProductId = null,
            actionCategoryId = null,
        )
        fakeRepository.banners = listOf(customBanner)

        val result = useCase()

        assertThat(result).containsExactly(customBanner)
    }

    @Test
    fun `invoke propagates IOException from repository`() = runTest {
        val error = IOException("Network error")
        fakeRepository.shouldThrow = error

        var caught: IOException? = null
        try {
            useCase()
        } catch (e: IOException) {
            caught = e
        }

        assertThat(caught).isEqualTo(error)
    }

    @Test
    fun `invoke delegates to repository getBanners`() = runTest {
        fakeRepository.banners = listOf(
            HomeBanner("id1", "Title1", "Sub1", null, null, null, null),
            HomeBanner("id2", "Title2", "Sub2", null, null, null, null),
        )

        val result = useCase()

        assertThat(result).hasSize(2)
        assertThat(result[0].id).isEqualTo("id1")
        assertThat(result[1].id).isEqualTo("id2")
    }
}
