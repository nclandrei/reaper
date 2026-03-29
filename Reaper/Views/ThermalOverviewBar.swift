import SwiftUI

struct ThermalOverviewBar: View {
    let groups: [ProcessGroup]
    let systemStats: SystemStats

    @State private var pulseOpacity: Double = 1.0
    @State private var hoveredGroupID: pid_t? = nil

    private var totalGroupCPU: Double {
        groups.reduce(0) { $0 + $1.totalCPU }
    }

    private var sortedGroups: [ProcessGroup] {
        groups.filter { $0.totalCPU > 0 }.sorted { $0.totalCPU > $1.totalCPU }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            labelRow
            thermalBar
            statsRow
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var labelRow: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(red: 0.90, green: 0.22, blue: 0.27))
                .frame(width: 6, height: 6)
                .opacity(pulseOpacity)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
                    ) {
                        pulseOpacity = 0.2
                    }
                }

            Text("Thermal Overview")
                .font(.system(size: 10, weight: .medium, design: .default))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(Color.white.opacity(0.45))
        }
    }

    private var thermalBar: some View {
        GeometryReader { geo in
            HStack(spacing: 1) {
                if sortedGroups.isEmpty {
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                } else {
                    ForEach(sortedGroups) { group in
                        let fraction = totalGroupCPU > 0 ? group.totalCPU / totalGroupCPU : 0
                        let isHovered = hoveredGroupID == group.id
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: group.heatLevel.gradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(2, geo.size.width * fraction))
                            .brightness(isHovered ? 0.15 : 0)
                            .onHover { hovering in
                                hoveredGroupID = hovering ? group.id : nil
                            }
                            .help("\(group.name) \(Formatters.cpu(group.totalCPU))")
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .frame(height: 28)
    }

    private var statsRow: some View {
        HStack {
            Text("CPU \(Formatters.cpu(systemStats.totalCPU))")
                .foregroundStyle(Color.white.opacity(0.7))

            Spacer()

            // Simulated temperature from total CPU load
            let simulatedTemp = 35.0 + (systemStats.totalCPU * 0.45)
            Text(String(format: "%.1f C", simulatedTemp))
                .foregroundStyle(Color.white.opacity(0.45))

            Spacer()

            Text("MEM \(Formatters.memoryFraction(used: systemStats.usedMemory, total: systemStats.totalMemory))")
                .foregroundStyle(Color.white.opacity(0.7))
        }
        .font(.system(size: 10, weight: .regular, design: .monospaced))
    }
}
