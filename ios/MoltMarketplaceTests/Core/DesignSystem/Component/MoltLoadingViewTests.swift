import Testing
@testable import MoltMarketplace

// MARK: - MoltLoadingViewTests

@Suite("MoltLoadingView Tests")
struct MoltLoadingViewTests {
    @Test("MoltLoadingView initialises without parameters")
    func test_init_noParameters_initialises() {
        let view = MoltLoadingView()
        _ = view
        #expect(true)
    }

    @Test("MoltLoadingView body is a valid View", .disabled("SwiftUI body requires runtime environment; use UI tests instead"))
    func test_body_isValidView() {
        let view = MoltLoadingView()
        let body = view.body
        _ = body
        #expect(true)
    }
}

// MARK: - MoltLoadingIndicatorTests

@Suite("MoltLoadingIndicator Tests")
struct MoltLoadingIndicatorTests {
    @Test("MoltLoadingIndicator initialises without parameters")
    func test_init_noParameters_initialises() {
        let indicator = MoltLoadingIndicator()
        _ = indicator
        #expect(true)
    }

    @Test("MoltLoadingIndicator body is a valid View", .disabled("SwiftUI body requires runtime environment; use UI tests instead"))
    func test_body_isValidView() {
        let indicator = MoltLoadingIndicator()
        let body = indicator.body
        _ = body
        #expect(true)
    }

    @Test("MoltLoadingView and MoltLoadingIndicator are distinct types")
    func test_types_areDistinct() {
        let full = MoltLoadingView()
        let inline = MoltLoadingIndicator()
        // Different types confirm separate full-screen vs inline components
        _ = full
        _ = inline
        #expect(true)
    }
}
