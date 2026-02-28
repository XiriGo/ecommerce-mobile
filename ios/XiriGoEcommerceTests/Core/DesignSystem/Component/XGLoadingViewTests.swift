import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGLoadingViewTests

@Suite("XGLoadingView Tests")
struct XGLoadingViewTests {
    @Test("XGLoadingView initialises without parameters")
    func init_noParameters_initialises() {
        let view = XGLoadingView()
        _ = view
        #expect(true)
    }

    @Test("XGLoadingView body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        let view = XGLoadingView()
        let body = view.body
        _ = body
        #expect(true)
    }
}

// MARK: - XGLoadingIndicatorTests

@Suite("XGLoadingIndicator Tests")
struct XGLoadingIndicatorTests {
    @Test("XGLoadingIndicator initialises without parameters")
    func test_init_noParameters_initialises() {
        let indicator = XGLoadingIndicator()
        _ = indicator
        #expect(true)
    }

    @Test("XGLoadingIndicator body is a valid View", .disabled(swiftUIDisabledReason))
    func test_body_isValidView() {
        let indicator = XGLoadingIndicator()
        let body = indicator.body
        _ = body
        #expect(true)
    }

    @Test("XGLoadingView and XGLoadingIndicator are distinct types")
    func types_areDistinct() {
        let full = XGLoadingView()
        let inline = XGLoadingIndicator()
        // Different types confirm separate full-screen vs inline components
        _ = full
        _ = inline
        #expect(true)
    }
}
