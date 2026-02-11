import Testing
import Foundation
@testable import MoltMarketplace

@Suite("Localization Tests")
struct LocalizableTests {

    // MARK: - Language Support

    @Test("English localization is available")
    func testEnglishLocalizationExists() {
        let appName = String(localized: "app_name", locale: Locale(identifier: "en"))
        #expect(!appName.isEmpty)
        #expect(appName == "Molt Marketplace")
    }

    @Test("Maltese localization is available")
    func testMalteseLocalizationExists() {
        let appName = String(localized: "app_name", locale: Locale(identifier: "mt"))
        #expect(!appName.isEmpty)
        #expect(appName == "Molt Marketplace")
    }

    @Test("Turkish localization is available")
    func testTurkishLocalizationExists() {
        let appName = String(localized: "app_name", locale: Locale(identifier: "tr"))
        #expect(!appName.isEmpty)
        #expect(appName == "Molt Marketplace")
    }

    // MARK: - Common Strings

    @Test("Retry button string exists for all languages")
    func testRetryButtonExists() {
        let enRetry = String(localized: "common_retry_button", locale: Locale(identifier: "en"))
        let mtRetry = String(localized: "common_retry_button", locale: Locale(identifier: "mt"))
        let trRetry = String(localized: "common_retry_button", locale: Locale(identifier: "tr"))

        #expect(enRetry == "Retry")
        #expect(mtRetry == "Erga' ipprova")
        #expect(trRetry == "Tekrar Dene")
    }

    @Test("Loading message exists for all languages")
    func testLoadingMessageExists() {
        let enLoading = String(localized: "common_loading_message", locale: Locale(identifier: "en"))
        let mtLoading = String(localized: "common_loading_message", locale: Locale(identifier: "mt"))
        let trLoading = String(localized: "common_loading_message", locale: Locale(identifier: "tr"))

        #expect(enLoading == "Loading...")
        #expect(mtLoading == "Qed jillowdja...")
        #expect(trLoading == "Yukleniyor...")
    }

    // MARK: - Error Messages

    @Test("Network error message exists for all languages")
    func testNetworkErrorExists() {
        let enError = String(localized: "common_error_network", locale: Locale(identifier: "en"))
        let mtError = String(localized: "common_error_network", locale: Locale(identifier: "mt"))
        let trError = String(localized: "common_error_network", locale: Locale(identifier: "tr"))

        #expect(enError == "Connection error. Please check your internet.")
        #expect(!mtError.isEmpty)
        #expect(!trError.isEmpty)
    }

    @Test("Server error message exists for all languages")
    func testServerErrorExists() {
        let enError = String(localized: "common_error_server", locale: Locale(identifier: "en"))
        let mtError = String(localized: "common_error_server", locale: Locale(identifier: "mt"))
        let trError = String(localized: "common_error_server", locale: Locale(identifier: "tr"))

        #expect(enError == "Something went wrong. Please try again later.")
        #expect(!mtError.isEmpty)
        #expect(!trError.isEmpty)
    }

    @Test("Unauthorized error message exists for all languages")
    func testUnauthorizedErrorExists() {
        let enError = String(localized: "common_error_unauthorized", locale: Locale(identifier: "en"))
        let mtError = String(localized: "common_error_unauthorized", locale: Locale(identifier: "mt"))
        let trError = String(localized: "common_error_unauthorized", locale: Locale(identifier: "tr"))

        #expect(enError == "Please log in to continue.")
        #expect(!mtError.isEmpty)
        #expect(!trError.isEmpty)
    }

    @Test("Not found error message exists for all languages")
    func testNotFoundErrorExists() {
        let enError = String(localized: "common_error_not_found", locale: Locale(identifier: "en"))
        let mtError = String(localized: "common_error_not_found", locale: Locale(identifier: "mt"))
        let trError = String(localized: "common_error_not_found", locale: Locale(identifier: "tr"))

        #expect(enError == "The requested item was not found.")
        #expect(!mtError.isEmpty)
        #expect(!trError.isEmpty)
    }

