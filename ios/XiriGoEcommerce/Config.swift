import Foundation

enum Config {
    // MARK: - Internal

    static let apiBaseURL: URL = {
        guard let url = apiBaseURLString else {
            fatalError("Invalid API base URL string. Check Config.apiBaseURL configuration.")
        }
        return url
    }()

    static let bundleVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

    static let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // MARK: - Private

    private static var apiBaseURLString: URL? {
        #if DEBUG
        URL(string: "https://api-dev.xirigo.com")
        #elseif STAGING
        URL(string: "https://api-staging.xirigo.com")
        #else
        URL(string: "https://api.xirigo.com")
        #endif
    }
}
