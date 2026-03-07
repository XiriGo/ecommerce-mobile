import XCTest

// MARK: - PerformanceTestCase

/// Base class for performance tests that need XCTest's `measure()` API.
/// Swift Testing doesn't support performance measurement, so these use XCTest.
class PerformanceTestCase: XCTestCase {
    // MARK: - Memory Leak Assertions

    /// Tracks an object for deallocation verification at teardown.
    /// If the object is still alive when the test ends, the test fails.
    private func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line,
    ) {
        let description = String(describing: instance)
        addTeardownBlock { [weak instance] @Sendable in
            XCTAssertNil(
                instance,
                "Potential memory leak: \(description) was not deallocated",
                file: file,
                line: line,
            )
        }
    }

    // MARK: - Performance Measurement Helpers

    /// Measures execution time with configurable iteration count.
    private func measureTime(
        iterations: Int = 10,
        block: () -> Void,
    ) {
        let options = XCTMeasureOptions()
        options.iterationCount = iterations
        measure(metrics: [XCTClockMetric()], options: options) {
            block()
        }
    }

    /// Measures memory usage during a block.
    private func measureMemory(
        iterations: Int = 5,
        block: () -> Void,
    ) {
        let options = XCTMeasureOptions()
        options.iterationCount = iterations
        measure(metrics: [XCTMemoryMetric()], options: options) {
            block()
        }
    }

    /// Measures both time and memory.
    private func measureTimeAndMemory(
        iterations: Int = 5,
        block: () -> Void,
    ) {
        let options = XCTMeasureOptions()
        options.iterationCount = iterations
        measure(
            metrics: [XCTClockMetric(), XCTMemoryMetric(), XCTCPUMetric()],
            options: options,
        ) {
            block()
        }
    }
}

// MARK: - MemorySnapshot

/// Captures memory stats for comparison.
struct MemorySnapshot {
    // MARK: - Internal

    let residentSize: UInt64
    let virtualSize: UInt64

    /// Returns resident memory in MB.
    var residentMB: Double {
        Double(residentSize) / Self.bytesPerMB
    }

    static func current() -> Self {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / integerSize
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            return Self(
                residentSize: info.resident_size,
                virtualSize: info.virtual_size,
            )
        }
        return Self(residentSize: 0, virtualSize: 0)
    }

    // MARK: - Private

    private static let bytesPerMB: Double = 1_048_576.0
    private static let integerSize = UInt32(MemoryLayout<integer_t>.size)
}