    @Test("Unknown error message exists for all languages")
    func testUnknownErrorExists() {
        let enError = String(localized: "common_error_unknown", locale: Locale(identifier: "en"))
        let mtError = String(localized: "common_error_unknown", locale: Locale(identifier: "mt"))
        let trError = String(localized: "common_error_unknown", locale: Locale(identifier: "tr"))

        #expect(enError == "An unexpected error occurred.")
        #expect(!mtError.isEmpty)
        #expect(!trError.isEmpty)
    }

    // MARK: - Button Labels

    @Test("OK button exists for all languages")
    func testOKButtonExists() {
        let enOK = String(localized: "common_ok_button", locale: Locale(identifier: "en"))
        let mtOK = String(localized: "common_ok_button", locale: Locale(identifier: "mt"))
        let trOK = String(localized: "common_ok_button", locale: Locale(identifier: "tr"))

        #expect(enOK == "OK")
        #expect(mtOK == "OK")
        #expect(trOK == "Tamam")
    }

    @Test("Cancel button exists for all languages")
    func testCancelButtonExists() {
        let enCancel = String(localized: "common_cancel_button", locale: Locale(identifier: "en"))
        let mtCancel = String(localized: "common_cancel_button", locale: Locale(identifier: "mt"))
        let trCancel = String(localized: "common_cancel_button", locale: Locale(identifier: "tr"))

        #expect(enCancel == "Cancel")
        #expect(mtCancel == "Ikkanella")
        #expect(trCancel == "Iptal")
    }

    @Test("Close button exists for all languages")
    func testCloseButtonExists() {
        let enClose = String(localized: "common_close_button", locale: Locale(identifier: "en"))
        let mtClose = String(localized: "common_close_button", locale: Locale(identifier: "mt"))
        let trClose = String(localized: "common_close_button", locale: Locale(identifier: "tr"))

        #expect(enClose == "Close")
        #expect(mtClose == "Aghlaq")
        #expect(trClose == "Kapat")
    }

    @Test("Search placeholder exists for all languages")
    func testSearchPlaceholderExists() {
        let enSearch = String(localized: "common_search_placeholder", locale: Locale(identifier: "en"))
        let mtSearch = String(localized: "common_search_placeholder", locale: Locale(identifier: "mt"))
        let trSearch = String(localized: "common_search_placeholder", locale: Locale(identifier: "tr"))

        #expect(enSearch == "Search")
        #expect(mtSearch == "Fittex")
        #expect(trSearch == "Ara")
    }

    // MARK: - Localization Completeness

    @Test("All common strings are translated to Maltese")
    func testMalteseCompleteness() {
        let keys = [
            "app_name", "common_retry_button", "common_loading_message",
            "common_error_network", "common_error_server", "common_error_unauthorized",
            "common_error_not_found", "common_error_unknown", "common_ok_button",
            "common_cancel_button", "common_close_button", "common_search_placeholder"
        ]

        for key in keys {
            let translated = String(localized: String.LocalizationValue(key), locale: Locale(identifier: "mt"))
            #expect(!translated.isEmpty, "Missing Maltese translation for key: \(key)")
        }
    }

    @Test("All common strings are translated to Turkish")
    func testTurkishCompleteness() {
        let keys = [
            "app_name", "common_retry_button", "common_loading_message",
            "common_error_network", "common_error_server", "common_error_unauthorized",
            "common_error_not_found", "common_error_unknown", "common_ok_button",
            "common_cancel_button", "common_close_button", "common_search_placeholder"
        ]

        for key in keys {
            let translated = String(localized: String.LocalizationValue(key), locale: Locale(identifier: "tr"))
            #expect(!translated.isEmpty, "Missing Turkish translation for key: \(key)")
        }
    }
}
