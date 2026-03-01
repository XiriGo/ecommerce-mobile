package com.xirigo.ecommerce.core.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Placeholder entity required by Room. Room requires at least one entity in the database.
 * This will be removed when the first real entity is added (e.g., CartItem in M2-01).
 */
@Entity(tableName = "placeholder")
internal data class PlaceholderEntity(
    @PrimaryKey
    val id: Int = 0,
)
