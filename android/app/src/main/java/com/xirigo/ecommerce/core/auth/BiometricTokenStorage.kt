package com.xirigo.ecommerce.core.auth

interface BiometricTokenStorage {
    suspend fun storeRefreshTokenWithBiometric(token: String)
    suspend fun retrieveRefreshTokenWithBiometric(): String?
    suspend fun clearBiometricToken()
    fun isBiometricAvailable(): Boolean
}
