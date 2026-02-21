package com.molt.marketplace.core.auth

import retrofit2.http.Body
import retrofit2.http.DELETE
import retrofit2.http.Header
import retrofit2.http.POST
import com.molt.marketplace.core.auth.dto.AuthTokenResponse
import com.molt.marketplace.core.auth.dto.LoginRequest
import com.molt.marketplace.core.auth.dto.RegisterRequest

interface AuthApi {

    @POST("auth/customer/emailpass")
    suspend fun login(@Body request: LoginRequest): AuthTokenResponse

    @POST("auth/customer/emailpass/register")
    suspend fun register(@Body request: RegisterRequest): AuthTokenResponse

    @POST("auth/session")
    suspend fun createSession(@Header("Authorization") bearerToken: String)

    @DELETE("auth/session")
    suspend fun destroySession(@Header("Authorization") bearerToken: String)

    @POST("auth/token/refresh")
    suspend fun refreshToken(@Header("Authorization") bearerToken: String): AuthTokenResponse
}
