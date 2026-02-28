package com.xirigo.ecommerce.core.auth

import app.cash.turbine.test
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test

class AuthStateManagerTest {

    private lateinit var tokenStorage: FakeTokenStorage
    private lateinit var authStateManager: AuthStateManagerImpl

    @Before
    fun setUp() {
        tokenStorage = FakeTokenStorage()
        authStateManager = AuthStateManagerImpl(tokenStorage)
    }

    // region initial state

    @Test
    fun `authState initial value is Loading`() {
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Loading)
    }

    // endregion

    // region checkStoredToken

    @Test
    fun `checkStoredToken with no stored token transitions to Guest`() = runTest {
        authStateManager.checkStoredToken()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)
    }

    @Test
    fun `checkStoredToken with stored token transitions to Authenticated`() = runTest {
        tokenStorage.saveAccessToken("stored-token")
        authStateManager.checkStoredToken()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Authenticated("stored-token"))
    }

    @Test
    fun `checkStoredToken emits Loading then Guest via flow when no token`() = runTest {
        authStateManager.authState.test {
            assertThat(awaitItem()).isEqualTo(AuthState.Loading)
            authStateManager.checkStoredToken()
            assertThat(awaitItem()).isEqualTo(AuthState.Guest)
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `checkStoredToken emits Loading then Authenticated via flow when token exists`() = runTest {
        tokenStorage.saveAccessToken("jwt-token")
        authStateManager.authState.test {
            assertThat(awaitItem()).isEqualTo(AuthState.Loading)
            authStateManager.checkStoredToken()
            assertThat(awaitItem()).isEqualTo(AuthState.Authenticated("jwt-token"))
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `checkStoredToken called twice reflects most recent storage state`() = runTest {
        authStateManager.checkStoredToken()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)

        tokenStorage.saveAccessToken("later-token")
        authStateManager.checkStoredToken()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Authenticated("later-token"))
    }

    // endregion

    // region onLoginSuccess

    @Test
    fun `onLoginSuccess transitions state to Authenticated`() = runTest {
        authStateManager.onLoginSuccess("my-token")
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Authenticated("my-token"))
    }

    @Test
    fun `onLoginSuccess saves token to storage`() = runTest {
        authStateManager.onLoginSuccess("saved-token")
        assertThat(tokenStorage.getAccessToken()).isEqualTo("saved-token")
    }

    @Test
    fun `onLoginSuccess emits Authenticated state via flow`() = runTest {
        authStateManager.authState.test {
            assertThat(awaitItem()).isEqualTo(AuthState.Loading)
            authStateManager.onLoginSuccess("flow-token")
            assertThat(awaitItem()).isEqualTo(AuthState.Authenticated("flow-token"))
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `onLoginSuccess updates token from Guest state`() = runTest {
        authStateManager.checkStoredToken()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)

        authStateManager.onLoginSuccess("new-token")
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Authenticated("new-token"))
    }

    // endregion

    // region onLogout

    @Test
    fun `onLogout transitions state to Guest`() = runTest {
        authStateManager.onLoginSuccess("existing-token")
        authStateManager.onLogout()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)
    }

    @Test
    fun `onLogout clears token from storage`() = runTest {
        tokenStorage.saveAccessToken("token-to-clear")
        authStateManager.onLogout()
        assertThat(tokenStorage.getAccessToken()).isNull()
    }

    @Test
    fun `onLogout emits Guest state via flow`() = runTest {
        authStateManager.onLoginSuccess("token")
        authStateManager.authState.test {
            assertThat(awaitItem()).isEqualTo(AuthState.Authenticated("token"))
            authStateManager.onLogout()
            assertThat(awaitItem()).isEqualTo(AuthState.Guest)
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `onLogout from Loading state transitions to Guest`() = runTest {
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Loading)
        authStateManager.onLogout()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)
    }

    @Test
    fun `onLogout with no stored token does not throw`() = runTest {
        authStateManager.onLogout()
        assertThat(authStateManager.authState.value).isEqualTo(AuthState.Guest)
    }

    // endregion

    // region AuthState sealed interface

    @Test
    fun `AuthState Loading equals itself`() {
        assertThat(AuthState.Loading).isEqualTo(AuthState.Loading)
    }

    @Test
    fun `AuthState Guest equals itself`() {
        assertThat(AuthState.Guest).isEqualTo(AuthState.Guest)
    }

    @Test
    fun `AuthState Authenticated with same token is equal`() {
        assertThat(AuthState.Authenticated("tok")).isEqualTo(AuthState.Authenticated("tok"))
    }

    @Test
    fun `AuthState Authenticated with different tokens is not equal`() {
        assertThat(AuthState.Authenticated("a")).isNotEqualTo(AuthState.Authenticated("b"))
    }

    @Test
    fun `AuthState Loading is not equal to Guest`() {
        assertThat(AuthState.Loading).isNotEqualTo(AuthState.Guest)
    }

    // endregion
}
