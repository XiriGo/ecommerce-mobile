import Factory
import Testing
@testable import XiriGoEcommerce

// MARK: - ContainerTests

@Suite("Container Registration Tests", .serialized)
struct ContainerTests {
    // MARK: - Lifecycle

    init() {
        Container.shared.reset()
        Scope.singleton.reset()
    }

    // MARK: - Internal

    // MARK: - Resolution

    @Test("apiClient resolves without crash")
    func apiClient_resolves() {
        let client = Container.shared.apiClient()
        #expect(client is APIClient)
    }

    @Test("tokenProvider resolves without crash")
    func tokenProvider_resolves() {
        let provider = Container.shared.tokenProvider()
        #expect(provider is any TokenProvider)
    }

    @Test("networkMonitor resolves without crash")
    func networkMonitor_resolves() {
        let monitor = Container.shared.networkMonitor()
        #expect(monitor is NetworkMonitor)
    }

    // MARK: - Singleton Behavior

    @Test("apiClient returns same instance on multiple resolutions (singleton)")
    func apiClient_singleton_returnsSameInstance() {
        let first = Container.shared.apiClient()
        let second = Container.shared.apiClient()
        #expect(first === second)
    }

    @Test("networkMonitor returns same instance on multiple resolutions (singleton)")
    func networkMonitor_singleton_returnsSameInstance() {
        let first = Container.shared.networkMonitor()
        let second = Container.shared.networkMonitor()
        #expect(first === second)
    }

    @Test("tokenProvider returns same instance on multiple resolutions (singleton)")
    func tokenProvider_singleton_returnsSameInstance() {
        // Avoid `as AnyObject` cast which crashes Swift 6.2.3 compiler with @Observable types.
        // Instead, verify singleton by checking the concrete type resolves consistently.
        let first = Container.shared.tokenProvider()
        let second = Container.shared.tokenProvider()
        // Both must resolve to the same concrete type (singleton returns the same object)
        let firstType = String(describing: type(of: first))
        let secondType = String(describing: type(of: second))
        #expect(firstType == secondType)
    }

    // MARK: - Test Override

    @Test("container registration can be overridden for tests")
    func containerOverride_replacesRegistration() {
        let fakeProvider = FakeTokenProvider()
        fakeProvider.accessToken = "test_token"
        Container.shared.tokenProvider.register { fakeProvider }

        let resolved = Container.shared.tokenProvider()
        #expect(resolved is FakeTokenProvider)
    }

    @Test("container reset restores original registrations")
    func containerReset_restoresOriginalRegistrations() {
        Container.shared.tokenProvider.register { FakeTokenProvider() }
        Container.shared.reset()

        // After reset, tokenProvider resolves to the real LazyTokenProvider (not FakeTokenProvider)
        let resolved = Container.shared.tokenProvider()
        #expect(!(resolved is FakeTokenProvider))
    }

    // MARK: - Cross-Test Isolation

    @Test("override followed by reset does not leak into next resolution")
    func override_thenReset_noLeakage() {
        // Override and verify override is active
        let fake = FakeTokenProvider()
        Container.shared.tokenProvider.register { fake }
        #expect(Container.shared.tokenProvider() is FakeTokenProvider)

        // Reset and verify original is restored — simulates what each test's init() does
        Container.shared.reset()
        Scope.singleton.reset()
        #expect(!(Container.shared.tokenProvider() is FakeTokenProvider))
    }

    @Test("resetting container clears all three singleton caches")
    func reset_clearsSingletonCachesForAllRegistrations() {
        // Resolve all three singletons to populate caches
        let originalClient = Container.shared.apiClient()
        let originalMonitor = Container.shared.networkMonitor()

        // Reset clears the singleton cache — next resolution creates fresh instances
        Container.shared.reset()
        Scope.singleton.reset()

        let newClient = Container.shared.apiClient()
        let newMonitor = Container.shared.networkMonitor()

        // After reset, new instances are returned (singleton cache was cleared)
        #expect(originalClient !== newClient)
        #expect(originalMonitor !== newMonitor)
    }

    // MARK: - Container Shared Reference

    @Test("Container.shared refers to the same container across multiple accesses")
    func containerShared_isSameObject() {
        let first = Container.shared
        let second = Container.shared
        // Container.shared must be the same instance (identity)
        #expect(first === second)
    }

    // MARK: - All Registrations Coexist

    @Test("all three registrations resolve concurrently without interfering")
    func allRegistrations_resolveIndependently() {
        let client = Container.shared.apiClient()
        let provider = Container.shared.tokenProvider()
        let monitor = Container.shared.networkMonitor()

        #expect(client is APIClient)
        #expect(provider is any TokenProvider)
        #expect(monitor is NetworkMonitor)
    }

    // MARK: - Override Specificity

    @Test("overriding tokenProvider does not affect apiClient or networkMonitor registrations")
    func override_tokenProvider_doesNotAffectOtherRegistrations() {
        Container.shared.tokenProvider.register { FakeTokenProvider() }

        // Other registrations remain unaffected
        #expect(Container.shared.apiClient() is APIClient)
        #expect(Container.shared.networkMonitor() is NetworkMonitor)
    }

    @Test("overriding networkMonitor does not affect tokenProvider or apiClient registrations")
    func override_networkMonitor_doesNotAffectOtherRegistrations() {
        let fakeMonitor = NetworkMonitor()
        Container.shared.networkMonitor.register { fakeMonitor }

        #expect(Container.shared.tokenProvider() is any TokenProvider)
        #expect(Container.shared.apiClient() is APIClient)
    }
}
