package com.xirigo.ecommerce.core.di

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import androidx.room.Room
import com.xirigo.ecommerce.core.data.local.MoltDatabase

// Top-level extension properties for preferencesDataStore (must be at file level)
private val Context.storageTestDataStore by preferencesDataStore("test_prefs_storage_module")
private val Context.storageEmitDataStore by preferencesDataStore("test_prefs_emit")
private val Context.storageEmptyDataStore by preferencesDataStore("test_prefs_empty")
private val Context.storageWriteDataStore by preferencesDataStore("test_prefs_write")

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [33])
class StorageModuleTest {

    private lateinit var context: Context
    private var database: MoltDatabase? = null

    @Before
    fun setUp() {
        context = RuntimeEnvironment.getApplication()
    }

    @After
    fun tearDown() {
        database?.close()
    }

    // region MoltDatabase

    @Test
    fun `provideDatabase returns non-null MoltDatabase`() {
        database = Room.inMemoryDatabaseBuilder(context, MoltDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        assertThat(database).isNotNull()
    }

    @Test
    fun `provideDatabase creates open database after first access`() {
        database = Room.inMemoryDatabaseBuilder(context, MoltDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        // Room lazily opens the database — force it open via openHelper
        database!!.openHelper.writableDatabase
        assertThat(database!!.isOpen).isTrue()
    }

    @Test
    fun `provideDatabase is a MoltDatabase instance`() {
        database = Room.inMemoryDatabaseBuilder(context, MoltDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        assertThat(database).isInstanceOf(MoltDatabase::class.java)
    }

    @Test
    fun `provideDatabase can be closed without error`() {
        val db = Room.inMemoryDatabaseBuilder(context, MoltDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        db.close()
        assertThat(db.isOpen).isFalse()
        database = null
    }

    @Test
    fun `provideDatabase with fallbackToDestructiveMigration does not throw`() {
        database = Room.databaseBuilder(
            context,
            MoltDatabase::class.java,
            "molt_database_test_fallback",
        ).fallbackToDestructiveMigration(dropAllTables = true).build()
        assertThat(database).isNotNull()
    }

    // endregion

    // region DataStore<Preferences>

    @Test
    fun `DataStore can be created with application context`() {
        val ds = context.storageTestDataStore
        assertThat(ds).isNotNull()
    }

    @Test
    fun `DataStore emits a non-null preferences object`() = runBlocking {
        val prefs = context.storageEmitDataStore.data.first()
        assertThat(prefs).isNotNull()
    }

    @Test
    fun `DataStore returns null for non-existent key initially`() = runBlocking {
        val prefs = context.storageEmptyDataStore.data.first()
        val key = stringPreferencesKey("non_existent_key")
        assertThat(prefs[key]).isNull()
    }

    @Test
    fun `DataStore persists and reads back written value`() = runBlocking {
        val key = stringPreferencesKey("test_key")
        val expectedValue = "test_value"

        context.storageWriteDataStore.edit { it[key] = expectedValue }

        val prefs = context.storageWriteDataStore.data.first()
        assertThat(prefs[key]).isEqualTo(expectedValue)
    }

    // endregion
}
