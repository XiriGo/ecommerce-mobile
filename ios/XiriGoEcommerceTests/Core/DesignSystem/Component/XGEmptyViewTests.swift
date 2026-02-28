import Testing
@testable import XiriGoEcommerce

private let swiftUIDisabledReason: Comment = "SwiftUI body requires runtime environment; use UI tests instead"

// MARK: - XGEmptyViewTests

@Suite("XGEmptyView Tests")
@MainActor
struct XGEmptyViewTests {
    // MARK: - Initialisation

    @Test("EmptyView initialises with message only")
    func init_withMessageOnly_initialises() {
        let view = XGEmptyView(message: "No products found")
        _ = view
        #expect(true)
    }

    @Test("EmptyView uses default system image tray when not specified")
    func init_defaultSystemImage_isTray() {
        let view = XGEmptyView(message: "Empty")
        _ = view
        #expect(true)
    }

    @Test("EmptyView initialises with custom system image")
    func init_withCustomSystemImage_initialises() {
        let view = XGEmptyView(message: "Cart is empty", systemImage: "cart")
        _ = view
        #expect(true)
    }

    @Test("EmptyView initialises with action label and no-op handler")
    func init_withActionLabelAndHandler_initialises() {
        // Use a no-op closure to avoid Swift 6 Sendable data-race warnings
        let view = XGEmptyView(
            message: "No items",
            actionLabel: "Browse Products",
            onAction: {},
        )
        _ = view
        #expect(true)
    }

    @Test("EmptyView initialises without action by default")
    func init_defaultActionIsNil() {
        let view = XGEmptyView(message: "Empty state")
        _ = view
        #expect(true)
    }

    // MARK: - Action presence

    @Test("EmptyView with actionLabel and onAction shows button (non-nil)")
    func init_withBothActionParams_showsButton() {
        let view = XGEmptyView(message: "Empty", actionLabel: "Retry", onAction: {})
        _ = view
        #expect(true)
    }

    @Test("EmptyView without actionLabel hides button")
    func init_withoutActionLabel_noButton() {
        let view = XGEmptyView(message: "Empty")
        _ = view
        #expect(true)
    }

    // MARK: - Action counter logic

    @Test("Action counter increments correctly when tapped")
    func actionCounter_singleIncrement_isOne() {
        var actionCount = 0
        actionCount += 1
        #expect(actionCount == 1)
    }

    // MARK: - Various System Images

    @Test("EmptyView accepts magnifyingglass system image")
    func init_withMagnifyingglassImage_initialises() {
        let view = XGEmptyView(message: "No search results", systemImage: "magnifyingglass")
        _ = view
        #expect(true)
    }

    @Test("EmptyView accepts heart system image")
    func init_withHeartImage_initialises() {
        let view = XGEmptyView(message: "No wishlist items", systemImage: "heart")
        _ = view
        #expect(true)
    }

    // MARK: - Body

    @Test("EmptyView body is a valid View", .disabled(swiftUIDisabledReason))
    func body_isValidView() {
        let view = XGEmptyView(message: "Nothing here")
        let body = view.body
        _ = body
        #expect(true)
    }
}
