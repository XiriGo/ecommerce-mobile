package com.xirigo.ecommerce.feature.home.domain.usecase

import javax.inject.Inject
import com.xirigo.ecommerce.feature.home.domain.model.HomeCategory
import com.xirigo.ecommerce.feature.home.domain.repository.HomeRepository

class GetHomeCategoriesUseCase @Inject constructor(
    private val repository: HomeRepository,
) {
    suspend operator fun invoke(): List<HomeCategory> = repository.getCategories()
}
