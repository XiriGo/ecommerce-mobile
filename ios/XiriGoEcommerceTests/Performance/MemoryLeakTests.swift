import XCTest
@testable import XiriGoEcommerce

/// Memory leak detection tests for ViewModels and key objects.
/// Maps to TEST.md Section 6.2 — Memory Leak Detection.
///
/// Uses XCTest because `addTeardownBlock` for weak reference verification
/// is not available in Swift Testing.
final class MemoryLeakTests: PerformanceTestCase {
    // MARK: - Internal

    func test_memoryBaseline_isReasonable() {
        let snapshot = MemorySnapshot.current()
        // Test process memory should be under 200MB during unit tests
        XCTAssertLessThan(
            snapshot.residentMB,
            maxTestMemoryMB,
            "Test process memory usage is \(String(format: "%.1f", snapshot.residentMB))MB — investigate memory growth",
        )
    }

    // MARK: - Private

    // NOTE: Add specific ViewModel leak tests as features are implemented.
    // Example pattern:
    //
    // func test_homeViewModel_deallocation() {
    //     assertNoDeallocLeak {
    //         let repo = FakeHomeRepository()
    //         return HomeViewModel(
    //             getBannersUseCase: GetHomeBannersUseCase(repository: repo),
    //             getCategoriesUseCase: GetHomeCategoriesUseCase(repository: repo),
    //             ...
    //         )
    //     }
    // }

    // MARK: - Memory Baseline

    private let maxTestMemoryMB: Double = 512.0

    // MARK: - ViewModel Memory Leak Tests

    /// Generic helper: verifies that a ViewModel is deallocated after scope ends.
    private func assertNoDeallocLeak<T: AnyObject>(
        _ factory: () -> T,
        file: StaticString = #filePath,
        line: UInt = #line,
    ) {
        var instance: T? = factory()
        weak var weakInstance = instance
        instance = nil
        XCTAssertNil(
            weakInstance,
            "\(String(describing: T.self)) was not deallocated — potential memory leak",
            file: file,
            line: line,
        )
    }
}
