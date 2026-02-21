package com.molt.marketplace.core.di

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
import com.molt.marketplace.core.data.local.MoltDatabase

private val Context.preferencesDataStore by preferencesDataStore(name = "molt_preferences")

@Module
@InstallIn(SingletonComponent::class)
object StorageModule {

    @Provides
    @Singleton
    fun providePreferencesDataStore(@ApplicationContext context: Context): DataStore<Preferences> =
        context.preferencesDataStore

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): MoltDatabase = Room.databaseBuilder(
        context,
        MoltDatabase::class.java,
        "molt_database",
    ).fallbackToDestructiveMigration(dropAllTables = true).build()
}
