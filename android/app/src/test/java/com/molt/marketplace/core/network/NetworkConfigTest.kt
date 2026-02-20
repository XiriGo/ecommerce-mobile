package com.molt.marketplace.core.network

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class NetworkConfigTest {

    @Test
    fun `CONNECT_TIMEOUT_SECONDS should be 30`() {
        assertThat(NetworkConfig.CONNECT_TIMEOUT_SECONDS).isEqualTo(30L)
    }

    @Test
    fun `READ_TIMEOUT_SECONDS should be 60`() {
        assertThat(NetworkConfig.READ_TIMEOUT_SECONDS).isEqualTo(60L)
    }

    @Test
    fun `WRITE_TIMEOUT_SECONDS should be 60`() {
        assertThat(NetworkConfig.WRITE_TIMEOUT_SECONDS).isEqualTo(60L)
    }

    @Test
    fun `CACHE_SIZE_BYTES should be 10 MB`() {
        val expectedBytes = 10L * 1024 * 1024
        assertThat(NetworkConfig.CACHE_SIZE_BYTES).isEqualTo(expectedBytes)
    }

    @Test
    fun `read and write timeouts should be equal`() {
        assertThat(NetworkConfig.READ_TIMEOUT_SECONDS).isEqualTo(NetworkConfig.WRITE_TIMEOUT_SECONDS)
    }

    @Test
    fun `connect timeout should be less than read timeout`() {
        assertThat(NetworkConfig.CONNECT_TIMEOUT_SECONDS).isLessThan(NetworkConfig.READ_TIMEOUT_SECONDS)
    }
}
