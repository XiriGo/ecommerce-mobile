package com.xirigo.ecommerce.feature.onboarding.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton
import com.xirigo.ecommerce.feature.onboarding.data.repository.OnboardingRepositoryImpl
import com.xirigo.ecommerce.feature.onboarding.domain.repository.OnboardingRepository

@Module
@InstallIn(SingletonComponent::class)
abstract class OnboardingModule {

    @Binds
    @Singleton
    abstract fun bindOnboardingRepository(impl: OnboardingRepositoryImpl): OnboardingRepository
}
