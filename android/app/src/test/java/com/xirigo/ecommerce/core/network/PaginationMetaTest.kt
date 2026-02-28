package com.xirigo.ecommerce.core.network

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class PaginationMetaTest {

    @Test
    fun `hasMore should be true when more items exist beyond current page`() {
        val meta = PaginationMeta(count = 100, limit = 20, offset = 0)
        assertThat(meta.hasMore).isTrue()
    }

    @Test
    fun `hasMore should be false when on last page`() {
        val meta = PaginationMeta(count = 40, limit = 20, offset = 20)
        assertThat(meta.hasMore).isFalse()
    }

    @Test
    fun `hasMore should be false when offset plus limit equals count`() {
        val meta = PaginationMeta(count = 20, limit = 20, offset = 0)
        assertThat(meta.hasMore).isFalse()
    }

    @Test
    fun `hasMore should be true when offset plus limit is less than count`() {
        val meta = PaginationMeta(count = 21, limit = 20, offset = 0)
        assertThat(meta.hasMore).isTrue()
    }

    @Test
    fun `hasMore should be false when count is zero`() {
        val meta = PaginationMeta(count = 0, limit = 20, offset = 0)
        assertThat(meta.hasMore).isFalse()
    }

    @Test
    fun `hasMore should be false when offset already exceeds count`() {
        val meta = PaginationMeta(count = 10, limit = 20, offset = 20)
        assertThat(meta.hasMore).isFalse()
    }

    @Test
    fun `hasMore should be true for mid-page navigation`() {
        val meta = PaginationMeta(count = 100, limit = 20, offset = 40)
        assertThat(meta.hasMore).isTrue()
    }

    @Test
    fun `hasMore should be false on last page of multi-page result`() {
        val meta = PaginationMeta(count = 100, limit = 20, offset = 80)
        assertThat(meta.hasMore).isFalse()
    }

    @Test
    fun `PaginationMeta equality should hold for same values`() {
        val meta1 = PaginationMeta(count = 50, limit = 10, offset = 20)
        val meta2 = PaginationMeta(count = 50, limit = 10, offset = 20)
        assertThat(meta1).isEqualTo(meta2)
    }

    @Test
    fun `hasMore with limit of 1 and count of 2 should be true`() {
        val meta = PaginationMeta(count = 2, limit = 1, offset = 0)
        assertThat(meta.hasMore).isTrue()
    }

    @Test
    fun `hasMore with limit of 1 and single item fetched at offset 0 should be false when count is 1`() {
        val meta = PaginationMeta(count = 1, limit = 1, offset = 0)
        assertThat(meta.hasMore).isFalse()
    }
}
