import Foundation

enum Config {
    static let apiBaseURL: URL = {
        #if DEBUG
        return URL(string: "https://api-dev.molt.mt")!
        #elseif STAGING
        return URL(string: "https://api-staging.molt.mt")!
        #else
        return URL(string: "https://api.molt.mt")!
        #endif
    }()

    static let bundleVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }()

    static let buildNumber: String = {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }()
}
