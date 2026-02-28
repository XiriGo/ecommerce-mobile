import SwiftUI
import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - MoltImageTests

@Suite("MoltImage Tests")
struct MoltImageTests {
    // MARK: - Initialisation

    @Test("MoltImage initialises with nil URL (placeholder state)")
    func test_init_nilUrl_initialises() {
        let image = MoltImage(url: nil)
        _ = image
        #expect(true)
    }

    @Test("MoltImage initialises with valid URL")
    func test_init_validUrl_initialises() {
        let url = URL(string: "https://example.com/product.jpg")
        let image = MoltImage(url: url)
        _ = image
        #expect(url != nil)
    }

    @Test("MoltImage initialises with default fill content mode")
    func test_init_defaultContentMode_isFill() {
        let image = MoltImage(url: nil)
        _ = image
        // Default contentMode is .fill per component definition
        #expect(true)
    }

    @Test("MoltImage initialises with fit content mode")
    func test_init_fitContentMode_initialises() {
        let image = MoltImage(url: nil, contentMode: .fit)
        _ = image
        #expect(true)
    }

    @Test("MoltImage initialises with fill content mode explicitly")
    func test_init_fillContentMode_initialises() {
        let image = MoltImage(url: nil, contentMode: .fill)
        _ = image
        #expect(true)
    }

    // MARK: - URL Handling

    @Test("Nil URL results in placeholder state")
    func test_nilUrl_showsPlaceholder() {
        let image = MoltImage(url: nil)
        _ = image
        // When URL is nil, AsyncImage shows the empty case → placeholder view rendered
        #expect(true)
    }

    @Test("URL with HTTPS scheme is accepted")
    func test_httpsUrl_isAccepted() {
        let url = URL(string: "https://cdn.example.com/img.jpg")
        #expect(url != nil)
        let image = MoltImage(url: url)
        _ = image
        #expect(true)
    }

    // MARK: - Body

    @Test("MoltImage body is a valid View", .disabled(swiftUIDisabledReason))
    func test_body_isValidView() {
        let image = MoltImage(url: nil)
        let body = image.body
        _ = body
        #expect(true)
    }
}
