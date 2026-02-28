package com.xirigo.ecommerce.core.di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton
import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.preferencesDataStore
import androidx.room.Room
import com.xirigo.ecommerce.core.data.local.XGDatabase

private val Context.preferencesDataStore by preferencesDataStore(name = "xg_preferences")

@Module
@InstallIn(SingletonComponent::class)
object StorageModule {

    @Provides
    @Singleton
    fun providePreferencesDataStore(@ApplicationContext context: Context): DataStore<Preferences> =
        context.preferencesDataStore

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): XGDatabase = Room.databaseBuilder(
        context,
        XGDatabase::class.java,
        "xg_database",
    ).fallbackToDestructiveMigration(dropAllTables = true).build()
}
