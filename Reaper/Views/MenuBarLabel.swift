import SwiftUI

enum MenuBarMetric: String, CaseIterable, Identifiable {
    case memory = "Memory"
    case cpu = "CPU"

    var id: String { rawValue }
}

struct MenuBarLabel: View {
    let stats: SystemStats
    let metric: MenuBarMetric

    var body: some View {
        switch metric {
        case .memory:
            HStack(spacing: 3) {
                Image(systemName: "memorychip")
                    .font(.system(size: 11))
                Text(Formatters.memoryFraction(used: stats.usedMemory, total: stats.totalMemory))
                    .font(.system(size: 11, design: .monospaced))
                    .monospacedDigit()
            }
        case .cpu:
            HStack(spacing: 3) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11))
                Text("\(Int(stats.totalCPU))%")
                    .font(.system(size: 11, design: .monospaced))
                    .monospacedDigit()
            }
        }
    }
}
