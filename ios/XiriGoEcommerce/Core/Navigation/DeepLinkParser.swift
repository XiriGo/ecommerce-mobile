import Foundation

// MARK: - DeepLinkParser

/// Parses deep link URLs into Route values.
/// Supports `molt://` custom scheme and `https://molt.mt/` universal links.
enum DeepLinkParser {
    // MARK: - Internal

    /// Parses a URL into a Route. Returns nil for invalid or unrecognized links.
    static func parse(_ url: URL) -> Route? {
        let scheme = url.scheme?.lowercased() ?? ""
        let host = url.host?.lowercased() ?? ""

        switch scheme {
        case "molt":
            return parseMoltScheme(host: host, pathComponents: pathComponents(from: url))

        case "https" where host == "molt.mt":
            return parseUniversalLink(pathComponents: pathComponents(from: url))

        default:
            return nil
        }
    }

    // MARK: - Private

    private static func pathComponents(from url: URL) -> [String] {
        url.pathComponents.filter { $0 != "/" }
    }

    private static func parseMoltScheme(host: String, pathComponents: [String]) -> Route? {
        switch host {
        case "product":
            return parseProductRoute(pathComponents: pathComponents)

        case "category":
            return parseCategoryRoute(pathComponents: pathComponents)

        case "cart":
            return .cart

        case "order":
            return parseOrderRoute(pathComponents: pathComponents)

        case "profile":
            return .profile

        default:
            return nil
        }
    }

    private static func parseUniversalLink(pathComponents: [String]) -> Route? {
        guard let first = pathComponents.first else { return nil }

        switch first {
        case "product":
            return parseProductRoute(pathComponents: Array(pathComponents.dropFirst()))

        case "category":
            return parseCategoryRoute(pathComponents: Array(pathComponents.dropFirst()))

        default:
            return nil
        }
    }

    private static func parseProductRoute(pathComponents: [String]) -> Route? {
        guard let productId = pathComponents.first, !productId.isEmpty else { return nil }
        return .productDetail(productId: productId)
    }

    private static func parseCategoryRoute(pathComponents: [String]) -> Route? {
        guard let categoryId = pathComponents.first, !categoryId.isEmpty else { return nil }
        return .categoryProducts(categoryId: categoryId, categoryName: "")
    }

    private static func parseOrderRoute(pathComponents: [String]) -> Route? {
        guard let orderId = pathComponents.first, !orderId.isEmpty else { return nil }
        return .orderDetail(orderId: orderId)
    }
}
