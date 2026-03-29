import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var updaterService: UpdaterService
    @AppStorage("menuBarStyle") private var menuBarStyle: String = MenuBarStyle.skull.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.system(size: 13, weight: .semibold))

            Divider()

            // Indicator style
            HStack {
                Text("Menu bar icon")
                    .font(.system(size: 12))
                Spacer()
                Picker("", selection: $menuBarStyle) {
                    ForEach(MenuBarStyle.allCases) { style in
                        Text(style.rawValue).tag(style.rawValue)
                    }
                }
                .frame(width: 140)
            }

            // Hotkey recorder
            HStack {
                Text("Hotkey")
                    .font(.system(size: 12))
                Spacer()
                KeyboardShortcuts.Recorder(for: .togglePanel)
                    .frame(width: 140)
            }

            // Refresh interval
            HStack {
                Text("Refresh interval")
                    .font(.system(size: 12))
                Spacer()
                Picker("", selection: $viewModel.refreshInterval) {
                    Text("1s").tag(1.0)
                    Text("2s").tag(2.0)
                    Text("3s").tag(3.0)
                    Text("5s").tag(5.0)
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
                .onChange(of: viewModel.refreshInterval) { _ in
                    viewModel.saveRefreshInterval()
                }
            }

            Toggle("Launch at login", isOn: Binding(
                get: { viewModel.launchAtLogin },
                set: { viewModel.setLaunchAtLogin($0) }
            ))
            .font(.system(size: 12))

            Divider()

            // Updates
            Text("Updates")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

            Toggle("Check automatically", isOn: Binding(
                get: { updaterService.automaticallyChecksForUpdates },
                set: { updaterService.automaticallyChecksForUpdates = $0 }
            ))
            .font(.system(size: 12))

            Button("Check for Updates...") {
                updaterService.checkForUpdates()
            }
            .font(.system(size: 12))
            .disabled(!updaterService.canCheckForUpdates)

            if let lastCheck = updaterService.lastUpdateCheckDate {
                Text("Last checked: \(lastCheck.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .frame(width: 320)
    }
}
