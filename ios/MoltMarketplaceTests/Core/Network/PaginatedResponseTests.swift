import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - PaginatedResponseTests

@Suite("PaginationMeta Tests")
struct PaginatedResponseTests {
    // MARK: - hasMore Logic

    @Test("hasMore is true when more items exist beyond current page")
    func test_hasMore_offsetPlusLimitLessThanCount_returnsTrue() {
        // offset=0, limit=20, count=50 → 0+20=20 < 50 → hasMore = true
        let meta = PaginationMeta(count: 50, limit: 20, offset: 0)
        #expect(meta.hasMore == true)
    }

    @Test("hasMore is true when on a middle page")
    func test_hasMore_middlePage_returnsTrue() {
        // offset=20, limit=20, count=50 → 20+20=40 < 50 → hasMore = true
        let meta = PaginationMeta(count: 50, limit: 20, offset: 20)
        #expect(meta.hasMore == true)
    }

    @Test("hasMore is false when on the last full page")
    func test_hasMore_lastFullPage_returnsFalse() {
        // offset=40, limit=20, count=50 → 40+20=60 >= 50 → hasMore = false
        let meta = PaginationMeta(count: 50, limit: 20, offset: 40)
        #expect(meta.hasMore == false)
    }

    @Test("hasMore is false when count equals limit")
    func test_hasMore_countEqualsLimit_returnsFalse() {
        // offset=0, limit=20, count=20 → 0+20=20 >= 20 → hasMore = false
        let meta = PaginationMeta(count: 20, limit: 20, offset: 0)
        #expect(meta.hasMore == false)
    }

    @Test("hasMore is false when count is less than limit")
    func test_hasMore_countLessThanLimit_returnsFalse() {
        // offset=0, limit=20, count=5 → 0+20=20 >= 5 → hasMore = false
        let meta = PaginationMeta(count: 5, limit: 20, offset: 0)
        #expect(meta.hasMore == false)
    }

    @Test("hasMore is false when count is zero")
    func test_hasMore_emptyResults_returnsFalse() {
        let meta = PaginationMeta(count: 0, limit: 20, offset: 0)
        #expect(meta.hasMore == false)
    }

    @Test("hasMore is true on first page when count exceeds limit")
    func test_hasMore_firstPage_countExceedsLimit_returnsTrue() {
        let meta = PaginationMeta(count: 100, limit: 20, offset: 0)
        #expect(meta.hasMore == true)
    }

    @Test("hasMore is false when fetched exactly to end")
    func test_hasMore_offsetPlusLimitEqualsCount_returnsFalse() {
        // offset=80, limit=20, count=100 → 80+20=100 >= 100 → hasMore = false
        let meta = PaginationMeta(count: 100, limit: 20, offset: 80)
        #expect(meta.hasMore == false)
    }

    @Test("hasMore boundary: exactly one more item remains")
    func test_hasMore_oneMoreItemRemains_returnsTrue() {
        // offset=0, limit=20, count=21 → 0+20=20 < 21 → hasMore = true
        let meta = PaginationMeta(count: 21, limit: 20, offset: 0)
        #expect(meta.hasMore == true)
    }

    @Test("hasMore boundary: last item on current page is the last total item")
    func test_hasMore_lastItemExactlyAtEnd_returnsFalse() {
        // offset=0, limit=20, count=20 → 0+20=20 >= 20 → hasMore = false
        let meta = PaginationMeta(count: 20, limit: 20, offset: 0)
        #expect(meta.hasMore == false)
    }

    // MARK: - Decodable

    @Test("decodes PaginationMeta from JSON correctly")
    func test_decode_validJSON_isDecodedCorrectly() throws {
        let json = Data("""
        {
            "count": 142,
            "limit": 20,
            "offset": 20
        }
        """.utf8)

        let meta = try JSONDecoder.api.decode(PaginationMeta.self, from: json)

        #expect(meta.count == 142)
        #expect(meta.limit == 20)
        #expect(meta.offset == 20)
        #expect(meta.hasMore == true)
    }

    @Test("decodes PaginationMeta and correctly computes hasMore false")
    func test_decode_lastPage_hasMoreIsFalse() throws {
        let json = Data("""
        {
            "count": 142,
            "limit": 20,
            "offset": 140
        }
        """.utf8)

        let meta = try JSONDecoder.api.decode(PaginationMeta.self, from: json)
        // 140 + 20 = 160 >= 142 → hasMore = false
        #expect(meta.hasMore == false)
    }

    // MARK: - Equatable

    @Test("two PaginationMeta with same values are equal")
    func test_equatable_sameValues_areEqual() {
        let metaA = PaginationMeta(count: 50, limit: 20, offset: 0)
        let metaB = PaginationMeta(count: 50, limit: 20, offset: 0)
        #expect(metaA == metaB)
    }

    @Test("two PaginationMeta with different counts are not equal")
    func test_equatable_differentCount_areNotEqual() {
        let metaA = PaginationMeta(count: 50, limit: 20, offset: 0)
        let metaB = PaginationMeta(count: 100, limit: 20, offset: 0)
        #expect(metaA != metaB)
    }
}
