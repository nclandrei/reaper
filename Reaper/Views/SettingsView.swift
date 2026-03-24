import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @AppStorage("menuBarMetric") private var menuBarMetric: String = MenuBarMetric.memory.rawValue
    @AppStorage("cpuStyle") private var cpuStyle: String = MenuBarStyle.defaultForCPU.rawValue
    @AppStorage("memoryStyle") private var memoryStyle: String = MenuBarStyle.defaultForMemory.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.system(size: 13, weight: .semibold))

            Divider()

            // Metric toggle
            HStack {
                Text("Menu bar shows")
                    .font(.system(size: 12))
                Spacer()
                Picker("", selection: $menuBarMetric) {
                    ForEach(MenuBarMetric.allCases) { metric in
                        Text(metric.rawValue).tag(metric.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 130)
            }

            // Style picker for active metric
            HStack {
                Text(menuBarMetric == MenuBarMetric.cpu.rawValue ? "CPU indicator" : "Memory indicator")
                    .font(.system(size: 12))
                Spacer()
                Picker("", selection: menuBarMetric == MenuBarMetric.cpu.rawValue ? $cpuStyle : $memoryStyle) {
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
        }
        .padding(16)
        .frame(width: 320)
    }
}
