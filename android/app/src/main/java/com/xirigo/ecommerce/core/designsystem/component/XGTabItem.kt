package com.xirigo.ecommerce.core.designsystem.component

import androidx.compose.runtime.Stable
import androidx.compose.ui.graphics.vector.ImageVector

@Stable
data class XGTabItem(
    val label: String,
    val icon: ImageVector,
    val selectedIcon: ImageVector,
    val badgeCount: Int? = null,
)
