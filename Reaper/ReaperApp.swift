import SwiftUI

@main
struct ReaperApp: App {
    @StateObject private var viewModel = ProcessListViewModel()
    @AppStorage("menuBarMetric") private var menuBarMetric: String = MenuBarMetric.memory.rawValue

    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: viewModel)
        } label: {
            MenuBarLabel(
                stats: viewModel.systemStats,
                metric: MenuBarMetric(rawValue: menuBarMetric) ?? .memory
            )
        }
        .menuBarExtraStyle(.window)
    }
}
