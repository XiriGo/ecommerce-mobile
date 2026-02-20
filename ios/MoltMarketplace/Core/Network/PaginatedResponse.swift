import Foundation

// MARK: - PaginationMeta

/// Convenience type for extracting pagination state from Medusa list responses.
/// Each feature response DTO embeds its own resource array alongside
/// count/limit/offset fields. This struct is used by repositories to
/// pass pagination info to ViewModels.
struct PaginationMeta: Decodable, Equatable, Sendable {
    let count: Int
    let limit: Int
    let offset: Int

    // MARK: - Internal

    var hasMore: Bool {
        offset + limit < count
    }
}
