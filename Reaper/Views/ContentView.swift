import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ProcessListViewModel
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                searchText: $viewModel.searchText,
                sortOrder: $viewModel.sortOrder,
                systemStats: viewModel.systemStats
            )

            Divider()
                .opacity(0.2)
                .padding(.horizontal, 16)

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(viewModel.groups) { group in
                        ProcessGroupView(
                            group: group,
                            isExpanded: viewModel.expandedGroups.contains(group.id),
                            isSearching: !viewModel.searchText.isEmpty,
                            onToggle: { viewModel.toggleExpanded(group.id) },
                            onKill: { viewModel.killProcess(pid: $0) },
                            onForceKill: { viewModel.forceKillProcess(pid: $0) },
                            onKillGroup: { viewModel.killGroup(group) }
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }

            Divider()
                .opacity(0.2)
                .padding(.horizontal, 16)

            // Footer
            HStack {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .popover(isPresented: $showSettings) {
                    SettingsView(viewModel: SettingsViewModel())
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
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 420, height: 580)
        .glassBackground()
        .preferredColorScheme(.dark)
    }
}
