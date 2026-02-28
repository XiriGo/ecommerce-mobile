package com.xirigo.ecommerce.feature.home.domain.usecase

import javax.inject.Inject
import com.xirigo.ecommerce.feature.home.domain.model.HomeProduct
import com.xirigo.ecommerce.feature.home.domain.repository.HomeRepository

class GetNewArrivalsUseCase @Inject constructor(
    private val repository: HomeRepository,
) {
    suspend operator fun invoke(): List<HomeProduct> = repository.getNewArrivals()
}
