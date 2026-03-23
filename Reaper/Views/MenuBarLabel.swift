import SwiftUI

enum MenuBarMetric: String, CaseIterable, Identifiable {
    case memory = "Memory"
    case cpu = "CPU"

    var id: String { rawValue }
}

struct MenuBarLabel: View {
    let stats: SystemStats
    let metric: MenuBarMetric

    private var fillPercent: Double {
        switch metric {
        case .cpu:
            return min(1.0, max(0.0, stats.totalCPU / 100.0))
        case .memory:
            guard stats.totalMemory > 0 else { return 0 }
            return min(1.0, Double(stats.usedMemory) / Double(stats.totalMemory))
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "chart.bar.fill", variableValue: fillPercent)
                .font(.system(size: 14))

            switch metric {
            case .memory:
                Text(Formatters.memoryFraction(used: stats.usedMemory, total: stats.totalMemory))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .monospacedDigit()
            case .cpu:
                Text("\(Int(stats.totalCPU))%")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .monospacedDigit()
            }
        }
    }
}
