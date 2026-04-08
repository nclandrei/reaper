import XCTest
@testable import Reaper

// MARK: - Mock

final class MockLaunchAtLoginManager: LaunchAtLoginManaging {
    var isEnabled: Bool = false
    var registerCallCount = 0
    var unregisterCallCount = 0
    var shouldThrow = false

    func register() throws {
        registerCallCount += 1
        if shouldThrow { throw NSError(domain: "test", code: 1) }
        isEnabled = true
    }

    func unregister() throws {
        unregisterCallCount += 1
        if shouldThrow { throw NSError(domain: "test", code: 1) }
        isEnabled = false
    }
}

// MARK: - Tests

@MainActor
final class LaunchAtLoginTests: XCTestCase {

    private func makeSUT(
        managerEnabled: Bool = false,
        hasLaunchedBefore: Bool = false,
        shouldThrow: Bool = false
    ) -> (SettingsViewModel, MockLaunchAtLoginManager, UserDefaults) {
        let manager = MockLaunchAtLoginManager()
        manager.isEnabled = managerEnabled
        manager.shouldThrow = shouldThrow

        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        if hasLaunchedBefore {
            defaults.set(true, forKey: SettingsViewModel.hasLaunchedBeforeKey)
        }

        let vm = SettingsViewModel(manager: manager, defaults: defaults)
        return (vm, manager, defaults)
    }

    // MARK: - Init

    func testInitReadsCurrentStatus() {
        let (vm, _, _) = makeSUT(managerEnabled: true)
        XCTAssertTrue(vm.launchAtLogin)
    }

    func testInitReadsDisabledStatus() {
        let (vm, _, _) = makeSUT(managerEnabled: false)
        XCTAssertFalse(vm.launchAtLogin)
    }

    func testInitDefaultRefreshInterval() {
        let (vm, _, _) = makeSUT()
        XCTAssertEqual(vm.refreshInterval, 3.0)
    }

    func testInitReadsStoredRefreshInterval() {
        let manager = MockLaunchAtLoginManager()
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        defaults.set(5.0, forKey: "refreshInterval")
        let vm = SettingsViewModel(manager: manager, defaults: defaults)
        XCTAssertEqual(vm.refreshInterval, 5.0)
    }

    // MARK: - First launch auto-enable

    func testFirstLaunchRegistersLoginItem() {
        let (vm, manager, _) = makeSUT(hasLaunchedBefore: false)
        vm.enableLaunchAtLoginOnFirstLaunch()

        XCTAssertEqual(manager.registerCallCount, 1)
        XCTAssertTrue(vm.launchAtLogin)
    }

    func testFirstLaunchSetsHasLaunchedBeforeFlag() {
        let (vm, _, defaults) = makeSUT(hasLaunchedBefore: false)
        vm.enableLaunchAtLoginOnFirstLaunch()

        XCTAssertTrue(defaults.bool(forKey: SettingsViewModel.hasLaunchedBeforeKey))
    }

    func testSubsequentLaunchDoesNotRegisterAgain() {
        let (vm, manager, _) = makeSUT(hasLaunchedBefore: true)
        vm.enableLaunchAtLoginOnFirstLaunch()

        XCTAssertEqual(manager.registerCallCount, 0)
    }

    func testFirstLaunchRegistrationFailureDoesNotCrash() {
        let (vm, manager, _) = makeSUT(hasLaunchedBefore: false, shouldThrow: true)
        vm.enableLaunchAtLoginOnFirstLaunch()

        XCTAssertEqual(manager.registerCallCount, 1)
        // launchAtLogin stays false because register threw
        XCTAssertFalse(vm.launchAtLogin)
    }

    func testFirstLaunchSetsFlagEvenOnRegistrationFailure() {
        let (vm, _, defaults) = makeSUT(hasLaunchedBefore: false, shouldThrow: true)
        vm.enableLaunchAtLoginOnFirstLaunch()

        // Flag is set regardless so we don't retry every launch
        XCTAssertTrue(defaults.bool(forKey: SettingsViewModel.hasLaunchedBeforeKey))
    }

    // MARK: - Toggle on/off

    func testSetLaunchAtLoginTrue() {
        let (vm, manager, _) = makeSUT(managerEnabled: false)
        vm.setLaunchAtLogin(true)

        XCTAssertEqual(manager.registerCallCount, 1)
        XCTAssertTrue(vm.launchAtLogin)
    }

    func testSetLaunchAtLoginFalse() {
        let (vm, manager, _) = makeSUT(managerEnabled: true)
        vm.setLaunchAtLogin(false)

        XCTAssertEqual(manager.unregisterCallCount, 1)
        XCTAssertFalse(vm.launchAtLogin)
    }

    func testSetLaunchAtLoginTrueFailureRevertsState() {
        let (vm, manager, _) = makeSUT(managerEnabled: false, shouldThrow: true)
        vm.setLaunchAtLogin(true)

        XCTAssertEqual(manager.registerCallCount, 1)
        // Should stay false because register threw
        XCTAssertFalse(vm.launchAtLogin)
    }

    func testSetLaunchAtLoginFalseFailureRevertsState() {
        let (vm, manager, _) = makeSUT(managerEnabled: true, shouldThrow: true)
        vm.setLaunchAtLogin(false)

        XCTAssertEqual(manager.unregisterCallCount, 1)
        // Should stay true because unregister threw
        XCTAssertTrue(vm.launchAtLogin)
    }

    // MARK: - Multiple toggles

    func testMultipleToggles() {
        let (vm, manager, _) = makeSUT(managerEnabled: false)

        vm.setLaunchAtLogin(true)
        XCTAssertTrue(vm.launchAtLogin)
        XCTAssertEqual(manager.registerCallCount, 1)

        vm.setLaunchAtLogin(false)
        XCTAssertFalse(vm.launchAtLogin)
        XCTAssertEqual(manager.unregisterCallCount, 1)

        vm.setLaunchAtLogin(true)
        XCTAssertTrue(vm.launchAtLogin)
        XCTAssertEqual(manager.registerCallCount, 2)
    }

    // MARK: - Refresh interval persistence

    func testSaveRefreshInterval() {
        let (vm, _, defaults) = makeSUT()
        vm.refreshInterval = 5.0
        vm.saveRefreshInterval()

        XCTAssertEqual(defaults.double(forKey: "refreshInterval"), 5.0)
    }

    // MARK: - Calling enableLaunchAtLoginOnFirstLaunch twice

    func testCallingFirstLaunchTwiceOnlyRegistersOnce() {
        let (vm, manager, _) = makeSUT(hasLaunchedBefore: false)
        vm.enableLaunchAtLoginOnFirstLaunch()
        vm.enableLaunchAtLoginOnFirstLaunch()

        XCTAssertEqual(manager.registerCallCount, 1)
    }
}
