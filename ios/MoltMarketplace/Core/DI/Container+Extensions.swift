import Factory
import Foundation

// MARK: - Core Infrastructure (Singletons)

extension Container {
    // MARK: - Network

    /// Token provider for auth header injection. Currently a no-op placeholder.
    /// Replaced by a real Keychain-backed implementation in M0-06 (Auth Infrastructure).
    var tokenProvider: Factory<any TokenProvider> {
        self { NoOpTokenProvider() }
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
