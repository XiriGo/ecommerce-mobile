import Foundation
import Testing
@testable import MoltMarketplace

@Suite("Localization Tests")
struct LocalizableTests {
    // MARK: - Internal

    // MARK: - Language Support

    @Test("English localization is available")
    func englishLocalizationExists() {
        let appName = localizedString("app_name", language: "en")
        #expect(appName != nil)
        #expect(appName == "Molt Marketplace")
    }

    @Test("Maltese localization is available")
    func malteseLocalizationExists() {
        let appName = localizedString("app_name", language: "mt")
        #expect(appName != nil)
        #expect(appName == "Molt Marketplace")
    }

    @Test("Turkish localization is available")
    func turkishLocalizationExists() {
        let appName = localizedString("app_name", language: "tr")
        #expect(appName != nil)
        #expect(appName == "Molt Marketplace")
    }

    // MARK: - Common Strings

    @Test("Retry button string exists for all languages")
    func retryButtonExists() {
        #expect(localizedString("common_retry_button", language: "en") == "Retry")
        #expect(localizedString("common_retry_button", language: "mt") == "Erġa' pprova")
        #expect(localizedString("common_retry_button", language: "tr") == "Tekrar Dene")
    }

    @Test("Loading message exists for all languages")
    func loadingMessageExists() {
        #expect(localizedString("common_loading_message", language: "en") == "Loading...")
        #expect(localizedString("common_loading_message", language: "mt") == "Qed jillowdja...")
        #expect(localizedString("common_loading_message", language: "tr") == "Yukleniyor...")
    }

    // MARK: - Error Messages

    @Test("Network error message exists for all languages")
    func networkErrorExists() {
        let expected = "Connection error. Please check your internet."
        #expect(localizedString("common_error_network", language: "en") == expected)
        #expect(localizedString("common_error_network", language: "mt") != nil)
        #expect(localizedString("common_error_network", language: "tr") != nil)
    }

    @Test("Server error message exists for all languages")
    func serverErrorExists() {
        let expected = "Something went wrong. Please try again later."
        #expect(localizedString("common_error_server", language: "en") == expected)
        #expect(localizedString("common_error_server", language: "mt") != nil)
        #expect(localizedString("common_error_server", language: "tr") != nil)
    }

    @Test("Unauthorized error message exists for all languages")
    func unauthorizedErrorExists() {
        #expect(
            localizedString("common_error_unauthorized", language: "en")
                == "Please log in to continue.",
        )
        #expect(localizedString("common_error_unauthorized", language: "mt") != nil)
        #expect(localizedString("common_error_unauthorized", language: "tr") != nil)
    }

    @Test("Not found error message exists for all languages")
    func notFoundErrorExists() {
        #expect(
            localizedString("common_error_not_found", language: "en")
                == "The requested item was not found.",
        )
        #expect(localizedString("common_error_not_found", language: "mt") != nil)
        #expect(localizedString("common_error_not_found", language: "tr") != nil)
    }

    @Test("Unknown error message exists for all languages")
    func unknownErrorExists() {
        #expect(
            localizedString("common_error_unknown", language: "en")
                == "An unexpected error occurred.",
        )
        #expect(localizedString("common_error_unknown", language: "mt") != nil)
        #expect(localizedString("common_error_unknown", language: "tr") != nil)
    }

    // MARK: - Button Labels

    @Test("OK button exists for all languages")
    func oKButtonExists() {
        #expect(localizedString("common_ok_button", language: "en") == "OK")
        #expect(localizedString("common_ok_button", language: "mt") == "OK")
        #expect(localizedString("common_ok_button", language: "tr") == "Tamam")
    }

    @Test("Cancel button exists for all languages")
    func cancelButtonExists() {
        #expect(localizedString("common_cancel_button", language: "en") == "Cancel")
        #expect(localizedString("common_cancel_button", language: "mt") == "Ikkanella")
        #expect(localizedString("common_cancel_button", language: "tr") == "Iptal")
    }

    @Test("Close button exists for all languages")
    func closeButtonExists() {
        #expect(localizedString("common_close_button", language: "en") == "Close")
        #expect(localizedString("common_close_button", language: "mt") == "Agħlaq")
        #expect(localizedString("common_close_button", language: "tr") == "Kapat")
    }

    @Test("Search placeholder exists for all languages")
    func searchPlaceholderExists() {
        #expect(localizedString("common_search_placeholder", language: "en") == "Search")
        #expect(localizedString("common_search_placeholder", language: "mt") == "Fittex")
        #expect(localizedString("common_search_placeholder", language: "tr") == "Ara")
    }

    // MARK: - Localization Completeness

    @Test("All common strings are translated to Maltese")
    func malteseCompleteness() {
        let keys = [
            "app_name", "common_retry_button", "common_loading_message",
            "common_error_network", "common_error_server", "common_error_unauthorized",
            "common_error_not_found", "common_error_unknown", "common_ok_button",
            "common_cancel_button", "common_close_button", "common_search_placeholder",
        ]

        for key in keys {
            let translated = localizedString(key, language: "mt")
            #expect(translated != nil, "Missing Maltese translation for key: \(key)")
        }
    }

    @Test("All common strings are translated to Turkish")
    func turkishCompleteness() {
        let keys = [
            "app_name", "common_retry_button", "common_loading_message",
            "common_error_network", "common_error_server", "common_error_unauthorized",
            "common_error_not_found", "common_error_unknown", "common_ok_button",
            "common_cancel_button", "common_close_button", "common_search_placeholder",
        ]

        for key in keys {
            let translated = localizedString(key, language: "tr")
            #expect(translated != nil, "Missing Turkish translation for key: \(key)")
        }
    }

    // MARK: - Private

    // MARK: - Helper

    private func localizedString(_ key: String, language: String) -> String? {
        guard
            let path = Bundle.main.path(
                forResource: language,
                ofType: "lproj",
            ), let bundle = Bundle(path: path)
        else {
            return nil
        }
        let value = bundle.localizedString(forKey: key, value: nil, table: nil)
        return value == key ? nil : value
    }
}
