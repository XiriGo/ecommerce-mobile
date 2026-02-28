package com.xirigo.ecommerce.feature.home.domain.usecase

import javax.inject.Inject
import com.xirigo.ecommerce.feature.home.domain.model.FlashSale
import com.xirigo.ecommerce.feature.home.domain.repository.HomeRepository

class GetFlashSaleUseCase @Inject constructor(
    private val repository: HomeRepository,
) {
    suspend operator fun invoke(): FlashSale? = repository.getFlashSale()
}
