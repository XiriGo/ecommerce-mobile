import Foundation

// MARK: - MedusaErrorDTO

struct MedusaErrorDTO: Decodable, Sendable {
    let type: String
    let message: String
    let code: String?

    // MARK: - Lifecycle

    init(type: String, message: String, code: String? = nil) {
        self.type = type
        self.message = message
        self.code = code
    }
}
