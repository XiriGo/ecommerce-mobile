import Factory
import Testing
@testable import MoltMarketplace

// MARK: - ContainerTests

@Suite("Container Registration Tests", .serialized)
struct ContainerTests {
    init() {
        Container.shared.reset()
    }

    // MARK: - Resolution

    @Test("apiClient resolves without crash")
    func test_apiClient_resolves() {
        let client = Container.shared.apiClient()
        #expect(client is APIClient)
    }

    @Test("tokenProvider resolves to NoOpTokenProvider")
    func test_tokenProvider_resolves_toNoOp() {
        let provider = Container.shared.tokenProvider()
        #expect(provider is NoOpTokenProvider)
    }

    @Test("networkMonitor resolves without crash")
    func test_networkMonitor_resolves() {
        let monitor = Container.shared.networkMonitor()
        #expect(monitor is NetworkMonitor)
    }

    // MARK: - Singleton Behavior

    @Test("apiClient returns same instance on multiple resolutions (singleton)")
    func test_apiClient_singleton_returnsSameInstance() {
        let first = Container.shared.apiClient()
        let second = Container.shared.apiClient()
        #expect(first === second)
    }

    @Test("networkMonitor returns same instance on multiple resolutions (singleton)")
    func test_networkMonitor_singleton_returnsSameInstance() {
        let first = Container.shared.networkMonitor()
        let second = Container.shared.networkMonitor()
        #expect(first === second)
    }

    @Test("tokenProvider returns same instance on multiple resolutions (singleton)")
    func test_tokenProvider_singleton_returnsSameInstance() {
        let first = Container.shared.tokenProvider() as AnyObject
        let second = Container.shared.tokenProvider() as AnyObject
        #expect(first === second)
    }

    // MARK: - Test Override

    @Test("container registration can be overridden for tests")
    func test_containerOverride_replacesRegistration() {
        let fakeProvider = FakeTokenProvider()
        fakeProvider.accessToken = "test_token"
        Container.shared.tokenProvider.register { fakeProvider }

        let resolved = Container.shared.tokenProvider()
        #expect(resolved is FakeTokenProvider)
    }

    @Test("container reset restores original registrations")
    func test_containerReset_restoresOriginalRegistrations() {
        Container.shared.tokenProvider.register { FakeTokenProvider() }
        Container.shared.reset()

        let resolved = Container.shared.tokenProvider()
        #expect(resolved is NoOpTokenProvider)
    }
}
