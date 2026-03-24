import XCTest
@testable import Reaper

final class ProcessInfoTests: XCTestCase {

    private func makeProcess(
        pid: pid_t = 1,
        name: String = "node",
        cpu: Double = 0,
        memory: UInt64 = 0,
        path: String? = nil
    ) -> Reaper.ProcessInfo {
        Reaper.ProcessInfo(
            pid: pid,
            name: name,
            cpu: cpu,
            memory: memory,
            icon: nil,
            isApp: false,
            parentPID: 0,
            bundleIdentifier: nil,
            path: path
        )
    }

    // MARK: - matchesSearch

    func testMatchesSearchByName() {
        let proc = makeProcess(name: "Safari")
        XCTAssertTrue(proc.matchesSearch("safari"))
        XCTAssertTrue(proc.matchesSearch("Safari"))
        XCTAssertTrue(proc.matchesSearch("saf"))
        XCTAssertFalse(proc.matchesSearch("chrome"))
    }

    func testMatchesSearchByPathFindsCLITools() {
        // Bug: Claude Code runs as "node" but should be findable by searching "claude".
        // Activity Monitor shows the full command; Reaper should search against path too.
        let proc = makeProcess(
            name: "node",
            cpu: 105.0,
            path: "/Users/test/.claude/local/share/claude-code/node_modules/.bin/claude"
        )
        XCTAssertTrue(proc.matchesSearch("claude"), "Should find CLI tool by executable path")
        XCTAssertTrue(proc.matchesSearch("node"), "Should still match by process name")
    }

    func testMatchesSearchPathIsCaseInsensitive() {
        let proc = makeProcess(
            name: "node",
            path: "/path/to/Claude-Code/cli.js"
        )
        XCTAssertTrue(proc.matchesSearch("claude"))
        XCTAssertTrue(proc.matchesSearch("CLAUDE"))
    }

    func testMatchesSearchWithNilPath() {
        let proc = makeProcess(name: "node", path: nil)
        XCTAssertTrue(proc.matchesSearch("node"))
        XCTAssertFalse(proc.matchesSearch("claude"))
    }
}
