import SwiftUI
import ServiceManagement

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var refreshInterval: Double
    @Published var launchAtLogin: Bool

    init() {
        let saved = UserDefaults.standard.double(forKey: "refreshInterval")
        self.refreshInterval = saved > 0 ? saved : 3.0
        self.launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    func saveRefreshInterval() {
        UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval")
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchAtLogin = enabled
        } catch {
            // Revert on failure
        }
    }
}
