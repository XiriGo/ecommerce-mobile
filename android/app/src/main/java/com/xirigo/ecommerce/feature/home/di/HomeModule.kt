package com.xirigo.ecommerce.feature.home.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton
import com.xirigo.ecommerce.feature.home.data.repository.FakeHomeRepository
import com.xirigo.ecommerce.feature.home.domain.repository.HomeRepository

@Module
@InstallIn(SingletonComponent::class)
abstract class HomeModule {

    @Binds
    @Singleton
    abstract fun bindHomeRepository(impl: FakeHomeRepository): HomeRepository
}
