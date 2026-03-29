import XCTest
@testable import Reaper

final class CPUSmoothingTests: XCTestCase {

    // MARK: - First sample (no history)

    func testFirstSampleReturnsRawValue() {
        var smoother = CPUSmoother()
        let result = smoother.smooth(pid: 1, rawCPU: 50.0)
        XCTAssertEqual(result, 50.0, accuracy: 0.001)
    }

    // MARK: - EMA dampens spikes

    func testSpikeDampenedByEMA() {
        var smoother = CPUSmoother()
        // Establish a baseline of ~5%
        _ = smoother.smooth(pid: 1, rawCPU: 5.0)
        _ = smoother.smooth(pid: 1, rawCPU: 5.0)
        _ = smoother.smooth(pid: 1, rawCPU: 5.0)
        // Sudden spike to 80% should be dampened
        let spiked = smoother.smooth(pid: 1, rawCPU: 80.0)
        XCTAssertLessThan(spiked, 80.0, "Spike should be dampened")
        XCTAssertGreaterThan(spiked, 5.0, "Should still increase from baseline")
    }

    func testSustainedHighCPUConverges() {
        var smoother = CPUSmoother()
        _ = smoother.smooth(pid: 1, rawCPU: 0.0)
        // Feed sustained 90% CPU — should converge close to 90
        var value = 0.0
        for _ in 0..<10 {
            value = smoother.smooth(pid: 1, rawCPU: 90.0)
        }
        XCTAssertEqual(value, 90.0, accuracy: 5.0, "Should converge near 90% after many samples")
    }

    // MARK: - Independent per-process

    func testDifferentProcessesTrackedIndependently() {
        var smoother = CPUSmoother()
        _ = smoother.smooth(pid: 1, rawCPU: 50.0)
        _ = smoother.smooth(pid: 1, rawCPU: 50.0)
        let p1 = smoother.smooth(pid: 1, rawCPU: 50.0)

        let p2 = smoother.smooth(pid: 2, rawCPU: 10.0)

        XCTAssertEqual(p1, 50.0, accuracy: 1.0)
        XCTAssertEqual(p2, 10.0, accuracy: 1.0)
    }

    // MARK: - Cleanup stale PIDs

    func testPurgeCleansUpStalePIDs() {
        var smoother = CPUSmoother()
        _ = smoother.smooth(pid: 1, rawCPU: 50.0)
        _ = smoother.smooth(pid: 2, rawCPU: 30.0)
        _ = smoother.smooth(pid: 3, rawCPU: 10.0)

        smoother.purge(keeping: Set([1, 3]))

        // PID 2 was purged — should be treated as first sample
        let p2 = smoother.smooth(pid: 2, rawCPU: 99.0)
        XCTAssertEqual(p2, 99.0, accuracy: 0.001, "Purged PID should have no history")
    }
}
