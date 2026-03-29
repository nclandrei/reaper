import XCTest
@testable import Reaper

final class ProcessGroupTests: XCTestCase {

    private func makeProcess(pid: pid_t = 1, cpu: Double = 0, memory: UInt64 = 0) -> Reaper.ProcessInfo {
        Reaper.ProcessInfo(
            pid: pid,
            name: "proc-\(pid)",
            cpu: cpu,
            memory: memory,
            icon: nil,
            isApp: false,
            parentPID: 0,
            bundleIdentifier: nil,
            path: nil
        )
    }

    // MARK: - totalCPU

    func testTotalCPUSumsAllChildren() {
        let group = ProcessGroup(
            id: 1,
            name: "App",
            icon: nil,
            children: [
                makeProcess(pid: 1, cpu: 25.0),
                makeProcess(pid: 2, cpu: 12.5),
                makeProcess(pid: 3, cpu: 7.5),
            ],
            isApp: true
        )
        XCTAssertEqual(group.totalCPU, 45.0, accuracy: 0.001)
    }

    func testTotalCPUEmptyChildren() {
        let group = ProcessGroup(id: 1, name: "Empty", icon: nil, children: [], isApp: false)
        XCTAssertEqual(group.totalCPU, 0.0)
    }

    func testTotalCPUSingleChild() {
        let group = ProcessGroup(
            id: 1,
            name: "Single",
            icon: nil,
            children: [makeProcess(pid: 1, cpu: 99.9)],
            isApp: true
        )
        XCTAssertEqual(group.totalCPU, 99.9, accuracy: 0.001)
    }

    // MARK: - totalMemory

    func testTotalMemorySumsAllChildren() {
        let group = ProcessGroup(
            id: 1,
            name: "App",
            icon: nil,
            children: [
                makeProcess(pid: 1, memory: 100_000_000),
                makeProcess(pid: 2, memory: 200_000_000),
            ],
            isApp: true
        )
        XCTAssertEqual(group.totalMemory, 300_000_000)
    }

    func testTotalMemoryEmptyChildren() {
        let group = ProcessGroup(id: 1, name: "Empty", icon: nil, children: [], isApp: false)
        XCTAssertEqual(group.totalMemory, 0)
    }

    // MARK: - helperCount

    func testHelperCountWithMultipleChildren() {
        let group = ProcessGroup(
            id: 1,
            name: "App",
            icon: nil,
            children: [
                makeProcess(pid: 1),
                makeProcess(pid: 2),
                makeProcess(pid: 3),
            ],
            isApp: true
        )
        // helperCount = children.count - 1 = 2
        XCTAssertEqual(group.helperCount, 2)
    }

    func testHelperCountSingleChild() {
        let group = ProcessGroup(
            id: 1,
            name: "App",
            icon: nil,
            children: [makeProcess(pid: 1)],
            isApp: true
        )
        XCTAssertEqual(group.helperCount, 0)
    }

    func testHelperCountEmptyChildren() {
        let group = ProcessGroup(id: 1, name: "Empty", icon: nil, children: [], isApp: false)
        // max(0, 0 - 1) = 0, not -1
        XCTAssertEqual(group.helperCount, 0)
    }

    // MARK: - isBackground

    func testIsBackgroundTrueForSentinelID() {
        let group = ProcessGroup(id: -1, name: "Background", icon: nil, children: [
            makeProcess(pid: 100, cpu: 30.0, memory: 5_000_000_000),
            makeProcess(pid: 101, cpu: 49.0, memory: 6_000_000_000),
        ], isApp: false)
        XCTAssertTrue(group.isBackground)
    }

    func testIsBackgroundFalseForNormalGroup() {
        let group = ProcessGroup(id: 42, name: "Firefox", icon: nil, children: [
            makeProcess(pid: 42, cpu: 10.0),
        ], isApp: true)
        XCTAssertFalse(group.isBackground)
    }

    // MARK: - Identifiable

    func testIdentifiableID() {
        let group = ProcessGroup(id: 42, name: "Test", icon: nil, children: [], isApp: false)
        XCTAssertEqual(group.id, 42)
    }
}
