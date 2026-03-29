import XCTest
@testable import Reaper

@MainActor
final class UpdaterServiceTests: XCTestCase {

    // MARK: - automaticallyChecksForUpdates default

    func testAutomaticallyChecksForUpdatesDefaultsToTrue() {
        // When no updater controller is available (e.g. placeholder key in dev builds),
        // the property should still report true so the Settings toggle shows checked.
        let service = UpdaterService()
        XCTAssertTrue(
            service.automaticallyChecksForUpdates,
            "automaticallyChecksForUpdates should default to true"
        )
    }
}
