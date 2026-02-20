import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - MedusaErrorDTOTests

@Suite("MedusaErrorDTO Tests")
struct MedusaErrorDTOTests {
    // MARK: - Full Decode

    @Test("decodes full error with type message and code")
    func test_decode_fullError_withTypeMessageAndCode() throws {
        let json = """
        {
            "type": "not_found",
            "message": "Product with id prod_xxx was not found",
            "code": "RESOURCE_NOT_FOUND"
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder.api.decode(MedusaErrorDTO.self, from: json)

        #expect(dto.type == "not_found")
        #expect(dto.message == "Product with id prod_xxx was not found")
        #expect(dto.code == "RESOURCE_NOT_FOUND")
    }

    @Test("decodes error without optional code field")
    func test_decode_partialError_withoutCode_codeIsNil() throws {
        let json = """
        {
            "type": "unauthorized",
            "message": "Unauthorized access"
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder.api.decode(MedusaErrorDTO.self, from: json)

        #expect(dto.type == "unauthorized")
        #expect(dto.message == "Unauthorized access")
        #expect(dto.code == nil)
    }

    @Test("decodes server error with null code as nil")
    func test_decode_errorWithNullCode_codeIsNil() throws {
        let json = """
        {
            "type": "internal_server_error",
            "message": "An internal server error occurred",
            "code": null
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder.api.decode(MedusaErrorDTO.self, from: json)

        #expect(dto.type == "internal_server_error")
        #expect(dto.message == "An internal server error occurred")
        #expect(dto.code == nil)
    }

    @Test("throws error for malformed JSON missing required fields")
    func test_decode_malformedJSON_missingRequiredFields_throwsError() {
        let json = """
        {
            "type": "not_found"
        }
        """.data(using: .utf8)!

        #expect(throws: (any Error).self) {
            try JSONDecoder.api.decode(MedusaErrorDTO.self, from: json)
        }
    }

    @Test("throws error for completely malformed JSON")
    func test_decode_invalidJSON_throwsError() {
        let json = "not valid json".data(using: .utf8)!

        #expect(throws: (any Error).self) {
            try JSONDecoder.api.decode(MedusaErrorDTO.self, from: json)
        }
    }

    @Test("throws error for empty JSON object missing required fields")
    func test_decode_emptyJSON_throwsError() {
        let json = "{}".data(using: .utf8)!

        #expect(throws: (any Error).self) {
            try JSONDecoder.api.decode(MedusaErrorDTO.self, from: json)
        }
    }

    // MARK: - Direct Initialization

    @Test("init with all fields stores correctly")
    func test_init_allFields_areStoredCorrectly() {
        let dto = MedusaErrorDTO(type: "not_found", message: "Not found", code: "NF_001")
        #expect(dto.type == "not_found")
        #expect(dto.message == "Not found")
        #expect(dto.code == "NF_001")
    }

    @Test("init without code defaults to nil")
    func test_init_withoutCode_codeIsNil() {
        let dto = MedusaErrorDTO(type: "invalid_data", message: "Invalid email")
        #expect(dto.type == "invalid_data")
        #expect(dto.message == "Invalid email")
        #expect(dto.code == nil)
    }

    // MARK: - Various Error Types

    @Test("decodes invalid_data error type for validation errors")
    func test_decode_invalidDataType_isDecodedCorrectly() throws {
        let json = """
        {
            "type": "invalid_data",
            "message": "Email is already in use",
            "code": "EMAIL_DUPLICATE"
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder.api.decode(MedusaErrorDTO.self, from: json)
        #expect(dto.type == "invalid_data")
        #expect(dto.code == "EMAIL_DUPLICATE")
    }

    @Test("decodes rate limit error type")
    func test_decode_rateLimitError_isDecodedCorrectly() throws {
        let json = """
        {
            "type": "rate_limit",
            "message": "Too many requests. Please try again later."
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder.api.decode(MedusaErrorDTO.self, from: json)
        #expect(dto.type == "rate_limit")
        #expect(dto.message == "Too many requests. Please try again later.")
    }
}
