import XCTest
@testable import Reaper

final class AppGroupsTests: XCTestCase {
    @MainActor
    func testAppGroupsIncludesBackground() {
        // The appGroups property should NOT filter out background processes
        // It should return all groups for the heatmap display
        let bgGroup = ProcessGroup(
            id: -1,
            name: "Background",
            icon: nil,
            children: [
                ProcessInfo(pid: 100, name: "daemon", cpu: 5.0, memory: 100_000_000, icon: nil, isApp: false, parentPID: 1, bundleIdentifier: nil, path: nil)
            ],
            isApp: false
        )
        let appGroup = ProcessGroup(
            id: 200,
            name: "Safari",
            icon: nil,
            children: [
                ProcessInfo(pid: 200, name: "Safari", cpu: 10.0, memory: 500_000_000, icon: nil, isApp: true, parentPID: 1, bundleIdentifier: "com.apple.Safari", path: nil)
            ],
            isApp: true
        )

        let viewModel = ProcessListViewModel()
        viewModel.groups = [appGroup, bgGroup]

        XCTAssertEqual(viewModel.appGroups.count, 2, "Both app and background groups should be included")
        XCTAssertTrue(viewModel.appGroups.contains(where: { $0.name == "Background" }))
    }
}
