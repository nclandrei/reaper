import SwiftUI

@main
struct ReaperApp: App {
    @StateObject private var viewModel = ProcessListViewModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: viewModel)
        } label: {
            MenuBarLabel(cpuUsage: viewModel.systemStats.totalCPU)
        }
        .menuBarExtraStyle(.window)
    }
}
