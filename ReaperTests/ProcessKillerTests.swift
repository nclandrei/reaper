import XCTest
@testable import Reaper

final class ProcessKillerTests: XCTestCase {

    // MARK: - KillResult message strings

    func testSuccessMessage() {
        let result = ProcessKiller.KillResult.success
        XCTAssertEqual(result.message, "Process terminated")
    }

    func testAccessDeniedMessage() {
        let result = ProcessKiller.KillResult.accessDenied
        XCTAssertEqual(result.message, "Access denied")
    }

    func testNotFoundMessage() {
        let result = ProcessKiller.KillResult.notFound
        XCTAssertEqual(result.message, "Process not found")
    }

    func testFailedMessagePassesThrough() {
        let result = ProcessKiller.KillResult.failed("Something went wrong")
        XCTAssertEqual(result.message, "Something went wrong")
    }

    func testFailedMessageEmpty() {
        let result = ProcessKiller.KillResult.failed("")
        XCTAssertEqual(result.message, "")
    }
}
