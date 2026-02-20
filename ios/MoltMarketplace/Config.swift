import Foundation

internal enum Config {
    internal static let apiBaseURL: URL = {
        guard let url = apiBaseURLString else {
            fatalError("Invalid API base URL string. Check Config.apiBaseURL configuration.")
        }
        return url
    }()

    internal static let bundleVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }()

    internal static let buildNumber: String = {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }()

    // MARK: - Private

    private static var apiBaseURLString: URL? {
        #if DEBUG
        URL(string: "https://api-dev.molt.mt")
        #elseif STAGING
        URL(string: "https://api-staging.molt.mt")
        #else
        URL(string: "https://api.molt.mt")
        #endif
    }
}
