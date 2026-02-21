import Foundation
import Network

// MARK: - NetworkMonitor

@Observable
final class NetworkMonitor: @unchecked Sendable {
    // MARK: - Lifecycle

    init() {
        let monitor = NWPathMonitor()
        self.monitor = monitor
        let queue = DispatchQueue(label: "com.molt.marketplace.networkMonitor")

        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            Task { @MainActor [weak self] in
                self?.isConnected = connected
            }
        }

        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    // MARK: - Internal

    @MainActor
    private(set) var isConnected: Bool = true

    // MARK: - Private

    private let monitor: NWPathMonitor
}
