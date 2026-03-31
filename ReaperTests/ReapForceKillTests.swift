import XCTest
@testable import Reaper

final class ReapForceKillTests: XCTestCase {

    // MARK: - Bug 2: Reap button should force-kill, not send SIGTERM

    @MainActor
    func testKillProcessForceKillsSIGTERMResistantProcess() {
        // The Reap button for single-child groups calls killProcess(pid:)
        // which uses ProcessKiller.quit() → SIGTERM.
        // SIGTERM can be caught/ignored by CLI processes like Claude Code.
        // killProcess should use forceKill (SIGKILL) so Reap always works.

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "trap '' TERM; sleep 30"]
        try! process.run()
        let pid = process.processIdentifier
        defer {
            if process.isRunning { kill(pid, SIGKILL); process.waitUntilExit() }
        }

        let viewModel = ProcessListViewModel()
        viewModel.killProcess(pid: pid)

        // Give signal time to take effect
        Thread.sleep(forTimeInterval: 1.0)

        XCTAssertFalse(process.isRunning, "killProcess should force-kill even SIGTERM-resistant processes")
    }
}
