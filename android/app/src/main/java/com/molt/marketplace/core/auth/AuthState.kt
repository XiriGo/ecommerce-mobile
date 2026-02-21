package com.molt.marketplace.core.auth

import androidx.compose.runtime.Stable

@Stable
sealed interface AuthState {
    data object Loading : AuthState
    data class Authenticated(val token: String) : AuthState
    data object Guest : AuthState
}
