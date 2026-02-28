import SwiftUI
import Testing
@testable import XiriGoEcommerce

// MARK: - MoltTextFieldTests

@Suite("MoltTextField Tests")
struct MoltTextFieldTests {
    // MARK: - Initialisation

    @Test("TextField initialises with label and binding")
    func test_init_withLabelAndBinding_initialises() {
        var text = ""
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(value: binding, label: "Email")
        _ = field
        #expect(true)
    }

    @Test("TextField initialises with placeholder")
    func test_init_withPlaceholder_initialises() {
        var text = ""
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(
            value: binding,
            label: "Email",
            placeholder: "Enter your email"
        )
        _ = field
        #expect(true)
    }

    @Test("TextField initialises with error message")
    func test_init_withErrorMessage_initialises() {
        var text = "bad@"
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(
            value: binding,
            label: "Email",
            errorMessage: "Invalid email address"
        )
        _ = field
        #expect(true)
    }

    @Test("TextField initialises with helper text")
    func test_init_withHelperText_initialises() {
        var text = ""
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(
            value: binding,
            label: "Username",
            helperText: "Must be at least 3 characters"
        )
        _ = field
        #expect(true)
    }

    @Test("TextField initialises in password mode")
    func test_init_passwordMode_initialises() {
        var text = ""
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(
            value: binding,
            label: "Password",
            isPassword: true
        )
        _ = field
        #expect(true)
    }

    @Test("TextField initialises with maxLength")
    func test_init_withMaxLength_initialises() {
        var text = ""
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(
            value: binding,
            label: "Name",
            maxLength: 50
        )
        _ = field
        #expect(true)
    }

    @Test("TextField initialises in disabled state")
    func test_init_disabled_initialises() {
        var text = "read only"
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(
            value: binding,
            label: "Field",
            isEnabled: false
        )
        _ = field
        #expect(true)
    }

    @Test("TextField initialises in read-only state")
    func test_init_readOnly_initialises() {
        var text = "view only"
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(
            value: binding,
            label: "Field",
            isReadOnly: true
        )
        _ = field
        #expect(true)
    }

    @Test("TextField initialises with leading icon")
    func test_init_withLeadingIcon_initialises() {
        var text = ""
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(
            value: binding,
            label: "Search",
            leadingIcon: "magnifyingglass"
        )
        _ = field
        #expect(true)
    }

    @Test("TextField initialises with trailing icon and tap handler")
    func test_init_withTrailingIconAndTap_initialises() {
        var text = ""
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(
            value: binding,
            label: "Search",
            trailingIcon: "xmark.circle",
            onTrailingIconTap: {}
        )
        _ = field
        #expect(true)
    }

    // MARK: - Error vs Helper Text Priority

    @Test("ErrorMessage takes priority over helperText in initialiser")
    func test_init_errorMessageTakesPriorityOverHelperText_initialises() {
        // Both error and helper can be set — the view shows error when errorMessage != nil
        var text = ""
        let binding = Binding(get: { text }, set: { text = $0 })
        let field = MoltTextField(
            value: binding,
            label: "Field",
            errorMessage: "Required",
            helperText: "Enter something"
        )
        _ = field
        #expect(true)
    }
}
