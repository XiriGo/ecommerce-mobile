import Factory
import Foundation

// MARK: - Core Infrastructure (Singletons)

extension Container {
    // MARK: - Auth

    /// Keychain-backed token storage for secure JWT persistence.
    var tokenStorage: Factory<TokenStorage> {
        self { KeychainTokenStorage() }
            .singleton
    }

    /// Observable auth state manager that coordinates auth state transitions.
    var authStateManager: Factory<AuthStateManagerImpl> {
        self { MainActor.assumeIsolated { AuthStateManagerImpl(tokenStorage: self.tokenStorage()) } }
            .singleton
    }

    /// Session manager that coordinates login, register, logout, and token refresh.
    /// Also serves as the `TokenProvider` for the network layer.
    var sessionManager: Factory<SessionManager> {
        self {
            SessionManager(
                apiClient: self.apiClient(),
                tokenStorage: self.tokenStorage(),
                authStateManager: self.authStateManager()
            )
        }
        .singleton
    }

    // MARK: - Network

    /// Lazy token provider that breaks the circular dependency between APIClient
    /// and SessionManager. Resolves SessionManager on first use, not at construction.
    var tokenProvider: Factory<any TokenProvider> {
        self { LazyTokenProvider { Container.shared.sessionManager() } }
            .singleton
    }

    /// Singleton API client used by all feature repositories for network requests.
    /// Handles auth token injection, 401 refresh, retry with backoff, and error mapping.
    var apiClient: Factory<APIClient> {
        self {
            APIClient(
                baseURL: Config.apiBaseURL,
                tokenProvider: self.tokenProvider()
            )
        }
        .singleton
    }

    // MARK: - Monitoring

    /// Singleton network connectivity monitor using NWPathMonitor.
    /// Used by features to show offline banners and disable network-dependent actions.
    var networkMonitor: Factory<NetworkMonitor> {
        self { NetworkMonitor() }
            .singleton
    }
}

// MARK: - LazyTokenProvider

/// Breaks the circular dependency: APIClient -> TokenProvider -> SessionManager -> APIClient.
/// The underlying SessionManager is resolved lazily on first method call, not at construction.
private final class LazyTokenProvider: TokenProvider, @unchecked Sendable {
    private let resolver: @Sendable () -> SessionManager
    private var resolved: SessionManager?

    init(resolver: @escaping @Sendable () -> SessionManager) {
        self.resolver = resolver
    }

    private func provider() -> SessionManager {
        if let resolved { return resolved }
        let instance = resolver()
        resolved = instance
        return instance
    }

    func getAccessToken() async -> String? {
        await provider().getAccessToken()
    }

    func refreshToken() async throws -> String? {
        try await provider().refreshToken()
    }

    func clearTokens() async {
        await provider().clearTokens()
    }
}

// MARK: - Feature DI Pattern (Reference for M1+ Features)
//
// Every feature registers its dependencies as a Container extension. For small
// projects, add registrations directly to this file. For larger projects, create
// a separate file per feature: `Core/DI/Container+{Feature}.swift`.
//
// --- Repository Registration ---
//
//   extension Container {
//       var productRepository: Factory<ProductRepository> {
//           self { ProductRepositoryImpl(apiClient: self.apiClient()) }
//       }
//   }
//
// --- Use Case Registration ---
//
//   extension Container {
//       var getProductsUseCase: Factory<GetProductsUseCase> {
//           self { GetProductsUseCase(repository: self.productRepository()) }
//       }
//   }
//
// --- ViewModel Injection (Option A: @Injected property wrapper) ---
//
//   @MainActor @Observable
//   final class ProductListViewModel {
//       @ObservationIgnored @Injected(\.getProductsUseCase) private var useCase
//   }
//
// --- ViewModel Injection (Option B: init-based, preferred for testability) ---
//
//   @MainActor @Observable
//   final class ProductListViewModel {
//       private let getProductsUseCase: GetProductsUseCase
//
//       init(getProductsUseCase: GetProductsUseCase = Container.shared.getProductsUseCase()) {
//           self.getProductsUseCase = getProductsUseCase
//       }
//   }
//
// --- Scoping Rules ---
//
// - .singleton  : Infrastructure only (APIClient, NetworkMonitor, TokenProvider)
// - (default)   : Repositories and use cases (transient -- new instance per resolution)
// - .cached     : Use sparingly; only when you need "create once, but resettable"
//
// --- Test Replacement ---
//
// In tests, override container registrations or use init-based injection:
//
//   // Option A: Container override
//   Container.shared.reset()
//   Container.shared.productRepository.register { FakeProductRepository() }
//
//   // Option B: Init-based injection (preferred)
//   let fakeRepo = FakeProductRepository()
//   let useCase = GetProductsUseCase(repository: fakeRepo)
//   let viewModel = ProductListViewModel(getProductsUseCase: useCase)
