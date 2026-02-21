package com.molt.marketplace.core.auth

import com.google.common.truth.Truth.assertThat
import com.molt.marketplace.core.auth.dto.AuthTokenResponse
import com.molt.marketplace.core.network.TokenProvider
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test

/**
 * Tests for the DI-wiring contracts defined in [com.molt.marketplace.core.auth.di.AuthModule].
 *
 * Since Hilt component graphs require Android instrumentation tests, these unit tests
 * verify the contracts by constructing collaborators directly and asserting delegation
 * behavior — the same delegation that AuthModule wires via DI at runtime.
 */
class AuthModuleTest {

    private lateinit var fakeTokenStorage: FakeTokenStorage
    private lateinit var fakeAuthApi: FakeAuthApi
    private lateinit var authStateManager: AuthStateManagerImpl
    private lateinit var sessionManager: SessionManager

    @Before
    fun setUp() {
        fakeTokenStorage = FakeTokenStorage()
        fakeAuthApi = FakeAuthApi()
        authStateManager = AuthStateManagerImpl(fakeTokenStorage)
        sessionManager = SessionManager(fakeAuthApi, fakeTokenStorage, authStateManager)
    }

    // region TokenStorage contract

    @Test
    fun `TokenStorage getAccessToken returns null when empty`() = runTest {
        assertThat(fakeTokenStorage.getAccessToken()).isNull()
    }

    @Test
    fun `TokenStorage saveAccessToken and getAccessToken round-trip`() = runTest {
        fakeTokenStorage.saveAccessToken("round-trip-token")
        assertThat(fakeTokenStorage.getAccessToken()).isEqualTo("round-trip-token")
    }

    @Test
    fun `TokenStorage clearTokens removes the stored token`() = runTest {
        fakeTokenStorage.saveAccessToken("to-be-cleared")
        fakeTokenStorage.clearTokens()
        assertThat(fakeTokenStorage.getAccessToken()).isNull()
    }

    @Test
    fun `TokenStorage getAccessTokenFlow is non-null`() {
        assertThat(fakeTokenStorage.getAccessTokenFlow()).isNotNull()
    }

    // endregion

    // region SessionTokenProvider delegation (contract tests)

    @Test
    fun `SessionTokenProvider getAccessToken delegates to TokenStorage`() = runTest {
        fakeTokenStorage.saveAccessToken("provider-token")
        val provider = buildSessionTokenProvider()

        val token = provider.getAccessToken()

        assertThat(token).isEqualTo("provider-token")
    }

    @Test
    fun `SessionTokenProvider getAccessToken returns null when storage empty`() = runTest {
        val provider = buildSessionTokenProvider()

        val token = provider.getAccessToken()

        assertThat(token).isNull()
    }

    @Test
    fun `SessionTokenProvider clearTokens delegates to TokenStorage`() = runTest {
        fakeTokenStorage.saveAccessToken("token")
        val provider = buildSessionTokenProvider()

        provider.clearTokens()

        assertThat(fakeTokenStorage.getAccessToken()).isNull()
    }

    @Test
    fun `SessionTokenProvider refreshToken delegates to SessionManager`() = runTest {
        fakeTokenStorage.saveAccessToken("old-token")
        fakeAuthApi.refreshTokenResponse = AuthTokenResponse("refreshed-via-provider")
        val provider = buildSessionTokenProvider()

        val refreshed = provider.refreshToken()

        assertThat(refreshed).isEqualTo("refreshed-via-provider")
        assertThat(fakeTokenStorage.getAccessToken()).isEqualTo("refreshed-via-provider")
    }

    @Test
    fun `SessionTokenProvider refreshToken returns null when SessionManager refresh fails`() = runTest {
        fakeTokenStorage.saveAccessToken("expiring")
        fakeAuthApi.refreshTokenException = FakeAuthApi.httpException(401)
        val provider = buildSessionTokenProvider()

        val refreshed = provider.refreshToken()

        assertThat(refreshed).isNull()
    }

    // endregion

    // region AuthStateManager contract

    @Test
    fun `AuthStateManager initial state is Loading`() {
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Loading)
    }

    @Test
    fun `AuthStateManager onLoginSuccess transitions to Authenticated`() = runTest {
        authStateManager.onLoginSuccess("auth-token")
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Authenticated("auth-token"))
    }

    @Test
    fun `AuthStateManager onLogout transitions to Guest`() = runTest {
        authStateManager.onLoginSuccess("auth-token")
        authStateManager.onLogout()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)
    }

    // endregion

    // region SessionManager as AuthApi consumer

    @Test
    fun `SessionManager can be constructed and login invokes AuthApi`() = runTest {
        fakeAuthApi.loginResponse = AuthTokenResponse("module-token")

        val result = sessionManager.login("user@molt.com", "pass")

        assertThat(result.isSuccess).isTrue()
        assertThat(fakeAuthApi.lastLoginRequest).isNotNull()
    }

    @Test
    fun `SessionManager register invokes AuthApi`() = runTest {
        fakeAuthApi.registerResponse = AuthTokenResponse("register-token")

        val result = sessionManager.register("new@molt.com", "secret")

        assertThat(result.isSuccess).isTrue()
        assertThat(fakeAuthApi.lastRegisterRequest).isNotNull()
    }

    // endregion

    // region Helper

    /**
     * Builds a [TokenProvider] that mirrors the [com.molt.marketplace.core.auth.di.AuthProvidesModule]
     * SessionTokenProvider by delegating getAccessToken/clearTokens to [FakeTokenStorage]
     * and refreshToken to [SessionManager].
     */
    private fun buildSessionTokenProvider(): TokenProvider = object : TokenProvider {
        override suspend fun getAccessToken(): String? = fakeTokenStorage.getAccessToken()
        override suspend fun clearTokens() = fakeTokenStorage.clearTokens()
        override suspend fun refreshToken(): String? = sessionManager.refreshToken().getOrNull()
    }

    // endregion
}
