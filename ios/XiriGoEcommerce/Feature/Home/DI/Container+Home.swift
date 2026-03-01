import Factory

// MARK: - Container + Home

extension Container {
    // MARK: - Repository

    var homeRepository: Factory<HomeRepository> {
        self { FakeHomeRepository() }
            .singleton
    }

    // MARK: - Use Cases

    var getHomeBannersUseCase: Factory<GetHomeBannersUseCase> {
        self { GetHomeBannersUseCase(repository: self.homeRepository()) }
    }

    var getHomeCategoriesUseCase: Factory<GetHomeCategoriesUseCase> {
        self { GetHomeCategoriesUseCase(repository: self.homeRepository()) }
    }

    var getPopularProductsUseCase: Factory<GetPopularProductsUseCase> {
        self { GetPopularProductsUseCase(repository: self.homeRepository()) }
    }

    var getDailyDealUseCase: Factory<GetDailyDealUseCase> {
        self { GetDailyDealUseCase(repository: self.homeRepository()) }
    }

    var getNewArrivalsUseCase: Factory<GetNewArrivalsUseCase> {
        self { GetNewArrivalsUseCase(repository: self.homeRepository()) }
    }

    var getFlashSaleUseCase: Factory<GetFlashSaleUseCase> {
        self { GetFlashSaleUseCase(repository: self.homeRepository()) }
    }

    // MARK: - ViewModel

    var homeViewModel: Factory<HomeViewModel> {
        self {
            MainActor.assumeIsolated {
                HomeViewModel(
                    getBanners: self.getHomeBannersUseCase(),
                    getCategories: self.getHomeCategoriesUseCase(),
                    getPopularProducts: self.getPopularProductsUseCase(),
                    getDailyDeal: self.getDailyDealUseCase(),
                    getNewArrivals: self.getNewArrivalsUseCase(),
                    getFlashSale: self.getFlashSaleUseCase(),
                )
            }
        }
    }
}
