package com.molt.marketplace.core.auth

import com.google.common.truth.Truth.assertThat
import com.molt.marketplace.core.auth.dto.AuthTokenResponse
import com.molt.marketplace.core.auth.dto.LoginRequest
import com.molt.marketplace.core.auth.dto.RegisterRequest
import com.molt.marketplace.core.domain.error.AppError
import kotlinx.coroutines.test.runTest
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.ResponseBody.Companion.toResponseBody
import org.junit.Before
import org.junit.Test
import retrofit2.HttpException
import retrofit2.Response

class SessionManagerTest {

    private lateinit var fakeAuthApi: FakeAuthApi
    private lateinit var fakeTokenStorage: FakeTokenStorage
    private lateinit var authStateManager: AuthStateManagerImpl
    private lateinit var sessionManager: SessionManager

    @Before
    fun setUp() {
        fakeAuthApi = FakeAuthApi()
        fakeTokenStorage = FakeTokenStorage()
        authStateManager = AuthStateManagerImpl(fakeTokenStorage)
        sessionManager = SessionManager(fakeAuthApi, fakeTokenStorage, authStateManager)
    }

    // region login

    @Test
    fun `login success calls API saves token creates session and updates state`() = runTest {
        fakeAuthApi.loginResponse = AuthTokenResponse("login-jwt")

        val result = sessionManager.login("user@example.com", "password123")

        assertThat(result.isSuccess).isTrue()
        assertThat(fakeAuthApi.lastLoginRequest?.email).isEqualTo("user@example.com")
        assertThat(fakeAuthApi.lastLoginRequest?.password).isEqualTo("password123")
        assertThat(fakeTokenStorage.getAccessToken()).isEqualTo("login-jwt")
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Authenticated("login-jwt"))
        assertThat(fakeAuthApi.createSessionCallCount).isEqualTo(1)
    }

    @Test
    fun `login 401 failure returns error and state unchanged`() = runTest {
        fakeAuthApi.loginException = FakeAuthApi.httpException(401)

        val result = sessionManager.login("bad@example.com", "wrong")

        assertThat(result.isFailure).isTrue()
        val error = result.exceptionOrNull()
        assertThat(error).isInstanceOf(AppError.Unauthorized::class.java)
        assertThat(fakeTokenStorage.getAccessToken()).isNull()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Loading)
    }

    @Test
    fun `login 422 failure returns server error`() = runTest {
        fakeAuthApi.loginException = FakeAuthApi.httpException(422)

        val result = sessionManager.login("user@example.com", "password")

        assertThat(result.isFailure).isTrue()
        val error = result.exceptionOrNull()
        assertThat(error).isInstanceOf(AppError.Server::class.java)
    }

    @Test
    fun `login with blank token returns failure`() = runTest {
        fakeAuthApi.loginResponse = AuthTokenResponse("")

        val result = sessionManager.login("user@example.com", "password")

        assertThat(result.isFailure).isTrue()
        val error = result.exceptionOrNull()
        assertThat(error).isInstanceOf(AppError.Unknown::class.java)
        assertThat(fakeTokenStorage.getAccessToken()).isNull()
    }

    @Test
    fun `login session creation failure does not fail login`() = runTest {
        fakeAuthApi.loginResponse = AuthTokenResponse("good-token")
        fakeAuthApi.createSessionException = FakeAuthApi.httpException(503)

        val result = sessionManager.login("user@example.com", "password")

        assertThat(result.isSuccess).isTrue()
        assertThat(fakeTokenStorage.getAccessToken()).isEqualTo("good-token")
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Authenticated("good-token"))
    }

    @Test
    fun `login network failure returns network error`() = runTest {
        fakeAuthApi.loginException = java.io.IOException("No network")

        val result = sessionManager.login("user@example.com", "password")

        assertThat(result.isFailure).isTrue()
        val error = result.exceptionOrNull()
        assertThat(error).isInstanceOf(AppError.Network::class.java)
    }

    // endregion

    // region register

    @Test
    fun `register success calls API saves token creates session and updates state`() = runTest {
        fakeAuthApi.registerResponse = AuthTokenResponse("register-jwt")

        val result = sessionManager.register("new@example.com", "secret")

        assertThat(result.isSuccess).isTrue()
        assertThat(fakeAuthApi.lastRegisterRequest?.email).isEqualTo("new@example.com")
        assertThat(fakeAuthApi.lastRegisterRequest?.password).isEqualTo("secret")
        assertThat(fakeTokenStorage.getAccessToken()).isEqualTo("register-jwt")
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Authenticated("register-jwt"))
        assertThat(fakeAuthApi.createSessionCallCount).isEqualTo(1)
    }

    @Test
    fun `register 422 failure email exists returns server error`() = runTest {
        fakeAuthApi.registerException = FakeAuthApi.httpException(422)

        val result = sessionManager.register("existing@example.com", "password")

        assertThat(result.isFailure).isTrue()
        val error = result.exceptionOrNull()
        assertThat(error).isInstanceOf(AppError.Server::class.java)
        val serverError = error as AppError.Server
        assertThat(serverError.code).isEqualTo(422)
        assertThat(fakeTokenStorage.getAccessToken()).isNull()
    }

    @Test
    fun `register with blank token returns failure`() = runTest {
        fakeAuthApi.registerResponse = AuthTokenResponse("   ")

        val result = sessionManager.register("user@example.com", "password")

        assertThat(result.isFailure).isTrue()
        assertThat(result.exceptionOrNull()).isInstanceOf(AppError.Unknown::class.java)
    }

    @Test
    fun `register network failure returns network error`() = runTest {
        fakeAuthApi.registerException = java.io.IOException("Connection refused")

        val result = sessionManager.register("user@example.com", "password")

        assertThat(result.isFailure).isTrue()
        assertThat(result.exceptionOrNull()).isInstanceOf(AppError.Network::class.java)
    }

    // endregion

    // region logout

    @Test
    fun `logout clears local state even when API fails`() = runTest {
        fakeTokenStorage.saveAccessToken("existing-token")
        authStateManager.onLoginSuccess("existing-token")
        fakeAuthApi.destroySessionException = java.io.IOException("Offline")

        sessionManager.logout()

        assertThat(fakeTokenStorage.getAccessToken()).isNull()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)
    }

    @Test
    fun `logout calls destroySession with bearer token when token exists`() = runTest {
        fakeTokenStorage.saveAccessToken("active-token")
        authStateManager.onLoginSuccess("active-token")

        sessionManager.logout()

        assertThat(fakeAuthApi.lastDestroySessionBearerToken).isEqualTo("Bearer active-token")
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)
        assertThat(fakeTokenStorage.getAccessToken()).isNull()
    }

    @Test
    fun `logout when no token skips destroySession and clears state`() = runTest {
        assertThat(fakeTokenStorage.getAccessToken()).isNull()

        sessionManager.logout()

        assertThat(fakeAuthApi.destroySessionCallCount).isEqualTo(0)
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)
    }

    @Test
    fun `logout always succeeds locally regardless of API result`() = runTest {
        fakeTokenStorage.saveAccessToken("token")
        authStateManager.onLoginSuccess("token")
        fakeAuthApi.destroySessionException = FakeAuthApi.httpException(500)

        sessionManager.logout()

        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)
        assertThat(fakeTokenStorage.getAccessToken()).isNull()
    }

    // endregion

    // region refreshToken

    @Test
    fun `refreshToken success stores new token and updates state`() = runTest {
        fakeTokenStorage.saveAccessToken("old-token")
        authStateManager.onLoginSuccess("old-token")
        fakeAuthApi.refreshTokenResponse = AuthTokenResponse("refreshed-token")

        val result = sessionManager.refreshToken()

        assertThat(result.isSuccess).isTrue()
        assertThat(result.getOrNull()).isEqualTo("refreshed-token")
        assertThat(fakeTokenStorage.getAccessToken()).isEqualTo("refreshed-token")
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Authenticated("refreshed-token"))
    }

    @Test
    fun `refreshToken passes bearer token to API`() = runTest {
        fakeTokenStorage.saveAccessToken("current-token")
        fakeAuthApi.refreshTokenResponse = AuthTokenResponse("new-token")

        sessionManager.refreshToken()

        assertThat(fakeAuthApi.lastRefreshTokenBearerToken).isEqualTo("Bearer current-token")
    }

    @Test
    fun `refreshToken failure clears state to Guest`() = runTest {
        fakeTokenStorage.saveAccessToken("expiring-token")
        authStateManager.onLoginSuccess("expiring-token")
        fakeAuthApi.refreshTokenException = FakeAuthApi.httpException(401)

        val result = sessionManager.refreshToken()

        assertThat(result.isFailure).isTrue()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)
        assertThat(fakeTokenStorage.getAccessToken()).isNull()
    }

    @Test
    fun `refreshToken with no stored token returns Unauthorized failure`() = runTest {
        val result = sessionManager.refreshToken()

        assertThat(result.isFailure).isTrue()
        assertThat(result.exceptionOrNull()).isInstanceOf(AppError.Unauthorized::class.java)
    }

    @Test
    fun `refreshToken with blank token response returns failure`() = runTest {
        fakeTokenStorage.saveAccessToken("current-token")
        fakeAuthApi.refreshTokenResponse = AuthTokenResponse("")

        val result = sessionManager.refreshToken()

        assertThat(result.isFailure).isTrue()
        assertThat(result.exceptionOrNull()).isInstanceOf(AppError.Unknown::class.java)
    }

    @Test
    fun `refreshToken failure returns mapped AppError`() = runTest {
        fakeTokenStorage.saveAccessToken("token")
        fakeAuthApi.refreshTokenException = java.io.IOException("No network")

        val result = sessionManager.refreshToken()

        assertThat(result.isFailure).isTrue()
        assertThat(result.exceptionOrNull()).isInstanceOf(AppError.Network::class.java)
    }

    // endregion
}

