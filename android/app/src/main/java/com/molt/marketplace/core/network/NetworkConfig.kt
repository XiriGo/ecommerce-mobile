package com.molt.marketplace.core.network

object NetworkConfig {
    const val CONNECT_TIMEOUT_SECONDS = 30L
    const val READ_TIMEOUT_SECONDS = 60L
    const val WRITE_TIMEOUT_SECONDS = 60L
    const val CACHE_SIZE_BYTES = 10L * 1024 * 1024 // 10 MB
}
