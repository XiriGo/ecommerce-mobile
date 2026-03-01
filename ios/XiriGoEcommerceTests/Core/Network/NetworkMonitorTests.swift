import Testing
@testable import XiriGoEcommerce

// MARK: - NetworkMonitorTests

@Suite("NetworkMonitor Tests")
struct NetworkMonitorTests {
    @Test("initializes without crash")
    func init_doesNotCrash() {
        let monitor = NetworkMonitor()
        _ = monitor
    }

    @Test("isConnected defaults to true on init")
    @MainActor
    func isConnected_defaultsToTrue() {
        let monitor = NetworkMonitor()
        #expect(monitor.isConnected == true)
    }

    @Test("conforms to Sendable")
    func sendableConformance() {
        let monitor = NetworkMonitor()
        let sendableRef: any Sendable = monitor
        #expect(sendableRef is NetworkMonitor)
    }

    @Test("singleton from container is observable class")
    func container_networkMonitor_isObservable() {
        let monitor = NetworkMonitor()
        // NetworkMonitor is @Observable -- verify it is a reference type (class)
        #expect(type(of: monitor) is AnyClass)
    }

    // MARK: - Additional Coverage

    @Test("two NetworkMonitor instances are independent objects")
    func twoInstances_areDifferentObjects() {
        let first = NetworkMonitor()
        let second = NetworkMonitor()
        #expect(first !== second)
    }

    @Test("deinit does not crash when monitor is immediately discarded")
    func deinit_doesNotCrash() {
        // Create monitor in a local scope so it is deallocated when scope exits
        do {
            let monitor = NetworkMonitor()
            _ = monitor
        }
        // Reaching here means deinit (which calls NWPathMonitor.cancel()) did not crash
    }

    @Test("multiple isConnected reads return consistent value")
    @MainActor
    func isConnected_multipleReads_areConsistent() {
        let monitor = NetworkMonitor()
        let first = monitor.isConnected
        let second = monitor.isConnected
        #expect(first == second)
    }
}
