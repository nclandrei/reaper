import Foundation
import ServiceManagement

/// Abstraction over SMAppService to enable testing.
protocol LaunchAtLoginManaging {
    var isEnabled: Bool { get }
    func register() throws
    func unregister() throws
}

/// Production implementation backed by SMAppService.
struct SMAppServiceLaunchAtLoginManager: LaunchAtLoginManaging {
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    func register() throws {
        try SMAppService.mainApp.register()
    }

    func unregister() throws {
        try SMAppService.mainApp.unregister()
    }
}
