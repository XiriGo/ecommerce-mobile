import Foundation
import Testing
@testable import MoltMarketplace

// MARK: - JSONCodersTests

@Suite("JSONCoders Tests")
struct JSONCodersTests {
    // MARK: - Snake Case Decoding

    @Test("decoder converts snake_case JSON keys to camelCase properties")
    func test_decode_snakeCaseKeys_areConvertedToCamelCase() throws {
        struct Response: Decodable {
            let firstName: String
            let lastName: String
            let createdAt: String
        }

        let json = """
        {
            "first_name": "John",
            "last_name": "Doe",
            "created_at": "2025-01-15T10:30:00Z"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder.api.decode(Response.self, from: json)
        #expect(response.firstName == "John")
        #expect(response.lastName == "Doe")
        #expect(response.createdAt == "2025-01-15T10:30:00Z")
    }

    @Test("decoder handles nested objects with snake_case keys")
    func test_decode_nestedSnakeCaseKeys_areConvertedCorrectly() throws {
        struct Address: Decodable {
            let streetAddress: String
            let postalCode: String
        }
        struct Response: Decodable {
            let shippingAddress: Address
        }

        let json = """
        {
            "shipping_address": {
                "street_address": "123 Main St",
                "postal_code": "12345"
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder.api.decode(Response.self, from: json)
        #expect(response.shippingAddress.streetAddress == "123 Main St")
        #expect(response.shippingAddress.postalCode == "12345")
    }

    // MARK: - Date Decoding

    @Test("decoder decodes ISO 8601 date strings correctly")
    func test_decode_iso8601DateString_isDecodedAsDate() throws {
        struct Response: Decodable {
            let createdAt: Date
        }

        let json = """
        {
            "created_at": "2025-01-15T10:30:00Z"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder.api.decode(Response.self, from: json)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: response.createdAt)
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 15)
        #expect(components.hour == 10)
        #expect(components.minute == 30)
        #expect(components.second == 0)
    }

    @Test("decoder throws for non-ISO8601 date strings")
    func test_decode_invalidDateString_throwsError() {
        struct Response: Decodable {
            let createdAt: Date
        }

        let json = """
        {
            "created_at": "January 15, 2025"
        }
        """.data(using: .utf8)!

        #expect(throws: (any Error).self) {
            try JSONDecoder.api.decode(Response.self, from: json)
        }
    }

    // MARK: - Encoder: snake_case Encoding

    @Test("encoder converts camelCase properties to snake_case JSON keys")
    func test_encode_camelCaseProperties_areConvertedToSnakeCaseKeys() throws {
        struct Request: Encodable {
            let firstName: String
            let currencyCode: String
        }

        let request = Request(firstName: "Jane", currencyCode: "EUR")
        let data = try JSONEncoder.api.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["first_name"] as? String == "Jane")
        #expect(json?["currency_code"] as? String == "EUR")
    }

    @Test("encoder converts date to ISO 8601 string")
    func test_encode_date_isEncodedAsISO8601String() throws {
        struct Request: Encodable {
            let createdAt: Date
        }

        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 15
        components.hour = 12
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(identifier: "UTC")

        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!
        let request = Request(createdAt: date)

        let data = try JSONEncoder.api.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        let dateString = json?["created_at"] as? String
        #expect(dateString != nil)
        #expect(dateString?.contains("2025") == true)
        #expect(dateString?.contains("06") == true || dateString?.contains("T") == true)
    }

    // MARK: - Round-trip

    @Test("encode then decode produces same values")
    func test_encodeAndDecode_roundTrip_preservesValues() throws {
        struct Model: Codable, Equatable {
            let productId: String
            let variantTitle: String
            let unitPrice: Int
        }

        let original = Model(productId: "prod_123", variantTitle: "Red XL", unitPrice: 1999)
        let encoded = try JSONEncoder.api.encode(original)
        let decoded = try JSONDecoder.api.decode(Model.self, from: encoded)

        #expect(decoded == original)
    }

    @Test("decode ignores unknown keys in JSON")
    func test_decode_unknownKeys_areIgnored() throws {
        struct Response: Decodable {
            let name: String
        }

        let json = """
        {
            "name": "Test",
            "unknown_field": "some value",
            "another_unknown": 42
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder.api.decode(Response.self, from: json)
        #expect(response.name == "Test")
    }
}
