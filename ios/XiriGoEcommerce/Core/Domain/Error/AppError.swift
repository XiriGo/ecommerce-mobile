import Foundation

// MARK: - AppError

enum AppError: Error, Equatable {
    case network(message: String = "Network error")
    case server(code: Int, message: String)
    case notFound(message: String = "Not found")
    case unauthorized(message: String = "Unauthorized")
    case unknown(message: String = "Unknown error")
}

// MARK: - User Message Mapping

extension Error {
    /// Returns localized user-facing message from String Catalog
    var toUserMessage: String {
        guard let appError = self as? AppError else {
            return String(localized: "common_error_unknown")
        }
        switch appError {
            case .network:
                return String(localized: "common_error_network")

            case .server:
                return String(localized: "common_error_server")

            case .unauthorized:
                return String(localized: "common_error_unauthorized")

            case .notFound:
                return String(localized: "common_error_not_found")

            case .unknown:
                return String(localized: "common_error_unknown")
        }
    }
}
