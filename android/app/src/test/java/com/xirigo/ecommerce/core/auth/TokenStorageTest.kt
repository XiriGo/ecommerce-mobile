package com.xirigo.ecommerce.core.auth

import app.cash.turbine.test
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test

class TokenStorageTest {

    private lateinit var storage: FakeTokenStorage

    @Before
    fun setUp() {
        storage = FakeTokenStorage()
    }

    // region getAccessToken

    @Test
    fun `getAccessToken returns null initially`() = runTest {
        val token = storage.getAccessToken()
        assertThat(token).isNull()
    }

    @Test
    fun `getAccessToken returns token after save`() = runTest {
        storage.saveAccessToken("test-token")
        val token = storage.getAccessToken()
        assertThat(token).isEqualTo("test-token")
    }

    @Test
    fun `getAccessToken returns null after clear`() = runTest {
        storage.saveAccessToken("test-token")
        storage.clearTokens()
        val token = storage.getAccessToken()
        assertThat(token).isNull()
    }

    // endregion

    // region saveAccessToken

    @Test
    fun `saveAccessToken overwrites previous value`() = runTest {
        storage.saveAccessToken("first-token")
        storage.saveAccessToken("second-token")
        val token = storage.getAccessToken()
        assertThat(token).isEqualTo("second-token")
    }

    @Test
    fun `saveAccessToken persists the exact token string`() = runTest {
        val expected = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.signature"
        storage.saveAccessToken(expected)
        assertThat(storage.getAccessToken()).isEqualTo(expected)
    }

    // endregion

    // region clearTokens

    @Test
    fun `clearTokens on empty storage does not throw`() = runTest {
        storage.clearTokens()
        assertThat(storage.getAccessToken()).isNull()
    }

    @Test
    fun `clearTokens removes token`() = runTest {
        storage.saveAccessToken("some-token")
        storage.clearTokens()
        assertThat(storage.getAccessToken()).isNull()
    }

    // endregion

    // region getAccessTokenFlow

    @Test
    fun `getAccessTokenFlow emits null initially`() = runTest {
        storage.getAccessTokenFlow().test {
            assertThat(awaitItem()).isNull()
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `getAccessTokenFlow emits token after save`() = runTest {
        storage.getAccessTokenFlow().test {
            assertThat(awaitItem()).isNull()
            storage.saveAccessToken("flow-token")
            assertThat(awaitItem()).isEqualTo("flow-token")
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `getAccessTokenFlow emits null after clear`() = runTest {
        storage.saveAccessToken("token")
        storage.getAccessTokenFlow().test {
            assertThat(awaitItem()).isEqualTo("token")
            storage.clearTokens()
            assertThat(awaitItem()).isNull()
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `getAccessTokenFlow emits each new token on overwrite`() = runTest {
        storage.getAccessTokenFlow().test {
            assertThat(awaitItem()).isNull()
            storage.saveAccessToken("token-1")
            assertThat(awaitItem()).isEqualTo("token-1")
            storage.saveAccessToken("token-2")
            assertThat(awaitItem()).isEqualTo("token-2")
            cancelAndIgnoreRemainingEvents()
        }
    }

    // endregion
}
