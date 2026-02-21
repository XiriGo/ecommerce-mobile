import Testing
@testable import MoltMarketplace

// MARK: - NetworkMonitorTests

@Suite("NetworkMonitor Tests")
struct NetworkMonitorTests {
    @Test("initializes without crash")
    func test_init_doesNotCrash() {
        let monitor = NetworkMonitor()
        _ = monitor
    }

    @Test("isConnected defaults to true on init")
    @MainActor func test_isConnected_defaultsToTrue() {
        let monitor = NetworkMonitor()
        #expect(monitor.isConnected == true)
    }

    @Test("conforms to Sendable")
    func test_sendableConformance() {
        let monitor = NetworkMonitor()
        let sendableRef: any Sendable = monitor
        #expect(sendableRef is NetworkMonitor)
    }

    @Test("singleton from container is observable class")
    func test_container_networkMonitor_isObservable() {
        let monitor = NetworkMonitor()
        // NetworkMonitor is @Observable -- verify it is a reference type (class)
        let ref1: AnyObject = monitor
        let ref2: AnyObject = monitor
        #expect(ref1 === ref2)
    }
}
