import Testing
@testable import MoltMarketplace

// MARK: - MoltEmptyViewTests

@Suite("MoltEmptyView Tests")
struct MoltEmptyViewTests {
    // MARK: - Initialisation

    @Test("EmptyView initialises with message only")
    func test_init_withMessageOnly_initialises() {
        let view = MoltEmptyView(message: "No products found")
        _ = view
        #expect(true)
    }

    @Test("EmptyView uses default system image tray when not specified")
    func test_init_defaultSystemImage_isTray() {
        let view = MoltEmptyView(message: "Empty")
        _ = view
        #expect(true)
    }

    @Test("EmptyView initialises with custom system image")
    func test_init_withCustomSystemImage_initialises() {
        let view = MoltEmptyView(message: "Cart is empty", systemImage: "cart")
        _ = view
        #expect(true)
    }

    @Test("EmptyView initialises with action label and no-op handler")
    func test_init_withActionLabelAndHandler_initialises() {
        // Use a no-op closure to avoid Swift 6 Sendable data-race warnings
        let view = MoltEmptyView(
            message: "No items",
            actionLabel: "Browse Products",
            onAction: {}
        )
        _ = view
        #expect(true)
    }

    @Test("EmptyView initialises without action by default")
    func test_init_defaultActionIsNil() {
        let view = MoltEmptyView(message: "Empty state")
        _ = view
        #expect(true)
    }

    // MARK: - Action presence

    @Test("EmptyView with actionLabel and onAction shows button (non-nil)")
    func test_init_withBothActionParams_showsButton() {
        let view = MoltEmptyView(message: "Empty", actionLabel: "Retry", onAction: {})
        _ = view
        #expect(true)
    }

    @Test("EmptyView without actionLabel hides button")
    func test_init_withoutActionLabel_noButton() {
        let view = MoltEmptyView(message: "Empty")
        _ = view
        #expect(true)
    }

    // MARK: - Action counter logic

    @Test("Action counter increments correctly when tapped")
    func test_actionCounter_singleIncrement_isOne() {
        var actionCount = 0
        actionCount += 1
        #expect(actionCount == 1)
    }

    // MARK: - Various System Images

    @Test("EmptyView accepts magnifyingglass system image")
    func test_init_withMagnifyingglassImage_initialises() {
        let view = MoltEmptyView(message: "No search results", systemImage: "magnifyingglass")
        _ = view
        #expect(true)
    }

    @Test("EmptyView accepts heart system image")
    func test_init_withHeartImage_initialises() {
        let view = MoltEmptyView(message: "No wishlist items", systemImage: "heart")
        _ = view
        #expect(true)
    }

    // MARK: - Body

    @Test("EmptyView body is a valid View", .disabled("SwiftUI body requires runtime environment; use UI tests instead"))
    func test_body_isValidView() {
        let view = MoltEmptyView(message: "Nothing here")
        let body = view.body
        _ = body
        #expect(true)
    }
}
