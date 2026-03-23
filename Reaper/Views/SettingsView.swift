import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @AppStorage("menuBarMetric") private var menuBarMetric: String = MenuBarMetric.memory.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.system(size: 13, weight: .semibold))

            Divider()

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
        .frame(width: 300)
    }
}
