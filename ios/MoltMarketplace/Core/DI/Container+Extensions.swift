import Factory
import Foundation

// MARK: - Network

extension Container {
    var tokenProvider: Factory<any TokenProvider> {
        self { NoOpTokenProvider() }
            .singleton
    }

    var apiClient: Factory<APIClient> {
        self {
            APIClient(
                baseURL: Config.apiBaseURL,
                tokenProvider: self.tokenProvider()
            )
        }
        .singleton
    }

    var networkMonitor: Factory<NetworkMonitor> {
        self { NetworkMonitor() }
            .singleton
    }
}
