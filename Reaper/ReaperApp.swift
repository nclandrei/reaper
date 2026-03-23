import SwiftUI

@main
struct ReaperApp: App {
    @StateObject private var viewModel = ProcessListViewModel()
    @AppStorage("menuBarMetric") private var menuBarMetric: String = MenuBarMetric.memory.rawValue

    private var activeMetric: MenuBarMetric {
        MenuBarMetric(rawValue: menuBarMetric) ?? .memory
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: viewModel)
        } label: {
            MenuBarLabel(
                stats: viewModel.systemStats,
                metric: activeMetric,
                history: activeMetric == .cpu ? viewModel.cpuHistory : viewModel.memoryHistory
            )
        }
        .menuBarExtraStyle(.window)
    }
}
