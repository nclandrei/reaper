import SwiftUI

enum MenuBarMetric: String, CaseIterable, Identifiable {
    case memory = "Memory"
    case cpu = "CPU"

    var id: String { rawValue }
}

struct MenuBarLabel: View {
    let stats: SystemStats
    let metric: MenuBarMetric
    let history: [Double]

    // Unicode block elements: ▁▂▃▄▅▆▇█
    private static let blocks: [Character] = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]

    var body: some View {
        HStack(spacing: 4) {
            Text(sparkline)
                .font(.system(size: 10))
                .baselineOffset(-1)

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

    private var sparkline: String {
        let count = 12
        let samples: [Double]
        if history.count >= count {
            samples = Array(history.suffix(count))
        } else {
            samples = Array(repeating: 0.0, count: count - history.count) + history
        }

        return String(samples.map { value in
            let normalized = min(1.0, max(0.0, value / 100.0))
            let index = Int(normalized * Double(Self.blocks.count - 1))
            return Self.blocks[min(index, Self.blocks.count - 1)]
        })
    }
}
