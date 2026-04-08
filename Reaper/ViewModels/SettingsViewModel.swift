import SwiftUI
import ServiceManagement

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var refreshInterval: Double
    @Published var launchAtLogin: Bool

    private let manager: LaunchAtLoginManaging
    private let defaults: UserDefaults

    static let hasLaunchedBeforeKey = "hasLaunchedBefore"

    init(manager: LaunchAtLoginManaging = SMAppServiceLaunchAtLoginManager(),
         defaults: UserDefaults = .standard) {
        self.manager = manager
        self.defaults = defaults

        let saved = defaults.double(forKey: "refreshInterval")
        self.refreshInterval = saved > 0 ? saved : 3.0
        self.launchAtLogin = manager.isEnabled
    }

    /// Call once at app startup to enable launch-at-login on first install.
    func enableLaunchAtLoginOnFirstLaunch() {
        guard !defaults.bool(forKey: Self.hasLaunchedBeforeKey) else { return }
        defaults.set(true, forKey: Self.hasLaunchedBeforeKey)
        setLaunchAtLogin(true)
    }

    func saveRefreshInterval() {
        defaults.set(refreshInterval, forKey: "refreshInterval")
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try manager.register()
            } else {
                try manager.unregister()
            }
            launchAtLogin = enabled
        } catch {
            // Revert on failure
        }
    }
}