/**
 * In-memory fake implementation of [AuthApi] for unit tests.
 */
class FakeAuthApi : AuthApi {

    var loginResponse: AuthTokenResponse? = null
    var loginException: Throwable? = null
    var lastLoginRequest: LoginRequest? = null

    var registerResponse: AuthTokenResponse? = null
    var registerException: Throwable? = null
    var lastRegisterRequest: RegisterRequest? = null

    var createSessionException: Throwable? = null
    var createSessionCallCount: Int = 0

    var destroySessionException: Throwable? = null
    var destroySessionCallCount: Int = 0
    var lastDestroySessionBearerToken: String? = null

    var refreshTokenResponse: AuthTokenResponse? = null
    var refreshTokenException: Throwable? = null
    var lastRefreshTokenBearerToken: String? = null

    override suspend fun login(request: LoginRequest): AuthTokenResponse {
        lastLoginRequest = request
        loginException?.let { throw it }
        return requireNotNull(loginResponse) { "FakeAuthApi: loginResponse not set" }
    }

    override suspend fun register(request: RegisterRequest): AuthTokenResponse {
        lastRegisterRequest = request
        registerException?.let { throw it }
        return requireNotNull(registerResponse) { "FakeAuthApi: registerResponse not set" }
    }

    override suspend fun createSession(bearerToken: String) {
        createSessionCallCount++
        createSessionException?.let { throw it }
    }

    override suspend fun destroySession(bearerToken: String) {
        destroySessionCallCount++
        lastDestroySessionBearerToken = bearerToken
        destroySessionException?.let { throw it }
    }

    override suspend fun refreshToken(bearerToken: String): AuthTokenResponse {
        lastRefreshTokenBearerToken = bearerToken
        refreshTokenException?.let { throw it }
        return requireNotNull(refreshTokenResponse) { "FakeAuthApi: refreshTokenResponse not set" }
    }

    companion object {
        fun httpException(code: Int): HttpException {
            val body = "".toResponseBody("text/plain".toMediaTypeOrNull())
            val response = Response.error<Any>(code, body)
            return HttpException(response)
        }
    }
}
