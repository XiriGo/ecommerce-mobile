import Foundation

// MARK: - NetworkConfig

enum NetworkConfig {
    static let timeoutIntervalForRequest: TimeInterval = 60
    static let timeoutIntervalForResource: TimeInterval = 300
    static let memoryCacheCapacity: Int = 10_485_760 // 10 MB
    static let diskCacheCapacity: Int = 52_428_800 // 50 MB
}
