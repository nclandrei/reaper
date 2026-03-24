import SwiftUI

@main
struct ReaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = ProcessListViewModel()
    @AppStorage("menuBarMetric") private var menuBarMetric: String = MenuBarMetric.memory.rawValue
    @AppStorage("cpuStyle") private var cpuStyle: String = MenuBarStyle.defaultForCPU.rawValue
    @AppStorage("memoryStyle") private var memoryStyle: String = MenuBarStyle.defaultForMemory.rawValue

    private var activeMetric: MenuBarMetric {
        MenuBarMetric(rawValue: menuBarMetric) ?? .memory
    }

    private var activeStyle: MenuBarStyle {
        let raw = activeMetric == .cpu ? cpuStyle : memoryStyle
        return MenuBarStyle(rawValue: raw) ?? (activeMetric == .cpu ? .defaultForCPU : .defaultForMemory)
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: viewModel)
        } label: {
            MenuBarLabel(
                stats: viewModel.systemStats,
                metric: activeMetric,
                style: activeStyle,
                cpuHistory: viewModel.cpuHistory,
                memoryHistory: viewModel.memoryHistory
            )
        }
        .menuBarExtraStyle(.window)
    }
}
