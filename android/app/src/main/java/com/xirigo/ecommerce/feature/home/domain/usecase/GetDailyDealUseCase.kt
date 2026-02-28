package com.xirigo.ecommerce.feature.home.domain.usecase

import javax.inject.Inject
import com.xirigo.ecommerce.feature.home.domain.model.DailyDeal
import com.xirigo.ecommerce.feature.home.domain.repository.HomeRepository

class GetDailyDealUseCase @Inject constructor(
    private val repository: HomeRepository,
) {
    suspend operator fun invoke(): DailyDeal? = repository.getDailyDeal()
}
