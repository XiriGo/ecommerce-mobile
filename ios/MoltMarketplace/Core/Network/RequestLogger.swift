import Foundation

#if DEBUG
import os

// MARK: - RequestLogger

enum RequestLogger {
    // MARK: - Internal

    static func logRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "nil"
        let headers = redactedHeaders(request.allHTTPHeaderFields ?? [:])
        let bodySize = request.httpBody?.count ?? 0

        logger.debug("---> \(method) \(url)")
        logger.debug("Headers: \(headers, privacy: .public)")
        if bodySize > 0 {
            logger.debug("Body: \(bodySize) bytes")
        }
    }

    static func logResponse(_ response: HTTPURLResponse, data: Data, duration: TimeInterval) {
        let url = response.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode
        let bodySize = data.count
        let durationMs = Int(duration * 1000)

        if (200 ... 299).contains(statusCode) {
            logger.info("<--- \(statusCode) \(url) (\(durationMs)ms, \(bodySize) bytes)")
        } else {
            logger.error("<--- \(statusCode) \(url) (\(durationMs)ms, \(bodySize) bytes)")
        }
    }

    static func logError(_ error: Error, url: String?) {
        let urlString = url ?? "nil"
        logger.error("<--- ERROR \(urlString): \(error.localizedDescription)")
    }

    // MARK: - Private

    private static let logger = Logger(subsystem: "com.molt.marketplace", category: "Network")

    private static func redactedHeaders(_ headers: [String: String]) -> String {
        var redacted = headers
        if redacted["Authorization"] != nil {
            redacted["Authorization"] = "Bearer <REDACTED>"
        }
        return redacted.description
    }
}
#endif
