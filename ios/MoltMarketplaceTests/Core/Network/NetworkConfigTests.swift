import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - NetworkConfigTests

@Suite("NetworkConfig Tests")
struct NetworkConfigTests {
    @Test("request timeout is 60 seconds")
    func test_timeoutIntervalForRequest_is60Seconds() {
        #expect(NetworkConfig.timeoutIntervalForRequest == 60)
    }

    @Test("resource timeout is 300 seconds")
    func test_timeoutIntervalForResource_is300Seconds() {
        #expect(NetworkConfig.timeoutIntervalForResource == 300)
    }

    @Test("memory cache capacity is 10 MB")
    func test_memoryCacheCapacity_is10MB() {
        let tenMB = 10_485_760
        #expect(NetworkConfig.memoryCacheCapacity == tenMB)
    }

    @Test("disk cache capacity is 50 MB")
    func test_diskCacheCapacity_is50MB() {
        let fiftyMB = 52_428_800
        #expect(NetworkConfig.diskCacheCapacity == fiftyMB)
    }

    @Test("resource timeout is greater than request timeout")
    func test_resourceTimeout_isGreaterThanRequestTimeout() {
        #expect(NetworkConfig.timeoutIntervalForResource > NetworkConfig.timeoutIntervalForRequest)
    }

    @Test("disk cache capacity is greater than memory cache capacity")
    func test_diskCapacity_isGreaterThanMemoryCapacity() {
        #expect(NetworkConfig.diskCacheCapacity > NetworkConfig.memoryCacheCapacity)
    }
}
