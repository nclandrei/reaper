import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ProcessListViewModel
    @ObservedObject var updaterService: UpdaterService
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Thermal overview bar
            ThermalOverviewBar(
                groups: viewModel.appGroups,
                systemStats: viewModel.systemStats
            )

            // Search
            HStack(spacing: 8) {
                Image(systemName: "thermometer.medium")
                    .foregroundStyle(.white.opacity(0.35))
                    .font(.system(size: 13))
                TextField("Scan for heat...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))

                Text("/")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.25))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.white.opacity(0.08), lineWidth: 0.5)
                    )
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            // Heatmap grid
            HeatmapGridView(
                groups: viewModel.appGroups,
                onKill: { viewModel.killProcess(pid: $0) },
                onForceKill: { viewModel.forceKillProcess(pid: $0) },
                onKillGroup: { viewModel.killGroup($0) }
            )
            .padding(.horizontal, 12)

            // Legend
            ThermalLegend()

            // Footer
            HStack {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 14))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .popover(isPresented: $showSettings) {
                    SettingsView(viewModel: SettingsViewModel(), updaterService: updaterService)
                }

                Spacer()

                Text("\(viewModel.groups.reduce(0) { $0 + $1.children.count }) processes")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)

                Spacer()

                Button {
                    NSApp.terminate(nil)
                } label: {
                    Text("Quit Reaper")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color(red: 1.0, green: 0.09, blue: 0.27))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color(red: 1.0, green: 0.09, blue: 0.27).opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(red: 1.0, green: 0.09, blue: 0.27).opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.white.opacity(0.06))
                    .frame(height: 1)
            }
        }
        .frame(width: 420, height: 560)
        .background(.ultraThinMaterial)
        .preferredColorScheme(.dark)
    }
}
