package com.xirigo.ecommerce.feature.home.domain.usecase

import javax.inject.Inject
import com.xirigo.ecommerce.feature.home.domain.model.HomeBanner
import com.xirigo.ecommerce.feature.home.domain.repository.HomeRepository

class GetHomeBannersUseCase @Inject constructor(
    private val repository: HomeRepository,
) {
    suspend operator fun invoke(): List<HomeBanner> = repository.getBanners()
}
